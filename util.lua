
local function AbsVal(x, y, z)
	if z then
		return math.sqrt(x*x + y*y + z*z)
	elseif y then
		return math.sqrt(x*x + y*y)
	elseif x[3] then
		return math.sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3])
	else
		return math.sqrt(x[1]*x[1] + x[2]*x[2])
	end
end

local function RotateVector(x, y, angle)
	return x*math.cos(angle) - y*math.sin(angle), x*math.sin(angle) + y*math.cos(angle)
end

local function Angle(x, z)
	if x == 0 and z == 0 then
		return 0
	end
	local mult = 1/AbsVal(x, z)
	x, z = x*mult, z*mult
	if z > 0 then
		return math.acos(x)
	elseif z < 0 then
		return 2*math.pi - math.acos(x)
	elseif x < 0 then
		return math.pi
	end
	-- x < 0
	return 0
end


return {
    Angle = Angle,
    RotateVector = RotateVector,
}
