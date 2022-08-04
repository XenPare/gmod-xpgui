--[[
	Column
]]

local PANEL = {}

AccessorFunc(PANEL, "m_iMinWidth", "MinWidth")
AccessorFunc(PANEL, "m_iMaxWidth", "MaxWidth")

AccessorFunc(PANEL, "m_iTextAlign", "TextAlign")

AccessorFunc(PANEL, "m_bFixedWidth", "FixedWidth")
AccessorFunc(PANEL, "m_bDesc", "Descending")
AccessorFunc(PANEL, "m_iColumnID", "ColumnID")

Derma_Hook(PANEL, "Paint", "Paint", "ListViewColumn")
Derma_Hook(PANEL, "ApplySchemeSettings", "Scheme", "ListViewColumn")
Derma_Hook(PANEL, "PerformLayout", "Layout", "ListViewColumn")

function PANEL:Init()
	self.Header = vgui.Create("XPButton", self)

	local id = 0
	self.Header.Paint = function(pan, w, h)
		id = self:GetColumnID()
		if pan:IsHovered() then
			pan.Color.a = Lerp(7.5 * FrameTime(), pan.Color.a, 35)
		else
			pan.Color.a = Lerp(7.5 * FrameTime(), pan.Color.a, 25)
		end

		if pan:IsDown() then
			pan.Color.a = Lerp(7.5 * FrameTime(), pan.Color.a, 75)
		end

		draw.RoundedBoxEx(6, 0, 0, w - (id < #self:GetParent().Columns and 1 or 0), h, pan.Color, not (id > 1), not (id < #self:GetParent().Columns), false, false)
	end

	self.Header:SetFont("xpgui_extratiny")

	self.Header.DoClick = function()
		self:DoClick()
	end

	self.Header.DoRightClick = function()
		self:DoRightClick()
	end

	self.DraggerBar = vgui.Create("DListView_DraggerBar", self)

	self:SetMinWidth(10)
	self:SetMaxWidth(19200)
end

function PANEL:SetFixedWidth(i)
	self:SetMinWidth(i)
	self:SetMaxWidth(i)
end

function PANEL:DoClick()
	self:GetParent():SortByColumn(self:GetColumnID(), self:GetDescending())
	self:SetDescending(not self:GetDescending())
end

function PANEL:DoRightClick() end

function PANEL:SetName(strName)
	self.Header:SetText(strName)
end

function PANEL:Paint()
	return true
end

function PANEL:PerformLayout()
	if self:GetTextAlign() then
		self.Header:SetContentAlignment(self:GetTextAlign())
	end

	self.Header:SetPos(0, 0)
	self.Header:SetSize(self:GetWide(), self:GetParent():GetHeaderHeight())

	self.DraggerBar:SetWide(4)
	self.DraggerBar:StretchToParent(nil, 0, nil, 0)
	self.DraggerBar:AlignRight()
end

function PANEL:ResizeColumn(iSize)
	self:GetParent():OnRequestResize(self, iSize)
end

function PANEL:SetWidth(iSize)
	iSize = math.Clamp(iSize, self:GetMinWidth(), math.max(self:GetMaxWidth(), 0))
	if math.floor(iSize) ~= self:GetWide() then
		self:GetParent():SetDirty(true)
	end

	self:SetWide(iSize)
	return iSize
end

derma.DefineControl("XPListView_Column", "", PANEL, "Panel")

--[[
	Column Plain
]]

local PANEL = {}

function PANEL:DoClick() end

derma.DefineControl("XPListView_ColumnPlain", "", PANEL, "DListView_Column")