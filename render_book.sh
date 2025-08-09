#!/bin/bash

name=$1

#html
cd "./raw/$name" || exit 1

# ChunkedHTML creates the directory for output. It does not work if the directory already exists and is not empty.
if [[ `find -maxdepth 1 -name html -type d` != "" ]]; then
    rm -r ./html
fi
yml=`find -maxdepth 1 -name "*.yml" -type f`
if [[ $yml == "" ]]; then
    echo "No defaults YAML file found. Use render.sh instead, or add a defaults YAML file specifying the input files."
    exit 1
fi

# html
if pandoc --defaults=../../src/yml/chunkedhtml.yml --defaults="$yml" -o ./html; then
    echo "html done!"
else
    echo "html failed on $file"
fi

# epub
if pandoc --defaults=../../src/yml/base.yml --defaults="$yml" -o "$name.epub"; then
    echo "epub done!"
else
    echo "epub failed on $file"
fi

# docx
if pandoc --defaults=../../src/yml/base.yml --defaults="$yml" -o "$name.docx"; then
    echo "docx done!"
else
    echo "docx failed on $file"
fi

# pdf
if pandoc --defaults=../../src/yml/base.yml --defaults=../../src/yml/pdf.yml --defaults="$yml" -o "$name.pdf"; then
    echo "pdf done!"
else
    echo "pdf failed on $file"
fi

cd ../..
