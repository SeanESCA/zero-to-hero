#!/bin/bash

# ./render.sh folder_name file_name
folder_name=$1

cd "./raw/$folder_name" || exit 1

for file in `find -maxdepth 1 -name "*.md" -type f`; do
    # html
    if pandoc "$file" -d "../../src/yml/base.yml" -d "../../src/yml/html.yml" --csl="https://www.zotero.org/styles/harvard-university-of-bath" --bibliography="../references.bib" -o "$(basename "$file" .md).html" ; then
        echo "html done!"
    else
        echo "html failed on $file"
    fi

    # epub
    if pandoc "$file" -d "../../src/yml/base.yml" --csl="https://www.zotero.org/styles/harvard-university-of-bath" --bibliography="../references.bib" -o "$(basename "$file" .md).epub"; then
        echo "epub done!"
    else
        echo "epub failed on $file"
    fi

    # docx
    if pandoc "$file" -d "../../src/yml/base.yml" --csl="https://www.zotero.org/styles/harvard-university-of-bath" --bibliography="../references.bib" -o "$(basename "$file" .md).docx"; then
        echo "docx done!"
    else
        echo "docx failed on $file"
    fi

    # pdf
    if pandoc "$file" -d "../../src/yml/base.yml" -d "../../src/yml/pdf.yml" --csl="https://www.zotero.org/styles/harvard-university-of-bath" --bibliography="../references.bib" -o "$(basename "$file" .md).pdf"; then
        echo "pdf done!"
    else
        echo "pdf failed on $file"
    fi
done

cd ../..