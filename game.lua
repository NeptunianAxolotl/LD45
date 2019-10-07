--------------------------------------------------
-- Component handling
--------------------------------------------------

local componentIndex = 0
local function SetupComponent(body, compDefName, params)
    params = params or {}
    local comp = {}
    comp.def = compConfig[compDefName]

    comp.xOff = params.xOff or 0
    comp.yOff = params.yOff or 0
    comp.angle = params.angle or 0

    componentIndex = componentIndex + 1
    comp.index = componentIndex

    local scaleFactor = 1
    if params.scaleFactor then
        scaleFactor = params.scaleFactor
    elseif comp.def.scaleMin and comp.def.scaleMax then
        scaleFactor = comp.def.scaleMin + math.random()*(comp.def.scaleMax - comp.def.scaleMin)
    end

    local xOff, yOff, angle = comp.xOff, comp.yOff, comp.angle
    if comp.def.circleShapeRadius then
        comp.shape = love.physics.newCircleShape(xOff, yOff, comp.def.circleShapeRadius*scaleFactor)
    else
        local coords = comp.def.shapeCoords
        local modCoords = {}
        for i = 1, #coords, 2 do
            local cx, cy = coords[i]*(params.xScale or 1)*scaleFactor, coords[i + 1]*scaleFactor
            cx, cy = util.RotateVector(cx, cy, angle)
            cx, cy = cx + xOff, cy + yOff
            modCoords[#modCoords + 1] = cx
            modCoords[#modCoords + 1] = cy
        end
        comp.shape = love.physics.newPolygonShape(unpack(modCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, comp.def.density)

    comp.nbhd = IterableMap.New()

    comp.maxHealth   = params.maxHealthOverride or (comp.def.maxHealth*scaleFactor)
    comp.health      = params.health or comp.maxHealth
    comp.activeKey   = params.activeKey
    comp.isPlayer    = params.isPlayer
    comp.playerShip  = params.playerShip
    comp.xScale      = params.xScale
    comp.scaleFactor = scaleFactor

    local fixtureData = params.fixtureData or {}
    fixtureData.noAttach = comp.def.noAttach
    fixtureData.noSelect = comp.def.noSelect
    fixtureData.comp = comp
    comp.fixture:setUserData(fixtureData)

    return comp
end

local junkIndex = 0
local function MakeJunk(world, compDefName, x, y, angle, vx, vy, vangle, params)
    junkIndex = junkIndex + 1

    local junkBody = love.physics.newBody(world, x, y, "dynamic")
    params = params or {}
    params.fixtureData = {junkIndex = junkIndex, compDefName = compDefName}

    local comp = SetupComponent(junkBody, compDefName, params)
    junkBody:setAngle(angle)
    junkBody:setLinearVelocity(vx, vy)
    junkBody:setAngularVelocity(vangle)
    
    local components = IterableMap.New()
    components.Add(comp.index, comp)
    return {
        junkIndex = junkIndex,
        body = junkBody,
        components = components
    }
end

local function GetRandomComponent(dist)
    local totalSum = 0
    for i = 1, #compConfigList do
        totalSum = totalSum + compConfigList[i].getOccurrence(dist)
    end

    local ran = math.random()*totalSum
    for i = 1, #compConfigList do
        ran = ran - compConfigList[i].getOccurrence(dist)
        if ran < 0 then
            return compConfigList[i].name
        end
    end

    local num = math.random(1, #compConfigList)
    return compConfigList[num].name
end

local function MakeRandomJunk(world, midX, midY, size)
    local posX = math.random()*size + midX - size/2
    local posY = math.random()*size + midY - size/2

    local dist = util.AbsVal(posX, posY)
    if util.JunkDensityFunc(dist) <= math.random() then
        return
    end

    local compDefName = GetRandomComponent(dist)
    return MakeJunk(world, compDefName, posX, posY, math.random()*2*math.pi, math.random()*25, math.random()*25, math.random()*0.3*math.pi)
end

local regionsWithJunk = {}
local function ExpandJunkspace(world, junkList, px, py)

    --Region 0,0 is centered on 0,0; has top left corner at -5000,-5000.
    local REGION_SIZE = 1500
    local function WorldPositionToRegionIndex(x, y)
        return math.floor((x+(REGION_SIZE/2))/REGION_SIZE),math.floor((y+(REGION_SIZE/2))/REGION_SIZE)
    end
    local prX, prY = WorldPositionToRegionIndex(px, py)
    --[[
    for every junk, if it is not in a region adjacent to the player, delete it
    ]]--
    local toDestroy = {}
    for k, v in pairs(junkList) do
        local jrX, jrY = WorldPositionToRegionIndex(v.body:getX(),v.body:getY())

        if prX - jrX > 1 or jrX - prX > 1 or prY - jrY > 1 or jrY - prY > 1 then
            v.body:destroy()
            toDestroy[#toDestroy+1] = k
        end
    end
    for i, k in ipairs(toDestroy) do
        junkList[k] = nil
    end
    --[[
    for every region not adjacent to the player;
     remove that region from regionsWithJunk
    ]]--
    local xRegionsToKill = {}
    local xyRegionsToKill = {}

    for xR, ys in pairs(regionsWithJunk) do
        if prX - xR > 1 or prX - xR > 1 then
            xRegionsToKill[xR] = true
        else
            xyRegionsToKill[xR] = xyRegionsToKill[xR] or {}
            for yR, v in pairs(ys) do
                if prY - yR > 1 or prY - yR > 1 then
                    xyRegionsToKill[xR][yR] = true
                end
            end
        end
    end
    for x, v in pairs(xRegionsToKill) do
        regionsWithJunk[x] = nil
    end
    for x, ys in pairs(xyRegionsToKill) do
        for y, v in pairs(ys) do
            regionsWithJunk[x][y] = nil
        end
    end
    --[[
    for every region adjacent to the player;
    if the region does not already have junk,
      add junk to that region, and update regionsWithJunk
    ]]--
    for x = -1, 1 do
        for y = -1, 1 do
            if not (regionsWithJunk[prX+x] and regionsWithJunk[prX+x][prY+y]) then
                local JUNK_PER_REGION = 100
                for i = 1, JUNK_PER_REGION do
                    local junk = MakeRandomJunk(world, (prX+x)*REGION_SIZE, (prY+y)*REGION_SIZE, REGION_SIZE)
                    if junk then
                        junkList[junk.junkIndex] = junk
                    end
                end
                if not regionsWithJunk[prX+x] then regionsWithJunk[prX+x] = {} end
                regionsWithJunk[prX+x][prY+y] = true
            end
        end
    end
end

local function SetupPlayer(world, junkList)
    local body = love.physics.newBody(world, 0, 0, "dynamic")
    body:setAngularVelocity(0.4)

    local bodyDir = math.random()*2*math.pi

    body:setLinearVelocity(util.ToCart(bodyDir, 35))

    local posX, posY = util.ToCart(bodyDir, 800)
    local vx, vy = util.ToCart(bodyDir + math.pi, 35)

    local junk = MakeJunk(world, "booster", posX, posY, math.random()*2*math.pi, vx, vy, math.random()*0.1*math.pi)
    junkList[junk.junkIndex] = junk

    local components = IterableMap.New()
    local newComp = SetupComponent(body, "player", {isPlayer = true, fixtureData = {isPlayer = true, compDefName = compDefName}})
    components.Add(newComp.index, newComp)

    return {
        body = body,
        components = components,
    }
end

--------------------------------------------------
-- Input
--------------------------------------------------

local function ActivateComponent(ship, comp, junkList, player, dt, enabled, world)
    local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
    local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
    local angle = ship.body:getAngle() + comp.angle
    vx, vy = util.RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
    if enabled then
        comp.def.onFunction(comp, ship.body, ox + vx, oy + vy, angle, junkList, player, dt, world)
    elseif comp.def.offFunction then
        comp.def.offFunction(comp, ship.body, ox + vx, oy + vy, angle, junkList, player, dt, world)
    end
end

local function UpdateComponentActivation(player, junkList, player, dt, world)
    local ship = player.ship
    if not ship then
        return
    end

    for _, comp in ship.components.Iterator() do
        if comp.def.holdActivate then
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                ActivateComponent(ship, comp, junkList, player, dt, true, world)
                comp.activated = true
            else
                comp.activated = false
            end
        elseif comp.def.toggleActivate and comp.activated then
            ActivateComponent(ship, comp, junkList, player, dt, true, world)
        end

        if (not comp.activated) and comp.def.offFunction then
            ActivateComponent(ship, comp, junkList, player, dt, false, world)
        end
    end
end

local function KeyPressed(player, junkList, key)
    if not player.ship then
        return
    end

    if player.ship and player.needKeybind and player.onComponent then
        local comp = player.onComponent
        if comp and comp.def.text and not comp.activeKey then
            comp.activeKey = key
            player.needKeybind = false
        end
    end

    local onlyActivate = false
    for _, comp in player.ship.components.Iterator() do
        if comp.def.toggleActivate and comp.activeKey == key then
            comp.activated = not comp.activated
            if comp.activated then
                onlyActivate = true
            end
        end
    end

    if onlyActivate then
        for _, comp in player.ship.components.Iterator() do
            if comp.def.toggleActivate and comp.activeKey == key then
                comp.activated = true
            end
        end
    end
end

local function TestJunkClick(junk)
    junk.selected = not junk.selected
    print("junk selected", junk.body:getX(), junk.body:getY())
end

local moveAttemptAngles = {
    0,
    0.06*math.pi,
    -0.06*math.pi,
    -0.12*math.pi,
    0.12*math.pi,
    0.18*math.pi,
    -0.18*math.pi,
    -0.24*math.pi,
    0.24*math.pi,
    0.3*math.pi,
    -0.3*math.pi,
}

local function AttemptMoveInDirection(player, px, py, speed, faceAngle, newAngle)
    local dx, dy = util.ToCart(newAngle, speed)
    local nx, ny = px + dx, py + dy

    local onShip, comp, compDist = util.GetNearestComponent(player.ship, px, py)
    local newOnShip, newComp, newCompDist = util.GetNearestComponent(player.ship, nx, ny)
    
    if newCompDist and compDist and (newCompDist > compDist - speed*0.7) then
        if not util.IsPointOnShip(player.ship, nx, ny) then
            return false
        end
    end

    player.joint:destroy()

    player.guy.body:setAngle(faceAngle)
    player.guy.body:setX(nx)
    player.guy.body:setY(ny)

    player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)

    return true
end

local function UpdateMovePlayerGuy(player, mx, my)
    --drawSystem.PlayAnimation("explosion", mx, my)
    if not love.mouse.isDown(1) then
        return
    end
    if not player.ship then
        return
    end

    local px, py = player.guy.body:getX(), player.guy.body:getY()
    local norm = util.Dist(mx, my, px, py)
    local speed = player.crawlSpeed
    if norm < player.crawlSpeed*0.5 then
        return
    elseif norm < player.crawlSpeed then
        speed = norm
    end

    local dx, dy = (mx - px)/norm, (my - py)/norm
    local newAngle = util.Angle(dx, dy)

    for i = 1, #moveAttemptAngles do
        if AttemptMoveInDirection(player, px, py, speed, newAngle, newAngle + moveAttemptAngles[i]) then
            return
        end
    end
    
    player.joint:destroy()
    player.guy.body:setAngle(newAngle)
    player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)
end

local function UpdatePlayerComponentAttributes(player)
    if not player.ship then
        player.needKeybind = false
        player.onComponent = false
        return
    end
    local px, py = player.guy.body:getX(), player.guy.body:getY()
    local onShip, comp, compDist = util.GetNearestComponent(player.ship, px, py, true)

    if not comp then
        player.needKeybind = false
        player.onComponent = false
        return
    end
    player.onComponent = comp

    if comp.def.text and not comp.activeKey then
        player.needKeybind = true
        return
    end
    player.needKeybind = false
end

--------------------------------------------------
-- Graph Functions
--------------------------------------------------

local function AddLogicalConnection(comp1, comp2)
    comp1.nbhd.Add(comp2.index, comp2)
    comp2.nbhd.Add(comp1.index, comp1)
end

local function DeleteComponent(ship, delComp)
    for _, comp in delComp.nbhd.Iterator() do
        comp.nbhd.Remove(delComp.index)
    end

    ship.components.Remove(delComp.index)
    delComp.fixture:destroy()
end

local function FloodFromPoint(comp, floodVal)
    if comp.floodfillVal then
        return false
    end
    local front = {}
    front[#front + 1] = comp

    while #front > 0 do
        local vertex = front[#front]
        vertex.floodfillVal = floodVal
        
        front[#front] = nil
        for _, comp in vertex.nbhd.Iterator() do
            if (not comp.floodfillVal) then
                front[#front + 1] = comp
            end
        end
    end

    return floodVal
end

local function GetGuyComponent(player)
    local onShip, closestComp, closestDist = util.GetNearestComponent(player.ship, player.guy.body:getX(), player.guy.body:getY())
    return closestComp
end

local function RemoveComponent(world, player, junkList, ship, delComp)
    local xWorld, yWorld = ship.body:getWorldPoint(delComp.xOff, delComp.yOff)
    drawSystem.PlayAnimation("explosion", xWorld + math.random()*4 - 2, yWorld + math.random()*4 - 2)
    
    DeleteComponent(ship, delComp)
    if ship.components.IsEmpty() then
        if ship.junkIndex then
            ship.body:destroy()
            junkList[ship.junkIndex] = nil
        else
            player.ship.body:destroy()
            player.ship = nil
            player.joint = nil
        end
    end

    if (not ship.playerShip) or (not player.ship) then
        return
    end
    
    for _, comp in ship.components.Iterator() do
        comp.floodfillVal = false
    end

    local guyComponent = GetGuyComponent(player)
    FloodFromPoint(guyComponent, 1)

    local maxIndex, keyByIndex, dataByKey = ship.components.GetBarbarianData()
    for i = maxIndex, 1, -1 do
        local comp = dataByKey[keyByIndex[i]]
        if not comp.floodfillVal then
            if not comp.def.isGirder then
                local x, y = ship.body:getWorldPoint(comp.xOff, comp.yOff)
                local vx, vy = ship.body:getLinearVelocity()
                local angle = ship.body:getAngle() + comp.angle

                local junk = MakeJunk(world, comp.def.name, x, y, angle, vx, vy, ship.body:getAngularVelocity(), 
                    {
                        health = comp.health,
                        scaleFactor = comp.scaleFactor,  
                    }
                )
                junkList[junk.junkIndex] = junk
            end
            DeleteComponent(ship, comp)
        end
    end
end

local function DamageComponent(world, player, junkList, ship, comp, damage)
    if comp.phaseState then
        damage = 1000000
    end
    
    comp.health = comp.health - damage
    if comp.health > 0 then
        return
    end

    RemoveComponent(world, player, junkList, ship, comp)
end

--------------------------------------------------
-- Collisions
--------------------------------------------------

local collisionToAdd = IterableMap.New()

local function AddGirderToPos(ship, playerShip, dist, x1, y1, x2, y2)
    local mx, my = (x1 + x2)/2, (y1 + y2)/2
    local worldAngle = util.Angle(x2 - x1, y2 - y1)

    local xOff, yOff = ship.body:getLocalPoint(mx, my)
    local angle = worldAngle - ship.body:getAngle()
    local compDefName = "girder"
    local def = compConfig[compDefName]

    local newGirder = SetupComponent(ship.body, compDefName, {
            playerShip = playerShip,
            fixtureData = {playerShip = playerShip, compDefName = compDefName},
            xOff = xOff,
            yOff = yOff,
            angle = angle,
            xScale = dist/def.girderReach,
        }
    )

    ship.components.Add(newGirder.index, newGirder)

    return newGirder
end

local function AddGirder(player, newComp, comp)
    local dist, x1, y1, x2, y2 = love.physics.getDistance(newComp.fixture, comp.fixture)

    if dist < player.girderAddDist then
        if dist < 3 then
            dist = 3
        end
        local newGirder = AddGirderToPos(player.ship, true, dist, x1, y1, x2, y2)
        AddLogicalConnection(newGirder, newComp)
        AddLogicalConnection(newGirder, comp)
        return true
    end
end

local function AddGirders(player, newComp)
    local on, nearestComp = util.GetNearestComponent(player.ship, player.guy.body:getX(), player.guy.body:getY())
    local girderAdded = false
    for _, comp in player.ship.components.Iterator() do
        if comp.index ~= newComp.index then
            if (not comp.def.isGirder) or (nearestComp and nearestComp.index == comp.index) then
                girderAdded = AddGirder(player, newComp, comp) or girderAdded
            end
        end
    end

    if not girderAdded then
        local onShip, closestComp, closestDist = util.GetNearestComponent(player.ship, player.guy.body:getX(), player.guy.body:getY())
        if closestComp then
            AddGirder(player, newComp, closestComp)
        end
    end
end

local function DoMerge(player, junkList, playerFixture, otherFixture, playerData, otherData)
    if not otherData.junkIndex then
        return true
    end
    local junk = junkList[otherData.junkIndex]

    if not player.ship then
        player.ship = junk
        player.ship.playerShip = true
        player.ship.junkIndex = nil
        junkList[otherData.junkIndex] = nil

        for _, comp in player.ship.components.Iterator() do
            comp.playerShip = true
            local fixtureData = comp.fixture:getUserData()
            fixtureData.playerShip = true
            fixtureData.junkIndex = nil
            comp.fixture:setUserData(fixtureData)

            player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)

            
            drawSystem.sendToConsole("> You cling desperately onto " .. comp.def.humanName .. ".", 5, captureColor)
            
            return true
        end
    end

    local playerBody = player.ship.body
    local junkBody = junk.body

    for _, comp in junk.components.Iterator() do
        local xOff, yOff = playerBody:getLocalPoint(junkBody:getWorldPoint(comp.xOff, comp.yOff))

        local angle = junkBody:getAngle() - playerBody:getAngle() + comp.angle

        local newComp = SetupComponent(playerBody, otherData.compDefName, {
                playerShip = true,
                fixtureData = {playerShip = true, compDefName = compDefName},
                xOff = xOff,
                yOff = yOff,
                angle = angle,
                health = comp.health,
                scaleFactor = comp.scaleFactor,
            }
        )
        
        player.ship.components.Add(newComp.index, newComp)

        drawSystem.sendToConsole("> Captured " .. comp.def.humanName .. ".", 5, captureColor)
        
        AddGirders(player, newComp)
    end
    
    otherFixture:getBody():destroy()
    junkList[otherData.junkIndex] = nil

    return true
end

local function ProcessCollision(key, data, index, world, player, junkList)
    local mainFixture, otherFixture, colDamage, colSpeed = data[1], data[2], data[3], data[4], data[5]
    if otherFixture:isDestroyed() or mainFixture:isDestroyed() then
        return true
    end
    local mainData  = mainFixture:getUserData()
    local otherData = otherFixture:getUserData()

    local playerCollision = (mainData.isPlayer or mainData.playerShip)
    local junkCollision = mainData.junkIndex
    local otherBullet = (otherData.bulletIndex)

    if not (playerCollision or junkCollision) then
        -- Must be bullet on bullet
        if mainFixture.bullet then
            util.DoBulletDamage(mainFixture.bullet)
        end
        if otherData.bullet then
            util.DoBulletDamage(otherData.bullet)
        end
        return true
    end

    if junkCollision then
        if otherBullet then
            local damage = util.DoBulletDamage(otherData.bullet)
            DamageComponent(world, player, junkList, junkList[mainData.junkIndex], mainData.comp, damage)
        elseif colSpeed > 120 then
            DamageComponent(world, player, junkList, junkList[mainData.junkIndex], mainData.comp, colDamage)
            DamageComponent(world, player, junkList, junkList[otherData.junkIndex], otherData.comp, colDamage)
        end
        return true
    end

    if otherBullet then
        local damage = util.DoBulletDamage(otherData.bullet)
        if not mainData.isPlayer then
            -- Is player ship
            DamageComponent(world, player, junkList, player.ship, mainData.comp, colDamage)
        end
        return true
    end

    -- Player or player ship is mainFixture
    if (not otherData.noAttach) and (mainData.isPlayer) then
        if DoMerge(player, junkList, mainFixture, otherFixture, mainData, otherData) then
            return true
        end
    end

    if not mainData.isPlayer then
        -- Is player ship
        if colSpeed > 40 then
            DamageComponent(world, player, junkList, player.ship, mainData.comp, colDamage)
            DamageComponent(world, player, junkList, junkList[otherData.junkIndex], otherData.comp, colDamage)
        end
    end

    return true
end

local function ProcessCollisions(world, player, junkList)
    collisionToAdd.Apply(ProcessCollision, world, player, junkList)
end

local function GetRelativeSpeed(coll, body1, body2)
    local cx1, cy1, cx2, cy2 = coll:getPositions()
    local mx, my = (cx1 + (cx2 or cx1))/2, (cy1 + (cy2 or cy1))/2

    local pvx, pvy = body1:getLinearVelocityFromWorldPoint(mx, my)
    local ovx, ovy = body2:getLinearVelocityFromWorldPoint(mx, my)
    local vx, vy = pvx - ovx, pvy - ovy
    return util.AbsVal(vx, vy)
end

local collIndex = 0
local function beginContact(a, b, coll)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}

    local aIsPlayer = (aData.isPlayer or aData.playerShip)
    local bIsPlayer = (bData.isPlayer or bData.playerShip)

    if aIsPlayer == bIsPlayer then
        if not aIsPlayer then
            local aData = a:getUserData()
            local speed = GetRelativeSpeed(coll, a:getBody(), b:getBody())
            local damage = math.max(10, speed - 60)
            if aData.junkIndex then
                collIndex = collIndex + 1
                collisionToAdd.Add(collIndex, {a, b, damage, speed})
            elseif bData.junkIndex then
                collIndex = collIndex + 1
              collisionToAdd.Add(collIndex, {b, a, damage, speed})
            else
                collIndex = collIndex + 1
                collisionToAdd.Add(collIndex, {a, b, damage, speed})
            end
        end
        return
    end

    local playerFixture = (aIsPlayer and a) or b
    local otherFixture  = (aIsPlayer and b) or a
    local otherData     = otherFixture:getUserData()

    local speed = GetRelativeSpeed(coll, playerFixture:getBody(), otherFixture:getBody())
    local damage = math.max(10, speed - 30)
    collIndex = collIndex + 1
    collisionToAdd.Add(collIndex, {playerFixture, otherFixture, damage, speed})
end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)
end

--------------------------------------------------
-- Updates
--------------------------------------------------

local function reset()
    componentIndex = 0
    junkIndex = 0
    collIndex = 0
    collisionToAdd = IterableMap.New()
    regionsWithJunk = {}
end

return {
    UpdateComponentActivation = UpdateComponentActivation,
    KeyPressed = KeyPressed,
    UpdateMovePlayerGuy = UpdateMovePlayerGuy,
    UpdatePlayerComponentAttributes = UpdatePlayerComponentAttributes,
    TestJunkClick = TestJunkClick,
    ProcessCollisions = ProcessCollisions,
    beginContact = beginContact,
    endContact = endContact,
    postSolve = postSolve,
    MakeJunk = MakeJunk,
    ExpandJunkspace = ExpandJunkspace,
    SetupPlayer = SetupPlayer,
    KeypressInput = KeypressInput,
    UpdateActivation = UpdateActivation,
    reset = reset,
}
