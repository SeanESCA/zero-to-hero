-- Converts fenced divs with the first class starting with 'callout'.
-- Must be run before collapse.lua.

local function tchelper(first, rest)
   -- Helper function for converting strings to proper case.
   return first:upper()..rest:lower()
end

function Div(div)
  if (div.classes[1] ~= nil) and (string.find(div.classes[1],"callout") ~= nil) then
    -- Table of default callout titles.
    local titles = {
      ["callout"] = "Callout",
      ["callout-attention"] = "Attention",
      ["callout-caution"] = "Caution",
      ["callout-answer"] = "Answer",
      ["callout-exercise"] = "Exercise",
      ["callout-eye"] = "Accessibility",
      ["callout-important"] = "Important",
      ["callout-note"] = "Note",
      ["callout-question"] = "Question",
      ["callout-tip"] = "Tip",
      ["callout-warning"] = "Warning",
    }
    
    local title = ""
    -- Use the title given as a heading.
    if (div.content[1].t == "Header") then
      title = pandoc.utils.stringify(div.content[1])
      div.content:remove(1)

    -- If not given, then use a pre-defined title.
    elseif (titles[div.classes[1]] ~= nil) then
      title = titles[div.classes[1]]

    -- If this type of callout is undefined, then extract the title from the type given.
    else 
      title = div.classes[1]:sub(9)
      title = title:gsub("(%a)([%w_']*)", tchelper)
    end    

    if (FORMAT:match "latex") or (FORMAT:match "pdf") then
      div = {
        pandoc.RawBlock(
          "latex", 
          string.format("\\begin{%s}[%s]", div.classes[1], title)
        ),
        div, -- Callout body.
        pandoc.RawBlock("latex", string.format("\\end{%s}", div.classes[1]))
      }
    elseif FORMAT:match "docx" then
      local style = div.classes[1]:gsub("(%a)([%w_']*)", tchelper):gsub("%-", "")
      div = pandoc.Div(
        pandoc.Table(
          {},
          {{ pandoc.AlignDefault }},
          pandoc.TableHead{ pandoc.Row{ pandoc.Cell{ title } } },
          {{
            attr={},
            body={
              pandoc.Row{ pandoc.Cell{ div } }
            },
            head={},
            row_head_columns=0
          }},
          pandoc.TableFoot(),
          {["custom-style"]=style}
        )
      )
    else
      -- Add the callout class. It must be the first class for collapse.lua to work.
      table.insert(div.classes, 1, "callout")

      -- Define the callout structure.
      div = pandoc.Div(
        {
          -- Define the callout header.
          pandoc.Div({
            pandoc.Div("", {class="callout-icon-container"}),
            pandoc.Div(pandoc.Strong(title), {class="callout-title-container"}) 
          }, {class="callout-header"}),
          -- Define the callout body.
          pandoc.Div(div.content, {class="callout-body-container"})
        },
        div.attr
      )
    end
    return div
  end
end