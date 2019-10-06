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
local function SetupComponent(body, compDefName, params)
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

local function MakeJunk(world, index, compDefName, x, y, angle, vx, vy, vangle)
    local junkBody = love.physics.newBody(world, x, y, "dynamic")

    local comp = SetupComponent(junkBody, compDefName, {fixtureData = {junkIndex = index, compDefName = compDefName}})
    junkBody:setAngle(angle)
    junkBody:setLinearVelocity(vx, vy)
    junkBody:setAngularVelocity(vangle)
    
    local components = IterableMap.New()
    components.Add(comp.index, comp)
    return {
        junkIndex = index,
        body = junkBody,
        components = components
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
    comp.def:onFunction(ship.body, ox + vx, oy + vy, angle, junkList, player)
end


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
            print(comp.activeKey)
            
            if comp.activeKey then
                print(love.keyboard.isDown(comp.activeKey))
            end
            
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                print(comp.activated)
                
                if comp.activated == true then
                    comp.activated = false
                else
                    ActivateComponent(ship, comp, junkList, player)
                    comp.activated = true
                end
            end
        end
    end
end

--[[
local function KeypressInput(ship, key, isRepeat)
    if not ship then
        return
    end
    for _, comp in ship.components.Iterator() do
        if comp.def.holdActivate then
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
                ActivateComponent(ship, comp)
                comp.activated = true
            else
                comp.activated = false
            end
        end
    end
end
]]--

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

local function FloodFromPoint(comp, floodVal, ignoreIndex)
    if comp.floodfillVal then
        return false
    end
    local front = {}
    front[#front + 1] = comp

    while #front > 0 do
        for _, comp in front[#front].nbhd.Iterator() do
            if (not comp.floodfillVal) and (not ignoreIndex[comp.index]) then
                front[#front + 1] = comp
            end
        end
        comp.floodfillVal = floodVal
        front[#front] = nil
    end

    return floodVal
end

local function RemoveComponent(ship, delComp)
    for _, comp in ship.components.Iterator() do
        comp.floodfillVal = false
    end

    local floodValues = {}
    --for _, comp in delComp.nbhd.Iterator() do
    --    local floodIndex = FloodFromPoint(comp, comp.index, {[delComp.index] = true})
    --    if floodIndex then
    --        floodValues[#floodValues + 1] = floodIndex
    --    end
    --end

    if #floodValues == 0 then
        --DeleteComponent(ship, delComp)
        if ship.components.IsEmpty() then
            if ship.junkIndex then
                --ship.junkIndex
            else

            end
        end
        return
    end
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
    for _, comp in player.ship.components.Iterator() do
        if comp ~= newComp.index then
            if not comp.def.isGirder then
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

local function ProcessCollision(key, data, index, player, junkList)
    local playerFixture, otherFixture = data[1], data[2]
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
    
    if not playerData.isPlayer then
        RemoveComponent(player.ship, playerData.comp)
        RemoveComponent(junkList[otherData.junkIndex], otherData.comp)
    end

    return true
end

local function ProcessCollisions(player, junkList)
    collisionToAdd.Apply(ProcessCollision, player, junkList)
end

local function beginContact(a, b, col1)
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

    collisionToAdd.Add(otherData.junkIndex, {playerFixture, otherFixture})
end

local function endContact(a, b, col1)
end

--------------------------------------------------
-- Updates
--------------------------------------------------

--[[
function UpdateActivation(player, junkList)

    local ship = player.ship
    
    if not ship then
        return
    end
    
    for _, comp in ship.components.Iterator() do
        if comp.def.toggleActivate and comp.activated then
            if comp.activeKey and love.keyboard.isDown(comp.activeKey) then
            end
        end
    end
end
]]--

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
    KeypressInput = KeypressInput,
    UpdateActivation = UpdateActivation,
}
