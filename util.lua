
local function AbsVal(x, y)
	return math.sqrt(x*x + y*y)
end

local function Dist(x1, y1, x2, y2)
	return AbsVal(x1 - x2, y1 - y2)
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

local function ToCart(dir, rad)
	return rad*math.cos(dir), rad*math.sin(dir)
end

local function GetNearestComponent(ship, x, y)
    if not ship then
        return false, false, false
    end

    local closest = false
    local closestDist = false

    local closestOn = false
    local closestOnDist = false

    for i = 1, #ship.components do
        local comp = ship.components[i]
        local cx, cy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        local dist = Dist(x, y, cx, cy)
        if (not closestDist) or (dist < closestDist) then
            closest = i
            closestDist = dist
        end

        if ((not closestOn) or (dist < closestOn)) and (dist < comp.def.walkRadius) then
            closestOn = i
            closestOnDist = dist
        end
	end
	
	if closestOn then
		return true, closestOn, closestOnDist
	end

	return false, closest, closestDist
end

return {
	AbsVal = AbsVal,
	Dist = Dist,
    RotateVector = RotateVector,
	Angle = Angle,
	ToCart = ToCart,
	GetNearestComponent = GetNearestComponent,
}
