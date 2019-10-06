local compConfig, compConfigList = unpack(require("components"))

local function GetRandomComponent()
    local num = math.random(1, #compConfigList)
    return compConfigList[num].name
end

--------------------------------------------------
-- Component handling
--------------------------------------------------

local function UpdatePlayerComponentAttributes(player)
    player.needKeybind = false
    if player.ship then
        for _, comp in player.ship.components.Iterator() do
            if comp.def.text and not comp.activeKey then
                player.needKeybind = true
                break
            end
        end
    end

    if not player.needKeybind then
        setKeybind = false
    end
end

local componentIndex = 0
local function SetupComponent(body, compDefName, params, reuseTable)
    params = params or {}
    local comp = {}
    comp.def = compConfig[compDefName]

    comp.xOff = params.xOff or 0
    comp.yOff = params.yOff or 0
    comp.angle = params.angle or 0

    componentIndex = componentIndex + 1
    comp.index = componentIndex

    local xOff, yOff, angle = comp.xOff, comp.yOff, comp.angle
    if comp.def.circleShapeRadius then
        comp.shape = love.physics.newCircleShape(xOff, yOff, comp.def.circleShapeRadius)
    else
        local coords = comp.def.shapeCoords
        local modCoords = {}
        for i = 1, #coords, 2 do
            local cx, cy = coords[i], coords[i + 1]
            if params.xScale then
                cx = cx*params.xScale
            end
            cx, cy = util.RotateVector(cx, cy, angle)
            cx, cy = cx + xOff, cy + yOff
            modCoords[#modCoords + 1] = cx
            modCoords[#modCoords + 1] = cy
        end
        comp.shape = love.physics.newPolygonShape(unpack(modCoords))
    end
    comp.fixture = love.physics.newFixture(body, comp.shape, comp.def.density)

    comp.nbhd = IterableMap.New()

    comp.maxHealth   = params.maxHealthOverride or comp.def.maxHealth
    comp.health      = comp.maxHealth
    comp.activeKey   = params.activeKey
    comp.isPlayer    = params.isPlayer
    comp.playerShip  = params.playerShip
    comp.xScale      = params.xScale

    local fixtureData = params.fixtureData or {}
    fixtureData.noAttach = comp.def.noAttach
    fixtureData.noSelect = comp.def.noSelect
    fixtureData.comp = comp
    comp.fixture:setUserData(fixtureData)

    return comp
end

local junkIndex = 0
local function MakeJunk(world, compDefName, x, y, angle, vx, vy, vangle, reuseComponent)
    junkIndex = junkIndex + 1

    local junkBody = love.physics.newBody(world, x, y, "dynamic")

    local comp = SetupComponent(junkBody, compDefName, {fixtureData = {junkIndex = junkIndex, compDefName = compDefName}})
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

local function MakeRandomJunk(world, midX, midY, size, exclX, exclY, exclusionRad)
    --print("mrj",world, midX, midY, size, exclX, exclY, exclusionRad)
    local posX = math.random()*size + midX - size/2
    local posY = math.random()*size + midY - size/2

    if util.AbsVal(posX - exclX, posY - exclY) >= exclusionRad then
        local compDefName = GetRandomComponent()
        return MakeJunk(world, compDefName, posX, posY, math.random()*2*math.pi, math.random()*25, math.random()*25, math.random()*0.3*math.pi)
    end
    return nil
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
                    local junk = MakeRandomJunk(world, (prX+x)*REGION_SIZE, (prY+y)*REGION_SIZE, REGION_SIZE, px, py, 1000)
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

    body:setLinearVelocity(util.ToCart(bodyDir, 80))

    local posX, posY = util.ToCart(bodyDir, 800)
    local vx, vy = util.ToCart(bodyDir + math.pi, 40)

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

local function ActivateComponent(ship, comp, junkList, player)
    local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
    local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
    local angle = ship.body:getAngle() + comp.angle
    vx, vy = util.RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
    comp.def.onFunction(comp, ship.body, ox + vx, oy + vy, angle, junkList, player)
end

toggleKeys = {}
local function UpdateInput(ship, junkList, player)
    if not ship then
        return
    end
    
    for _, comp in ship.components.Iterator() do
        if comp.def.holdActivate then
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                ActivateComponent(ship, comp, junkList, player)
                comp.activated = true
            else
                comp.activated = false
            end
        elseif comp.def.toggleActivate then
            if comp.activated == true then
                ActivateComponent(ship, comp, junkList, player)
            end    
        
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                for i, key in ipairs(toggleKeys) do
                    if key == comp.activeKey then
                        goto keyheld
                    end
                end
                
                table.insert(toggleKeys, comp.activeKey)
                
                if comp.activated == false then
                    comp.activated = true
                else
                    comp.activated = false
                end
                
                ::keyheld::
                
            else
                for i, key in ipairs(toggleKeys) do
                    if key == comp.activeKey then
                        table.remove(toggleKeys, i)
                    end
                end
            end
        end
    end
end

local function TestJunkClick(junk)
    junk.selected = not junk.selected
    print("junk selected", junk.body:getX(), junk.body:getY())
end

local function UpdateMovePlayerGuy(player, mx, my)
    if not love.mouse.isDown(1) then
        return
    end
    if not player.ship then
        return
    end

    local px, py = player.guy.body:getX(), player.guy.body:getY()
    local norm = util.Dist(mx, my, px, py)
    if norm < 2*player.crawlSpeed then
        return
    end
    local dx, dy = (mx - px)/norm, (my - py)/norm
    local nx, ny = px + dx*player.crawlSpeed, py + dy*player.crawlSpeed

    local onShip, compIndex, compDist = util.GetNearestComponent(player.ship, px, py)
    local newOnShip, newCompIndex, newCompDist = util.GetNearestComponent(player.ship, nx, ny)

    local newAngle = util.Angle(dx, dy)

    player.joint:destroy()

    player.guy.body:setAngle(newAngle)
    if newOnShip or (newCompDist < compDist) then
        player.guy.body:setX(nx)
        player.guy.body:setY(ny)
    end

    player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)
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

    for _, comp in ship.components.Iterator() do
        if not comp.floodfillVal then
            if not comp.def.isGirder then
                local x, y = ship.body:getWorldPoint(comp.xOff, comp.yOff)
                local vx, vy = ship.body:getLinearVelocity()
                local angle = ship.body:getAngle() + comp.angle

                local junk = MakeJunk(world, comp.def.name, x, y, angle, vx, vy, ship.body:getAngularVelocity(), comp)
                junkList[junk.junkIndex] = junk
            end 
            DeleteComponent(ship, comp)
        end
    end
end

local function DamageComponent(world, player, junkList, ship, comp, damage)
    comp.health = comp.health - damage
    if comp.health > 0 then
        return
    end

    RemoveComponent(world, player, junkList, ship, comp)
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local collisionToAdd = IterableMap.New()

local function AddGirderToPos(ship, playerShip, dist, x1, y1, x2, y2)
    local mx, my = (x1 + x2)/2, (y1 + y2)/2
    local worldAngle = util.Angle(x2 - x1, y2 - y1)

    local xOff, yOff = ship.body:getLocalPoint(mx, my)
    local angle = worldAngle - ship.body:getAngle()
    local compDefName = "girder"

    local newGirder = SetupComponent(ship.body, compDefName, {
            playerShip = playerShip,
            fixtureData = {playerShip = playerShip, compDefName = compDefName},
            xOff = xOff,
            yOff = yOff,
            angle = angle,
            xScale = dist/25,
        }
    )

    ship.components.Add(newGirder.index, newGirder)

    return newGirder
end

local function AddGirders(player, newComp)
    local on, nearestComp = util.GetNearestComponent(player.ship, player.guy.body:getX(), player.guy.body:getY())
    for _, comp in player.ship.components.Iterator() do
        if comp ~= newComp.index then
            if (not comp.def.isGirder) or (nearestComp and nearestComp.index == comp.index) then
                local dist, x1, y1, x2, y2 = love.physics.getDistance(newComp.fixture, comp.fixture)

                if dist > 3 and dist < player.girderAddDist then
                    local newGirder = AddGirderToPos(player.ship, true, dist, x1, y1, x2, y2)
                    AddLogicalConnection(newGirder, newComp)
                    AddLogicalConnection(newGirder, comp)
                end
            end
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

            UpdatePlayerComponentAttributes(player)
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
            }
        )
        player.ship.components.Add(newComp.index, newComp)
        
        AddGirders(player, newComp)
    end
    
    otherFixture:getBody():destroy()
    junkList[otherData.junkIndex] = nil

    UpdatePlayerComponentAttributes(player)

    return true
end

local function ProcessCollision(key, data, index, world, player, junkList)
    local playerFixture, otherFixture, colSpeed = data[1], data[2], data[3]
    if otherFixture:isDestroyed() or playerFixture:isDestroyed() then
        return true
    end
    local playerData = playerFixture:getUserData()
    local otherData  = otherFixture:getUserData()

    if (not otherData.noAttach) and (playerData.isPlayer) then
        if DoMerge(player, junkList, playerFixture, otherFixture, playerData, otherData) then
            return true
        end
    end

    local damage = colSpeed
    
    if not playerData.isPlayer then
        DamageComponent(world, player, junkList, player.ship, playerData.comp, damage)
        DamageComponent(world, player, junkList, junkList[otherData.junkIndex], otherData.comp, damage)
    end

    return true
end

local function ProcessCollisions(world, player, junkList)
    collisionToAdd.Apply(ProcessCollision, world, player, junkList)
end

local function beginContact(a, b, coll)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}


    local aIsPlayer = (aData.isPlayer or aData.playerShip)
    local bIsPlayer = (bData.isPlayer or bData.playerShip)

    if aIsPlayer == bIsPlayer then
        return
    end

    local playerFixture = (aIsPlayer and a) or b
    local otherFixture  = (aIsPlayer and b) or a
    local otherData     = otherFixture:getUserData()

    if not otherData.junkIndex then
       return 
    end

    local cx1, cy1, cx2, cy2 = coll:getPositions()
    local mx, my = (cx1 + (cx2 or cx1))/2, (cy1 + (cy2 or cy1))/2

    local pvx, pvy = playerFixture:getBody():getLinearVelocityFromWorldPoint(mx, my)
    local ovx, ovy = otherFixture:getBody():getLinearVelocityFromWorldPoint(mx, my)
    local vx, vy = pvx - ovx, pvy - ovy
    local speed = util.AbsVal(vx, vy)

    collisionToAdd.Add(otherData.junkIndex, {playerFixture, otherFixture, speed})
end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)
end

--------------------------------------------------
-- Updates
--------------------------------------------------

return {
    SetupComponent = SetupComponent,
    UpdateInput = UpdateInput,
    UpdateMovePlayerGuy = UpdateMovePlayerGuy,
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
}
