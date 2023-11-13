#!/bin/bash

# This script is useful for regenerating all of the smoke tests running locally.

for f in tests/*.yaml
do
  source script/run-one.sh $f $1
done
