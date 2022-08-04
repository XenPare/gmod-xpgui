local PANEL = {}

local tex_corner8 = surface.GetTextureID("gui/corner8")
local CT, FT

local function drawLine(x,y,w)
	surface.DrawLine(x, y - 1, x + w, y - 1)
	surface.DrawLine(x - 1, y, x + w + 1, y)
	surface.DrawLine(x, y + 1, x + w, y + 1)
end

function PANEL:Init()
	if self.DropButton then
		self.DropButton:Remove()
	end

	CT = SysTime()
	self.OpenAnimStartTime = SysTime()
	self.OpenBarScale = 0
	self.OpenBarColor = XPGUI.ComboBoxOpenBarColor

	self.DropButton = vgui.Create("DPanel", self)

	self:SetTall(21)

	self.DropButton.Paint = function(panel, w, h)
		CT = SysTime()
		if self:IsMenuOpen() then
			if self.OpenAnimStartTime > 0 and CT > self.OpenAnimStartTime + 0.2 then
				self.OpenAnimStartTime = -1
			end

			if self.OpenAnimStartTime > 0 and CT < self.OpenAnimStartTime + 0.2 then
				self.OpenBarScale = 6 / 0.2 * (CT - self.OpenAnimStartTime)
			end

			self.OpenBarColor = LerpColor(2.5 * FrameTime(), self.OpenBarColor, self:GetSelectedID() and XPGUI.ComboBoxOpenBarChosenColor or XPGUI.ComboBoxOpenBarOpenedColor)
		else
			if self.OpenAnimStartTime < 0 and not self:GetSelectedID() then
				self.OpenAnimStartTime = CT
			end

			if self.OpenAnimStartTime > 0 and CT < self.OpenAnimStartTime + 0.2 and not self:GetSelectedID() then
				self.OpenBarScale = 6 - 6 / 0.2 * (CT - self.OpenAnimStartTime)
			end

			self.OpenBarColor = LerpColor(2.5 * FrameTime(), self.OpenBarColor, self:GetSelectedID() and XPGUI.ComboBoxOpenBarChosenColor or XPGUI.ComboBoxOpenBarColor)
		end

		surface.SetDrawColor(self.OpenBarColor)

		drawLine(4, h * 0.5, 12)
		if self.OpenBarScale > 0 then
			drawLine(4, h * 0.5 - self.OpenBarScale, 12)
			drawLine(4, h * 0.5 + self.OpenBarScale, 12)
		end

	end

	self.DropButton:SetMouseInputEnabled(false)
	self.DropButton.ComboBox = self

	self.FGColor = XPGUI.BGColor
	self.FGColor = Color(255 - self.FGColor.r, 255 - self.FGColor.g, 255 - self.FGColor.b, 25)
	self.FGLineColor = XPGUI.ComboBoxFGLineColor

	self:SetFont("xpgui_tiny")
	self:SetTextColor(color_white)

	self:SetTooltipPanelOverride("XPTooltip")
end

function PANEL:PerformLayout()
	self.DropButton:SetSize(self:GetTall(), self:GetTall())
	self.DropButton:AlignRight(0)
	self.DropButton:CenterVertical()
end

function PANEL:DoClickInternal()
	if not self:GetSelectedID() then
		self.OpenAnimStartTime = CT
	end
end

function PANEL:Paint(w, h)
	if self:IsHovered() or self:IsMenuOpen() then
		self.FGColor.a = Lerp(7.5 * FrameTime(), self.FGColor.a, 35)
		self.FGLineColor.a = Lerp(7.5 * FrameTime(), self.FGLineColor.a, 100)
	else
		self.FGColor.a = Lerp(7.5 * FrameTime(), self.FGColor.a, 25)
		self.FGLineColor.a = Lerp(7.5 * FrameTime(), self.FGLineColor.a, 10)
	end

	if self:IsDown() then
		self.FGColor.a = Lerp(7.5 * FrameTime(),self.FGColor.a, 75)
	end

	draw.RoundedBox(6, 0, 0, w, h, self.FGColor) -- bg

	draw.NoTexture()
	surface.SetDrawColor(self.FGLineColor)
	surface.DrawLine(self.DropButton:GetPos() - 1, 0, self.DropButton:GetPos() - 1, h)
end

function PANEL:OpenMenu(pControlOpener)
	if pControlOpener and pControlOpener == self.TextEntry then
		return
	end

	if #self.Choices == 0 then
		return
	end

	if IsValid(self.Menu) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = vgui.Create("XPMenu", self)

	if self:GetSortItems() then
		local sorted = {}
		for k, v in pairs(self.Choices) do
			local val = tostring(v)
			if string.len(val) > 1 and not tonumber(val) and val:StartWith("#") then
				val = language.GetPhrase(val:sub(2))
			end

			table.insert(sorted, {
				id = k,
				data = v,
				label = val
			})
		end

		for _, v in SortedPairsByMemberValue(sorted, "label") do
			local option = self.Menu:AddOption(v.data, function()
				self:ChooseOption(v.data, v.id)
			end)
			if self.ChoiceIcons[v.id] then
				option:SetIcon(self.ChoiceIcons[v.id])
			end
		end
	else
		for k, v in pairs(self.Choices) do
			local option = self.Menu:AddOption(v, function()
				self:ChooseOption(v, k)
			end)
			if self.ChoiceIcons[k] then
				option:SetIcon(self.ChoiceIcons[k])
			end
		end
	end

	local x, y = self:LocalToScreen(0, self:GetTall())
	self.Menu:SetMinimumWidth(self:GetWide())
	self.Menu:Open(x, y, false, self)
end

function PANEL:OnCursorEntered(val)
	XPGUI.PlaySound(XPGUI.ButtonHoverSound)
end

function PANEL:OnDepressed()
	XPGUI.PlaySound(XPGUI.ButtonClickSound)
end

derma.DefineControl("XPComboBox", "", PANEL, "DComboBox")