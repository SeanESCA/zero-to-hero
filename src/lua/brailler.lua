-- Modifies fenced divs containing output from wherexy.

function Div(div)
    if (div.classes[1] == "wherexy") then
        -- For compatibility with wherexy output already converted into tables.
        if (div.content[1].t == "Table") then
            -- Set caption.
            if (div.content[2] ~= nil) and (div.content[2].t == "Para") then
                div.content[1].caption = div.content[2].content
                table.remove(div.content,2)
            end

            -- Set row_head_columns to 1.
            div.content[1].bodies[1].row_head_columns = 1
            return div
        end

        -- Set column alignments and extract table header cells.
        local alignments = { { pandoc.AlignCenter } }
        local head = { pandoc.Cell("") }

        for str in string.gmatch(div.content[1].text, "%S+") do
            table.insert( alignments, { pandoc.AlignCenter } )
            table.insert( head, pandoc.Cell(str) )
        end

        -- Extract cells in table body.
        local body = {}
        local row = {}
        local col_count = 0

        for str in string.gmatch(pandoc.utils.stringify(div.content[2]), "%S+") do
            table.insert( row, pandoc.Cell( str ) )
            col_count = col_count + 1
            if (col_count == #alignments) then
                -- Start a new row.
                table.insert( body, pandoc.Row( row ) )
                row = {}
                col_count = 0
            end
        end

        -- Set the table caption, if given.
        local caption = ""
        if (div.content[3] ~= nil) then
            caption = pandoc.utils.stringify( div.content[3] )
        end

        -- Create the table containing the wherexy output.
        local tbl = pandoc.Table(
            pandoc.Caption{ caption },
            alignments,
            pandoc.TableHead{ pandoc.Row( head ) },
            {
                {
                    attr={},
                    body=body,
                    head={},
                    row_head_columns=1
                }
            },
            pandoc.TableFoot()
        )
        return pandoc.Div( tbl, div.attr )
    end
end