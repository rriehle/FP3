#!/bin/sh
working_git_branch="$(git rev-parse --abbrev-ref HEAD)"
git checkout gh-pages
rm -rf build/*
git merge --commit --no-edit $working_git_branch
touch .nojekyll  # Make sure the repo has this file in its root, otherwise it will not render on github.io
make html
open build/html/index.html  # On OS X this launches the rendered page into a browser; need something else for Linux or Windows
git add *
git commit -a --no-edit -m "Updating presentation materials"
git pull -s ours --no-edit
# git push
sleep 1  # Need to load the page in gh-pages before flipping back to the working branch
git checkout $working_git_branch
