function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "' .. directory .. '"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end
function recursive_scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "' .. directory .. '"')
    for filename in pfile:lines() do
        if filename:match("%.png$") then
            i = i + 1
            t[i] = directory .. "/" .. filename
        elseif filename:match("%.") then
        else
            local subdir = recursive_scandir(directory .. "/" .. filename)
            for _, v in ipairs(subdir) do
                i = i + 1
                t[i] = v
            end
        end
    end
    pfile:close()
    return t
end

-- scandir("./textures")
local mc_dirs = {
    "/entity",
}
local mc_dirlist = recursive_scandir("./textures" .. mc_dirs[1])


--https://forum.cockos.com/showpost.php?s=1159741da808e9b94bcf480f84c6bc78&p=2360581&postcount=3
local function CopyFile(old_path, new_path)
    local old_file = io.open(old_path, "rb")
    local new_file = io.open(new_path, "wb")
    local old_file_sz, new_file_sz = 0, 0
    if not old_file or not new_file then
        return false
    end
    while true do
        local block = old_file:read(2 ^ 13)
        if not block then
            old_file_sz = old_file:seek("end")
            break
        end
        new_file:write(block)
    end
    old_file:close()
    new_file_sz = new_file:seek("end")
    new_file:close()
    return new_file_sz == old_file_sz
end

local mcl = io.open("./mcl_list.txt", "r")
local matched = io.open("./matched.txt", "w")
local unmatched = io.open("./unmatched.txt", "w")
local function open_mc_list(name)
    return io.open("./mc_list_" .. name .. ".txt", "r")
end
-- local mc_lists = {
--     open_mc_list("blocks"),
--     open_mc_list("mob_effect"),
--     open_mc_list("item"),
--     open_mc_list("entity"),
-- }

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
if mcl ~= nil then
    for mcl_line in mcl:lines() do
        local un_mcl_line = mcl_line:gsub("(mcl_[a-z]-_)", "")
        local un_default_line = mcl_line:gsub("(default_)", "")
        local line_split = split(mcl_line, "_")
        local un_mcl_line_split = split(mcl_line:gsub("(mcl_%a-_)", ""), "_")
        local un_farming_line = mcl_line:gsub("(farming_)", "")
        local patterns = {
            {
                match = mcl_line,
                -- cond = true,
                -- output = "",
            },
            {
                match = un_mcl_line,
                -- cond = true,
                -- output = "",
            },
            {
                match = (line_split[2] or "") .. "_" .. (line_split[1] or ""),
                cond = #line_split == 2,
                -- output = "",
            },
            {
                match = mcl_line:gsub("mcl_", ""),
                -- cond = not line:match("copper"),
                -- output = "%1",
            },
            {
                match = un_mcl_line,
                cond = not mcl_line:match("copper"),
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
                match = mcl_line:gsub("mcl_copper_", "copper_"),
                -- cond = ,
                -- output = "",
            },
            {
                match = mcl_line:gsub("xpanes_top_glass_(.+)", function(s)
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
                match = "mcl_potions_effect_(.*)",
                -- cond = ,
                -- output = "",
            },
            {
                match = un_farming_line,
                -- cond = ,
                -- output = "%1",
            },
            {
                match = "mcl_boats_(.*)",
                -- cond = ,
                -- output = "%1",
            },
            {
                match = "mcl_compass_(.*)",
                -- cond = ,
                -- output = "%1",
            },
            {
                match = "mcl_%a+_" .. (line_split[2] or "") .. "_" .. line_split[1],
                cond = #line_split == 2,
                -- output = "",
            },
            { match = mcl_line:gsub("default_tool_wood", "wood_"), },
            { match = mcl_line:gsub("default_tool_stone", "stone_"), },
            { match = mcl_line:gsub("default_tool_steel", "steel_"), },
            { match = mcl_line:gsub("default_tool_gold", "gold_"), },
            { match = mcl_line:gsub("default_tool_diamond", "diamond_"), },
            { match = mcl_line:gsub("default_tool_netherite", "netherite_"), },
            { match = mcl_line:gsub("xpanes_top_iron", "iron_bars"), },
            { match = mcl_line:gsub("mobs_mc_(.*)", "%1"), },
        }
        for k_filedir, filedir in ipairs(mc_dirlist) do
            local undir = filedir:match(".*/([^/]-%.png)")
            if undir ~= nil then
                for k_pattern, pattern in ipairs(patterns) do
                    -- print(pattern.match)
                    local match = undir:match(pattern.match)
                    if match then
                        -- print(match)
                        CopyFile(filedir, "./tp/" .. mcl_line)
                        break
                    end
                end
            else
                -- print(filedir:match(".*/([^/]-%.png)"))
                
            end
            -- print(undir)
        end
    end
end


--[[

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
                    CopyFile(output, "./tp/" .. line)
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
--]]
mcl:close()
matched:close()
unmatched:close()

