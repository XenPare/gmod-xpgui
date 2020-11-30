local PANEL = {}

function PANEL:Init()
	self:SetFont("xpgui_medium")
	self:SetText("")

	self:SetTooltipPanelOverride("XPTooltip")

	self:SizeToContents()
	self:SetSize(self:GetWide() + 10, 36)

	self:DockMargin(3, 2, 3, 2)

	self:SetDoubleClickingEnabled(false)
	self:SetExpensiveShadow(1, ColorAlpha(color_black, 140))

	self.Color = XPGUI.BGColor
	self.Color = Color(255 - self.Color.r, 255 - self.Color.g, 255 - self.Color.b, 25)
end

function PANEL:OnDepressed()
	XPGUI.PlaySound("xpgui/sidemenu/sidemenu_click_01.wav")
end

function PANEL:OnCursorEntered()
	if self:GetDisabled() then
		return
	end

	XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav")
end

function PANEL:Paint(w, h)
	if self:IsHovered() then
		self.Color.a = Lerp(0.075, self.Color.a , 35)
	else
		self.Color.a = Lerp(0.075, self.Color.a , 25)
	end

	if self:IsDown() then
		self.Color.a = Lerp(0.075, self.Color.a , 75)
	end

	draw.RoundedBox(6, 0, 0, w, h, self.Color)
end

function PANEL:UpdateColours()
	if self:GetDisabled() then
		return self:SetTextStyleColor(Color(152, 152, 152))
	else
		return self:SetTextStyleColor(color_white)
	end
end

derma.DefineControl("XPButton", "", PANEL, "DButton")