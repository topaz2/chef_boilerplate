#!/bin/bash -ex

# Workaround for the issue below
# @see https://github.com/berkshelf/vagrant-berkshelf/issues/212
export PATH='/opt/chefdk/bin:'$PATH

vagrant up
