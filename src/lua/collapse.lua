-- Makes callouts with collapse="true" collapsible for HTML output.
-- Must be run after callout.lua.

function Div(div)
  if (FORMAT:match "html") and (div.classes[1] == "callout") and (div.attr.attributes.collapse == "true") then
    -- Collect the classes in a string.
    local classes_str = ""
    for _, class in pairs(div.classes) do
      classes_str = classes_str .. class .. " "
    end

    -- Only the id and classes are passed to the collapsible callout.
    return {
      pandoc.RawBlock("html", string.format(
        [[<details class="%s" id="%s"><summary class="callout-header">]],
        classes_str,
        div.identifier
      )),
      div.content[1].content[1], -- Icon container
      div.content[1].content[2], -- Heading container
      pandoc.RawBlock("html", [[</summary>]]),
      div.content[2], -- Callout body.
      pandoc.RawBlock("html", [[</details>]])
      }
  end
end