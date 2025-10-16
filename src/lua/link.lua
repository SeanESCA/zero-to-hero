-- Adds (opens in new tab) to the link text if the link opens in a new tab.

function Link(link)
    if (link.attr.attributes.target == "_blank") then
        link.content = pandoc.utils.stringify(link.content) .. " (opens in new tab)"
    end
    return link
end