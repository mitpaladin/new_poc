#!/bin/bash
function rakeall() {
  bundle exec rake
  for gemfile in `find lib -name Gemfile.lock`
  do
    pushd `dirname $gemfile`
    bundle exec rake
    popd
  done
}
