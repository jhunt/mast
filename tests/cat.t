#!/bin/sh

file ./cat
stat ./cat
echo

if [ -z "$TEST_DIR" ]; then
  echo >&2 "TEST_DIR not set"
  exit 2
fi

# system cat ...
cat >$TEST_DIR/file <<EOF
This is my file. There are many
like it, but this one is mine.

My file is my best friend. It
is my life. I must master it as
I must master my life.

Without me, my file is useless.
Without my file, I am useless.
EOF

out=`echo "test" | ./cat`
if [ "$out" != "test" ]; then
  echo "test" | ./cat
  echo >&2 "\`echo | cat' output \"$out\", not \"test\""
  exit 1
fi
echo "ok, \`echo | cat' works"

if ./cat -x </dev/null >/dev/null 2>&1; then
  ./cat -x
  echo "\`cat -x' unexpectedly exited non-zero"
  exit 1
fi

out=`./cat $TEST_DIR/file 2>&1 | cksum`
want=`cksum < $TEST_DIR/file`
if [ "$out" != "$want" ]; then
  echo "./cat $TEST_DIR/file 2>&1 | cksum:"
  (./cat $TEST_DIR/file 2>&1 | cksum) 2>&1
  echo
  echo "cksum < $TEST_DIR/file:"
  cksum < $TEST_DIR/file
  echo
  echo "^^ those should match, but do not."
  exit 1
fi
echo "ok, \`cat file | cksum' matches \`cksum < file'"

out=`./cat -u $TEST_DIR/file 2>&1 | cksum`
want=`cksum < $TEST_DIR/file`
if [ "$out" != "$want" ]; then
  echo "./cat -u $TEST_DIR/file 2>&1:"
  ./cat -u $TEST_DIR/file 2>&1
  echo
  echo "./cat -u $TEST_DIR/file 2>&1 | cksum:"
  (./cat -u $TEST_DIR/file 2>&1 | cksum) 2>&1
  echo
  echo "cksum < $TEST_DIR/file:"
  cksum < $TEST_DIR/file
  echo
  echo "^^ those should match, but do not."
  exit 1
fi
echo "ok, \`cat -u file | cksum' matches \`cksum < file'"

echo one >$TEST_DIR/a
echo two >$TEST_DIR/b
want="one
two
two"
out="`./cat $TEST_DIR/a $TEST_DIR/b $TEST_DIR/b`"
if  [ "$out" != "$want" ]; then
  echo "./cat $TEST_DIR/a $TEST_DIR/b $TEST_DIR/b:"
  ./cat $TEST_DIR/a $TEST_DIR/b $TEST_DIR/b
  echo
  echo "expected:"
  echo one
  echo two
  echo two
  echo
  echo "^^ those should match, but do not."
  exit 1
fi
echo "ok, \`cat a b b' works"

exit 0
