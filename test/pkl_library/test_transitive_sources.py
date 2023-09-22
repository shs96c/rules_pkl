import runfiles
import unittest
from pathlib import Path


class TestTransitiveSources(unittest.TestCase):
    def test_contains_expected_files(self):
        want_files = set(
            [
                Path(p)
                for p in [
                    "test/pkl_library/srcs/animals.pkl",
                    "test/pkl_library/srcs/horse.pkl",
                ]
            ]
        )

        r = runfiles.Create()
        own_repo = r.CurrentRepository()

        runfiles_root = Path(own_repo)
        path = runfiles_root / "test" / "pkl_library" / "srcs"
        got_files = set(
            [p.relative_to(runfiles_root) for p in Path(path).glob("*")]
        )
        self.assertSetEqual(want_files, got_files)


if __name__ == "__main__":
    unittest.main()
