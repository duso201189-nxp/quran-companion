"""R02 acceptance test: resource identity constants are asserted verbatim."""
import unittest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from qf_content_sync import constants


class ResourceIdentityTests(unittest.TestCase):
    def test_resource_group_and_id(self):
        self.assertEqual(constants.RESOURCE_GROUP, "word_by_word_transliterations")
        self.assertEqual(constants.RESOURCE_ID, 60)
        self.assertEqual(constants.INCREMENTAL_RECORD_TYPE, "word_transliteration")

    def test_snapshot_url_matches_contract_verbatim(self):
        self.assertEqual(
            constants.SNAPSHOT_URL,
            "https://apis.quran.foundation/content/api/v4/resources/snapshots/"
            "word_by_word_transliterations/60",
        )

    def test_auth_header_names(self):
        self.assertEqual(constants.AUTH_TOKEN_HEADER, "x-auth-token")
        self.assertEqual(constants.CLIENT_ID_HEADER, "x-client-id")

    def test_expected_ayahs_matches_legacy_pipeline(self):
        self.assertEqual(constants.EXPECTED_AYAHS, 6236)


if __name__ == "__main__":
    unittest.main()
