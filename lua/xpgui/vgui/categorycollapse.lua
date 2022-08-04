--[[
	XPCategoryHeader
]]

local PANEL = {}

function PANEL:Init()
	self:SetContentAlignment(4)
	self:SetTextInset(5, -3)
	self:SetFont("xpgui_tiny")
end

function PANEL:DoClick()
	self:GetParent():Toggle()
end

function PANEL:UpdateColours(skin)
	if not self:GetParent():GetExpanded() then
		self:SetExpensiveShadow(0, XPGUI.CollapsibleCategoryClosedShadowColor)
		return self:SetTextStyleColor(skin.Colours.Category.Header_Closed)
	end

	self:SetExpensiveShadow(1, XPGUI.CollapsibleCategoryExpandedShadowColor)
	return self:SetTextStyleColor(skin.Colours.Category.Header)
end

function PANEL:Paint(w, h)
	if not self:GetParent():GetExpanded() then
		draw.SimpleText("u", "Marlett", w, h * 0.5 - 2, XPGUI.CollapsibleCategoryExpandIconColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	end
end

derma.DefineControl("XPCategoryHeader", "Category Header", PANEL, "XPButton")

--[[
	XPCollapsibleCategory
]]

local PANEL = {}

AccessorFunc(PANEL, "m_bSizeExpanded", "Expanded", FORCE_BOOL)
AccessorFunc(PANEL, "m_iContentHeight",	"StartHeight")
AccessorFunc(PANEL, "m_fAnimTime", "AnimTime")
AccessorFunc(PANEL, "m_bDrawBackground", "PaintBackground", FORCE_BOOL)
AccessorFunc(PANEL, "m_bDrawBackground", "DrawBackground", FORCE_BOOL) -- deprecated
AccessorFunc(PANEL, "m_iPadding", "Padding")
AccessorFunc(PANEL, "m_pList", "List")

function PANEL:Init()
	self.Header = vgui.Create("XPCategoryHeader", self)
	self.Header:Dock(TOP)
	self.Header:SetSize(20, 20)

	self:SetSize(16, 16)
	self:SetExpanded(true)
	self:SetMouseInputEnabled(true)

	self:SetAnimTime(0.2)
	self.animSlide = Derma_Anim("Anim", self, self.AnimSlide)

	self:SetPaintBackground(true)
	self:DockMargin(0, 0, 0, 2)
	self:DockPadding(0, 0, 0, 0)

	self.ColorA = XPGUI.ButtonColor.a
	self.Color = Color(XPGUI.ButtonColor.r, XPGUI.ButtonColor.g, XPGUI.ButtonColor.b, XPGUI.ButtonColor.a)
end

function PANEL:Add(strName)
	local button = vgui.Create("XPButton", self)

	button:SetHeight(17)
	button:SetTextInset(4, 0)

	button:SetContentAlignment(4)
	button:DockMargin(1, 0, 1, 0)
	button.DoClickInternal = function()
		if self:GetList() then
			self:GetList():UnselectAll()
		else
			self:UnselectAll()
		end
		button:SetSelected(true)
	end

	button:Dock(TOP)
	button:SetText(strName)

	self:InvalidateLayout(true)
	self:UpdateAltLines()

	return button
end

function PANEL:UnselectAll()
	local children = self:GetChildren()
	for _, v in pairs(children) do
		if v.SetSelected then
			v:SetSelected(false)
		end
	end
end

function PANEL:UpdateAltLines()
	local children = self:GetChildren()
	for k, v in pairs(children) do
		v.AltLine = k % 2 ~= 1
	end
end

function PANEL:Think()
	self.animSlide:Run()
end

function PANEL:SetLabel(strLabel)
	self.Header:SetText( strLabel )
end

function PANEL:SetHeaderHeight(height)
	self.Header:SetTall(height)
end

function PANEL:GetHeaderHeight()
	return self.Header:GetTall()
end

function PANEL:Paint(w, h)
	if self.Header:IsHovered() then
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA + 15)
	else
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA)
	end

	if self.Header:IsDown() then
		self.Color.a = Lerp(7.5 * FrameTime(), self.Color.a, self.ColorA + 25)
	end

	draw.RoundedBox(6, 0, 0, w, h, self.Color)
	return false
end

function PANEL:SetContents(pContents)
	self.Contents = pContents
	self.Contents:SetParent(self)
	self.Contents:Dock(FILL)

	if not self:GetExpanded() then
		self.OldHeight = self:GetTall()
	elseif self:GetExpanded() and IsValid(self.Contents) and self.Contents:GetTall() < 1 then
		self.Contents:SizeToChildren(false, true)
		self.OldHeight = self.Contents:GetTall()
		self:SetTall(self.OldHeight)
	end

	self:InvalidateLayout(true)
end

function PANEL:SetExpanded(expanded)
	self.m_bSizeExpanded = tobool(expanded)
	if not self:GetExpanded() then
		if not self.animSlide.Finished and self.OldHeight then
			return
		end
		self.OldHeight = self:GetTall()
	end
end

function PANEL:Toggle()
	self:SetExpanded(not self:GetExpanded())

	self.animSlide:Start(self:GetAnimTime(), {
		From = self:GetTall()
	})

	self:InvalidateLayout(true)
	self:GetParent():InvalidateLayout()
	self:GetParent():GetParent():InvalidateLayout()

	local open = "1"
	if not self:GetExpanded() then
		open = "0"
	end

	self:SetCookie("Open", open)
	self:OnToggle(self:GetExpanded())
end

function PANEL:OnToggle(expanded) end

function PANEL:DoExpansion(b)
	if self:GetExpanded() == b then
		return
	end
	self:Toggle()
end

function PANEL:PerformLayout()
	if IsValid(self.Contents) then
		if self:GetExpanded() then
			self.Contents:InvalidateLayout(true)
			self.Contents:SetVisible(true)
		else
			self.Contents:SetVisible(false)
		end
	end

	if self:GetExpanded() then
		if IsValid(self.Contents) and #self.Contents:GetChildren() > 0 then
			self.Contents:SizeToChildren(false, true)
		end
		self:SizeToChildren(false, true)
	else
		if IsValid(self.Contents) and not self.OldHeight then
			self.OldHeight = self.Contents:GetTall()
		end
		self:SetTall(self:GetHeaderHeight())
	end

	self.Header:ApplySchemeSettings()
	self.animSlide:Run()
	self:UpdateAltLines()
end

function PANEL:OnMousePressed(mCode)
	if not self:GetParent().OnMousePressed then
		return
	end
	return self:GetParent():OnMousePressed(mCode)
end

function PANEL:AnimSlide(anim, delta, data)
	self:InvalidateLayout()
	self:InvalidateParent()

	if anim.Started then
		if not IsValid(self.Contents) and (self.OldHeight or 0) < self.Header:GetTall() then
			self.OldHeight = 0
			for _, pnl in pairs(self:GetChildren()) do
				self.OldHeight = self.OldHeight + pnl:GetTall()
			end
		end

		if self:GetExpanded() then
			data.To = math.max(self.OldHeight, self:GetTall())
		else
			data.To = self:GetTall()
		end
	end

	if IsValid(self.Contents) then
		self.Contents:SetVisible(true)
	end

	self:SetTall(Lerp(delta, data.From, data.To))
end

function PANEL:LoadCookies()
	local op = self:GetCookieNumber("Open", 1) == 1

	self:SetExpanded(op)
	self:InvalidateLayout(true)
	self:GetParent():InvalidateLayout()
	self:GetParent():GetParent():InvalidateLayout()
end

derma.DefineControl("XPCollapsibleCategory", "Collapsable Category Panel", PANEL, "Panel")