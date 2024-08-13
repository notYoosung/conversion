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

if mc ~= nil and mcl ~= nil and o ~= nil then
    local mc_list = mc:read("*a")
    -- o:write(i_read)
    local patterns = {}
    
    for line in mcl:lines() do
        local un_mcl_line = line:gsub("(mcl_%a+_)", 1)
        local line_split = split(line, "_")
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
                -- cond = #line_split == 2,
                -- output = "%1",
            },
            -- {
            --     match = "mcl_%a+_" .. line_split[2] .. "_" .. line_split[1],
            --     cond = #line_split == 2,
            --     -- output = "",
            -- },
        }

        for _, pattern in ipairs(patterns) do
            local cond = pattern.cond == nil or pattern.cond == true
            if not cond then goto match_unsuccessful end
            local match = mc_list:match("" .. pattern.match)
            local output = pattern.output or match
            if match == nil then goto match_unsuccessful end
            matched:write("\"" .. line .. "\", \"" .. output .. "\"\n")
            goto continue
            ::match_unsuccessful::
            unmatched:write("\"" .. line .. "\"\n")
            ::continue::
        end
        -- o:write(line .. "\n")
    end
    
    mc:close()
    mcl:close()
    matched:close()
    unmatched:close()
end
