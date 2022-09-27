local PANEL = {}

AccessorFunc(PANEL, "m_bDirty", "Dirty", FORCE_BOOL)
AccessorFunc(PANEL, "m_bSortable", "Sortable", FORCE_BOOL)

AccessorFunc(PANEL, "m_iHeaderHeight", "HeaderHeight")
AccessorFunc(PANEL, "m_iDataHeight", "DataHeight")

AccessorFunc(PANEL, "m_bMultiSelect", "MultiSelect")
AccessorFunc(PANEL, "m_bHideHeaders", "HideHeaders")

function PANEL:Init()
	self:SetSortable(true)
	self:SetMouseInputEnabled(true)
	self:SetMultiSelect(true)
	self:SetHideHeaders(false)

	self:SetPaintBackground(true)
	self:SetHeaderHeight(16)
	self:SetDataHeight(17)

	self.Columns = {}

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty(true)

	self.pnlCanvasCanvas = vgui.Create("EditablePanel", self)
	self.pnlCanvasCanvas:SetPos(0, self:GetHeaderHeight())

	self.pnlCanvas = vgui.Create("EditablePanel", self.pnlCanvasCanvas)

	self.VBar = vgui.Create("XPScrollBar", self)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(6, 0, 0, w - 19, h, XPGUI.BGColor)
end

function PANEL:DisableScrollbar()
	if IsValid(self.VBar) then
		self.VBar:Remove()
	end
	self.VBar = nil
end

function PANEL:GetLines()
	return self.Lines
end

function PANEL:GetInnerTall()
	return self:GetCanvas():GetTall()
end

function PANEL:GetCanvas()
	return self.pnlCanvas
end

function PANEL:AddColumn(strName, iPosition)
	local pColumn = nil

	if self.m_bSortable then
		pColumn = vgui.Create("XPListView_Column", self)
	else
		pColumn = vgui.Create("XPListView_ColumnPlain", self)
	end

	pColumn:SetName(strName)
	pColumn:SetZPos(10)

	if iPosition then
		table.insert(self.Columns, iPosition, pColumn)
		for i = 1, #self.Columns do
			self.Columns[i]:SetColumnID(i)
		end
	else
		local ID = table.insert(self.Columns, pColumn)
		pColumn:SetColumnID(ID)
	end

	self:InvalidateLayout()

	return pColumn
end

function PANEL:RemoveLine(lineID)
	local line = self:GetLine(lineID)
	local selectedID = self:GetSortedID(lineID)

	self.Lines[lineID] = nil
	table.remove(self.Sorted, selectedID)

	self:SetDirty(true)
	self:InvalidateLayout()

	line:Remove()
end

function PANEL:ColumnWidth(i)
	local ctrl = self.Columns[i]
	if not ctrl then
		return 0
	end
	return ctrl:GetWide()
end

function PANEL:FixColumnsLayout()
	local numColumns = #self.Columns
	if numColumns == 0 then
		return
	end

	local allWidth = 0
	for _, column in pairs(self.Columns) do
		allWidth = allWidth + column:GetWide()
	end

	local changeRequired = self.pnlCanvas:GetWide() - allWidth
	local changePerColumn = math.floor(changeRequired / numColumns)
	local remainder = changeRequired - (changePerColumn * numColumns)

	for k, Column in pairs(self.Columns) do
		local TargetWidth = Column:GetWide() + changePerColumn
		remainder = remainder + (TargetWidth - Column:SetWidth(TargetWidth))
	end

	local totalMaxWidth = 0
	while remainder ~= 0 do
		local perPanel = math.floor(remainder / numColumns)
		for _, column in pairs(self.Columns) do
			remainder = math.Approach(remainder, 0, perPanel)

			local TargetWidth = column:GetWide() + perPanel
			remainder = remainder + (TargetWidth - column:SetWidth(TargetWidth))
			if remainder == 0 then
				break
			end

			totalMaxWidth = totalMaxWidth + column:GetMaxWidth()
		end

		if totalMaxWidth < self.pnlCanvas:GetWide() then
			break
		end

		remainder = math.Approach(remainder, 0, 1)
	end

	local x = 0
	for _, column in pairs(self.Columns) do
		column.x = x
		x = x + column:GetWide()

		column:SetTall(self:GetHeaderHeight())
		column:SetVisible(not self:GetHideHeaders())
	end
end

function PANEL:PerformLayout()
	self.pnlCanvasCanvas:SetSize(self:GetWide() - 19, self:GetTall() - self:GetHeaderHeight())

	local wide = self:GetWide()
	local yPos = 0

	if IsValid(self.VBar) then
		self.VBar:SetPos(self:GetWide() - 16, 0)
		self.VBar:SetSize(16, self:GetTall())
		self.VBar:SetUp(self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall())
		yPos = self.VBar:GetOffset()

		if self.VBar.Enabled then
			wide = wide - 19
		end
	end

	if self.m_bHideHeaders then
		self.pnlCanvas:SetPos(0, yPos)
	else
		self.pnlCanvas:SetPos(0, yPos)
	end

	self.pnlCanvas:SetSize(wide, self.pnlCanvas:GetTall())

	self:FixColumnsLayout()

	if self:GetDirty() then
		self:SetDirty(false)

		local y = self:DataLayout()
		self.pnlCanvas:SetTall(y)
		self:InvalidateLayout(true)
	end
end

function PANEL:OnScrollbarAppear()
	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:OnRequestResize(sizingColumn, iSize)
	local passed = false
	local rightColumn = nil
	for _, column in ipairs(self.Columns) do
		if passed then
			rightColumn = column
			break
		end

		if sizingColumn == column then
			passed = true
		end
	end

	if rightColumn then
		local SizeChange = sizingColumn:GetWide() - iSize
		rightColumn:SetWide(rightColumn:GetWide() + SizeChange)
	end

	sizingColumn:SetWide(iSize)
	self:SetDirty(true)

	self:InvalidateLayout()
end

function PANEL:DataLayout()
	local y, h = 0, self.m_iDataHeight
	for k, line in ipairs(self.Sorted) do
		line:SetPos(1, y)
		line:SetSize(self.pnlCanvas:GetWide() - 2, h)
		line:DataLayout(self)
		line:SetAltLine(k % 2 == 1)

		y = y + line:GetTall()
	end
	return y
end

function PANEL:AddLine(...)
	self:SetDirty(true)
	self:InvalidateLayout()

	local line = vgui.Create("XPListView_Line", self.pnlCanvas)
	local id = table.insert(self.Lines, line)

	line:SetListView(self)
	line:SetID(id)

	for k in pairs(self.Columns) do
		line:SetColumnText(k, "")
	end

	for k, v in pairs({...}) do
		line:SetColumnText(k, v)
	end

	local sortID = table.insert(self.Sorted, line)
	if sortID % 2 == 1 then
		line:SetAltLine(true)
	end

	return line
end

function PANEL:OnMouseWheeled(dlta)
	if not IsValid(self.VBar) then
		return
	end
	return self.VBar:OnMouseWheeled(dlta)
end

function PANEL:ClearSelection(dlta)
	for _, line in pairs(self.Lines) do
		line:SetSelected(false)
	end
end

function PANEL:GetSelectedLine()
	for k, line in pairs(self.Lines) do
		if line:IsSelected() then
			return k, line
		end
	end
end

function PANEL:GetLine(id)
	return self.Lines[id]
end

function PANEL:GetSortedID(line)
	for k, v in pairs(self.Sorted) do
		if v:GetID() == line then
			return k
		end
	end
end

function PANEL:OnClickLine(line, bClear)
	local bMultiSelect = self:GetMultiSelect()
	if not bMultiSelect and not bClear then
		return
	end

	if bMultiSelect and input.IsKeyDown(KEY_LCONTROL) then
		bClear = false
	end

	if bMultiSelect and input.IsKeyDown(KEY_LSHIFT) then
		local selected = self:GetSortedID(self:GetSelectedLine())
		if selected then
			local lineID = self:GetSortedID(line:GetID())

			local first = math.min(selected, lineID)
			local last = math.max(selected, lineID)

			for id = first, last do
				local line = self.Sorted[id]
				if not line:IsLineSelected() then
					self:OnRowSelected(line:GetID(), line)
				end
				line:SetSelected(true)
			end

			if bClear then
				self:ClearSelection()
			end

			for id = first, last do
				local line = self.Sorted[id]
				line:SetSelected(true)
			end

			return
		end
	end

	if line:IsSelected() and line.m_fClickTime and (not bMultiSelect or bClear) then
		local fTimeDistance = SysTime() - line.m_fClickTime
		if fTimeDistance < 0.3 then
			self:DoDoubleClick(line:GetID(), line)
			return
		end
	end

	if not bMultiSelect or bClear then
		self:ClearSelection()
	end

	if line:IsSelected() then
		return
	end

	line:SetSelected(true)
	line.m_fClickTime = SysTime()

	self:OnRowSelected(line:GetID(), line)
end

function PANEL:SortByColumns(c1, d1, c2, d2, c3, d3, c4, d4)
	table.Copy(self.Sorted, self.Lines)

	table.sort(self.Sorted, function(a, b)
		if not IsValid(a) or not IsValid(b) then
			return true
		end

		if c1 and a:GetColumnText(c1) ~= b:GetColumnText(c1) then
			if d1 then
				a, b = b, a
			end
			return a:GetColumnText(c1) < b:GetColumnText(c1)
		end

		if c2 and a:GetColumnText(c2) ~= b:GetColumnText(c2) then
			if d2 then
				a, b = b, a
			end
			return a:GetColumnText(c2) < b:GetColumnText(c2)
		end

		if c3 and a:GetColumnText(c3) ~= b:GetColumnText(c3) then
			if d3 then
				a, b = b, a
			end
			return a:GetColumnText(c3) < b:GetColumnText(c3)
		end

		if c4 and a:GetColumnText(c4) ~= b:GetColumnText(c4) then
			if d4 then
				a, b = b, a
			end
			return a:GetColumnText(c4) < b:GetColumnText(c4)
		end

		return true
	end)

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:SortByColumn(columnID, desc)
	table.Copy(self.Sorted, self.Lines)

	table.sort(self.Sorted, function(a, b)
		if desc then
			a, b = b, a
		end

		local aval = a:GetSortValue(columnID) or a:GetColumnText(columnID)
		local bval = b:GetSortValue(columnID) or b:GetColumnText(columnID)

		return aval < bval
	end)

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:SelectItem(item)
	if not item then
		return
	end

	item:SetSelected(true)
	self:OnRowSelected(item:GetID(), item)
end

function PANEL:SelectFirstItem()
	self:ClearSelection()
	self:SelectItem(self.Sorted[1])
end

function PANEL:DoDoubleClick(lineID, line) end
function PANEL:OnRowSelected(lineID, line) end
function PANEL:OnRowRightClick(lineID, line) end

function PANEL:Clear()
	for _, v in pairs(self.Lines) do
		v:Remove()
	end

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty(true)
end

function PANEL:GetSelected()
	local ret = {}
	for _, v in pairs(self.Lines) do
		if v:IsLineSelected() then
			table.insert(ret, v)
		end
	end
	return ret
end

function PANEL:SizeToContents()
	self:SetHeight(self.pnlCanvas:GetTall() + self:GetHeaderHeight())
end

derma.DefineControl("XPListView", "", PANEL, "DPanel")