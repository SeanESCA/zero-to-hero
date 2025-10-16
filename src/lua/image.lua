-- Centers images in PDF and TeX output, and sets alt text in DOCX output,
-- if a caption is not provided.

if (FORMAT:match "latex") or (FORMAT:match "pdf") then
    function Image (img)
        if ( pandoc.utils.stringify(img.caption) == "" ) then
            return {
                pandoc.RawInline("latex", "\\hfill\\break{\\centering"),
                img,
                pandoc.RawInline("latex", "\\par}")
            }
        end
    end
elseif (FORMAT:match "docx") then
    function Image (img)
        if ( pandoc.utils.stringify(img.caption) == "" ) then
            img.caption = img.attributes["alt"]
            return img
        end
    end
end