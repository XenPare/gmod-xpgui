--[[
    Math stuff
]]

local scrW, scrH
local cos, sin, rad, insert =  math.cos, math.sin, math.rad, table.insert

--(1 - t) * from + t * to

function LerpColor(t, from, to)
    return Color(
       (1 - t) * from.r + t * to.r,
       (1 - t) * from.g + t * to.g,
       (1 - t) * from.b + t * to.b,
       (1 - t) * from.a + t * to.a
    )
end

--[[
    Config
]]

local col_shadow = Color(0, 0, 0, 145)
local col_half_shadow = Color(0, 0, 0, 110)

local shadow_x = 1
local shadow_y = 0

--[[
    Blur
]]

local blur = Material("pp/blurscreen")
local pan_x, pan_y
function surface.DrawPanelBlur(panel, amount)
    pan_x, pan_y = panel:LocalToScreen(0, 0)
    scrW, scrH = ScrW(), ScrH()

    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * (amount or 6))
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(pan_x * -1, pan_y * -1, scrW, scrH)
    end
end

--[[
    Material
]]

function surface.DrawMaterial(material, xalign, yalign, x, y, color)
    surface.SetDrawColor(color or color_white)
    surface.SetMaterial(material)
	surface.DrawTexturedRect(xalign, yalign, x, y)  
end

function surface.DrawShadowMaterial(material, xalign, yalign, x, y, color)
    surface.SetDrawColor(col_shadow)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x, y + 3)

    surface.SetDrawColor(col_half_shadow)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x + shadow_x , y + shadow_y)

    surface.SetDrawColor(color or color_white)
    surface.SetMaterial(material)
    surface.DrawTexturedRect(xalign, yalign, x, y)   
end

--[[
    crestr, add description later, please
]]

function draw.NoRoundedBox(x, y, w, h, color)
    draw.NoTexture()
    surface.SetDrawColor(color or color_white)
    surface.DrawRect(x, y, w, h)
end

--[[
    Rounded stuff
]]

local pos_x, pos_y = 0,0

function draw.DrawPanelRoundedRectBlur(panel, x, y, w, h, color)
    pos_x, pos_y = panel:LocalToScreen(x, y)

    draw.RoundedRectBlur(x, y, w, h, 6, 8, color, true, true, true, true, pos_x, pos_y)
end

local cir = {}
local tempsin, tempcos = 0, 0
local a, x_pos, y_pos, x_pos_real, y_pos_real
local DrawPoly = surface.DrawPoly

local function DrawQuadrant(x, y, radius, orientation, tex_w, tex_h, real_x, real_y) -- orientation: 1 = bottom Left, 2 = top Left, 3 = bottom Right, 4 = top Right
    tex_w = tex_w or ScrW()
    tex_h = tex_h or ScrH()
    cir = {}

	insert(cir, {x = x, y = y, u = (real_x or x) / tex_w, v = (real_y or y) / tex_h})
	for i = 0, 32 do
        a = rad((i / 32) * ((orientation == 2 or orientation == 3) and 90 or -90))
        tempsin = sin(a) * radius
        tempcos = cos(a) * radius
        if orientation == 1 then
            x_pos = x + tempsin
            y_pos = y + tempcos
            if real_y then
                x_pos_real = real_x + tempsin
                y_pos_real = real_y + tempcos
            end
        elseif orientation == 2 then
            x_pos = x - tempcos
            y_pos = y - tempsin
            if real_y then
                x_pos_real = real_x - tempcos
                y_pos_real = real_y - tempsin
            end
        elseif orientation == 3 then
            x_pos = x + tempcos
            y_pos = y + tempsin
            if real_y then
                x_pos_real = real_x + tempcos
                y_pos_real = real_y + tempsin
            end
        elseif orientation == 4 then
            x_pos = x - tempsin
            y_pos = y - tempcos
            if real_y then
                x_pos_real = real_x - tempsin
                y_pos_real = real_y - tempcos
            end
        end
        insert(cir, {x = x_pos, y = y_pos, u = (x_pos_real or x_pos) / tex_w, v = (y_pos_real or y_pos) / tex_h})
    end
	DrawPoly(cir)
end

local top_PosX, top_PosX_real, top_Wide = 0, 0, 0
local mid_PosY, mid_PosY_real= 0, 0
local bottom_PosX, bottom_PosX_real, bottom_Wide = 0, 0, 0

function surface.TrueRoundedRectEx(radius, x, y, w, h, r_topLeft, r_topRight, r_bottomLeft, r_bottomRight, tex_w, tex_h, real_x, real_y)
    w = w > radius * 2 and w or radius * 2
    h = h > radius * 2 and h or radius * 2

    real_x = real_x or x
    real_y = real_y or y

    tex_w = tex_w or ScrW()
    tex_h = tex_h or ScrH()
    
    top_PosX, top_Wide = x, w
    mid_PosY = y + radius
    bottom_PosX, bottom_Wide = x, w
    
    top_PosX_real, mid_PosY_real, bottom_PosX_real = real_x, real_y + radius, real_x

    if r_topLeft  then
        top_PosX = top_PosX + radius
        top_PosX_real = top_PosX_real + radius
        top_Wide = top_Wide - radius
        DrawQuadrant(x + radius, y + radius, radius, 2, tex_w, tex_h, real_x + radius, real_y + radius)
    end

    if r_topRight then
        top_Wide = top_Wide - radius
        DrawQuadrant(x + w - radius, y + radius, radius, 4, tex_w, tex_h, real_x + w - radius, real_y + radius)
    end

    if r_bottomLeft then
        bottom_PosX = bottom_PosX + radius
        bottom_PosX_real = bottom_PosX_real + radius
        bottom_Wide = bottom_Wide - radius
        DrawQuadrant(x + radius, y + h - radius, radius, 1, tex_w, tex_h, real_x + radius, real_y + h - radius)
    end

    if r_bottomRight then
        bottom_Wide = bottom_Wide - radius
        DrawQuadrant(x + w - radius, y + h - radius, radius, 3, tex_w, tex_h, real_x + w - radius, real_y + h - radius)
    end

    surface.DrawTexturedRectUV(top_PosX, y, top_Wide, radius, top_PosX_real / tex_w, real_y / tex_h, (top_PosX_real + top_Wide) / tex_w, (real_y + radius) / tex_h) -- top
    surface.DrawTexturedRectUV(x, mid_PosY, w, h - radius - radius, real_x / tex_w, mid_PosY_real / tex_h, (real_x + w) / tex_w, (mid_PosY_real + h - radius - radius) / tex_h) -- mid
    surface.DrawTexturedRectUV(bottom_PosX, y + h - radius, bottom_Wide, radius, bottom_PosX_real / tex_w, (real_y + h - radius) / tex_h, (bottom_PosX_real + bottom_Wide) / tex_w, (real_y + h) / tex_h) -- bottom
end

function draw.RoundedRectBlur(x, y, w, h, radius, amount, color, r_topLeft, r_topRight, r_bottomLeft, r_bottomRight, real_x, real_y)
    scrW, scrH = ScrW(), ScrH()

    r_topLeft, r_topRight, r_bottomLeft, r_bottomRight = r_topLeft == nil and true or r_topLeft, r_topRight == nil and true or r_topRight, r_bottomLeft == nil and true or r_bottomLeft, r_bottomRight == nil and true or r_bottomRight

    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * amount)
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.TrueRoundedRectEx(radius, x, y, w, h, r_topLeft, r_topRight, r_bottomLeft, r_bottomRight, scrW, scrH, real_x, real_y)
    end
    
    if color then
        draw.RoundedBoxEx(radius, x, y, w, h, color, r_topLeft, r_topRight, r_bottomLeft, r_bottomRight)
    end
end

function draw.BlurredRect(x, y, w, h, amount, color, real_x, real_y)
    scrW, scrH = ScrW(), ScrH()

    real_x = real_x or x
    real_y = real_y or y

    surface.SetDrawColor(color_white)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / 3) * amount)
        blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRectUV(x, y, w, h, real_x / scrW, real_y / scrH, (real_x + w) / scrW, (real_y + h) / scrH)
    end

    if color then
        surface.SetDrawColor(color)
        surface.DrawRect(x, y, w, h)
    end
end