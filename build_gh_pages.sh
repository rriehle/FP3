#!/bin/sh

git checkout gh-pages
rm -rf build/*
git merge --commit --no-edit master
touch .nojekyll  # Make sure the repo has this file in its root, otherwise it will not render on github.io
make html
open build/html/index.html  # On OS X this launches the rendered page into a browser; need something else for Linux or Windows
git add *
git commit -a --no-edit -m "Updating presentation materials"
git pull -s ours --no-edit
git push
