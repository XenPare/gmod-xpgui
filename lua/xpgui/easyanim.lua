-- https://github.com/alexsnowrun/easyanim

local animObject = {
	-- Changeable properties
	Duration = 0,
	Ease = function(x) return x end,
	Pos = 0,

	-- Internal properties
	Value = 0,
	NewValue = 0,
	StartTime = 0,
	EndTime = 0,
	Status = false,
}


function animObject:SetDuration(dur)
	self.Duration = dur
end

function animObject:SetEasing(func)
	self.Ease = func
end

function animObject:SetAnimPrinciple() end

function animObject:AnimTo(val)
	local time = CurTime()
	if val ~= self.NewValue then
		self.NewValue = val
		self.Pos = self.Pos + self.Value
		self.Delta = self.NewValue - self.Pos
		self:SetAnimPrinciple()
		self.StartTime = time
		self.EndTime = time + self.Duration
	end

	if time <= self.EndTime then
		self.Value = self.Delta * self.Ease((time - self.StartTime) / self.Duration)

		self.Status = true
	else
		self.Value = self.NewValue
		self.Pos = 0
		self.Status = false
	end

	return self.Pos + self.Value
end

function animObject:GetValue()
	return self.Pos + self.Value
end
setmetatable(animObject,{__call = function(self, Duration, Easing) return setmetatable({Duration = Duration or 0, Ease = Easing or animObject.Ease},{__index = self}) end})

EasyAnim = {}

function EasyAnim.NewAnimation(Duration, Easing)
	return animObject(Duration, Easing)
end

-- Easing functions from easings.net

local sin, cos, pi, sqrt = math.sin, math.cos, math.pi, math.sqrt

local c1 = 1.70158
local c2 = c1 * 1.525
local c3 = c1 + 1
local c4 = 2 * pi / 3
local c5 = 2 * pi / 4.5

local n1 = 7.5625
local d1 = 2.75

-- Sine
function EASE_InSine(x)
	return 1 - cos((x * pi) * 0.5)
end

function EASE_OutSine(x)
	return sin(x * pi / 2)
end

function EASE_InOutSine(x)
	return -(cos(pi * x) - 1) / 2
end

--Cubic

function EASE_InCubic(x)
	return x * x * x
end

function EASE_OutCubic(x)
	return 1 - (1 - x)^3
end

function EASE_InOutCubic(x)
	return x < 0.5 and 4 * x * x * x or 1 - (-2 * x + 2)^3 / 2
end

--Quint

function EASE_InQuint(x)
	return x * x * x * x * x
end

function EASE_OutQuint(x)
	return 1 - (1 - x)^5
end

function EASE_InOutQuint(x)
	return x < 0.5 and 16 * x * x * x * x * x or 1 - (-2 * x + 2)^5 / 2
end

--Circ

function EASE_InCirc(x)
	return 1 - sqrt(1 - (x*x))
end

function EASE_OutCirc(x)
	return sqrt(1 - (x - 1)^2)
end

function EASE_InOutCirc(x)
	return x < 0.5
	and (1 - sqrt(1 - (2 * x)^2)) / 2
	or (sqrt(1 - (-2 * x + 2)^2) + 1) / 2
end

--Elastic

function EASE_InElastic(x)
	return x == 0 and 0 or (x == 1 and 1 or -2^(10 * x - 10) * sin((x * 10 - 10.75) * c4))
end

function EASE_OutElastic(x)
	return x == 0 and 0 or x == 1 and 1 or 2^(-10 * x) * sin((x * 10 - 0.75) * c4) + 1
end

function EASE_InOutElastic(x)
	return x == 0
		and 0
		or x == 1
		and 1
		or x < 0.5
		and -2^(20 * x - 10) * sin((20 * x - 11.125) * c5) / 2
	or 2^(-20 * x + 10) * sin((20 * x - 11.125) * c5) / 2 + 1
end

--Quad

function EASE_InQuad(x)
	return x * x
end

function EASE_OutQuad(x)
	return 1 - (1 - x) * (1 - x)
end

function EASE_InOutQuad(x)
	return x < 0.5 and 2 * x * x or 1 - (-2 * x + 2)^2 / 2
end

--Quart

function EASE_InQuart(x)
	return x * x * x * x
end

function EASE_OutQuart(x)
	return 1 - (1 - x)^4
end

function EASE_InOutQuart(x)
	return x < 0.5 and 8 * x * x * x * x or 1 - (-2 * x + 2)^4 / 2
end

--Expo

function EASE_InExpo(x)
	return x == 0 and 0 or 2^(10 * x - 10)
end

function EASE_OutExpo(x)
	return x == 1 and 1 or 1 - 2^(-10 * x)
end

function EASE_InOutExpo(x)
	return x == 0
		and 0
		or x == 1
		and 1
		or x < 0.5 and 2^(20 * x - 10) / 2
	or (2 - 2^(-20 * x + 10)) / 2
end

--Back

function EASE_InBack(x)
	return c3 * x * x * x - c1 * x * x
end

function EASE_OutBack(x)
	return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
end

function EASE_InOutBack(x)
	return x < 0.5
	and ((2 * x)^2 * ((c2 + 1) * 2 * x - c2)) / 2
	or ((2 * x - 2)^2 * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
end

--Bounce

function EASE_OutBounce(x)
	if x < (1 / d1) then
		return n1 * x * x
	elseif x < (2 / d1) then
		x = x -  1.5 / d1
		return n1 * x * x + 0.75
	elseif x < (2.5 / d1) then
		x = x - 2.25 / d1
		return n1 * x * x + 0.9375
	else
		x = x - 2.625 / d1
		return n1 * x * x + 0.984375
	end
end

function EASE_InBounce(x)
	return 1 - EASE_OutBounce(1 - x)
end

function EASE_InOutBounce(x)
	return x < 0.5
	and (1 - EASE_OutBounce(1 - 2 * x)) / 2
	or (1 + EASE_OutBounce(2 * x - 1)) / 2
end
