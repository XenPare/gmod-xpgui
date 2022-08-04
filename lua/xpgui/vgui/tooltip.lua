local PANEL = {}

function PANEL:Init()
	self:SetDrawOnTop(true)
	self.DeleteContentsOnClose = false

	self:SetText("")
	self:SetFont("xpgui_small")
	self:SetExpensiveShadow(1, ColorAlpha(color_black, 170))
end

function PANEL:UpdateColours()
	return self:SetTextStyleColor(color_white)
end

function PANEL:SetContents(panel, bDelete)
	panel:SetParent(self)

	self.Contents = panel
	self.DeleteContentsOnClose = bDelete or false
	self.Contents:SizeToContents()
	self:InvalidateLayout(true)

	self.Contents:SetVisible(false)
end

function PANEL:PerformLayout()
	if IsValid(self.Contents) then
		self:SetWide(self.Contents:GetWide() + 8)
		self:SetTall(self.Contents:GetTall() + 8)
		self.Contents:SetPos(4, 4)
		self.Contents:SetVisible(true)
	else
		local w, h = self:GetContentSize()
		self:SetSize(w + 10, h + 8)
		self:SetContentAlignment(5)

		if self:GetText() == "" then
			self:SetVisible(false)
		else
			self:SetVisible(true)
		end
	end
end

local Mat = Material("vgui/arrow")
function PANEL:DrawArrow(x, y)
	self.Contents:SetVisible(true)
	surface.SetMaterial(Mat)
	surface.DrawTexturedRect(self.ArrowPosX + x, self.ArrowPosY + y, self.ArrowWide, self.ArrowTall)
end

function PANEL:PositionTooltip()
	if not IsValid(self.TargetPanel) then
		self:Remove()
		return
	end

	self:PerformLayout()

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()

	local lx, ly = self.TargetPanel:LocalToScreen(0, 0)

	y = y - 50
	y = math.min(y, ly - h * 1.5)
	if y < 2 then
		y = 2
	end

	self:SetPos(math.Clamp(x - w * 0.5, 0, ScrW() - self:GetWide()) + 10, math.Clamp(y, 0, ScrH() - self:GetTall()) + self:GetTall() / 2)
end

function PANEL:Paint(w, h)
	self:PositionTooltip()

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

	draw.RoundedBox(6, 0, 0, w, h, XPGUI.BGColor)
end

function PANEL:OpenForPanel(panel)
	self.TargetPanel = panel
	self:PositionTooltip()

	local cooldown = 0.25
	if cooldown > 0 then
		self:SetVisible(false)
		timer.Simple(cooldown, function()
			if not IsValid(self) or not IsValid(panel) then
				return
			end
			self:PositionTooltip()
			self:SetVisible(true)
		end)
	end
end

function PANEL:Close()
	if not self.DeleteContentsOnClose and IsValid(self.Contents) then
		self.Contents:SetVisible(false)
		self.Contents:SetParent(nil)
	end
	self:Remove()
end

derma.DefineControl("XPTooltip", "", PANEL, "DLabel")