local debugHitboxKey = 'm'
local debugEnabled = false

IterableMap = require("IterableMap")
util = require("util")

SUPER_DEBUG_ENABLED = false

font = require("font")

introTimer = 0
introList = 0

drawSystem = require("draw")
gameSystem = require("game")


local world
local player = {
    guy = nil,
    ship = nil,
    needKeybind = false,
    crawlSpeed = 5,
    girderAddDist = 60,
}

local junkList = {}
local junkIndex = 0

--------------------------------------------------
-- Draw
--------------------------------------------------

local lastDt = 0
function love.draw()
        
    --intro console messages
    if introList == 0 and introTimer > 0.5 then
        drawSystem.sendToConsole("> They told you the freighter was safe.", 3) 
        introList = introList + 1
    end
        
    if introList == 1 and introTimer > 1.5 then
        drawSystem.sendToConsole("> You knew better.", 3) 
        introList = introList + 1
    end
        
    if introList == 2 and introTimer > 5 then
        drawSystem.sendToConsole("> You hadn't boarded a commercial flight in years", 3) 
        introList = introList + 1
        end
        
    if introList == 3 and introTimer > 6 then
        drawSystem.sendToConsole("> without an emergency pressure suit stashed in your carry-on.", 3) 
        introList = introList + 1
    end
    
    if introList == 4 and introTimer > 9 then
        drawSystem.sendToConsole(">  Now, you have nothing.", 3) 
        introList = introList + 1
    end
    
    if introList == 5 and introTimer > 14 then
        drawSystem.sendToConsole("> Maybe you can salvage something from this wreck.", 4) 
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
    
    love.graphics.setColor(0,0,0, math.max(0, 1 - ((introTimer - 6.5) / 1.5)))
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
local escPressed = false
function love.update(dt)
    if love.keyboard.isDown("escape") and escPressed == false then
        introSystem.setIntroCancel()
        escPressed = true
    end
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
local escPressed = false
function love.update(dt)
    introTimer = introTimer + dt
    
        lastDt = dt
        local px, py = (player.ship or player.guy).body:getWorldCenter()
        gameSystem.ExpandJunkspace(world, junkList, px, py)
        gameSystem.UpdateComponentActivation(player, junkList, player, dt)
        util.UpdatePhasedObjects(dt)

        local mx, my = drawSystem.WindowSpaceToWorldSpace(love.mouse.getX(), love.mouse.getY())
        gameSystem.UpdateMovePlayerGuy(player, mx, my)
        gameSystem.UpdatePlayerComponentAttributes(player)

        if dt < 0.4 then
            world:update(dt)
        end
        gameSystem.ProcessCollisions(world, player, junkList)
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
        drawSystem.load()

        SetupWorld()

        player.guy = gameSystem.SetupPlayer(world, junkList)
end
