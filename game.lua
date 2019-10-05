local compConfig, compConfigList = unpack(require("components"))
local util = require("util")

local function GetRandomComponent()
    local num = math.random(1, #compConfigList)
    return compConfigList[num].name
end

--------------------------------------------------
-- Component handling
--------------------------------------------------

local function UpdatePlayerComponentAttributes(player)
    needKeybind = false
    for i = 1, #player.components do
        local comp = player.components[i]
        if comp.def.text and not comp.activeKey then
            needKeybind = true
            break
        end
    end

    if not needKeybind then
        setKeybind = false
    end
end

local function SetupComponent(body, compDefName, params)
    params = params or {}
    local comp = {}
    comp.def = compConfig[compDefName]

    comp.xOff = params.xOff or 0
    comp.yOff = params.yOff or 0
    comp.angle = params.angle or 0

    local xOff, yOff, angle = comp.xOff, comp.yOff, comp.angle
    if comp.def.circleShapeRadius then
        comp.shape = love.physics.newCircleShape(xOff, yOff, comp.def.circleShapeRadius)
    else
        local coords = comp.def.shapeCoords
        local modCoords = {}
        for i = 1, #coords, 2 do
            local cx, cy = util.RotateVector(coords[i], coords[i + 1], angle)
            cx, cy = cx + xOff, cy + yOff
            modCoords[#modCoords + 1] = cx
            modCoords[#modCoords + 1] = cy
        end
        comp.shape = love.physics.newPolygonShape(unpack(modCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, comp.def.density)

    comp.activeKey = params.activeKey
    comp.isPlayer  = params.isPlayer
    local fixtureData = params.fixtureData or {}
    fixtureData.noAttach = comp.def.noAttach
    fixtureData.comp = comp
    comp.fixture:setUserData(fixtureData)

    return comp
end

local function MakeJunk(world, index)
    local junk = love.physics.newBody(world, math.random()*1000 - 500, math.random()*1000 - 500, "dynamic")

    local compDefName = GetRandomComponent()
    local comp = SetupComponent(junk, compDefName, {fixtureData = {junkIndex = index, compDefName = compDefName}})
    junk:setAngle(math.random()*2*math.pi)
    junk:setLinearVelocity(math.random()*4, math.random()*4)
    junk:setAngularVelocity(math.random()*0.3*math.pi)
    return {
        body = junk,
        components = {comp}
    }
end

--------------------------------------------------
-- Input
--------------------------------------------------

local function UpdateInput(ship)
    for i = 1, #ship.components do
        local comp = ship.components[i]
        if comp.def.holdActivate then
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
                local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
                local angle = ship.body:getAngle() + comp.angle
                vx, vy = util.RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
                comp.def:onFunction(ship.body, ox + vx, oy + vy, angle)
                comp.activated = true
            else
                comp.activated = false
            end
        end
    end
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local collisionToAdd

local function DoMerge(player, junkList, playerFixture, otherFixture)
    if otherFixture:isDestroyed() then
        return
    end

    local otherData = otherFixture:getUserData()
    if not otherData.junkIndex then
        return
    end
    local junk = junkList[otherData.junkIndex]

    local junkBody = junk.body
    local playerBody = playerFixture:getBody()

    for i = 1, #junk.components do
        local comp = junk.components[i]
        local xOff, yOff = playerBody:getLocalPoint(junkBody:getWorldPoint(comp.xOff, comp.yOff))

        local angle = junkBody:getAngle() - playerBody:getAngle() + comp.angle

        player.components[#player.components + 1] = SetupComponent(playerBody, otherData.compDefName, {
                isPlayer = true,
                fixtureData = {isPlayer = true, compDefName = compDefName},
                xOff = xOff,
                yOff = yOff,
                angle = angle,
            }
        )
    end
    
    otherFixture:getBody():destroy()
    junkList[otherData.junkIndex] = nil

    UpdatePlayerComponentAttributes(player)
end

local function ProcessCollisions(player, junkList)
    if not collisionToAdd then
        return
    end
    for i = 1, #collisionToAdd do
        local playerFixture, otherFixture = collisionToAdd[i][1], collisionToAdd[i][2]
        DoMerge(player, junkList, playerFixture, otherFixture)
    end
    collisionToAdd = false
end

local function beginContact(a, b, col1)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}
    if aData.noAttach or bData.noAttach then
        return
    end
    if aData.isPlayer == bData.isPlayer then
        return
    end
    playerFixture = (aData.isPlayer and a) or b
    otherFixture  = (bData.isPlayer and a) or b

    collisionToAdd = collisionToAdd or {}
    collisionToAdd[#collisionToAdd + 1] = {playerFixture, otherFixture}
end

--------------------------------------------------
-- Updates
--------------------------------------------------

return {
    SetupComponent = SetupComponent,
    UpdateInput = UpdateInput,
    ProcessCollisions = ProcessCollisions,
    beginContact = beginContact,
    MakeJunk = MakeJunk,
}
