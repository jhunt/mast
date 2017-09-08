#!/bin/sh

file ./basename
stat ./basename
echo

#####################################################################

eq() {
  in=$1
  want=$2
  if ! ./basename "$in" >/dev/null 2>&1; then
    ./basename "$in"
    echo >&2 "\`basename \"$in\"' exited non-zero ($rc)"
    exit 1
  fi

  out="`./basename \"$in\"`"
  if [ "$out" != "$want" ]; then
    ./basename "$in"
    echo >&2 "\`basename \"$in\"' output '$out', not '$want'"
    exit 1
  fi

  echo "ok, \`basename \"$in\"' output '$want'"
}

suffix() {
  in=$1
  suff=$2
  want=$3
  if ! ./basename "$in" "$suff" >/dev/null 2>&1; then
    ./basename "$in" "$suff"
    echo >&2 "\`basename \"$in\" \"$suff\"' exited non-zero ($rc)"
    exit 1
  fi

  out="`./basename \"$in\" \"$suff\"`"
  if [ "$out" != "$want" ]; then
    ./basename "$in" "$suff"
    echo >&2 "\`basename \"$in\" \"$suff\"' output '$out', not '$want'"
    exit 1
  fi

  echo "ok, \`basename \"$in\" \"$suff\"' output '$want'"
}

#####################################################################

if ./basename >/dev/null 2>&1; then
  ./basename
  echo >&2 "\`basename' with no arguments exited zero, unexpectedly"
  exit 1
fi
echo "ok, \`basename' with too few arguments exits non-zero"

if ./basename 1 2 3 >/dev/null 2>&1; then
  ./basename 1 2 3
  echo >&2 "\`basename' with more than two arguments exited zero, unexpectedly"
  exit 1
fi
echo "ok, \`basename' with too many arguments exits non-zero"

eq "" .
eq . .
eq ./ .
eq / /
eq ///// /
eq no-slashes       no-slashes
eq /path/to/test    test
eq ///path/to/test  test
eq path/to/test     test
eq path///to/test   test
eq path/to///test   test
eq path/to/test/    test
eq path/to/test///  test

suffix file.sh .txt file.sh
suffix file.tar.gz .tar file.tar.gz
suffix file.tar.gz .gz  file.tar
suffix file.txt .txt file
suffix file file file

exit 0
