#!/bin/sh

file ./cmp
stat ./cmp
echo

#####################################################################

eq() {
  cmd=$1
  want=$2
  simple=$3

  if [ -z "$simple" ]; then
    simple="$cmd"
  fi

  out=`sh -c "$cmd" 2>&1`
  if [ "$out" != "$want" ]; then
    echo "$cmd:"
    sh -c "$cmd" 2>&1
    echo
    echo "expected:"
    echo "$want"
    echo
    echo "^^ those should match but did not"
    exit 1
  fi

  echo "ok, \`$simple' output what was expected"
}

passes() {
  cmd=$1
  simple=$2

  if [ -z "$simple" ]; then
    simple="$cmd"
  fi

  out=`sh -c "$cmd" 2>&1`
  rc=$?
  if [ $rc != 0 ]; then
    sh -c "$cmd" 2>&1
    echo >&2 "\`$simple' exited non-zero ($rc)"
    exit 1
  fi

  echo "ok, \`$simple' exited zero (success!)"
}

fails() {
  cmd=$1
  simple=$2

  if [ -z "$simple" ]; then
    simple="$cmd"
  fi

  out=`sh -c "$cmd" 2>&1`
  rc=$?
  if [ $rc = 0 ]; then
    sh -c "$cmd" 2>&1
    echo >&2 "\`$simple' exited zero (unespectedly)"
    exit 1
  fi

  echo "ok, \`$simple' exited non-zero (expected failure)"
}

#####################################################################

cat >$TEST_DIR/a <<EOF
I think that I shall never see
A poem lovely as a tree.

A tree who...
EOF

cat >$TEST_DIR/b <<EOF
I think that I shall never see
A poem lovely as a tree.

A tree tha...
EOF

cp $TEST_DIR/a $TEST_DIR/c

passes  "./cmp $TEST_DIR/a $TEST_DIR/a"
passes  "./cmp $TEST_DIR/a $TEST_DIR/c"
fails   "./cmp $TEST_DIR/a $TEST_DIR/b"
fails   "./cmp $TEST_DIR/b $TEST_DIR/c"

eq "./cmp $TEST_DIR/a $TEST_DIR/b" \
   "$TEST_DIR/a $TEST_DIR/b differ: char 8, line 4" \
   "cmp a b"

eq "cat $TEST_DIR/a | ./cmp - $TEST_DIR/b" \
   "- $TEST_DIR/b differ: char 8, line 4" \
   "cat a | cmp - b"

eq "cat $TEST_DIR/b | ./cmp $TEST_DIR/a -" \
   "$TEST_DIR/a - differ: char 8, line 4" \
   "cat b | cmp a -"

eq "./cmp -s $TEST_DIR/a $TEST_DIR/b" \
   "" \
   "cmp -s a b"

eq "./cmp -l $TEST_DIR/a $TEST_DIR/b" \
   "65 167 164
67 157 141" \
   "cmp -s a b"
