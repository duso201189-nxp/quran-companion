"""OAuth2 client_credentials token exchange — fake transport only,
no real network call, no real credentials."""
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from qf_content_sync.client import AuthError, ContentSyncError, TransportResponse
from qf_content_sync.token import ClientCredentials, fetch_access_token, token_endpoint


def _no_sleep(_seconds):
    pass


CREDS = ClientCredentials(client_id="cid", client_secret="csecret", environment="prelive")


class TokenEndpointTests(unittest.TestCase):
    def test_prelive_host(self):
        self.assertEqual(token_endpoint("prelive"), "https://prelive-oauth2.quran.foundation/oauth2/token")

    def test_production_host(self):
        self.assertEqual(token_endpoint("production"), "https://oauth2.quran.foundation/oauth2/token")


class FetchAccessTokenTests(unittest.TestCase):
    def test_successful_exchange(self):
        captured = {}

        def transport(url, headers, form_body):
            captured["url"] = url
            captured["headers"] = headers
            captured["form_body"] = form_body
            return TransportResponse(
                status=200,
                json={"access_token": "abc123", "expires_in": 3600, "token_type": "Bearer"},
            )

        token = fetch_access_token(transport, CREDS, sleep=_no_sleep)
        self.assertEqual(token.token, "abc123")
        self.assertEqual(token.expires_in, 3600)
        self.assertEqual(captured["url"], "https://prelive-oauth2.quran.foundation/oauth2/token")
        self.assertTrue(captured["headers"]["Authorization"].startswith("Basic "))
        self.assertEqual(captured["form_body"]["grant_type"], "client_credentials")
        self.assertEqual(captured["form_body"]["scope"], "content")

    def test_missing_access_token_in_response_raises(self):
        def transport(url, headers, form_body):
            return TransportResponse(status=200, json={"expires_in": 3600})

        with self.assertRaises(ContentSyncError):
            fetch_access_token(transport, CREDS, sleep=_no_sleep)

    def test_401_raises_auth_error(self):
        def transport(url, headers, form_body):
            return TransportResponse(status=401)

        with self.assertRaises(AuthError):
            fetch_access_token(transport, CREDS, sleep=_no_sleep)

    def test_client_secret_never_appears_in_request_body(self):
        # The secret must travel only in the Basic-auth header, never
        # the form body (which mirrors what a log line might capture).
        def transport(url, headers, form_body):
            self.assertNotIn("csecret", form_body.values())
            return TransportResponse(status=200, json={"access_token": "abc123"})

        fetch_access_token(transport, CREDS, sleep=_no_sleep)


if __name__ == "__main__":
    unittest.main()
