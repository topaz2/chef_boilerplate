#!/bin/bash -ex

env
echo $TAG

if [ ! $(git describe --exact-match $TAG 2> /dev/null) ]
then
  LATEST_TAG=$(git describe --abbrev=0 --tags)
  CHANGELOG=$(git log --oneline --graph --decorate $LATEST_TAG..)

  # Increment patch number if $TAG ommited
  if [ -z $TAG ]
  then
    TAG=$(echo $LATEST_TAG | awk -F . '{ printf "%d.%d.%d", $1, $2, $3 + 1 }')
  fi

  sudo su - $BUILD_USER_ID
  git checkout master
  git remote set-url origin git@github.com:topaz2/chef_boilerplate
  sed -i "s/version.*$/version '$TAG'/" metadata.rb
  (echo "## $TAG:

$CHANGELOG
"; cat CHANGELOG.md) | tee CHANGELOG.md
  # git commit -a -m "Released $TAG"
  # git tag -a -m "$CHANGELOG" $TAG
  # echo $BUILD_USER_ID
  # git push --all -n

  sudo chmod g+w -R .git
  git add .
  sudo -S su - $BUILD_USER_ID -c sh "git commit -a -m \"Released $TAG\""
  git tag -a -m "$CHANGELOG" $TAG
#  sudo -u $BUILD_USER_ID git push --all -n
  sudo -S su - $BUILD_USER_ID -c sh "git push --all -n"

#  bundle ex knife cookbook site share boilerplate Utilities -u topaz2
fi
