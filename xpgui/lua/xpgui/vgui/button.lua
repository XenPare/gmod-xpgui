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

	self.ColorA = XPGUI.ButtonColor.a
	self.Color = Color(XPGUI.ButtonColor.r, XPGUI.ButtonColor.g, XPGUI.ButtonColor.b, XPGUI.ButtonColor.a)
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
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA + 15)
	else
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA)
	end

	if self:IsDown() then
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA + 25)
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