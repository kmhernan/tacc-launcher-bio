#!/bin/bash

FILE="some-text-file.tab"

while read line; do
  echo $line
done < $FILE
