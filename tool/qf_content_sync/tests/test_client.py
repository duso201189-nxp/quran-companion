"""R03 (bootstrap ordering), R04 (incremental ordering), R07 (retry),
R08 (error classification) — every test here uses a fake transport.
No test in this file performs a real network call.
"""
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from qf_content_sync import constants
from qf_content_sync.client import (
    AuthError,
    Credentials,
    RequestError,
    TransientError,
    TransportResponse,
    fetch_bootstrap,
    fetch_incremental,
    raise_for_status,
    retry_with_backoff,
)


def _no_sleep(_seconds):
    """Test double for `sleep` — never actually waits."""


CREDS = Credentials(client_id="test-client", access_token="test-token", environment="prelive")


class RaiseForStatusTests(unittest.TestCase):
    def test_2xx_does_not_raise(self):
        raise_for_status(TransportResponse(status=200))

    def test_401_and_403_raise_auth_error(self):
        for status in constants.AUTH_FAILURE_STATUSES:
            with self.assertRaises(AuthError):
                raise_for_status(TransportResponse(status=status))

    def test_400_404_422_raise_request_error(self):
        for status in constants.CLIENT_REQUEST_ERROR_STATUSES:
            with self.assertRaises(RequestError):
                raise_for_status(TransportResponse(status=status))

    def test_429_raises_transient_with_retry_after(self):
        response = TransportResponse(status=429, headers={"Retry-After": "2.5"})
        with self.assertRaises(TransientError) as ctx:
            raise_for_status(response)
        self.assertEqual(ctx.exception.retry_after, 2.5)

    def test_5xx_raises_transient(self):
        with self.assertRaises(TransientError):
            raise_for_status(TransportResponse(status=503))

    def test_unmapped_status_defaults_to_transient_not_success(self):
        # R08's own stated failure mode: an unmapped class must never
        # be treated as an implicit success.
        with self.assertRaises(TransientError):
            raise_for_status(TransportResponse(status=599))


class RetryWithBackoffTests(unittest.TestCase):
    def test_succeeds_after_transient_failures(self):
        attempts = {"n": 0}
        sleeps: list[float] = []

        def flaky():
            attempts["n"] += 1
            if attempts["n"] < 3:
                return TransportResponse(status=503)
            return TransportResponse(status=200, json={"ok": True})

        response = retry_with_backoff(flaky, max_attempts=5, base_delay=1.0, sleep=sleeps.append)
        self.assertEqual(response.status, 200)
        self.assertEqual(attempts["n"], 3)
        # Exponential: 1.0, 2.0 (two waits before the third, successful, attempt).
        self.assertEqual(sleeps, [1.0, 2.0])

    def test_exhausts_attempts_and_raises(self):
        def always_fails():
            return TransportResponse(status=503)

        with self.assertRaises(TransientError):
            retry_with_backoff(always_fails, max_attempts=3, base_delay=0.01, sleep=_no_sleep)

    def test_auth_error_is_not_retried(self):
        attempts = {"n": 0}

        def unauthorized():
            attempts["n"] += 1
            return TransportResponse(status=401)

        with self.assertRaises(AuthError):
            retry_with_backoff(unauthorized, max_attempts=5, sleep=_no_sleep)
        self.assertEqual(attempts["n"], 1)

    def test_429_retry_after_is_used_as_delay(self):
        sleeps: list[float] = []
        attempts = {"n": 0}

        def rate_limited():
            attempts["n"] += 1
            if attempts["n"] == 1:
                return TransportResponse(status=429, headers={"Retry-After": "9"})
            return TransportResponse(status=200, json={})

        retry_with_backoff(rate_limited, max_attempts=3, sleep=sleeps.append)
        self.assertEqual(sleeps, [9.0])


class FetchBootstrapTests(unittest.TestCase):
    def test_applies_every_snapshot_before_returning_a_token(self):
        """R03: all snapshot_urls fetched and applied before the caller
        ever receives a usable sync_token."""
        calls: list[str] = []

        def transport(url, headers):
            calls.append(url)
            self.assertEqual(headers[constants.AUTH_TOKEN_HEADER], "test-token")
            self.assertEqual(headers[constants.CLIENT_ID_HEADER], "test-client")
            if "bootstrap=true" in url:
                return TransportResponse(
                    status=200,
                    json={
                        "sync_token": "tok-1",
                        "changes": [
                            {"type": "RESOURCE_CREATE", "snapshot_url": "https://qf.example/snap/a"},
                            {"type": "RESOURCE_CREATE", "snapshot_url": "https://qf.example/snap/b"},
                        ],
                    },
                )
            if url == "https://qf.example/snap/a":
                return TransportResponse(status=200, json={"records": [{"word_id": 1}]})
            if url == "https://qf.example/snap/b":
                return TransportResponse(status=200, json={"records": [{"word_id": 2}]})
            raise AssertionError(f"unexpected url {url}")

        result = fetch_bootstrap(transport, CREDS, sleep=_no_sleep)
        self.assertEqual(result.sync_token, "tok-1")
        self.assertEqual([r["word_id"] for r in result.records], [1, 2])
        # The bootstrap call happened before either snapshot fetch.
        self.assertTrue(calls[0].startswith(constants.SYNC_ENDPOINT))

    def test_a_failed_snapshot_prevents_any_result_from_being_returned(self):
        """R03 fault injection: interrupted bootstrap must never yield a
        result the caller could mistake for 'fully applied' — no partial
        BootstrapResult, no token, is ever produced."""

        def transport(url, headers):
            if "bootstrap=true" in url:
                return TransportResponse(
                    status=200,
                    json={
                        "sync_token": "tok-1",
                        "changes": [
                            {"snapshot_url": "https://qf.example/snap/a"},
                            {"snapshot_url": "https://qf.example/snap/b"},
                        ],
                    },
                )
            if url == "https://qf.example/snap/a":
                return TransportResponse(status=200, json={"records": [{"word_id": 1}]})
            if url == "https://qf.example/snap/b":
                return TransportResponse(status=503)  # transient failure, retries exhaust
            raise AssertionError(f"unexpected url {url}")

        with self.assertRaises(TransientError):
            fetch_bootstrap(transport, CREDS, sleep=_no_sleep)

    def test_missing_sync_token_in_bootstrap_response_raises(self):
        def transport(url, headers):
            return TransportResponse(status=200, json={"changes": []})

        with self.assertRaises(Exception):
            fetch_bootstrap(transport, CREDS, sleep=_no_sleep)


class FetchIncrementalTests(unittest.TestCase):
    def test_multi_page_ascending_sequence_token_only_from_final_page(self):
        """R04: pages applied in ascending sequence order; next_sync_token
        taken only from the final page (has_more == False)."""

        pages = {
            "page1": TransportResponse(
                status=200,
                json={
                    "changes": [{"sequence": 1}, {"sequence": 2}],
                    "has_more": True,
                    "next_page_url": "https://qf.example/sync/page2",
                    "next_sync_token": "SHOULD-NOT-BE-USED",
                },
            ),
            "https://qf.example/sync/page2": TransportResponse(
                status=200,
                json={
                    "changes": [{"sequence": 3}],
                    "has_more": False,
                    "next_sync_token": "final-token",
                },
            ),
        }

        def transport(url, headers):
            if url.startswith(constants.SYNC_ENDPOINT):
                return pages["page1"]
            return pages[url]

        result = fetch_incremental(transport, CREDS, "prev-token", sleep=_no_sleep)
        self.assertEqual(result.next_sync_token, "final-token")
        self.assertEqual([r["sequence"] for r in result.records], [1, 2, 3])

    def test_out_of_order_sequence_is_rejected(self):
        def transport(url, headers):
            return TransportResponse(
                status=200,
                json={
                    "changes": [{"sequence": 5}, {"sequence": 3}],
                    "has_more": False,
                    "next_sync_token": "tok",
                },
            )

        with self.assertRaises(Exception):
            fetch_incremental(transport, CREDS, "prev-token", sleep=_no_sleep)

    def test_final_page_without_token_raises(self):
        def transport(url, headers):
            return TransportResponse(status=200, json={"changes": [], "has_more": False})

        with self.assertRaises(Exception):
            fetch_incremental(transport, CREDS, "prev-token", sleep=_no_sleep)


if __name__ == "__main__":
    unittest.main()
