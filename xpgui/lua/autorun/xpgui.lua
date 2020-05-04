--[[
    Lua
]]

for _, f in pairs(file.Find("xpgui/*", "LUA")) do
    AddCSLuaFile("xpgui/" .. f)
end

for _, f in pairs(file.Find("xpgui/vgui/*", "LUA")) do
    AddCSLuaFile("xpgui/vgui/" .. f)
end

if CLIENT then 
    XPGUI = {}
    
    for _, f in pairs(file.Find("xpgui/vgui/*", "LUA")) do
        include("xpgui/vgui/" .. f)
    end

    for _, f in pairs(file.Find("xpgui/*", "LUA")) do
        include("xpgui/" .. f)
    end
end

--[[
    Sounds
]]

if SERVER then
    local folders = {}
    for _, f in pairs(file.Find("sound/xpgui/*", "GAME")) do
        table.insert(folders, f)
    end

    for _, folder in pairs(folders) do
        for _, file in pairs(file.Find("sound/xpgui/" .. folder .. "/*", "GAME")) do
            resource.AddFile(file)
        end
    end
end