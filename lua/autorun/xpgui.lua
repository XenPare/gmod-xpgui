for _, f in pairs(file.Find("xpgui/*", "LUA")) do
	AddCSLuaFile("xpgui/" .. f)
end
for _, f in pairs(file.Find("xpgui/vgui/*", "LUA")) do
	AddCSLuaFile("xpgui/vgui/" .. f)
end

if SERVER then
	resource.AddWorkshop("2390567739")
else
	XPGUI = {}
	for _, f in pairs(file.Find("xpgui/vgui/*", "LUA")) do
		include("xpgui/vgui/" .. f)
	end
	for _, f in pairs(file.Find("xpgui/*", "LUA")) do
		include("xpgui/" .. f)
	end
end