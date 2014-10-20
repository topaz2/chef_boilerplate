#!/bin/bash -ex

kitchen test --destroy=always -c `ohai cpu/total`
