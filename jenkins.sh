#!/bin/bash -x
export RAILS_ENV=test
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop
bundle exec rake
