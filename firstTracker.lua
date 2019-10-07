local externalFunc = {}

local preShip = true
local noBooster = true

local hints = {
    {
        distanceTrigger = 1200,
        hint = "distance!",
        duration = 15,
        waitTime = 4,
    },
    {
        compTrigger = "booster",
        hint = "booster!",
        duration = 15,
        waitTime = 4,
    },
    {
        compTrigger = "booster",
        hint = "booster!",
        duration = 15,
        waitTime = 4,
    },
    {
        compTrigger = "booster",
        hint = "booster!",
        duration = 15,
        waitTime = 4,
    },
    {
        compTrigger = "tractor_wheel",
        hint = "booster!",
        duration = 15,
        waitTime = 4,
    },
}

local hintSent = {}
local hintSentWait = {}

local function ProcessHint(dt, index, data, distance, compNames)
    if hintSent[index] then
        return
    end

    if data.distanceTrigger then
        if distance < data.distanceTrigger then
            drawSystem.sendToConsole(data.hint, data.duration, goalColor) 
            hintSent[index] = true
            if data.doFunc then
                data.doFunc()
            end
        end
        return
    end

    if not compNames[data.compTrigger] then
        return
    end

    if data.waitTime and (hintSentWait[index] or 0) < data.waitTime then
        hintSentWait[index] = (hintSentWait[index] or 0) + dt
        return
    end

    drawSystem.sendToConsole(data.hint, data.duration, goalColor) 
    hintSent[index] = true
    if data.doFunc then
        data.doFunc()
    end
end

function externalFunc.Update(player, dt)
    local compNames = {}
    if player.ship then
        preShip = false
        for _, comp in player.ship.components.Iterator() do
            compNames[comp.def.name] = true
        end
    end

    local ship = (player.ship or player.guy)
    local px, py = ship.body:getWorldCenter()
    local distance = util.AbsVal(px, py)

    for i = 1, #hints do
        ProcessHint(dt, i, hints[i], distance, compNames)
    end
end

function externalFunc.IsPreShip()
    return preShip
end

function externalFunc.NoBooster()
    return noBooster
end

function externalFunc.reset()
    hintSent = {}
    hintSentTime = {}
    preShip = true
    noBooster = true
end

return externalFunc