set -ef

grep '^|' java-results.md |grep -v white_check_mark
grep '| ' nodejs-results.md |grep -v white_check_mark |grep -v Open
grep '| ' python-results.md |grep -v white_check_mark |grep -v Open

