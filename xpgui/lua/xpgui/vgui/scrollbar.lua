local PANEL = {}

AccessorFunc(PANEL, "m_HideButtons", "HideButtons")

function PANEL:Init()
	self.Offset = 0
	self.Scroll = 0
	self.NextScroll = 0
	self.CanvasSize = 1
	self.BarSize = 1

	self.BackgroundOpacity = 0

	self.LastThink = 0

	self.btnGrip = vgui.Create("XPScrollBarGrip", self)

	self:SetSize(16, 15)
	self:SetHideButtons(false)
end

function PANEL:SetEnabled(b)
	if not b then
		self.Offset = 0
		self:SetScroll(0)
		self.HasChanged = true
	end

	self:SetMouseInputEnabled(b)
	self:SetVisible(b)

	if self.Enabled ~= b then
		self:GetParent():InvalidateLayout()
		if self:GetParent().OnScrollbarAppear then
			self:GetParent():OnScrollbarAppear()
		end
	end

	self.Enabled = b
end

function PANEL:Value()
	return self.Pos
end

function PANEL:BarScale()
	if self.BarSize == 0 then 
		return 1 
	end

	return self.BarSize / (self.CanvasSize + self.BarSize)
end

function PANEL:SetUp(_barsize_, _canvassize_)
	self.BarSize = _barsize_
	self.CanvasSize = math.max(_canvassize_ - _barsize_, 1)

	self:SetEnabled(_canvassize_ > _barsize_)

	self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
	if not self:IsVisible() then 
		return false 
	end

	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel

	self.NextScroll = self:GetScroll() + dlta * -75
	return true
end

function PANEL:Think()
	local now = CurTime()
	local timepassed = now - self.LastThink
	self.LastThink = now
	if not self.Dragging then
		self:SetScroll(math.Approach(self:GetScroll(), self.NextScroll, 700 * timepassed))
	end
end

function PANEL:AddScroll(dlta)
	local OldScroll = self:GetScroll()

	dlta = dlta * 25
	self:SetScroll(self:GetScroll() + dlta)
	return OldScroll ~= self:GetScroll()
end

function PANEL:SetScroll(scrll)
	if not self.Enabled then 
		self.Scroll = 0 
		return 
	end

	self.Scroll = math.Clamp(scrll, 0, self.CanvasSize)

	self:InvalidateLayout()

	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)

	local func = self:GetParent().OnVScroll
	if func then
		func(self:GetParent(), self:GetOffset())
	else
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:AnimateTo(scrll, length, delay, ease)
	local anim = self:NewAnimation(length, delay, ease)
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function(anim, pnl, fraction)
		pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
	end
end

function PANEL:GetScroll()
	if not self.Enabled then 
		self.Scroll = 0 
	end
	return self.Scroll
end

function PANEL:GetOffset()
	if not self.Enabled then 
		return 0 
	end
	return self.Scroll * -1
end

function PANEL:Paint(w, h)
	self.BackgroundOpacity = Lerp(5 * FrameTime(), self.BackgroundOpacity, self.Dragging and 180 or 0)

	draw.RoundedBox(self.btnGrip.BarScale, w - self.btnGrip.BarScale, 0, self.btnGrip.BarScale, h, ColorAlpha(XPGUI.ScrollBarBGColor, self.BackgroundOpacity))
	return true
end

function PANEL:OnMousePressed()
	--
end

function PANEL:OnMouseReleased()
	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture(false)

	self.btnGrip.Depressed = false
end

function PANEL:OnCursorMoved(x, y)
	if not self.Enabled then 
		return 
	end

	if not self.Dragging then 
		return 
	end

	local x, y = self:ScreenToLocal(0, gui.MouseY())
	y = y - self.HoldPos

	local TrackSize = self:GetTall() - self.btnGrip:GetTall()

	y = y / TrackSize
	
	self.NextScroll = y * self.CanvasSize

	self:SetScroll(y * self.CanvasSize)
end

function PANEL:Grip()
	if not self.Enabled then 
		return 
	end

	if self.BarSize == 0 then
		return 
	end

	self:MouseCapture(true)
	self.Dragging = true

	local x, y = self.btnGrip:ScreenToLocal(0, gui.MouseY())
	self.HoldPos = y

	self.btnGrip.Depressed = true
end

function PANEL:PerformLayout()
	local Wide = self:GetWide()
	local Scroll = self:GetScroll() / self.CanvasSize
	local BarSize = math.max(self:BarScale() * self:GetTall(), 10)
	local Track = self:GetTall() - BarSize
	Track = Track + 1

	Scroll = Scroll * Track

	self.btnGrip:SetPos(0, Scroll)
	self.btnGrip:SetSize(Wide, BarSize)
end

derma.DefineControl("XPScrollBar", "A Scrollbar", PANEL, "Panel")