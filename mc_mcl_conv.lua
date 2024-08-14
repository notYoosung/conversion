local mcl = io.open("./mcl_list.txt", "r")
local matched = io.open("./matched.txt", "w")
local unmatched = io.open("./unmatched.txt", "w")
local function open_mc_list(name)
    return io.open("./mc_list_" .. name .. ".txt", "r")
end
local mc_lists = {
    open_mc_list("blocks"),
    open_mc_list("mob_effect"),
    open_mc_list("item"),
    open_mc_list("entity"),
}

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

for _, raw_mc_list in ipairs(mc_lists) do
    if raw_mc_list ~= nil and mcl ~= nil and matched ~= nil and unmatched ~= nil then
        local temp_mc_list = split(raw_mc_list:read("*a"), "\n")
        local mc_list = {}
        for _, v in ipairs(temp_mc_list) do
            mc_list[v] = v
            -- print(v)
        end
        -- o:write(i_read)
        local patterns = {}
        
        for line in mcl:lines() do
            line = line:gsub("%.png", "")
            local un_mcl_line = line:gsub("(mcl_[a-z]-_)", "")
            local un_default_line = line:gsub("(default_)", "")
            local line_split = split(line, "_")
            local un_mcl_line_split = split(line:gsub("(mcl_%a-_)", ""), "_")
            local un_farming_line = line:gsub("(farming_)", "")
            -- print(mc_list[line:gsub("mobs_mc_(.*)", "%1") .. ".png"])
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
                    match = line:gsub("mcl_", ""),
                    -- cond = not line:match("copper"),
                    -- output = "%1",
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
                    match = (un_mcl_line_split[2] or "") ..
                    "_" .. (un_mcl_line_split[3] or "") .. "_" .. (un_mcl_line_split[1] or ""),
                    cond = #un_mcl_line_split == 3,
                    -- output = "",
                },
                {
                    match = line:gsub("mcl_copper_", "copper_"),
                    -- cond = ,
                    -- output = "",
                },
                {
                    match = line:gsub("xpanes_top_glass_(.+)", function (s)
                        -- print(s)
                        return s .. "_stained_glass"
                    end)
                },
                {
                    match = un_default_line,
                    -- cond = ,
                    -- output = "%1",
                },
                {
                    match = line:gsub("mcl_potions_effect_", ""),
                    -- cond = ,
                    -- output = "",
                },
                {
                    match = un_farming_line,
                    -- cond = ,
                    -- output = "%1",
                },
                {
                    match = line:gsub("mcl_boats_(.*)", "%1"),
                    -- cond = ,
                    -- output = "%1",
                },
                {
                    match = line:gsub("mcl_compass_(.*)", "%1"),
                    -- cond = ,
                    -- output = "%1",
                },
                {
                    match = #line_split == 2 and "mcl_%a+_" .. line_split[2] .. "_" .. line_split[1],
                    cond = #line_split == 2,
                    -- output = "",
                },
                { match = line:gsub("default_tool_wood", "wood_"), },
                { match = line:gsub("default_tool_stone", "stone_"), },
                { match = line:gsub("default_tool_steel", "steel_"), },
                { match = line:gsub("default_tool_gold", "gold_"), },
                { match = line:gsub("default_tool_diamond", "diamond_"), },
                { match = line:gsub("default_tool_netherite", "netherite_"), },
                { match = line:gsub("xpanes_top_iron", "iron_bars"), },
                { match = line:gsub("mobs_mc_(.*)", "%1"), },
            }
            local found_match = false
            if line:match("mcmeta") then goto skip end
            for _, pattern in ipairs(patterns) do
                local cond = pattern.cond == nil or pattern.cond == true
                if not cond then
                    goto continue
                end
                local match = nil
                for k2, v2 in pairs(mc_list) do
                    local k2m = k2:match(pattern.match .. "%.png")
                    if k2m then
                        -- match = mc_list[k2m]
                        match = k2m
                        -- print(match)
                        break
                    -- elseif pattern.match:match("compass") and v2:match("compass") then
                    --     print(pattern.match .. ", " .. k2 .. "")
                    end
                end
                if match ~= nil then
                    -- print(pattern.match)
                    local output = match--pattern.output or match or ""
                    matched:write("\"" .. line .. ".png\", \"" .. output .. "\"\n")
                    found_match = true
                    break
                else
                    -- print(line .. ", " .. pattern.match)
                end
                ::continue::
            end
            if not found_match then
                unmatched:write("\"" .. line .. "\"\n")
            end
            ::skip::
            -- o:write(line .. "\n")

        end
        
        raw_mc_list:close()
    end
end

mcl:close()
matched:close()
unmatched:close()