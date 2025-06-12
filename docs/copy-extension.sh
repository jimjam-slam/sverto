#!/bin/bash

# from github.com/qmd-lab/closeread
# (but this can't be run as a project pre-render because it's a custom project
# type... so the extension needs to already be present!)

mkdir -p _extensions/
cp -Rf ../_extensions/quarto-svelte _extensions/
echo "> quarto-svelte extension retrieved"

if [ ! -f ./package.json ]; then
    echo "> quarto-svelte package.json not found; also copying"
    cp ../package.json package.json
fi

npm install
echo "> NPM packes installed"
