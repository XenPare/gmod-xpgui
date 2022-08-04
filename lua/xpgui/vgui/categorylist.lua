local PANEL = {}

function PANEL:Init()
	self.pnlCanvas:DockPadding(2, 2, 2, 2)
end

function PANEL:AddItem(item)
	item:Dock(TOP)
	DScrollPanel.AddItem(self, item)
	self:InvalidateLayout()
end

function PANEL:Add(name)
	local cat = vgui.Create("XPCollapsibleCategory", self)
	cat:SetLabel(name)
	cat:SetList(self)

	self:AddItem(cat)
	return cat
end

function PANEL:Paint(w, h)
	return false
end

function PANEL:UnselectAll()
	for _, v in pairs(self:GetChildren()) do
		if v.UnselectAll then
			v:UnselectAll()
		end
	end
end

derma.DefineControl("XPCategoryList", "", PANEL, "XPScrollPanel")