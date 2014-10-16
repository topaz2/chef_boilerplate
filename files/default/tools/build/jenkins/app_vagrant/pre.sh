#!/bin/bash -ex

vagrant --version

mkdir -p build/logs
if [ -w "Berksfile.lock" -a "$UPGRADE_DEPENDENCIES" = "true" ]
then
  bundle update
  berks update
else
  bundle install --full-index --jobs=`ohai cpu/total` --without development
  berks install -e development
fi

vagrant plugin install vagrant-berkshelf --plugin-version '2.0.1'
vagrant plugin install vagrant-hostmanager
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-cachier
vagrant destroy --force
