local debugHitboxKey = 'm'
local debugEnabled = false

local setKeybind = false
local needKeybind = false

local drawSystem = require("draw")
local gameSystem = require("game")

local world
local player

local junkList = {}
junkIndex = 0

--------------------------------------------------
-- Draw
--------------------------------------------------

function love.draw()
    drawSystem.draw(player, junkList, debugEnabled, needKeybind, setKeybind)
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

    if not isRepeat then
        if key == 'space' then
            setKeybind = not setKeybind
        elseif setKeybind then
            for i = 1, #player.components do
                local comp = player.components[i]
                if comp.def.text and not comp.activeKey then
                    comp.activeKey = key
                end
            end
            setKeybind = false
            needKeybind = false
        end
    end
end

--------------------------------------------------
-- Colisions
--------------------------------------------------

local function beginContact(a, b, coll)
    gameSystem.beginContact(a, b, col1)
end

local function endContact(a, b, coll)

end

local function preSolve(a, b, coll)

end

local function postSolve(a, b, coll,  normalimpulse, tangentimpulse)

end

--------------------------------------------------
-- Update
--------------------------------------------------

function love.update(dt)
    gameSystem.UpdateInput(player)
    world:update(0.033)
    gameSystem.ProcessCollisions(player, junkList)
end

--------------------------------------------------
-- Loading
--------------------------------------------------

local function SetupWorld()
    world = love.physics.newWorld(0, 0, true) -- Last argument is whether sleep is allowed.
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, 20 do
        junkIndex = junkIndex + 1
        junkList[junkIndex] = gameSystem.MakeJunk(world, junkIndex)
    end
end

local function SetupPlayer()
    local body = love.physics.newBody(world, 0, 0, "dynamic")
    body:setAngularVelocity(0.8)

    local components = {}
    components[1] = gameSystem.SetupComponent(body, "booster", {isPlayer = true, fixtureData = {isPlayer = true, compDefName = compDefName}})

    return {
        body = body,
        components = components,
    }
end


function love.load()
    math.randomseed(os.clock())
    drawSystem.load()

    SetupWorld()
    player = SetupPlayer()
end
