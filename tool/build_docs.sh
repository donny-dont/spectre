#!/usr/bin/env bash

##
# Run from the root of the spectre project to generate docs and
# deploy to gh-pages on github. 
# ~/dart/spectre$ ./tool/build_docs.sh
##
git push origin --delete gh-pages
git checkout --orphan gh-pages &&
dartdoc -m static --pkg packages/ lib/*.dart &&
git rm -rf .gitignore AUTHORS.txt LICENSE.txt README.md lib  pubspec.yaml web tool &&
mv docs tmp.docs &&
mv tmp.docs/* . && 
rm -rf tmp.docs &&
git add . &&
git commit -m "Docs" &&
git push origin gh-pages &&
git checkout master &&
git branch -D gh-pages &&
echo "Build and deployed docs finished"