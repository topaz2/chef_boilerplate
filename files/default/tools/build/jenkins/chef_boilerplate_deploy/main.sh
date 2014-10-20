#!/bin/bash -ex

if [ ! $(git describe --exact-match $TAG 2> /dev/null) ]
then
  LATEST_TAG=$(git describe --abbrev=0 --tags)
  CHANGELOG=$(git log --oneline --graph --decorate $LATEST_TAG..)

  # Increment patch number if $TAG ommited
  if [ -z $TAG ]
  then
    TAG=$(echo $LATEST_TAG | awk -F . '{ printf "%d.%d.%d", $1, $2, $3 + 1 }')
  fi

  sudo chmod g+w -R .git
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git checkout master"
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git remote set-url origin git@github.com:topaz2/chef_boilerplate"

  # Update changelog and meta data
  sed -i "s/version.*$/version '$TAG'/" metadata.rb
  echo "## $TAG:

$CHANGELOG
" | cat - CHANGELOG.md > /tmp/changelog.$$.tmp && mv /tmp/changelog.$$.tmp CHANGELOG.md

  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git add ."
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git commit -a -m \"Released $TAG\""
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git tag -a -m \"$CHANGELOG\" $TAG"
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git status"
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && git push --all -vvv"
  sudo -S su - $BUILD_USER_ID -c "cd $WORKSPACE && knife cookbook site share boilerplate Utilities -u $BUILD_USER_ID"
fi
