-- Introduces shortcodes that do the following:
-- - Handles embedded external content.

local msg_tbl = {}
local include_before_html_tbl = {}
local include_after_html_tbl = {}

function Meta(meta)
    -- Extract relevant metadata for shortcodes.
    if meta.shortcode["msg"] ~= nil then
        msg_tbl = meta.shortcode["msg"]
    end
    if meta.shortcode["include-before-html"] ~= nil then
        include_before_html_tbl = meta.shortcode["include-before-html"]
    end
    if meta.shortcode["include-after-html"] ~= nil then
        include_after_html_tbl = meta.shortcode["include-after-html"]
    end
end

local function iframe(shortcode, attr_tbl)
    local before_iframe
    local after_iframe
    attr_tbl["msg"] = nil
    -- Include additional content before or after iframe container, if any.
    if attr_tbl["include-before-html"] then
        before_iframe = attr_tbl["include-before-html"]
        attr_tbl["include-before-html"] = nil
    elseif include_before_html_tbl[shortcode] then
        before_iframe = include_before_html_tbl[shortcode]
    end
    if attr_tbl["include-after-html"] then
        after_iframe = attr_tbl["include-after-html"]
        attr_tbl["include-after-html"] = nil
    elseif include_after_html_tbl[shortcode] then
        after_iframe = include_after_html_tbl[shortcode]
    end

    -- Append unique class based on shortcode.
    if attr_tbl["class"] then
        attr_tbl["class"]:insert(pandoc.Str(shortcode .. "-iframe"))
    else
        attr_tbl["class"] = pandoc.Str(shortcode .. "-iframe")
    end

    local output_tbl = {}
    local iframe_str = "<iframe"
    for key, val in pairs(attr_tbl) do
        iframe_str = iframe_str .. " " .. key
        if val then
            iframe_str = iframe_str .. "=\"" .. pandoc.utils.stringify(val) .. "\""
        end
    end
    iframe_str = iframe_str .. "></iframe>"
    table.insert(output_tbl, pandoc.RawBlock("html", iframe_str))
    if after_iframe then
        table.insert(output_tbl, pandoc.Div(
            after_iframe,
            {class="after-iframe-container after-".. shortcode .. "-container"}
        ))
    elseif before_iframe then
        table.insert(output_tbl, 1, pandoc.Div(
            before_iframe,
            {class="before-iframe-container before-".. shortcode .. "-container"}
        ))
    end

    return output_tbl
end

function Block(block)
    local attr_tbl = {}
    local shortcode
    -- Determine if the block element is an shortcode.
    if (block.t == "Para") then
        if (block.content[1].text == "{{<") and (block.content[#block.content].text == ">}}") then
            -- Extract the iframe type.
            shortcode = block.content[3].text

            if (#block.content > 5) then
                -- Convert the shortcode attributes into a string.
                local attr
                for i = 5, (#block.content - 2) do
                    if (block.content[i].t == "Str") then
                        attr = block.content[i].text:sub(1,-2)
                        attr_tbl[attr] = nil
                    elseif (block.content[i].t == "Quoted") then
                        -- pandoc.utils.stringify does not work well with Quoted.
                        attr_tbl[attr] = block.content[i].content
                    end
                end
                -- Return an iframe for HTML output.
                if FORMAT:match("html") and attr_tbl["src"] then
                    return iframe(shortcode, attr_tbl)
                end
            end

            if attr_tbl["msg"] then
                attr_tbl["msg"] = pandoc.utils.stringify(attr_tbl["msg"])
            end
            if attr_tbl["src"] then
                attr_tbl["src"] = pandoc.utils.stringify(attr_tbl["src"])
            end
        end
    
    -- Get the src from raw iframe for non-HTML format.
    elseif (not FORMAT:match("html")) and (block.t == "RawBlock") and (block.text:match("iframe")) then
        if (block.text == "</iframe>") then
            return {}
        else
            -- Default shortcode since cannot determine based on external src.
            shortcode = "iframe"
            attr_tbl["src"] = block.text:match("src=\"(.-)\"")
        end
    end

    -- Return link to iframe content for non-HTML formats.
    if attr_tbl["src"] then
        if attr_tbl["msg"] then
            return pandoc.Link(attr_tbl["msg"], attr_tbl["src"])
        elseif msg_tbl[shortcode] then
            return pandoc.Link(msg_tbl[shortcode], attr_tbl["src"])
        else
            return pandoc.Link("You can click here to access the embedded resource online.", attr_tbl["src"])
        end
    end
end

-- Force Meta to run before Block.
return {
    { Meta = Meta },
    { Block = Block }
}