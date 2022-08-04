function XPGUI.Menu(parentMenu, parent)
	if not parentMenu then
		CloseDermaMenus()
	end

	local xpMenu = vgui.Create("XPMenu", parent)
	return xpMenu
end

local PANEL = {}

AccessorFunc(PANEL, "m_bBorder", "DrawBorder")
AccessorFunc(PANEL, "m_bDeleteSelf", "DeleteSelf")
AccessorFunc(PANEL, "m_iMinimumWidth", "MinimumWidth")
AccessorFunc(PANEL, "m_bDrawColumn", "DrawColumn")
AccessorFunc(PANEL, "m_iMaxHeight", "MaxHeight")
AccessorFunc(PANEL, "m_pOpenSubMenu", "OpenSubMenu")

function PANEL:Init()
	self.startTime = SysTime()

	self.RealTall = 0

	self:SetIsMenu(true)
	self:SetDrawBorder(true)
	self:SetPaintBackground(true)
	self:SetMinimumWidth(100)
	self:SetDrawOnTop(true)
	self:SetMaxHeight(ScrH() / 1.2)
	self:SetDeleteSelf(true)

	local x, y = input.GetCursorPos()
	self:SetPos(x, y)

	self:MakePopup()
	self:SetPadding(0)

	RegisterDermaMenuForClose(self)
end

function PANEL:AddPanel(pnl)
	self:AddItem(pnl)
	pnl.ParentMenu = self
end

function PANEL:AddOption(strText, funcFunction)
	local pnl = vgui.Create("XPMenuOption", self)
	pnl:SetMenu(self)

	pnl:SetText(strText)
	pnl:SetTextColor(color_white)
	pnl:SetFont("xpgui_medium")
	pnl:SetExpensiveShadow(1, ColorAlpha(color_black, 140))

	if funcFunction then
		pnl.DoClick = funcFunction
	end

	self.RealTall = self.RealTall + 24

	local mx, my = input.GetCursorPos()
	self:SetPos(mx, math.Clamp(my - self.RealTall + 24, 0, ScrH()))

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddCVar(strText, convar, on, off, funcFunction)
	local pnl = vgui.Create("DMenuOptionCVar", self)
	pnl:SetMenu(self)

	pnl:SetText(strText)
	pnl:SetTextColor(color_white)
	pnl:SetFont("xpgui_medium")
	pnl:SetExpensiveShadow(1, ColorAlpha(color_black, 140))

	if funcFunction then
		pnl.DoClick = funcFunction
	end

	pnl:SetConVar(convar)
	pnl:SetValueOn(on)
	pnl:SetValueOff(off)

	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSpacer(strText, funcFunction)
	local pnl = vgui.Create("DPanel", self)

	pnl.Paint = function(p, w, h)
		return
	end

	pnl:SetTall(10)
	self:AddPanel(pnl)

	return pnl
end

function PANEL:AddSubMenu(strText, funcFunction)
	local pnl = vgui.Create("XPMenuOption", self)
	local SubMenu = pnl:AddSubMenu(strText, funcFunction)

	pnl:SetText(strText)
	pnl:SetTextColor(color_white)
	pnl:SetFont("xpgui_medium")
	pnl:SetExpensiveShadow(1, ColorAlpha(color_black, 140))

	if funcFunction then
		pnl.DoClick = funcFunction
	end

	self:AddPanel(pnl)

	return SubMenu, pnl
end

function PANEL:Hide()
	local openmenu = self:GetOpenSubMenu()
	if openmenu then
		openmenu:Hide()
	end

	self:SetVisible(false)
	self:SetOpenSubMenu(nil)
end

function PANEL:OpenSubMenu(item, menu)
	local openmenu = self:GetOpenSubMenu()
	if IsValid(openmenu) and openmenu:IsVisible() then
		if menu and openmenu == menu then
			return
		end
		self:CloseSubMenu(openmenu)
	end

	if not IsValid(menu) then
		return
	end

	local x, y = item:LocalToScreen(self:GetWide(), 0)
	menu:Open(x - 3, y, false, item)

	self:SetOpenSubMenu(menu)
end

function PANEL:CloseSubMenu(menu)
	menu:Hide()
	self:SetOpenSubMenu(nil)
end

function PANEL:Paint(w, h)
	if not self:GetPaintBackground() then
		return
	end

	if not self.FirstInit then -- We need to pre-cache shape for better performance
		self.FirstInit = true
		self.PolyMask = surface.PrecacheRoundedRect(0, 0, self:GetWide(), self:GetTall(), 6, 16)
	end

	EZMASK.DrawWithMask(function()
		surface.SetDrawColor(color_white)
		surface.DrawPoly(self.PolyMask)
	end, function()
		surface.DrawPanelBlur(self, 6)
	end)
	draw.RoundedBox(6, 0, 0, w, h - 1, XPGUI.BGColor)

	return true
end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild(num)
	return self:GetCanvas():GetChildren()[num]
end

function PANEL:PerformLayout()
	local w = self:GetMinimumWidth()
	for _, pnl in pairs(self:GetCanvas():GetChildren()) do
		pnl:PerformLayout()
		w = math.max(w, pnl:GetWide())
	end

	self:SetWide(w)

	local y = 0
	for _, pnl in pairs(self:GetCanvas():GetChildren()) do
		pnl:SetWide(w)
		pnl:SetPos(0, y)
		pnl:InvalidateLayout(true)

		y = y + pnl:GetTall() + 1
	end

	y = math.min(y, self:GetMaxHeight())

	self:SetTall(y)

	derma.SkinHook("Layout", "Menu", self)

	self.BaseClass.PerformLayout(self)
end

function PANEL:Open(x, y, skipanimation, ownerpanel)
	RegisterDermaMenuForClose(self)

	local maunal = x and y

	x = x or gui.MouseX()
	y = y or gui.MouseY()

	local OwnerHeight = 0
	local OwnerWidth = 0
	if ownerpanel then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end

	self:PerformLayout()

	local w = self:GetWide()
	local h = self:GetTall()

	self:SetSize(w, h)

	if y + h > ScrH() then
		y = ((maunal and ScrH()) or (y + OwnerHeight)) - h
	end

	if x + w > ScrW() then
		x = ((maunal and ScrW()) or x) - w
	end

	if y < 1 then
		y = 1
	end

	if x < 1 then
		x = 1
	end

	self:SetPos(x, y)
	self:MakePopup()
	self:SetVisible(true)
	self:SetKeyboardInputEnabled(false)
end

function PANEL:OptionSelectedInternal(option)
	self:OptionSelected(option, option:GetText())
end

function PANEL:OptionSelected(option, text) end

function PANEL:ClearHighlights()
	for _, pnl in pairs(self:GetCanvas():GetChildren()) do
		pnl.Highlight = nil
	end
end

function PANEL:HighlightItem(item)
	for _, pnl in pairs(self:GetCanvas():GetChildren()) do
		if pnl == item then
			pnl.Highlight = true
		end
	end
end

derma.DefineControl("XPMenu", "", PANEL, "XPScrollPanel")