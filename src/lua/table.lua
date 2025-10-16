--[[
- Sets the caption for tables defined using fenced div syntax.
- Sets the row_head_columns argument, if given.
- Modifies the content structure for SPSS output.
]]

function Div(div)
  -- Check if the div has an id starting with 'tbl-'.
  if (div.identifier ~= nil) and (string.find(div.identifier, "tbl") ~= nil) then
    -- Set the caption of the table.
    if (div.content[1].caption ~= nil) and (div.content[2] ~= nil) and (div.content[2].t == "Para") then
      div.content[1].caption = pandoc.Caption(
        pandoc.utils.stringify(div.content[2])
      )
      table.remove(div.content,2)
    end
  end

  -- Check if the row_head_columns argument is given.
  local row_head_columns = tonumber(div.attributes.row_head_columns)
  if row_head_columns ~= nil then
    -- Set the number of columns for row headers of the table to row_head_columns.
    div.content[1].bodies[1].row_head_columns = row_head_columns   
    -- Remove the row_head_columns attribute from div.
    div.attributes.row_head_columns = nil
  end

  -- Pass custom table styles to tables for DOCX output.
  if div.attributes["custom-style"] and div.content[1].t == "Table" then
    div.content[1].attributes["custom-style"] = div.attributes["custom-style"]
    div.attributes["custom-style"] = nil
  end

  -- Check if the table contains SPSS output.
  if div.classes:includes("output") then
    -- Collect notes for the SPSS output.
    local notes = {}
    for i = 1,10 do
      if div.content[2] == nil then
        break
      else
        notes[i] = div.content[2]
        table.remove(div.content, 2)
      end
    end
    
    -- If there are notes, wrap them in a div.
    if notes[1] then
      div.content[2] = pandoc.Div(notes, {class = "output-note"})
    end

    if FORMAT:match("docx") then
      -- Apply styling for DOCX output.
      div.content[1].caption.long = pandoc.Div(
        pandoc.Para(div.content[1].caption.long[1].content),
        {["custom-style"]="SPSSOutputCaption"}
      )
      div.content[1].attributes["custom-style"] = "SPSSOutput"
    else
      -- Wrap all the SPSS output in a div for alignment in HTML.
      content_div = pandoc.Div(div.content, {class="output-content"})
      div = pandoc.Div(content_div, div.attr)
    end
  end

  return div
end