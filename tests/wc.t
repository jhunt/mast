#!/bin/sh

file ./wc
stat ./wc
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

eq 'echo hello | ./wc' \
   '      1       1       6' \
   'echo | wc'

cat >$TEST_DIR/file <<EOF
This is my file. There are many
like it, but this one is mine.

My file is my best friend. It
is my life. I must master it as
I must master my life.

Without me, my file is useless.
Without my file, I am useless.
EOF
eq "./wc $TEST_DIR/file" \
   "      9      46     213 $TEST_DIR/file" \
   "wc file"

eq "./wc -l $TEST_DIR/file" \
   "      9 $TEST_DIR/file" \
   "wc -l file"

eq "./wc -c $TEST_DIR/file" \
   "    213 $TEST_DIR/file" \
   "wc -c file"

eq "./wc -lw $TEST_DIR/file" \
   "      9      46 $TEST_DIR/file" \
   "wc -lw file"

eq "./wc -wl $TEST_DIR/file" \
   "      9      46 $TEST_DIR/file" \
   "wc -wl file"

eq "./wc -wwwllwlwllwlwllllww $TEST_DIR/file" \
   "      9      46 $TEST_DIR/file" \
   "wc -lw* file"

eq "./wc -m $TEST_DIR/file" \
   "    213 $TEST_DIR/file" \
   "wc -m file"

cat >$TEST_DIR/unicode <<EOF
¯\_(ツ)_/¯
EOF

eq "./wc $TEST_DIR/unicode" \
   "      1       1      14 $TEST_DIR/unicode" \
   "wc unicode"
eq "./wc -mlw $TEST_DIR/unicode" \
   "      1       1      10 $TEST_DIR/unicode" \
   "wc -mlw unicode"
