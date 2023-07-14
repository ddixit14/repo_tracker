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
