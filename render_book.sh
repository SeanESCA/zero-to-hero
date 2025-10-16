#!/bin/bash

# html
# ChunkedHTML creates the directory for output. It does not work if the 
# directory already exists and is not empty.
if [[ "$1" = "all" ]]; then
  dir="docs"
else
  dir="_$1"
fi

if [[ `find -maxdepth 1 -name "$dir" -type d` != "" ]]; then
  rm -r "./$dir"
fi

# html
if pandoc -d ./src/yml/chunkedhtml.yml -d "book.yml" -d "html.yml"\
 -d "_quarto-$1.yml" -o "./$dir"; then
  echo "html done!"
else
  echo "html failed"
fi

# epub
if pandoc -d ./src/yml/base.yml -d ./src/yml/epub.yml -d "book.yml"\
 -d "_quarto-$1.yml" -o "./$dir/$dir.epub"; then
  echo "epub done!"
else
  echo "epub failed"
fi

# docx
if pandoc -d ./src/yml/base.yml -d "book.yml" -d "_quarto-$1.yml" -o "./$dir/$dir.docx"; then
  echo "docx done!"
else
  echo "docx failed"
fi

# pdf
if pandoc -d ./src/yml/base.yml -d ./src/yml/pdf.yml -d "book.yml"\
 -d "_quarto-$1.yml" -o "./$dir/$dir.pdf"; then
  echo "pdf done!"
else
  echo "pdf failed"
fi
