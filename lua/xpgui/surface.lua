local col_shadow = Color(0, 0, 0, 145)
local col_half_shadow = Color(0, 0, 0, 110)

local shadow_x = 1
local shadow_y = 0

local scrW, scrH
local cos, sin, pi =  math.cos, math.sin, math.pi

--(1 - t) * from + t * to
function LerpColor(t, from, to)
	return Color(
		(1 - t) * from.r + t * to.r,
		(1 - t) * from.g + t * to.g,
		(1 - t) * from.b + t * to.b,
		(1 - t) * from.a + t * to.a
	)
end

local pan_x, pan_y
local blur = Material("pp/blurscreen")
function surface.DrawPanelBlur(panel, amount)
	pan_x, pan_y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor(color_white)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(pan_x * -1, pan_y * -1, ScrW(), ScrH())
	end
end

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

function draw.NoRoundedBox(x, y, w, h, color)
	draw.NoTexture()
	surface.SetDrawColor(color or color_white)
	surface.DrawRect(x, y, w, h)
end

function surface.PrecacheRoundedRect(x, y, w, h, r, seg)
	local min = (w > h and h or w) * 0.5
	r = r > min and min or r

	local poly = {}
	for i = 0, seg do
		local a = pi * 0.5 * i / seg
		local cosine, sine = r * cos(a), r * sin(a)
		poly[i+1] = {
			x = x + r - cosine,
			y = y + r - sine
		}
		poly[i + seg + 1] = {
			x = x + w - r + sine,
			y = y + r - cosine
		}
		poly[i + seg * 2 + 1] = {
			x = x + w - r + cosine,
			y = y + h - r + sine
		}
		poly[i + seg * 3 + 1] = {
			x = x + r - sine,
			y = y + h - r + cosine
		}
	end
	return poly
end

local poly = {}
function surface.DrawRoundedRect(x, y, w, h, r, seg)
	local min = (w > h and h or w) * 0.5
	r = r > min and min or r

	poly = {}
	for i = 0, seg do
		local a = pi * 0.5 * i / seg
		local cosine, sine = r * cos(a), r * sin(a)
		poly[i] = {
			x = x + r - cosine,
			y = y + r - sine
		}
		poly[i + seg + 1] = {
			x = x + w - r + sine,
			y = y + r - cosine
		}
		poly[i + seg * 2 + 1] = {
			x = x + w - r + cosine,
			y = y + h - r + sine
		}
		poly[i + seg * 3 + 1] = {
			x = x + r - sine,
			y = y + h - r + cosine
		}
	end
	surface.DrawPoly(poly)
end