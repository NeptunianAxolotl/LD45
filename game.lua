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
        for i = 1, #player.ship.components do
            local comp = player.ship.components[i]
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

    comp.activeKey   = params.activeKey
    comp.isPlayer    = params.isPlayer
    comp.playerShip  = params.playerShip

    local fixtureData = params.fixtureData or {}
    fixtureData.noAttach = comp.def.noAttach
    fixtureData.noSelect = comp.def.noSelect
    fixtureData.comp = comp
    comp.fixture:setUserData(fixtureData)

    return comp
end

local function MakeJunk(world, index, compDefName, x, y, angle, vx, vy, vangle)
    local junkBody = love.physics.newBody(world, x, y, "dynamic")

    local comp = SetupComponent(junkBody, compDefName, {fixtureData = {junkIndex = index, compDefName = compDefName}})
    junkBody:setAngle(angle)
    junkBody:setLinearVelocity(vx, vy)
    junkBody:setAngularVelocity(vangle)
    return {
        body = junkBody,
        components = {comp}
    }
end

local function MakeRandomJunk(world, index, midX, midY, size, exclusionRad)
    local posX = math.random()*size + midX - size/2
    local posY = math.random()*size + midY - size/2

    while util.AbsVal(posX - midX, posY - midY) < exclusionRad do
        posX = math.random()*size + midX - size/2
        posY = math.random()*size + midY - size/2
    end

    local compDefName = GetRandomComponent()
    return MakeJunk(world, index, compDefName, posX, posY, math.random()*2*math.pi, math.random()*25, math.random()*25, math.random()*0.3*math.pi)
end

local function SetupPlayer(world, junkList, junkIndex)
    local body = love.physics.newBody(world, 0, 0, "dynamic")
    body:setAngularVelocity(0.4)

    local bodyDir = math.random()*2*math.pi

    body:setLinearVelocity(util.ToCart(bodyDir, 80))

    local posX, posY = util.ToCart(bodyDir, 800)
    local vx, vy = util.ToCart(bodyDir + math.pi, 40)
    junkList[junkIndex] = MakeJunk(world, junkIndex, "booster", posX, posY, math.random()*2*math.pi, vx, vy, math.random()*0.1*math.pi)

    local components = {}
    components[1] = SetupComponent(body, "player", {isPlayer = true, fixtureData = {isPlayer = true, compDefName = compDefName}})

    return {
        body = body,
        components = components,
    }
end

--------------------------------------------------
-- Input
--------------------------------------------------

local function UpdateInput(ship)
    if not ship then
        return
    end
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

    if (not newOnShip) and (compDist < newCompDist) then
        return
    end
    local newAngle = util.Angle(dx, dy)

    player.joint:destroy()

    player.guy.body:setAngle(newAngle)
    player.guy.body:setX(nx)
    player.guy.body:setY(ny)

    player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local collisionToAdd = IterableMap.New()

local function DoMerge(player, junkList, playerFixture, otherFixture)
    if otherFixture:isDestroyed() then
        return true
    end

    local otherData = otherFixture:getUserData()
    if not otherData.junkIndex then
        return true
    end
    local junk = junkList[otherData.junkIndex]


    if not player.ship then
        player.ship = junk
        junkList[otherData.junkIndex] = nil

        local comp = player.ship.components
        for i = 1, #comp do
            comp[i].playerShip = true
            local fixtureData = comp[i].fixture:getUserData()
            fixtureData.playerShip = true
            fixtureData.junkIndex = nil
            comp[i].fixture:setUserData(fixtureData)

            player.joint = love.physics.newWeldJoint(player.ship.body, player.guy.body, player.guy.body:getX(), player.guy.body:getY(), false)

            UpdatePlayerComponentAttributes(player)
            return true
        end
    end

    local playerBody = player.ship.body
    local junkBody = junk.body

    for i = 1, #junk.components do
        local comp = junk.components[i]
        local xOff, yOff = playerBody:getLocalPoint(junkBody:getWorldPoint(comp.xOff, comp.yOff))

        local angle = junkBody:getAngle() - playerBody:getAngle() + comp.angle

        player.ship.components[#player.ship.components + 1] = SetupComponent(playerBody, otherData.compDefName, {
                playerShip = true,
                fixtureData = {playerShip = true, compDefName = compDefName},
                xOff = xOff,
                yOff = yOff,
                angle = angle,
            }
        )
    end
    
    otherFixture:getBody():destroy()
    junkList[otherData.junkIndex] = nil

    UpdatePlayerComponentAttributes(player)

    return true
end

local function ProcessCollision(key, data, index, player, junkList)
    local playerFixture, otherFixture = data[1], data[2]
    if DoMerge(player, junkList, playerFixture, otherFixture) then
        return true
    end
end

local function ProcessCollisions(player, junkList)
    collisionToAdd.Apply(ProcessCollision, player, junkList)
end

local function beginContact(a, b, col1)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}
    if aData.noAttach or bData.noAttach then
        return
    end

    if not (aData.isPlayer or bData.isPlayer) then
        return
    end
    local playerFixture = (aData.isPlayer and a) or b
    local otherFixture  = (bData.isPlayer and a) or b
    local otherData     = otherFixture:getUserData()
    if otherData.playerShip then
        return
    end
    if not otherData.junkIndex then
       return 
    end

    collisionToAdd.Add(otherData.junkIndex, {playerFixture, otherFixture})
end

local function endContact(a, b, col1)
    local aData, bData = a:getUserData() or {}, b:getUserData() or {}
    if aData.noAttach or bData.noAttach then
        return
    end
    
    if not (aData.isPlayer or bData.isPlayer) then
        return
    end
    local playerFixture = (aData.isPlayer and a) or b
    local otherFixture  = (bData.isPlayer and a) or b
    local otherData     = otherFixture:getUserData()
    if otherData.playerShip then
        return
    end
    if not otherData.junkIndex then
       return 
    end
    
    collisionToAdd.Remove(otherData.junkIndex)
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
    MakeJunk = MakeJunk,
    MakeRandomJunk = MakeRandomJunk,
    SetupPlayer = SetupPlayer,
}
