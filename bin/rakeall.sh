#!/bin/bash
function rakeall() {
  bundle exec rake
  for rakefile in `find lib -name Rakefile`
  do
    pushd `dirname $rakefile`
    bundle install
    bundle exec rake
    popd
  done
}
