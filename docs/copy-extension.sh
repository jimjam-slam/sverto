#!/bin/bash

# from github.com/qmd-lab/closeread

# Copy the extension only on full render, not preview
if [ "$QUARTO_PROJECT_RENDER_ALL" = 1 ]; then
    mkdir -p _extensions/
    cp -Rf ../_extensions/sverto _extensions/
    echo "> Sverto extension retrieved"
fi