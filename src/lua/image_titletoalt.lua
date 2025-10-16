-- Sets an image's alt attribute to its title.

function Image (img)
    if ( img.attributes["alt"] == nil ) then
        img.attributes["alt"] = img.title
        img.title = ""
        return img
    end
end