local externalFunc = {}

local preShip = true
local noBooster = true

local hints = {
	{
        distanceTrigger = 1200,
        hint = {"Move around your ship by holding the left mouse button.","Grab floating components by moving close to them."},
        duration = 15,
        waitTime = 1,
    },
    {
        distanceTrigger = 2500,
        hint = {"Collect the components listed in the bottom-right","to build a warp drive and win the game!"},
        duration = 15,
        waitTime = 2,
        doFunc = function ()     
            if util.GetObjectives().IsEmpty() then
                util.AddObjective("A warp drive [  ]", "warp_drive", 1)
                util.AddObjective("A phase displacer [  ]", "displacer", 1)
                util.AddObjective("A navigation console [  ]", "console", 1)
                util.AddObjective("Two laser batteries [  ]", "laser_battery", 2)
            end
        end
    },    
    {
        compTrigger = {{"booster","booster"},{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
        hint = {"Assign a key to your new $NAME,","then hold down that key to activate it."},
        duration = 15,
        waitTime = 2,
    },
    {
        compTrigger = {{"tractor_wheel","tractor wheel"},{"gyro","stabiliser"},{"displacer","displacement device"}},
        hint = {"Activate or deactivate the $NAME","by pressing its assigned key."},
        duration = 15,
        waitTime = 2,
    },
    {
        compTrigger = "navigation",
        hint = "The scanner points towards the nearest objective component.",
        duration = 15,
        waitTime = 2,
    },
}

local hintSent = {}
local hintSentWait = {}

local function SendHint(hint, duration, color)
    if type(hint) == "table" then
        for j = 1, #hint do
            drawSystem.sendToConsole(hint[j], duration, color) 
        end
    else
        drawSystem.sendToConsole(hint, duration, color) 
    end
end

local function ProcessHint(dt, index, data, distance, compNames)
    if hintSent[index] then
        return
    end
    
    local hintMessage = data.hint

    if data.distanceTrigger then
        if distance > data.distanceTrigger then
            SendHint(hintMessage, data.duration, goalColor) 
            hintSent[index] = true
            if data.doFunc then
                data.doFunc()
            end
        end
        return
    end

    if type(data.compTrigger) == "table" then
        local foundComp = false
        for i = 1, #data.compTrigger do
            if compNames[data.compTrigger[i][1]] then
                foundComp = true
                if type(hintMessage) == "table" then
                    for j = 1, #hintMessage do
                        hintMessage[j] = hintMessage[j]:gsub("$NAME",data.compTrigger[i][2])
                    end
                else
                    hintMessage = hintMessage:gsub("$NAME",data.compTrigger[i][2])
                end
            end
        end
        if not foundComp then
            return
        end
	else
        if not compNames[data.compTrigger] then
            return
        end
    end

    if data.waitTime and (hintSentWait[index] or 0) < data.waitTime then
        hintSentWait[index] = (hintSentWait[index] or 0) + dt
        return
    end
        
    SendHint(hintMessage, data.duration, goalColor) 
    
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