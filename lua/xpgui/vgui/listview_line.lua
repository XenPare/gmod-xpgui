local PANEL = {}

function PANEL:Init()
	self:SetTextInset(5, 0)
	self:SetFont("xpgui_tiny")
end

function PANEL:UpdateColours(skin)
	if self:GetParent():IsLineSelected() then
		return self:SetTextStyleColor(skin.Colours.Label.Bright)
	end
	return self:SetTextStyleColor(skin.Colours.Label.Dark)
end

function PANEL:Think()
	if self:GetParent():IsLineSelected() or self:GetParent():IsHovered() then
		self:SetTextColor(XPGUI.ListViewSelectedTextColor)
	else
		self:SetTextColor(XPGUI.ListViewTextColor)
	end
end

derma.DefineControl("XPListViewLabel", "", PANEL, "DLabel")

--[[
	Line
]]

local PANEL = {}

Derma_Hook(PANEL, "Paint", "Paint", "ListViewLine")
Derma_Hook(PANEL, "ApplySchemeSettings", "Scheme", "ListViewLine")
Derma_Hook(PANEL, "PerformLayout", "Layout", "ListViewLine")

AccessorFunc(PANEL, "m_iID", "ID")
AccessorFunc(PANEL, "m_pListView", "ListView")
AccessorFunc(PANEL, "m_bAlt", "AltLine")

function PANEL:Init()
	self:SetSelectable(true)
	self:SetMouseInputEnabled(true)

	self:SetTooltipPanelOverride("XPTooltip")

	self.Columns = {}
	self.Data = {}

	self.Color = XPGUI.ListViewLineColor
end

function PANEL:Paint(w,h)
	if self:IsHovered() then
		self.Color = LerpColor(10 * FrameTime(), self.Color, self:IsLineSelected() and XPGUI.ListViewLineSelectedHoverColor or XPGUI.ListViewLineHoverColor)
		draw.RoundedBox(4, 0, 0, w, h, self.Color)
	elseif self:IsLineSelected() then
		self.Color = LerpColor(10 * FrameTime(), self.Color, XPGUI.ListViewLineSelectedColor)
		draw.NoRoundedBox(0, 0, w, h, self.Color)
	end
end

function PANEL:OnSelect() end
function PANEL:OnRightClick() end

function PANEL:OnMousePressed(mcode)
	if mcode == MOUSE_RIGHT then
		if not self:IsLineSelected() then
			self:GetListView():OnClickLine(self, true)
			self:OnSelect()
		end

		self:GetListView():OnRowRightClick(self:GetID(), self)
		self:OnRightClick()
		return
	end

	self:GetListView():OnClickLine(self, true)
	self:OnSelect()
end

function PANEL:OnCursorMoved()
	if input.IsMouseDown(MOUSE_LEFT) then
		self:GetListView():OnClickLine(self)
	end
end

function PANEL:SetSelected(b)
	self.m_bSelected = b
	for id, column in pairs(self.Columns) do
		column:ApplySchemeSettings()
	end
end

function PANEL:IsLineSelected()
	return self.m_bSelected
end

function PANEL:SetColumnText(i, strText)
	if type(strText) == "Panel" then
		if IsValid(self.Columns[i]) then
			self.Columns[i]:Remove()
		end

		strText:SetParent(self)
		self.Columns[i] = strText
		self.Columns[i].Value = strText
		return
	end

	if not IsValid(self.Columns[i]) then
		self.Columns[i] = vgui.Create("XPListViewLabel", self)
		self.Columns[i].IsHovered = self.IsHovered
		self.Columns[i]:SetMouseInputEnabled(false)
	end

	self.Columns[i]:SetText(tostring(strText))
	self.Columns[i].Value = strText

	return self.Columns[i]
end
PANEL.SetValue = PANEL.SetColumnText

function PANEL:GetColumnText(i)
	if not self.Columns[i] then
		return ""
	end
	return self.Columns[i].Value
end
PANEL.GetValue = PANEL.GetColumnText

function PANEL:SetSortValue(i, data)
	self.Data[i] = data
end

function PANEL:GetSortValue(i)
	return self.Data[i]
end

function PANEL:DataLayout(ListView)
	self:ApplySchemeSettings()

	local height, x = self:GetTall(), 0
	for k, Column in pairs(self.Columns) do
		local w = ListView:ColumnWidth(k)
		Column:SetPos(x, 0)
		Column:SetSize(w, height)
		x = x + w
	end
end

derma.DefineControl("XPListViewLine", "", PANEL, "Panel")
derma.DefineControl("XPListView_Line", "", PANEL, "Panel")