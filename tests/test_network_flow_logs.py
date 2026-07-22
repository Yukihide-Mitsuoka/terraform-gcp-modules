import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
NETWORK_MAIN = ROOT / "modules/network/main.tf"


class NetworkFlowLogsTest(unittest.TestCase):
    def setUp(self):
        source = NETWORK_MAIN.read_text(encoding="utf-8")
        subnet_resource = 'resource "google_compute_subnetwork" "this" {'
        self.assertIn(subnet_resource, source)
        self.subnet_source = source[source.index(subnet_resource) :]

    def test_managed_subnets_enable_explicit_flow_logs(self):
        for setting in (
            "log_config {",
            'aggregation_interval = "INTERVAL_5_SEC"',
            "flow_sampling        = 0.5",
            'metadata             = "INCLUDE_ALL_METADATA"',
        ):
            with self.subTest(setting=setting):
                self.assertIn(setting, self.subnet_source)


if __name__ == "__main__":
    unittest.main()
