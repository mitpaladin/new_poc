#!/bin/bash
function rakeall() {
  bundle exec rake || return 1
  for rakefile in `find lib -name Rakefile`
  do
    pushd `dirname $rakefile`
    bundle install
    bundle exec rake || return 1
    popd
  done
}
