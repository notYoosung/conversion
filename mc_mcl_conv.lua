local mc = io.open("./mc_list_blocks.txt", "r")
local mcl = io.open("./mcl_list.txt", "r")
local matched = io.open("./matched.txt", "w")
local unmatched = io.open("./unmatched.txt", "w")

-- https://stackoverflow.com/a/7615129
local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

if mc ~= nil and mcl ~= nil and matched ~= nil and unmatched ~= nil then
    local mc_list = mc:read("*a")
    -- o:write(i_read)
    local patterns = {}
    
    for line in mcl:lines() do
        line = line:gsub("\\.png", "")
        local un_mcl_line = line:gsub("(mcl_%a-_)", "")
        local un_default_line = line:gsub("(default_)", "")
        local line_split = split(line, "_")
        local un_mcl_line_split = split(line:gsub("(mcl_%a-_)", ""), "_")
        patterns = {
            {
                match = line,
                -- cond = true,
                -- output = "",
            },
            {
                match = (line_split[2] or "") .. "_" .. (line_split[1] or ""),
                cond = #line_split == 2,
                -- output = "",
            },
            {
                match = un_mcl_line,
                cond = not line:match("copper"),
                -- output = "%1",
            },
            {
                match = (un_mcl_line_split[2] or "") .. "_" .. (un_mcl_line_split[1] or ""),
                cond = #un_mcl_line_split == 2,
                -- output = "",
            },
            {
                match = line:gsub("mcl_copper_", "copper_"),
                -- cond = ,
                -- output = "",
            },
            {
                match = line:gsub("xpanes_top_glass_(.-)", function (s)
                    return s .. "_stained_glass"
                end)
            },
            {
                match = un_default_line,
                -- cond = ,
                -- output = "%1",
            },
            -- {
            --     match = "mcl_%a+_" .. line_split[2] .. "_" .. line_split[1],
            --     cond = #line_split == 2,
            --     -- output = "",
            -- },
        }
        local found_match = false
        for _, pattern in ipairs(patterns) do
            local cond = pattern.cond == nil or pattern.cond == true
            if not cond then
                goto continue
            end
            local match = mc_list:match("" .. pattern.match)
            local output = match--pattern.output or match or ""
            if match == nil then
                goto continue
            end
            matched:write("\"" .. line .. "\", \"" .. output .. "\"\n")
            found_match = true
            break
            ::continue::
        end
        if not found_match then
            unmatched:write("\"" .. line .. "\"\n")
        end
        -- o:write(line .. "\n")

    end
    
    mc:close()
    mcl:close()
    matched:close()
    unmatched:close()
end
