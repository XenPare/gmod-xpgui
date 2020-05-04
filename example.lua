local function example()
	local menu = vgui.Create("XPFrame")
	menu:SetTitle("Initial way of closing is here !")

	--menu:SetNoRounded() -- that makes frame full screen without rounded shape
	--menu:Dock(FILL)

	local close = menu:SetBottomButton("Close", FILL, function()
		menu:Remove()
	end)

	close:SetToolTip("Click me to close the frame !")

	local entry = vgui.Create("XPTextEntry", menu)
	entry:Dock(TOP)
	entry:DockMargin(4, 4, 4, 4)
	entry:SetTall(32)
	entry:SetText("hi this is text entry type what you want")

	local list = vgui.Create("XPListView", menu)
	list:Dock(LEFT)
	list:SetWide(menu:GetWide() / 3)
	list:DockMargin(4, 4, 4, 4)

	list:AddColumn("Number")
	list:AddColumn("Sum with previous")

	for i = 1, 64 do
		list:AddLine(i, i + (i - 1))
	end

	list.OnRowSelected = function(panel, rowIndex, row)
		local menu = vgui.Create("XPMenu")
		menu:SetPos(input.GetCursorPos())

		menu:AddOption("Copy index", function()
			SetClipboardText(row:GetValue(1))
		end)

		menu:AddOption("Copy sum", function()
			SetClipboardText(row:GetValue(2))
		end)

		menu:Open()
	end

	local players = vgui.Create("XPComboBox", menu)
	players:Dock(TOP)
	players:DockMargin(4, 4, 4, 16)
	players:SetValue("Choose a player")

	players:AddChoice("Choose a player")
	for _, pl in pairs(player.GetAll()) do
		players:AddChoice(pl:Name())
	end

	local scroll = vgui.Create("XPScrollPanel", menu)
	scroll:Dock(FILL)

	for i = 1, 14 do
		local pnl = vgui.Create("EditablePanel", scroll)
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
		txt:SetWide(menu:GetWide() / 2)
		txt:SetText("this is checkbox #" .. i)
	end
end
concommand.Add("xpgui_example", example)