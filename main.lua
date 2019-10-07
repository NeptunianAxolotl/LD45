local debugHitboxKey = 'm'
local debugEnabled = false

compConfig, compConfigList = unpack(require("components"))
animationDefs = {}

IterableMap = require("IterableMap")
audioSystem = require("audio")
util = require("util")


SUPER_DEBUG_ENABLED = false

font = require("font")

introTimer = 0
introList = 0

notifyColor = {
    r = 1,
    g = 1,
    b = 1,
}
captureColor = {
    r = 0.8,
    g = 0.8,
    b = 0.8,

}
goalColor = {
    r = 0.2,
    g = 0.95,
    b = 0.2,
}

drawSystem = require("draw")
firstTracker = require("firstTracker")
gameSystem = require("game")

local world
local player, junkList

local function SetupVars()
    player = {
        guy = nil,
        ship = nil,
        needKeybind = false,
        crawlSpeed = 5,
        girderAddDist = 60,
    }

    junkList = {}
end

--------------------------------------------------
-- Draw
--------------------------------------------------

local lastDt = 0
function love.draw()
        
    --intro console messages
    if introList == 0 and introTimer > 0.5 then
        drawSystem.sendToConsole("> They told you the freighter was safe.", 3, notifyColor) 
        introList = introList + 1
    end
        
    if introList == 1 and introTimer > 1.5 then
        drawSystem.sendToConsole("> You knew better.", 3, notifyColor) 
        introList = introList + 1
    end
        
    if introList == 2 and introTimer > 5 then
        drawSystem.sendToConsole("> Now, you have nothing.", 3, notifyColor) 
        introList = introList + 1
    end
    
    if introList == 3 and introTimer > 13 then
        drawSystem.sendToConsole("> Maybe you can salvage something from this wreck.", 4, notifyColor) 
        introList = introList + 1
    end
    
    drawSystem.draw(world, player, junkList, debugEnabled, lastDt)
    
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()
    
    winPoints = {}
    winPoints[1] = 0
    winPoints[2] = 0
    winPoints[3] = 0
    winPoints[4] = winHeight
    winPoints[5] = winWidth
    winPoints[6] = winHeight
    winPoints[7] = winWidth
    winPoints[8] = 0
    
    love.graphics.setColor(0,0,0, math.max(0, 1 - ((introTimer - 5) / 1.5)))
    love.graphics.polygon("fill", winPoints)
    love.graphics.setColor(1,1,1)
    
    drawSystem.drawConsole()

end

--------------------------------------------------
-- Input
--------------------------------------------------

function love.mousemoved(x, y, dx, dy, istouch )
    --ps:moveTo(x,y)
end

function love.mousereleased(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
    if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        RestartFunc()
        return
    end

    if key == debugHitboxKey and not isRepeat then
        debugEnabled = not debugEnabled
    end

    gameSystem.KeyPressed(player, junkList, key, isRepeat)
end

local function MouseHitFunc(fixture)
    local fixtureData = fixture:getUserData()
    if fixtureData.junkIndex and not fixtureData.noSelect then
        -- Todo: point intersection
        if gameSystem.TestJunkClick(junkList[fixtureData.junkIndex]) then
            return false
        end
    end

    return true
end

function love.mousepressed(x, y, button, istouch, presses)
    --local mx, my = drawSystem.WindowSpaceToWorldSpace(x, y)
    -- clicking on junk
    --world:queryBoundingBox(mx - 2, my - 2, mx + 2, my + 2, MouseHitFunc)
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local function beginContact(a, b, coll)
    gameSystem.beginContact(a, b, coll)
end

local function endContact(a, b, coll)
end

local function preSolve(a, b, coll)
end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)
    gameSystem.postSolve(a, b, coll,  normalimpulse, tangentimpulse)
end

--------------------------------------------------
-- Update
--------------------------------------------------
function love.update(dt)
    introTimer = introTimer + dt
    
    lastDt = dt
    local px, py = (player.ship or player.guy).body:getWorldCenter()
    gameSystem.ExpandJunkspace(world, junkList, px, py)
    gameSystem.UpdateComponentActivation(player, junkList, player, dt, world)

    util.UpdateObjectives(player, junkList)
    util.UpdatePhasedObjects(dt)
    util.UpdateBullets(dt)

    local mx, my = drawSystem.WindowSpaceToWorldSpace(love.mouse.getX(), love.mouse.getY())
    gameSystem.UpdateMovePlayerGuy(player, mx, my)
    gameSystem.UpdatePlayerComponentAttributes(player)

    if dt < 0.4 then
        world:update(dt)
    end
    gameSystem.ProcessCollisions(world, player, junkList)
    
    util.UpdatePhasedObjects(dt)
    util.UpdateBullets(dt)

    local mx, my = drawSystem.WindowSpaceToWorldSpace(love.mouse.getX(), love.mouse.getY())
    gameSystem.UpdateMovePlayerGuy(player, mx, my)
    gameSystem.UpdatePlayerComponentAttributes(player)

    if dt < 0.4 then
        world:update(dt)
    end
    gameSystem.ProcessCollisions(world, player, junkList)

    firstTracker.Update(player, dt)
    
    --print("distance: " .. util.AbsVal(px, py))

    if util.GetObjectives().IsEmpty() then
        util.AddObjective("A phase displacement device.", "displayer", 1)
        util.AddObjective("An exotic matter battery", "laser_battery", 3)
    end
    --print ("distance: " .. util.AbsVal(px, py))
end

--------------------------------------------------
-- Resource Loading
--------------------------------------------------

local function LoadAnimation(image, width, height, duration, scaleMin, scaleMax)
    image = love.graphics.newImage(image)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
    animation.scaleMin = scaleMin or 1
    animation.scaleMax = scaleMax or 1

    animation.xOff, animation.yOff = width/2, height/2

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1

    return animation
end

local function LoadComponentResources()
    local compConfig, compConfigList = unpack(require("components"))
    for name, def in pairs(compConfig) do
        def.imageOff = love.graphics.newImage(def.imageOff)
        def.imageOn = love.graphics.newImage(def.imageOn)
        if def.imageDmg then
            for i = 1, #def.imageDmg do
                def.imageDmg[i] = love.graphics.newImage(def.imageDmg[i])
            end
            def.damBuckets = #def.imageDmg + 1
        end
        if def.imageExtra then
            for i = 1, #def.imageExtra do
                def.imageExtra[i] = love.graphics.newImage(def.imageExtra[i])
            end
        end
    end
end

local function LoadResources()
    LoadComponentResources()

    local animationList = require("animations")
    for i = 1, #animationList do
        local data = animationList[i]
        animationDefs[data.name] = LoadAnimation(data.image, data.width, data.height, data.duration, data.scaleMin, data.scaleMax)
    end
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
end

function love.load()   
    math.randomseed(os.clock())
    --love.graphics.setFont(love.graphics.newFont('Resources/fonts/pixelsix00.ttf'))
    util.load()
    audioSystem.load()
    LoadResources()

    SetupVars()
    SetupWorld()

    player.guy = gameSystem.SetupPlayer(world, junkList)
end

function RestartFunc()
    world:destroy()

    SetupVars()
    SetupWorld()

    gameSystem.reset()
    drawSystem.reset()
    firstTracker.reset{}
    util.reset()

    player.guy = gameSystem.SetupPlayer(world, junkList)
end
