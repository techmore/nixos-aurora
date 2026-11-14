import hashlib
import pathlib
import re
import tarfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "packages" / "j773g-kernel" / "integration-0443-v2"


class J773gBinaryKernelTests(unittest.TestCase):
    def test_payload_hashes(self):
        expected = {
            "Image": "9b2f6aa0bb7b8740c3659312504ca07091494cd068b26b3543063d4341139eb0",
            "t8132-j773g.dtb": "d086e25ffa5a4bbe645a1c29448dc8c013af8eea89cda564113b47a7fd7b56b4",
            "modules.tar.gz": "455854d97c192ee61237b65e253f36d474f12654c3f47bfbb29903437683c468",
            "config": "8527ceccf7718d672f1a4c0697ed9c5bd259d1407d1e0cbfb0d8061804025006",
        }
        for name, digest in expected.items():
            with self.subTest(name=name):
                self.assertEqual(hashlib.sha256((PAYLOAD / name).read_bytes()).hexdigest(), digest)

    def test_kernel_release_and_boot_drivers(self):
        image = (PAYLOAD / "Image").read_bytes()
        config = (PAYLOAD / "config").read_text()
        self.assertIn(b"Linux version 7.3.0-m4atlrx+ ", image)
        for option in (
            "CONFIG_APPLE_WATCHDOG=y",
            "CONFIG_NVME_APPLE=y",
            "CONFIG_BTRFS_FS=y",
            "CONFIG_EXT4_FS=y",
            "CONFIG_VFAT_FS=y",
        ):
            self.assertIn(option, config)

        with tarfile.open(PAYLOAD / "modules.tar.gz") as archive:
            names = archive.getnames()
            self.assertIn("lib/modules/7.3.0-m4atlrx+/modules.builtin", names)
            self.assertTrue(any(name.endswith(".ko") for name in names))

    def test_reported_config_matches_payload(self):
        # linuxPackagesFor reads these values instead of the config file.
        package = (ROOT / "packages" / "j773g-binary-kernel.nix").read_text()
        block = package.split("configValues = {", 1)[1].split("};", 1)[0]
        reported = dict(re.findall(r'^\s*([A-Z0-9_]+) = "([ymn])";$', block, re.M))
        self.assertIn("RUST", reported)
        lines = set((PAYLOAD / "config").read_text().splitlines())
        for name, value in reported.items():
            with self.subTest(option=name):
                expected = f"# CONFIG_{name} is not set" if value == "n" else f"CONFIG_{name}={value}"
                self.assertIn(expected, lines)


if __name__ == "__main__":
    unittest.main()
