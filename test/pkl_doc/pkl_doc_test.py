import unittest
import zipfile

from bazel_tools.tools.python.runfiles import runfiles


class TestPklDoc(unittest.TestCase):
    def test_contains_expected_files(self):
        want_files = [
            "index.html",
            "com.animals/1.2.3/Rabbits/Animal.html",

            "com.animals/1.2.3/Rabbits/index.html",
            "com.animals/1.2.3/package-data.json"
        ]

        r = runfiles.Create()
        path = r.Rlocation("_main/test/pkl_doc/pkl_doc_docs.zip")

        with zipfile.ZipFile(path) as zf:
            got_files = zf.namelist()
        for want_file in want_files:
            self.assertIn(want_file, got_files)


if __name__ == "__main__":
    unittest.main()
