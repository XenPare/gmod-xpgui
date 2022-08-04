XPGUI.Opened = {}

function XPGUI.GetLast()
	return table.GetLastValue(XPGUI.Opened)
end

function XPGUI.GetFirst()
	return table.GetFirstValue(XPGUI.Opened)
end

function XPGUI.GetAmount()
	return #XPGUI.Opened
end

function XPGUI.RemoveLast()
	XPGUI.GetLast():Close()
end

function XPGUI.Add(pnl)
	table.insert(XPGUI.Opened, pnl)
end

function XPGUI.PlaySound(path)
	if XPGUI.SoundEnabled then
		surface.PlaySound(path)
	end
end

local firstPressed
hook.Add("PreRender", "XPGUI Binding", function()
	if not firstPressed and input.IsButtonDown(KEY_ESCAPE) and #XPGUI.Opened > 0 then
		XPGUI.RemoveLast()
		firstPressed = true
		if gui.IsGameUIVisible() then
			gui.HideGameUI()
			return true
		end
	elseif not input.IsButtonDown(KEY_ESCAPE) then
		firstPressed = false
	end
end)
