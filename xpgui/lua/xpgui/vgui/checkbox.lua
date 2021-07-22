local PANEL = {}

function PANEL:Init()
	self:SetSize(16, 16)
	self:SetText("")
	self:SetTooltipPanelOverride("XPTooltip")

	self.CheckedColorAlpha = 0
	self.CheckBGColorAlpha = 75

	self.CheckPos_xy = 0
	self.CheckSize = 8
	self.CheckRound = 6

	self.Color = XPGUI.BGColor
	self.Color = Color(255 - self.Color.r, 255 - self.Color.g, 255 - self.Color.b, 25)

	self.CheckAnim = EasyAnim.NewAnimation(0.5, EASE_OutExpo)
end

function PANEL:Paint(w, h)
	local FT = FrameTime()
	if self:IsHovered() then
		self.Color.a = Lerp(FT * 7.5, self.Color.a , 35)
	else
		self.Color.a = Lerp(FT * 7.5, self.Color.a , 25)
	end

	if self:IsDown() then
		if self:GetChecked() then
			self.CheckedColorAlpha = Lerp(FT * 5, self.CheckedColorAlpha, 100)
		else
			self.CheckedColorAlpha = Lerp(FT * 5, self.CheckedColorAlpha, 100)
			self.CheckSize = self.CheckAnim:AnimTo(w*0.5)
		end
		self.Color.a = Lerp(FT * 7.5, self.Color.a , 75)
	else
		if self:GetChecked() then
			self.CheckedColorAlpha = Lerp(FT * 5, self.CheckedColorAlpha, 255)
			self.CheckSize = self.CheckAnim:AnimTo(w)
			self.CheckRound = Lerp(FT * 7.5, self.CheckRound, 4)
		else
			self.CheckedColorAlpha = Lerp(FT * 5, self.CheckedColorAlpha, 0)
			self.CheckSize = self.CheckAnim:AnimTo(0)
			self.CheckRound = Lerp(FT * 7.5, self.CheckRound, 12)
		end
	end
	self.CheckSize = math.ceil(self.CheckSize)
	self.CheckPos_xy = (w - self.CheckSize) * 0.5
	draw.RoundedBox(4, 0, 0, w, h, self.Color) -- bg
	draw.RoundedBox(self.CheckRound, self.CheckPos_xy, self.CheckPos_xy, self.CheckSize, self.CheckSize, ColorAlpha(XPGUI.CheckBoxCheckColor, self.CheckedColorAlpha))
end

function PANEL:OnCursorEntered(val)
	XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav")
end

function PANEL:OnChange(val)
	if val then
		XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_select_01.wav")
	end
end

vgui.Register("XPCheckBox", PANEL, "DCheckBox")

-- CheckBoxLabel
-- submenu_dropdown_select_01.wav

PANEL = {}

function PANEL:Init()
	self:SetTall(16)

	if self.Button then 
		self.Button:Remove() 
	end

	self.Button = vgui.Create("XPCheckBox", self)
	self.Button.OnChange = function(_, val) 
		self:OnChange(val) 
	end

	if self.Label then
		self.Label:SetFont("xpgui_tiny")
		self.Label:SetTextColor(color_white)

		function self.Label:OnCursorEntered()
			if self:GetDisabled() then
				return
			end
		
			XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_rollover_01.wav")
		end
	end
end

function PANEL:OnChange(val)
	if val then
		XPGUI.PlaySound("xpgui/submenu/submenu_dropdown_select_01.wav")
	end
end

function PANEL:PerformLayout()
	local x = self.m_iIndent || 0

	self.Button:SetSize(16, 16)
	self.Button:SetPos(x, math.floor((self:GetTall() - self.Button:GetTall() ) / 2))

	self.Label:SizeToContents()
	self.Label:SetPos(x + self.Button:GetWide() + 9, 0)
end

vgui.Register("XPCheckBoxLabel", PANEL, "DCheckBoxLabel")