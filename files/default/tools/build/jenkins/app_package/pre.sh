#!/bin/bash -ex

if [ -w "Berksfile.lock" -a "$UPGRADE_DEPENDENCIES" = "true" ]
then
  bundle update
  berks update
else
  bundle install --full-index --jobs=`ohai cpu/total` --without development
  berks install -e development
fi

DIR=/var/local/backup/archives
for env in development staging production
do
  sudo mkdir -p $DIR/$env
done
sudo chmod 777 -R $DIR
