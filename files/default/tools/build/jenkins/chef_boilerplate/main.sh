#!/bin/bash -ex

bundle ex foodcritic -f any --tags ~FC001 --tags ~FC014 .
bundle ex rspec --color --format progress
bundle ex rubocop
bundle ex kitchen test -c `ohai cpu/total`
bundle ex knife cookbook site share boilerplate Utilities -u topaz2
