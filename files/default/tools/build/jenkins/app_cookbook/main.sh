#!/bin/bash -ex

bundle ex kitchen test --destroy=always -c `ohai cpu/total`
