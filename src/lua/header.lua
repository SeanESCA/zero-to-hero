-- Unnumbers children headings with an unnumbered parent heading.
local parent_level = 1
local unnumber_children = false

function Header(header)
    -- Update parent level and number children again if there are no more unnumbered children.
    if (parent_level >= header.level) then
        parent_level = header.level
        unnumber_children = false
    
    -- If there are still children to unnumber, then give them the unnumbered class.
    elseif (unnumber_children) then
        header.classes:insert("unnumbered")
    end

    -- If a heading is explicitly unnumbered by the author, then all its children must be unnumbered.
    if (header.classes:includes('unnumbered')) then
        unnumber_children = true
    end

    return header
end