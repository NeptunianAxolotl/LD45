
--------------------------------------------------
-- Vector funcs
--------------------------------------------------

local function AbsVal(x, y)
	return math.sqrt(x*x + y*y)
end

local function Dist(x1, y1, x2, y2)
	return AbsVal(x1 - x2, y1 - y2)
end

local function intersection (x1, y1, x2, y2, x3, y3, x4, y4)
  local d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
  local a = x1 * y2 - y1 * x2
  local b = x3 * y4 - y3 * x4
  local x = (a * (x3 - x4) - (x1 - x2) * b) / d
  local y = (a * (y3 - y4) - (y1 - y2) * b) / d
  return x, y
end

local function getAngles(self, sourceX, sourceY)
    local angles = {}
    
    for i = 1, #self / 2 do
        angles[#angles + 1] = math.atan2(sourceY - self[2 * i], sourceX - self[(2 * i) - 1])
    end
    
    return angles
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

--------------------------------------------------
-- Junk spawning
--------------------------------------------------

local OCCURRENCE_BANDS = {
	3000,
	6000,
	10000,
	15000,
}

local function JunkDensityFunc(dist)
    if dist < 1000 then
        return 0
    end
    
    return (0.4 + 0.6*(dist - 1000)/8000)/2
end

local function InterpolateOccurrenceDensity(dist, o1, o2, o3, o4)
	if dist < OCCURRENCE_BANDS[1] then
		return o1
	end
	if dist < OCCURRENCE_BANDS[2] then
		local prop = (dist - OCCURRENCE_BANDS[1])/OCCURRENCE_BANDS[2]
		return (1 - prop)*o1 + prop*o2
	end
	if dist < OCCURRENCE_BANDS[3] then
		local prop = (dist - OCCURRENCE_BANDS[2])/OCCURRENCE_BANDS[3]
		return (1 - prop)*o2 + prop*o3
	end
	if dist < OCCURRENCE_BANDS[4] then
		local prop = (dist - OCCURRENCE_BANDS[3])/OCCURRENCE_BANDS[4]
		return (1 - prop)*o3 + prop*o4
	end
	return o4
end


--------------------------------------------------
-- Ship position checks
--------------------------------------------------

local function GetNearestComponent(ship, x, y, ignoreGirder, wantClosestOn)
    if not ship then
        return false, false, false
    end

    local closest = false
    local closestDist = false

    local closestOn = false
    local closestOnDist = false

	for _, comp in ship.components.Iterator() do
		if (not ignoreGirder) or (not comp.def.isGirder) then
			local cx, cy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
			local dist = Dist(x, y, cx, cy)
			if (not closestDist) or (dist < closestDist) then
				closest = comp
				closestDist = dist
			end

			if ((not closestOn) or (dist < closestOnDist)) and (dist < comp.def.walkRadius) then
				closestOn = comp
				closestOnDist = dist
			end
		end
	end
	
	if wantClosestOn and closestOn then
		return true, closestOn, closestOnDist
	end

	return false, closest, closestDist
end

local function IsPointOnShip(ship, x, y, ignoreGirder)
	for _, comp in ship.components.Iterator() do
		if (not ignoreGirder) or (not comp.isGirder) then
			if comp.fixture:testPoint(x, y) then
				return true
			end
		end
	end

	return false
end

--------------------------------------------------
-- Phase handling
--------------------------------------------------

local phasedObjects = IterableMap.New()
local function SetPhaseStatus(comp, isPhase)
	comp.fixture:setMask((isPhase and 1) or 16)
end

local function AddPhaseRadius(ship, px, py, radius, power)
	if not ship then
		return
	end

	for _, comp in ship.components.Iterator() do
		local x, y = ship.body:getWorldPoint(comp.xOff, comp.yOff)
		local dist = Dist(x, y, px, py)
		if dist < radius then
			comp.phaseState = (comp.phaseState or 0) + (comp.def.phaseSpeedMult or 1)*power*(2*radius - dist)/(2*radius)
			if comp.phaseState > 1 then
				comp.phaseState = 1
			end
			phasedObjects.Add(comp.index, comp)
		end
	end
end

local function UpdatePhasedObjects(dt)
    local maxIndex, keyByIndex, dataByKey = phasedObjects.GetBarbarianData()
	for i = maxIndex, 1, -1 do
		local key = keyByIndex[i]
		local comp = dataByKey[key]
		if comp and not comp.fixture:isDestroyed() then
			comp.phaseState = comp.phaseState - (comp.def.phaseSpeedMult or 1)*1.4*dt
			if (comp.phaseState > 0.5) ~= ((comp.phased and true) or false) then
				comp.phased = (comp.phaseState > 0.5)
				SetPhaseStatus(comp, comp.phased)
			end
			if comp.phaseState < 0 then
				comp.phaseState = nil
				phasedObjects.Remove(key)
			end
		else
			phasedObjects.Remove(key)
		end
	end
end

--------------------------------------------------
-- Bullet handling
--------------------------------------------------

local bulletImage
local bullets = IterableMap.New()
local bulletID = 0

local bulletShape = {
	-12, -3,
	12, -3,
	12, 3,
	-12, 3,
}

local BULLET_SPEED = 1500

local function FireBullet(world, body, shootX, shootY, activeAngle, vx, vy)
	bulletID = bulletID + 1
	
	local bullet = {}
	bullet.index = bulletID
	bullet.body = love.physics.newBody(world, shootX, shootY, "dynamic")
	bullet.shape = love.physics.newPolygonShape(unpack(bulletShape))
	bullet.fixture = love.physics.newFixture(bullet.body, bullet.shape, 1)

	bullet.life = 2
	bullet.damage = 110

	local fixtureData = {
		bullet = bullet,
		bulletIndex = bullet.index,
	}
	bullet.fixture:setUserData(fixtureData)

	local fx, fy = ToCart(activeAngle, BULLET_SPEED)

    bullet.body:setAngle(activeAngle)
    bullet.body:setLinearVelocity(vx + fx, vy + fy)
    bullets.Add(bullet.index, bullet)
end

local function DrawBullets()
	for _, bullet in bullets.Iterator() do
		if not bullet.toDestroy then
			love.graphics.draw(bulletImage, bullet.body:getX(), bullet.body:getY(), bullet.body:getAngle(), 0.15, 0.15, 87, 22)
		end
	end
end

local function DoBulletDamage(bullet)
	local damage = 0
	if not bullet.toDestroy then
		damage = bullet.damage
	end
	bullet.toDestroy = true
	return damage
end

local function UpdateBullets(dt)
    local maxIndex, keyByIndex, dataByKey = bullets.GetBarbarianData()
	for i = maxIndex, 1, -1 do
		local key = keyByIndex[i]
		local bullet = dataByKey[key]
		bullet.life = bullet.life - dt
		if bullet.life < 0 or bullet.toDestroy then
			bullet.body:destroy()
			bullets.Remove(bullet.index)
		end
	end
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function load()
	bulletImage = love.graphics.newImage('images/bullet 1.png')
end

return {
	AbsVal = AbsVal,
	Dist = Dist,
    RotateVector = RotateVector,
	Angle = Angle,
	ToCart = ToCart,
	JunkDensityFunc = JunkDensityFunc,
	InterpolateOccurrenceDensity = InterpolateOccurrenceDensity,
	GetNearestComponent = GetNearestComponent,
	IsPointOnShip = IsPointOnShip,
	AddPhaseRadius = AddPhaseRadius,
	UpdatePhasedObjects = UpdatePhasedObjects,
	FireBullet = FireBullet,
	DrawBullets = DrawBullets,
	UpdateBullets = UpdateBullets,
	DoBulletDamage = DoBulletDamage,
	load = load,
}
