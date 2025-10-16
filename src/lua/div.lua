-- Only display divs with matching profile or format, if any.
local profile = nil

function Meta(meta)
    profile = meta.profile
end

function Div(div)
    if div.classes:includes("content-visible") and (
        (
          div.attr.attributes["when-format"] and 
          not FORMAT:match(div.attr.attributes["when-format"])
        ) or (
          div.attr.attributes["unless-format"] and 
          FORMAT:match(div.attr.attributes["unless-format"])
        ) or (
          profile and div.attr.attributes["when-profile"] and
          div.attr.attributes["when-profile"] ~= profile
        ) or (
          profile and div.attr.attributes["unless-profile"] and
          div.attr.attributes["unless-profile"] == profile
    )
    ) then
        return {}
    elseif div.classes:includes("content-hidden") and (
        (
          div.attr.attributes["when-format"] and 
          FORMAT:match(div.attr.attributes["when-format"])
        ) or (
          div.attr.attributes["unless-format"] and 
          not FORMAT:match(div.attr.attributes["unless-format"])
        ) or (
          profile and div.attr.attributes["when-profile"] and
          div.attr.attributes["when-profile"] == profile
        ) or (
          profile and div.attr.attributes["unless-profile"] and 
          div.attr.attributes["unless-profile"] ~= profile
        )
    ) then
        return {}
    end
end

-- Extract metadata before checking divs.
return {
    { Meta = Meta },
    { Div = Div }
}
