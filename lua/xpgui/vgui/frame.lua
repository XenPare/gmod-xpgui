local gradtex = surface.GetTextureID("gui/gradient_down")

local PANEL = {}

function PANEL:Init()
	XPGUI.Add(self)

	self.startTime = SysTime()

	self:SetSize(ScrW() / 2, ScrH() / 2)
	self:Center()

	self:MakePopup()
	self:RequestFocus()

	self:SetAlpha(0)
	self:AlphaTo(255, 0.4, 0)

	self.Rounded = 6
	self.FrameBlur = true
	self.BackgroundBlur = false

	self.TopDock = vgui.Create("DButton", self)
	self.TopDock:Dock(TOP)
	self.TopDock:SetTall(32)
	self.TopDock:SetText("")

	self.TopDock.Paint = nil
	self.TopDock.Hovered = false

	self.TopDock.DoClick = function()
		self:Close()
	end

	self.TopDock.OnCursorEntered = function(dock)
		dock.Hovered = true
	end

	self.TopDock.OnCursorExited = function(dock)
		dock.Hovered = false
	end

	self.TopDock.CloseGradientAlpha = XPGUI.CloseHoverColor.a
	self.TopDockColor = XPGUI.CloseHoverColor

	self.TopDock.SlideAnim = EasyAnim.NewAnimation(0.5, EASE_OutExpo)
	self.TopDock.SlideAnim.Value = -self.TopDock:GetTall()
	self.TopDock.SlideAnim.SetAnimPrinciple = function(animObject)
		if self.TopDock:IsHovered() then
			animObject:SetDuration(0.5)
			animObject:SetEasing(EASE_OutExpo)
		else
			animObject:SetDuration(0.75)
			animObject:SetEasing(EASE_InExpo)
		end
	end
	self.TopDock.Think = function(dock)
		if dock:IsHovered() then
			self.TopDockColor = XPGUI.CloseHoverColor
			dock.SlideAnim:AnimTo(0)
		else
			self.TopDockColor = XPGUI.CloseColor
			dock.SlideAnim:AnimTo(-dock:GetTall())
		end
		if dock:IsDown() then
			self.TopDockColor = XPGUI.ClosePressColor
		end
	end
end

function PANEL:SetNoRounded(bool)
	self.Rounded = (bool == nil and true or bool) and 0 or 6
end

function PANEL:SetBackgroundBlur(bool)
	self.BackgroundBlur = bool == nil and true or bool
end

function PANEL:SetFrameBlur(bool)
	self.FrameBlur = bool == nil and true or bool
end

function PANEL:Paint(w, h)
	if self.BackgroundBlur then
		Derma_DrawBackgroundBlur(self, self.startTime)
	end

	if not self.FirstInit then -- We need to pre-cache shape for better performance
		self.FirstInit = true
		self.PolyMask = surface.PrecacheRoundedRect(0, 0, self:GetWide(), self:GetTall(), self.Rounded, 16)
	end

	EZMASK.DrawWithMask(function()
		surface.SetDrawColor(color_white)
		surface.DrawPoly(self.PolyMask)
	end, function()
		if self.FrameBlur then
			surface.DrawPanelBlur(self, 6)
		end
		draw.RoundedBox(self.Rounded, 0, 0, w, h, XPGUI.BGColor)

		surface.SetDrawColor(XPGUI.HeaderLineColor)
		surface.DrawLine(8, self.TopDock:GetTall() - 1, w - 8, self.TopDock:GetTall() - 1)
		surface.DrawLine(8, self.TopDock:GetTall(), w - 8, self.TopDock:GetTall())
		surface.SetTexture(gradtex)
		surface.SetDrawColor(ColorAlpha(self.TopDockColor, XPGUI.CloseHoverColor.a * math.abs(self.TopDock.SlideAnim:GetValue() + self.TopDock:GetTall()) / self.TopDock:GetTall()))
		surface.DrawTexturedRect(0, self.TopDock.SlideAnim:GetValue(), w, self.TopDock:GetTall())
	end)
end

function PANEL:SetTitle(text)
	self.Title = vgui.Create("DLabel", self.TopDock)
	self.Title:SetTextColor(color_white)
	self.Title:SetText(text)
	self.Title:SetExpensiveShadow(1, ColorAlpha(color_black, 120))

	self.Title:SetFont("xpgui_big")
	self.Title:SetContentAlignment(4)
	self.Title:SizeToContents()

	self.Title:Dock(TOP)
	self.Title:DockMargin(6, 2, 6, 2)
end

function PANEL:SetBottomButton(title, dock, func)
	if not IsValid(self.BottomDock) then
		self.BottomDock = vgui.Create("EditablePanel", self)
		self.BottomDock:Dock(BOTTOM)
		self.BottomDock:SetTall(47)
	end

	local Button = vgui.Create("XPButton", self.BottomDock)
	Button:SetText(title)
	Button:Dock(dock)
	Button:DockMargin(6, 6, 6, 6)
	Button:SizeToContents()

	Button.DoClick = function(self)
		func(self)
	end

	return Button
end

function PANEL:OnRemove()
	table.RemoveByValue(XPGUI.Opened, self)
end

function PANEL:OnClose()
    -- Use it instead of OnRemove
end

function PANEL:Close()
	self:AlphaTo(0, 0.3, 0, function(_, pan)
		pan:Remove()
	end)
	self:OnClose()
end

derma.DefineControl("XPFrame", "", PANEL, "EditablePanel")