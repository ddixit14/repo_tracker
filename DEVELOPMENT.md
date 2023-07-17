# How to manually test a change

To test the script for your change, ues `TEST_REPOS` environment
variable to specify java-test.txt, which has a shorter list of
the repositories than the actual java.txt:

```
~/repo_tracker$ TEST_REPOS=java-test.txt sh -x repo_status.sh java
...
Wrote java-test-results.md
~/repo_tracker$ cat java-test-results.md
```

# How to update document_reference_count.tsv

Go to http://go/repo_tracker_document_ref_count.
Run the query and "Copy results" > "VALUES AS TSV".


# I get error "declare: -A: invalid option"

Please use bash version 4 or higher to use associative array.

If your Mac has ole one, use one from Homebrew:

```
$ brew install bash
...
$ /usr/local/bin/bash --version
GNU bash, version 5.2.15(1)-release (x86_64-apple-darwin22.1.0)
...
$ TEST_REPOS=java-test.txt  /usr/local/bin/bash -x repo_status.sh java
```
