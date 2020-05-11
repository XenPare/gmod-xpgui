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
    local function AddDir(dir)
        local files, dirs = file.Find(dir .. "/*", "GAME")
        for _, fdir in pairs(dirs) do
            if fdir ~= ".svn" then
                AddDir(dir .. "/" .. fdir)
            end
        end
        
        for _, f in pairs(files) do
            resource.AddFile(dir .. "/" .. f)
        end
    end
     
    AddDir("sound/xpgui/generic")
    AddDir("sound/xpgui/lobby")
    AddDir("sound/xpgui/sidemenu")
    AddDir("sound/xpgui/submenu")
end
