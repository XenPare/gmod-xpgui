-- https://github.com/alexsnowrun/easymask

EZMASK = {}

local function ResetStencils()
	render.SetStencilWriteMask(0xFF)
	render.SetStencilTestMask(0xFF)
	render.SetStencilReferenceValue(0)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()
end

local function EnableMasking()
	render.SetStencilEnable(true)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_NEVER)
	render.SetStencilFailOperation(STENCIL_REPLACE)
end

local function SaveMask()
	render.SetStencilCompareFunction(STENCIL_EQUAL)
	render.SetStencilFailOperation(STENCIL_KEEP)
end

local function DisableMasking()
	render.SetStencilEnable(false)
end

function EZMASK.DrawWithMask(func_mask, func_todraw)
	ResetStencils()
	EnableMasking()
	func_mask()
	SaveMask()
	func_todraw()
	DisableMasking()
end

EZMASK.ResetStencils = ResetStencils
EZMASK.EnableMasking = EnableMasking
EZMASK.SaveMask = SaveMask
EZMASK.DisableMasking = DisableMasking