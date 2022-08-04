local PANEL = {}

AccessorFunc(PANEL, "m_iOverlap", "Overlap")
AccessorFunc(PANEL, "m_bShowDropTargets", "ShowDropTargets", FORCE_BOOL)

function PANEL:Init()
	self.Panels = {}
	self.OffsetX = 0
	self.FrameTime = 0

	self.pnlCanvas = vgui.Create("DDragBase", self)
	self.pnlCanvas:SetDropPos("6")
	self.pnlCanvas:SetUseLiveDrag(false)

	self.pnlCanvas.OnModified = function()
		self:OnDragModified()
	end

	self.pnlCanvas.UpdateDropTarget = function(Canvas, drop, pnl)
		if not self:GetShowDropTargets() then
			return
		end
		self.BaseClass.UpdateDropTarget(Canvas, drop, pnl)
	end

	self.pnlCanvas.OnChildAdded = function(Canvas, child)
		local dn = Canvas:GetDnD()
		if dn then
			child:Droppable(dn)
			child.OnDrop = function()
				local x, y = Canvas:LocalCursorPos()
				local closest, id = self.pnlCanvas:GetClosestChild(x, Canvas:GetTall() / 2), 0

				for k, v in pairs(self.Panels) do
					if v == closest then
						id = k
						break
					end
				end

				table.RemoveByValue(self.Panels, child)
				table.insert(self.Panels, id, child)

				self:InvalidateLayout()
				return child
			end
		end
	end

	self:SetOverlap(-4)

	self.btnLeft = vgui.Create("XPButton", self)
	self.btnLeft.PaintOver = function(panel, w, h)
		draw.SimpleText("<", "xpgui_big", w * 0.5, h * 0.5 - 2, XPGUI.HorizontalScrollerArrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.btnRight = vgui.Create("XPButton", self)
	self.btnRight.PaintOver = function(panel, w, h)
		draw.SimpleText(">", "xpgui_big", w * 0.5, h * 0.5 - 2, XPGUI.HorizontalScrollerArrowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:ScrollToChild(panel)
	self:InvalidateLayout(true)

	local x, y = self.pnlCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()

	x = x + w * 0.5
	x = x - self:GetWide() * 0.5

	self:SetScroll(x)
end

function PANEL:SetScroll(x)
	self.OffsetX = x
	self:InvalidateLayout(true)
end

function PANEL:SetUseLiveDrag(bool)
	self.pnlCanvas:SetUseLiveDrag(bool)
end

function PANEL:MakeDroppable(name)
	self.pnlCanvas:MakeDroppable(name)
end

function PANEL:AddPanel(pnl)
	table.insert(self.Panels, pnl)

	pnl:SetParent(self.pnlCanvas)
	self:InvalidateLayout(true)
end

function PANEL:Clear()
	self.pnlCanvas:Clear()
	self.Panels = {}
end

function PANEL:OnMouseWheeled(dlta)
	self.OffsetX = self.OffsetX + dlta * -30
	self:InvalidateLayout(true)
	return true
end

function PANEL:Think()
	local FrameRate = VGUIFrameTime() - self.FrameTime
	self.FrameTime = VGUIFrameTime()

	if self.btnRight:IsDown() then
		self.OffsetX = self.OffsetX + (500 * FrameRate)
		self:InvalidateLayout(true)
	end

	if self.btnLeft:IsDown() then
		self.OffsetX = self.OffsetX - (500 * FrameRate)
		self:InvalidateLayout(true)
	end

	if dragndrop.IsDragging() then
		local x, y = self:LocalCursorPos()
		if x < 30 then
			self.OffsetX = self.OffsetX - (350 * FrameRate)
		elseif x > self:GetWide() - 30 then
			self.OffsetX = self.OffsetX + (350 * FrameRate)
		end
		self:InvalidateLayout(true)
	end
end

function PANEL:PerformLayout()
	local w, h = self:GetSize()

	self.pnlCanvas:SetTall(h - 24)

	local x = 0
	for _, v in pairs(self.Panels) do
		if not IsValid(v) or not v:IsVisible() then
			continue
		end

		v:SetPos(x, 0)
		v:SetTall(h - 24)

		if v.ApplySchemeSettings then
			v:ApplySchemeSettings()
		end

		x = x + v:GetWide() - self.m_iOverlap
	end

	self.pnlCanvas:SetWide(x + self.m_iOverlap)

	if w < self.pnlCanvas:GetWide() then
		self.OffsetX = math.Clamp(self.OffsetX, 0, self.pnlCanvas:GetWide() - self:GetWide())
	else
		self.OffsetX = 0
	end

	self.pnlCanvas.x = self.OffsetX * -1

	self.btnLeft:SetSize(16, 16)
	self.btnLeft:AlignLeft(4)
	self.btnLeft:AlignBottom(4)

	self.btnRight:SetSize(16, 16)
	self.btnRight:AlignRight(4)
	self.btnRight:AlignBottom(4)

	self.btnLeft:SetVisible(self.pnlCanvas.x < 0)
	self.btnRight:SetVisible(self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide())
end

function PANEL:OnDragModified() end

derma.DefineControl("XPHorizontalScroller", "", PANEL, "Panel")