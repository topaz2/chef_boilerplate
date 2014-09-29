#!/bin/bash -ex

if [ "$ENVIRONMENT" = "development" ]
then
  bundle update
  berks update
else
  bundle install --full-index --jobs=`ohai cpu/total` --without development
  berks install -e development
fi
