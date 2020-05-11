local PANEL = {}

function PANEL:Init()
    XPGUI.Opened[XPGUI.GetAmount() + 1] = self

    self.startTime = SysTime()
    self.ExpensiveDrawing = false

    self:SetSize(ScrW() / 2, ScrH() / 2)
    self:Center()

    self:MakePopup()
    self:RequestFocus()

    self:SetAlpha(0)
    self:AlphaTo(255, 0.4, 0)

    self.Rounded = true

    self.TopDock = vgui.Create("DButton", self)
    self.TopDock:Dock(TOP)
    self.TopDock:SetTall(32)
    self.TopDock:SetText("")

    self.TopDock.Paint = nil
    self.TopDock.Hovered = false

    self.TopDock.DoClick = function()
        self:Close()
    end

    self.TopDock.OnCursorEntered = function()
        self.Hovered = true
    end

    self.TopDock.OnCursorExited = function()
        self.Hovered = false
    end

    self.TopDock.CloseGradientAlpha = 0

    local color = XPGUI.CloseColor
    local gradtex = surface.GetTextureID("gui/gradient_down")

    self.TopDock.Paint = function(self, w, h)
        if self.Hovered then
            color = XPGUI.CloseHoverColor
            self.CloseGradientAlpha = Lerp(0.05, self.CloseGradientAlpha, 255)
        else
            color = XPGUI.CloseColor
            self.CloseGradientAlpha = Lerp(0.05, self.CloseGradientAlpha, 0)
        end

        if self:IsDown() then
            color = XPGUI.ClosePressColor
        end

        surface.SetDrawColor(XPGUI.HeaderLineColor)
        surface.DrawLine(8, h - 1, w - 8, h - 1)
        surface.DrawLine(8, h, w - 8, h)
        surface.SetTexture(gradtex)
        surface.SetDrawColor(ColorAlpha(color,self.CloseGradientAlpha))
        surface.TrueRoundedRectEx(6, 0, 0, w, h, true, true, false, false, w, h)
    end
end

function PANEL:DrawExpended(bool)
    self.ExpensiveDrawing = bool == true and true or false
end

function PANEL:SetNoRounded(bool)
    self.Rounded = bool and bool or false
end

function PANEL:Paint(w, h)
    if self.BGBlur then
        Derma_DrawBackgroundBlur(self, self.startTime)
    end

    if self.ExpensiveDrawing then
        draw.DrawPanelRoundedRectBlur(self, 0, 0, w, h, XPGUI.BGColor) -- Very expensive drawing
    else
        surface.DrawPanelBlur(self, 8)
        draw.RoundedBox(self.Rounded and 6 or 0, 0, 0, w, h, XPGUI.BGColor)
    end
end

function PANEL:SetTitle(text)
    self.Title = vgui.Create("DLabel", self.TopDock)
    self.Title:SetTextColor(color_white)
    self.Title:SetText(text)
    self.Title:SetExpensiveShadow(1, ColorAlpha(color_black, 120))

    self.Title:SetFont("xpgui_big")
    self.Title:SetContentAlignment(4)
    self.Title:SizeToContents()

    self.Title:Dock(TOP)
    self.Title:DockMargin(6, 2, 6, 2)
end

function PANEL:SetBottomButton(title, dock, func)
    if not IsValid(self.BottomDock) then
        self.BottomDock = vgui.Create("EditablePanel", self)
        self.BottomDock:Dock(BOTTOM)
        self.BottomDock:SetTall(47)
    end

    local Button = vgui.Create("XPButton", self.BottomDock)
    Button:SetText(title)
    Button:Dock(dock)
    Button:DockMargin(6, 6, 6, 6)
    Button:SizeToContents()

    Button.DoClick = function(self)
        func(self)
    end

    return Button
end

function PANEL:OnRemove()
    if XPGUI.GetLast() == self then
        table.remove(XPGUI.Opened, XPGUI.GetAmount())
    end
end

function PANEL:Close()
    self:AlphaTo(0, 0.4, 0, function(_,pan) 
        pan:Remove() 
    end)
end

derma.DefineControl("XPFrame", "", PANEL, "EditablePanel")
