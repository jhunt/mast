#!/bin/sh

file ./true
stat ./true

if ./false; then
  echo >&2 "\`false' exited zero"
  exit 1
fi

if ./false with arguments; then
  echo >&2 "\`false' with arguments' exited zero"
  exit 1
fi

exit 0
