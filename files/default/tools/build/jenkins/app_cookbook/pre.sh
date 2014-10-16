#!/bin/bash -ex

if [ -w "Berksfile.lock" -a "$UPGRADE_DEPENDENCIES" = "true" ]
then
  bundle update
  berks update
else
  bundle install --full-index --jobs=`ohai cpu/total` --without development
  berks install -e development
fi
