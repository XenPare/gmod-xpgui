local function example()
	local frame = vgui.Create("XPFrame")
	frame:SetTitle("Example Frame")
	-- frame:SetBackgroundBlur(false)
	-- frame:SetFrameBlur(false)
	-- frame:SetNoRounded(true)

	local sheet = vgui.Create("XPPropertySheet", frame)
	sheet:DockMargin(4, 4, 4, 4)
	sheet:Dock(FILL)

	local pan1 = vgui.Create("EditablePanel", sheet)
	sheet:AddSheet("Preview Tab", pan1)

	local pan2 = vgui.Create("EditablePanel", sheet)
	sheet:AddSheet("Empty Tab", pan2)

	local bottom_button1 = frame:SetBottomButton("Left", LEFT, function()
		frame:Remove()
	end)

	local bottom_button2 = frame:SetBottomButton("Right", RIGHT, function()
		frame:Remove()
	end)

	local bottom_button3 = frame:SetBottomButton("Fill", FILL, function()
		frame:Remove()
	end)

	--[[
		Left Panel
	]]

	local left_panel = vgui.Create("XPScrollPanel", pan1)
	left_panel:Dock(LEFT)
	left_panel:DockMargin(6, 6, 6, 6)
	left_panel:SetWide(frame:GetWide() / 2 - 4)

	-- Horizontal Scroller
	local horizontal_scroll = vgui.Create("XPHorizontalScroller", left_panel)
	horizontal_scroll:Dock(TOP)
	horizontal_scroll:SetTall(frame:GetTall() / 2 - 8)
	horizontal_scroll:SetOverlap(-3)

	for i = 1, 12 do
		local button = vgui.Create("XPButton", horizontal_scroll)
		button:SetText("Button #" .. i)
		button:SetWide(horizontal_scroll:GetTall())

		button.DoClick = function()
			local menu = vgui.Create("XPMenu", parent)

			for i = 1, 3 do
				menu:AddOption("Menu Button #" .. i)
			end

			menu:Open()
		end

		horizontal_scroll:AddPanel(button)
	end

	for i = 1, 12 do
		local button = vgui.Create("XPButton", left_panel)
		button:Dock(TOP)
		button:SetText("Button #" .. i)
		button:SetToolTip("Clicking does really nothing")
	end

	--[[
		Right Panel
	]]

	local right_panel = vgui.Create("XPScrollPanel", pan1)
	right_panel:Dock(RIGHT)
	right_panel:DockMargin(6, 6, 6, 6)
	right_panel:SetWide(frame:GetWide() / 2 - 20)

	-- ComboBox
	local combobox = vgui.Create("XPComboBox", right_panel)
	combobox:Dock(TOP)
	combobox:DockMargin(4, 4, 4, 16)
	combobox:SetValue("Choose a number")

	for i = 1, 9 do
		combobox:AddChoice(i)
	end

	-- List
	local list = vgui.Create("XPListView", right_panel)
	list:Dock(TOP)
	list:SetTall(frame:GetTall() / 2)
	list:DockMargin(4, 4, 4, 4)

	list:AddColumn("Number")
	list:AddColumn("Previous + Current")

	for i = 1, 32 do
		list:AddLine(i, i + (i - 1))
	end

	-- Text Entry
	local entry = vgui.Create("XPTextEntry", right_panel)
	entry:Dock(TOP)
	entry:DockMargin(4, 4, 4, 4)
	entry:SetTall(32)
	entry:SetText("Text Entry")

	-- Checkbox
	for i = 1, 6 do
		local pnl = vgui.Create("EditablePanel", right_panel)
		pnl:Dock(TOP)
		pnl:SetTall(24)
		pnl:DockMargin(4, 4, 4, 4)

		local cb = vgui.Create("XPCheckBox", pnl)
		cb:SetPos(0, 0)
		cb:SetSize(24, 24)
		cb:SetValue(true)

		local txt = vgui.Create("DLabel", pnl)
		txt:SetFont("xpgui_medium")
		txt:SetPos(28, 0)
		txt:SetWide(frame:GetWide() / 2)
		txt:SetText("Simple checkbox")
	end
end
concommand.Add("xpgui_example", example)