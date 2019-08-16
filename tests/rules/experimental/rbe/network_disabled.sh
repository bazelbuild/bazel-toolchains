#!/bin/bash

curl https://www.google.com

# Expecting curl to fail. Return the return code.
if [ $? -eq 0 ]; then
  exit 1
fi
exit 0
