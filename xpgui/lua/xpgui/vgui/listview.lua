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

function PANEL:RemoveLine(LineID)
	local Line = self:GetLine(LineID)
	local SelectedID = self:GetSortedID(LineID)

	self.Lines[LineID] = nil
	table.remove(self.Sorted, SelectedID)

	self:SetDirty(true)
	self:InvalidateLayout()

	Line:Remove()
end

function PANEL:ColumnWidth(i)
	local ctrl = self.Columns[i]
	if not ctrl then 
		return 0 
	end
	return ctrl:GetWide()
end

function PANEL:FixColumnsLayout()
	local NumColumns = #self.Columns
	if NumColumns == 0 then 
		return 
	end

	local AllWidth = 0
	for k, Column in pairs(self.Columns) do
		AllWidth = AllWidth + Column:GetWide()
	end

	local ChangeRequired = self.pnlCanvas:GetWide() - AllWidth
	local ChangePerColumn = math.floor(ChangeRequired / NumColumns)
	local Remainder = ChangeRequired - (ChangePerColumn * NumColumns)

	for k, Column in pairs(self.Columns) do
		local TargetWidth = Column:GetWide() + ChangePerColumn
		Remainder = Remainder + (TargetWidth - Column:SetWidth(TargetWidth))
	end

	local TotalMaxWidth = 0
	while (Remainder ~= 0) do
		local PerPanel = math.floor(Remainder / NumColumns)
		for k, Column in pairs(self.Columns) do
			Remainder = math.Approach(Remainder, 0, PerPanel)

			local TargetWidth = Column:GetWide() + PerPanel
			Remainder = Remainder + (TargetWidth - Column:SetWidth(TargetWidth))

			if Remainder == 0 then 
				break 
			end

			TotalMaxWidth = TotalMaxWidth + Column:GetMaxWidth()
		end

		if TotalMaxWidth < self.pnlCanvas:GetWide() then 
			break 
		end

		Remainder = math.Approach(Remainder, 0, 1)
	end

	local x = 0
	for k, Column in pairs(self.Columns) do
		Column.x = x
		x = x + Column:GetWide()

		Column:SetTall(self:GetHeaderHeight())
		Column:SetVisible(!self:GetHideHeaders())
	end
end

function PANEL:PerformLayout()
	self.pnlCanvasCanvas:SetSize(self:GetWide() - 19, self:GetTall() - self:GetHeaderHeight())

	local Wide = self:GetWide()
	local YPos = 0

	if IsValid(self.VBar) then
		self.VBar:SetPos(self:GetWide() - 16, 0)
		self.VBar:SetSize(16, self:GetTall())
		self.VBar:SetUp(self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall())
		YPos = self.VBar:GetOffset()

		if self.VBar.Enabled then 
			Wide = Wide - 19 
		end
	end

	if (self.m_bHideHeaders) then
		self.pnlCanvas:SetPos(0, YPos)
	else
		self.pnlCanvas:SetPos(0, YPos)
	end

	self.pnlCanvas:SetSize(Wide, self.pnlCanvas:GetTall())

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

function PANEL:OnRequestResize(SizingColumn, iSize)
	local Passed = false
	local RightColumn = nil
	for k, Column in ipairs(self.Columns) do
		if (Passed) then
			RightColumn = Column
			break
		end

		if (SizingColumn == Column) then 
			Passed = true 
		end
	end

	if RightColumn then
		local SizeChange = SizingColumn:GetWide() - iSize
		RightColumn:SetWide(RightColumn:GetWide() + SizeChange)
	end

	SizingColumn:SetWide(iSize)
	self:SetDirty(true)

	self:InvalidateLayout()
end

function PANEL:DataLayout()
	local y, h = 0, self.m_iDataHeight
	for k, Line in ipairs(self.Sorted) do
		Line:SetPos(1, y)
		Line:SetSize(self.pnlCanvas:GetWide()-2, h)
		Line:DataLayout(self)

		Line:SetAltLine(k % 2 == 1)

		y = y + Line:GetTall()
	end
	return y
end

function PANEL:AddLine(...)
	self:SetDirty(true)
	self:InvalidateLayout()

	local Line = vgui.Create("XPListView_Line", self.pnlCanvas)
	local ID = table.insert(self.Lines, Line)

	Line:SetListView(self)
	Line:SetID(ID)

	for k, v in pairs(self.Columns) do
		Line:SetColumnText(k, "")
	end

	for k, v in pairs({...}) do
		Line:SetColumnText(k, v)
	end

	local SortID = table.insert(self.Sorted, Line)

	if SortID % 2 == 1 then
		Line:SetAltLine(true)
	end

	return Line
end

function PANEL:OnMouseWheeled(dlta)
	if (!IsValid(self.VBar)) then 
		return 
	end
	return self.VBar:OnMouseWheeled(dlta)
end

function PANEL:ClearSelection(dlta)
	for k, Line in pairs(self.Lines) do
		Line:SetSelected(false)
	end
end

function PANEL:GetSelectedLine()
	for k, Line in pairs(self.Lines) do
		if (Line:IsSelected()) then 
			return k, Line 
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

function PANEL:OnClickLine(Line, bClear)
	local bMultiSelect = self:GetMultiSelect()
	if not bMultiSelect && not bClear then 
		return 
	end

	if (bMultiSelect && input.IsKeyDown(KEY_LCONTROL)) then
		bClear = false
	end

	if (bMultiSelect && input.IsKeyDown(KEY_LSHIFT)) then
		local Selected = self:GetSortedID(self:GetSelectedLine())
		if Selected then
			local LineID = self:GetSortedID(Line:GetID())

			local First = math.min(Selected, LineID)
			local Last = math.max(Selected, LineID)

			for id = First, Last do
				local line = self.Sorted[id]
				if (!line:IsLineSelected()) then 
					self:OnRowSelected(line:GetID(), line) 
				end
				line:SetSelected(true)
			end

			if bClear then 
				self:ClearSelection() 
			end

			for id = First, Last do
				local line = self.Sorted[id]
				line:SetSelected(true)
			end

			return
		end
	end

	if Line:IsSelected() && Line.m_fClickTime && (!bMultiSelect || bClear) then
		local fTimeDistance = SysTime() - Line.m_fClickTime
		if fTimeDistance < 0.3 then
			self:DoDoubleClick(Line:GetID(), Line)
			return
		end
	end

	if not bMultiSelect || bClear then
		self:ClearSelection()
	end

	if Line:IsSelected() then 
		return 
	end

	Line:SetSelected(true)
	Line.m_fClickTime = SysTime()

	self:OnRowSelected(Line:GetID(), Line)
end

function PANEL:SortByColumns(c1, d1, c2, d2, c3, d3, c4, d4)
	table.Copy(self.Sorted, self.Lines)

	table.sort(self.Sorted, function(a, b)
		if not IsValid(a) then
			return true 
		end

		if not IsValid(b) then
			return false
		end

		if c1 && a:GetColumnText(c1) ~= b:GetColumnText(c1) then
			if d1 then 
				a, b = b, a 
			end
			return a:GetColumnText(c1) < b:GetColumnText(c1)
		end

		if c2 && a:GetColumnText(c2) ~= b:GetColumnText(c2) then
			if d2 then 
				a, b = b, a 
			end
			return a:GetColumnText(c2) < b:GetColumnText(c2)
		end

		if c3 && a:GetColumnText(c3) ~= b:GetColumnText(c3) then
			if d3 then 
				a, b = b, a 
			end
			return a:GetColumnText(c3) < b:GetColumnText(c3)
		end

		if c4 && a:GetColumnText(c4) ~= b:GetColumnText(c4) then
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

function PANEL:SortByColumn(ColumnID, Desc)
	table.Copy(self.Sorted, self.Lines)

	table.sort(self.Sorted, function(a, b)
		if Desc then
			a, b = b, a
		end

		local aval = a:GetSortValue(ColumnID) || a:GetColumnText(ColumnID)
		local bval = b:GetSortValue(ColumnID) || b:GetColumnText(ColumnID)

		return aval < bval
	end)

	self:SetDirty(true)
	self:InvalidateLayout()
end

function PANEL:SelectItem(Item)
	if not Item then 
		return 
	end

	Item:SetSelected(true)
	self:OnRowSelected(Item:GetID(), Item)
end

function PANEL:SelectFirstItem()
	self:ClearSelection()
	self:SelectItem(self.Sorted[1])
end

function PANEL:DoDoubleClick(LineID, Line)
	-- For Override
end

function PANEL:OnRowSelected(LineID, Line)
	-- For Override
end

function PANEL:OnRowRightClick(LineID, Line)
	-- For Override
end

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

derma.DefineControl("XPListView", "Data View", PANEL, "DPanel")