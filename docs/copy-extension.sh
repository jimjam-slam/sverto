#!/bin/bash

# from github.com/qmd-lab/closeread

# Copy the extension only on full render, not preview
if [ "$QUARTO_PROJECT_RENDER_ALL" = 1 ]; then
    mkdir -p _extensions/
    cp -Rf ../_extensions/sverto _extensions/
    echo "> Sverto extension retrieved"

    if [ ! -f ../package.json ]; then
        echo "> Sverto package.json not found; also copying"
        cp ../package.json package.json
    fi
fi