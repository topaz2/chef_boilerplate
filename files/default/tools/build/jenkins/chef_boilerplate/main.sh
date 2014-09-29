#!/bin/bash -ex

bundle ex foodcritic -f any --tags ~FC001 --tags ~FC014 .
bundle ex rspec --color --format progress
bundle ex rubocop
bundle ex kitchen test --destroy=always -c `ohai cpu/total`
