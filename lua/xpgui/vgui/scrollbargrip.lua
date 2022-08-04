local PANEL = {}

function PANEL:Init()
	self.BarScale = 6
	self.ColorA = XPGUI.ScrollBarGripColor.a
	self.Color = Color(XPGUI.ScrollBarGripColor.r, XPGUI.ScrollBarGripColor.g, XPGUI.ScrollBarGripColor.b, XPGUI.ScrollBarGripColor.a)
end

function PANEL:OnMousePressed()
	self:GetParent():Grip(1)
end

function PANEL:Think()
	if self:IsHovered() or self:GetParent().Dragging then
		self.BarScale = Lerp(10 * FrameTime(), self.BarScale, self:GetWide())
	else
		self.BarScale = Lerp(10 * FrameTime(), self.BarScale, 6)
	end

	if self:GetParent().Dragging then
		self.Color.a = Lerp(10 * FrameTime(), self.Color.a, 255)
	else
		self.Color.a = Lerp(10 * FrameTime(), self.Color.a, self.ColorA)
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(self.BarScale * 0.5, w - self.BarScale, 0, self.BarScale, h, self.Color)
	return true
end

derma.DefineControl("XPScrollBarGrip", "", PANEL, "DPanel")