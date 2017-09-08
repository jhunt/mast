#!/bin/sh

file ./true
stat ./true

if ! ./true; then
  echo >&2 "\`true' exited nonzero ($?)"
  exit 1
fi

if ! ./true with arguments; then
  echo >&2 "\`true' with arguments' exited nonzero ($?)"
  exit 1
fi

exit 0
