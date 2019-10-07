local externalFunc = {}

local preShip = true
local noBooster = true

local softlocked = nil

local hints = {
	{
        customTrigger = "console_no_win",
        hint = {"> Collect all the components to activate the warp console."},
        duration = 5,
    },
	{
        customTrigger = "console_win",
        hint = {"Welcome home."},
        colorOverride = notifyColor,
        duration = 500000000000000000,
    },
	{
        customTrigger = "console_restart",
        hint = {"Press CTRL + R to restart."},
        colorOverride = notifyColor,
        duration = 50000000000000000000,
    },
	{
        customTrigger = "ready_to_warp",
        hint = {"> Activate a warp console to warp home!"},
        duration = 10,
    },
    {
        distanceTrigger = 2800,
        hint = {"> Gather the components listed on the right","to escape this field of flotsam."},
        duration = 9,
        waitTime = 2,
        doFunc = function ()     
            if util.GetObjectives().IsEmpty() then
                util.AddObjective("A warp drive", "warp_drive", 1)
                util.AddObjective("A warp displacer", "displacer", 1)
                util.AddObjective("A warp console", "console", 1)
                util.AddObjective("Two warp batteries", "laser_battery", 2)
            end
        end
    },
    {
        compTrigger = {{"booster","booster"},{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
        hint = {"> Click and hold the Left Mouse Button to", "crawl around your 'ship'."},
        duration = 8,
        waitTime = 0.5,
    },
    {
        compTrigger = "booster",
        hint = {"> Press any key to bind it to your booster,", "then hold the key to produce thrust."},
        duration = 8,
        waitTime = 5.5,
    },
    {
        compTrigger = {{"booster","booster"},{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
        hint = {"> Grab nearby components with your puny arms", "to enlarge your ship."},
        duration = 8,
        waitTime = 11.5,
    },
    --{
    --    compTrigger = {{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
    --    hint = {"> Crawl onto your new $NAME, press a key to","bind it, then hold down that key to activate it."},
    --    duration = 9,
    --    waitTime = 2,
    --},
    {
        compTrigger = {{"tractor_wheel","tractor wheel"},{"gyro","stabiliser"},{"displacer","displacement device"}},
        hint = {"> Activate or deactivate the $NAME","by binding it and pressing the assigned key."},
        duration = 9,
        waitTime = 2,
    },
    {
        compTrigger = "navigation",
        hint = {"> The scanner points towards the nearest", "warp component."},
        duration = 9,
        waitTime = 2,
    },
}

local customTriggerNames = {}
for i = 1, #hints do
    if hints[i].customTrigger then
        customTriggerNames[hints[i].customTrigger] = i
    end
end

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
    
    if data.customTrigger then
        return
    end
    
    local hintMessage = data.hint

    if data.distanceTrigger then
        if distance > data.distanceTrigger then
            SendHint(hintMessage, data.duration, data.colorOverride or goalColor)
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
        
    SendHint(hintMessage, data.duration, data.colorOverride or goalColor) 
    
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
    
    isSoftlocked = false
    noBooster = true
    
    if player and (not preShip) then
        if player.ship then
            -- have a ship that has an engine = not noBooster
            for _, comp in player.ship.components.Iterator() do
                if comp.def.isPropulsion then
                    noBooster = false
                end
            end
            if math.abs(player.ship.body:getAngularVelocity()) > 1.8 then
                isSoftlocked = true
            end
        end
        
        -- travelling slowly on your own or without any propulsion = softlock
        if noBooster then
            local vx, vy = (player.ship or player.guy).body:getLinearVelocity()
            if util.AbsVal(vx,vy) < 70 then isSoftlocked = true end
        end
    end
    
    if isSoftlocked then
        softlocked = softlocked and softlocked + dt or dt
    else
        softlocked = nil
    end
    
end

function externalFunc.SoftlockedTime()
    return softlocked
end

function externalFunc.IsPreShip()
    return preShip
end

function externalFunc.NoBooster()
    return noBooster
end

function externalFunc.SendCustomTrigger(triggerName)
    if customTriggerNames[triggerName] then
        local index = customTriggerNames[triggerName]
        if not hintSent[index] then
            local data = hints[index]
            SendHint(data.hint, data.duration, data.colorOverride or goalColor)
            hintSent[index] = true
        end
    end
end

function externalFunc.reset()
    hintSent = {}
    hintSentTime = {}
    preShip = true
    noBooster = true
end

return externalFunc