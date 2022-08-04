local PANEL = {}

function PANEL:Init()
	self:SetDrawBorder(false)
	self:SetDrawBackground(false)
	self:SetTextColor(XPGUI.TextEntryTextColor)
	self:SetFont("xpgui_tiny")
	self:SetCursorColor(XPGUI.TextEntryCursorColor)
	self:SetHighlightColor(XPGUI.TextEntryHighlightColor)

	self.IndicatorColor = Color(255, 255, 255)

	self:SetTooltipPanelOverride("XPTooltip")
	self:SetTooltip(false)
end

function PANEL:IndicatorLayout()
	if self:HasFocus() then
		self.IndicatorColor = LerpColor(5 * FrameTime(), self.IndicatorColor, XPGUI.TextEntryIndicatorFocusedColor)
	else
		self.IndicatorColor = LerpColor(5 * FrameTime(), self.IndicatorColor, XPGUI.TextEntryIndicatorColor)
	end
end

function PANEL:Paint(w,h)
	self:IndicatorLayout()

	draw.NoTexture()
	surface.SetDrawColor(self.IndicatorColor)
	surface.DrawLine(0, 5, 0, h - 6)
	surface.DrawLine(1, 7, 1, h - 8)
	surface.SetDrawColor(ColorAlpha(self.IndicatorColor, 127))
	surface.DrawLine(0, 4, 0, h - 5)
	surface.DrawLine(1, 5, 1, h - 6)
	draw.RoundedBox(6, 0, 0, w, h, XPGUI.TextEntryBGColor)

	derma.SkinHook("Paint", "TextEntry", self, w, h)
end

derma.DefineControl("XPTextEntry", "", PANEL, "DTextEntry")