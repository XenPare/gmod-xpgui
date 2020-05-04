XPGUI.Opened = {}

function XPGUI.GetLast()
    return XPGUI.Opened[#XPGUI.Opened]
end

function XPGUI.GetFirst()
    return XPGUI.Opened[1]
end

function XPGUI.GetAmount()
    return #XPGUI.Opened
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
            XPGUI.GetLast():Remove()
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