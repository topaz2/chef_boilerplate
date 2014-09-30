#!/bin/bash -ex

# Clear previous build files
rm -rf boilerplate-master master.zip

wget https://github.com/topaz2/boilerplate/archive/master.zip
unzip master.zip
cd boilerplate-master

if [ "$ENVIRONMENT" = "development" ]
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
