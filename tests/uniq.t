#!/bin/sh

file ./uniq
stat ./uniq
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
  rc=$?
  if [ $rc != 0 ]; then
    sh -c "$cmd" 2>&1
    echo >&2 "\`$simple' exited non-zero ($rc)"
    exit 1
  fi
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

#####################################################################

cat >$TEST_DIR/file <<EOF
1 foo bar baz
1 foo bar baz
2  -  bar baz
3  foo bar baz
1 foo bar baz
1 foo bar baz
4 foo bar
5 bar             bar            baz
1 foo bar baz
1 foo bar baz
1 foo bar baz
EOF

eq 'cat $TEST_DIR/file | ./uniq' \
"1 foo bar baz
2  -  bar baz
3  foo bar baz
1 foo bar baz
4 foo bar
5 bar             bar            baz
1 foo bar baz" \
   'cat file | uniq'

eq 'cat $TEST_DIR/file | ./uniq -c' \
"      2 1 foo bar baz
      1 2  -  bar baz
      1 3  foo bar baz
      2 1 foo bar baz
      1 4 foo bar
      1 5 bar             bar            baz
      3 1 foo bar baz" \
   'cat file | uniq -u'

eq 'cat $TEST_DIR/file | ./uniq -u' \
"2  -  bar baz
3  foo bar baz
4 foo bar
5 bar             bar            baz" \
   'cat file | uniq -c'

eq 'cat $TEST_DIR/file | ./uniq -d' \
"1 foo bar baz
1 foo bar baz
1 foo bar baz" \
   'cat file | uniq -d'

eq 'cat $TEST_DIR/file | ./uniq -ud' \
   "" \
   'cat file | uniq -ud'

eq 'cat $TEST_DIR/file | ./uniq -s6' \
"1 foo bar baz
3  foo bar baz
1 foo bar baz
4 foo bar
5 bar             bar            baz
1 foo bar baz" \
  'cat file | uniq -s6'

eq 'cat $TEST_DIR/file | ./uniq -s 6' \
"1 foo bar baz
3  foo bar baz
1 foo bar baz
4 foo bar
5 bar             bar            baz
1 foo bar baz" \
  'cat file | uniq -s 6'

eq 'cat $TEST_DIR/file | ./uniq -s999' \
"1 foo bar baz" \
  'cat file | uniq -s999'

eq 'cat $TEST_DIR/file | ./uniq -f3' \
"1 foo bar baz
4 foo bar
5 bar             bar            baz" \
  'cat file | uniq -f3'

eq 'cat $TEST_DIR/file | ./uniq -f 3' \
"1 foo bar baz
4 foo bar
5 bar             bar            baz" \
  'cat file | uniq -f 3'

exit 0;
