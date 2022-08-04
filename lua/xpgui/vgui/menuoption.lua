local PANEL = {}

AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")

function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetTextInset(30, 0)
	self:SetTextColor(Color(10, 10, 10))
	self:SetChecked(false)

	self:SetTooltipPanelOverride("XPTooltip")
end

function PANEL:SetSubMenu(menu)
	self.SubMenu = menu

	if not IsValid(self.SubMenuArrow) then
		self.SubMenuArrow = vgui.Create("DPanel", self)
		self.SubMenuArrow.Paint = function(panel, w, h)
			derma.SkinHook("Paint", "MenuRightArrow", panel, w, h)
		end
	end
end

function PANEL:AddSubMenu()
	local subMenu = XPGUI.Menu(self)
	subMenu:SetVisible(false)
	subMenu:SetParent(self)

	self:SetSubMenu(subMenu)
	return subMenu
end

function PANEL:OnCursorEntered()
	if IsValid(self.ParentMenu) then
		self.ParentMenu:OpenSubMenu(self, self.SubMenu)
		return
	end
	self:GetParent():OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited() end

local pos_x, pos_y
function PANEL:Paint(w, h)
	if self:IsHovered() then
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, 35)
	else
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, 25)
	end

	if self:IsDown() then
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, 75)
	end

	pos_x, pos_y = self:GetPos()
	if pos_y == self:GetParent():GetTall() - h then
		draw.RoundedBoxEx(6, 0, 0, w, h, self.Color, false, false, true, true)
	elseif pos_y == 0 then
		draw.RoundedBoxEx(6, 0, 0, w, h, self.Color, true, true)
	else
		draw.RoundedBox(0, 0, 0, w, h, self.Color)
	end
end

function PANEL:OnMousePressed(mousecode)
	self.m_MenuClicking = true
	DButton.OnMousePressed(self, mousecode)
end

function PANEL:OnMouseReleased(mousecode)
	DButton.OnMouseReleased(self, mousecode)
	if self.m_MenuClicking and mousecode == MOUSE_LEFT then
		self.m_MenuClicking = false
		CloseDermaMenus()
	end
end

function PANEL:DoRightClick()
	if self:GetIsCheckable() then
		self:ToggleCheck()
	end
end

function PANEL:DoClickInternal()
	if self:GetIsCheckable() then
		self:ToggleCheck()
	end
	if self.m_pMenu then
		self.m_pMenu:OptionSelectedInternal(self)
	end
end

function PANEL:ToggleCheck()
	self:SetChecked(not self:GetChecked())
	self:OnChecked(self:GetChecked())
end

function PANEL:OnChecked(b) end

function PANEL:PerformLayout()
	self:SizeToContents()
	self:SetWide(self:GetWide() + 30)

	local w = math.max(self:GetParent():GetWide(), self:GetWide())
	self:SetSize(w, 22)

	if IsValid(self.SubMenuArrow) then
		self.SubMenuArrow:SetSize(15, 15)
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight(4)
	end

	DButton.PerformLayout(self)
end

derma.DefineControl("XPMenuOption", "", PANEL, "XPButton")