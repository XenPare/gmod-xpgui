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
    XPGUI.GetLast():Remove()
end

function XPGUI.Add(pnl)
    table.insert(XPGUI.Opened, pnl)
end

function XPGUI.PlaySound(path)
    if XPGUI.SoundEnabled then
        surface.PlaySound(path)
    end
end

local FirstPressed, cache = false
hook.Add("Think", "XPGUI Binding", function()
    cache = input.IsButtonDown(KEY_ESCAPE)
    if not table.IsEmpty(XPGUI.Opened) then
        if cache and FirstPressed then
            XPGUI.RemoveLast()
        end

        FirstPressed = not cache

        if gui.IsGameUIVisible() then
            gui.HideGameUI()
            return true 
        end
    end
end)

if XPGUI.EternalHidingESC then
    hook.Add("PreRender", "XPGUI Binding", function()
        if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then		
            gui.HideGameUI()
            return true 
        end
    end)
end
