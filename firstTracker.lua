local externalFunc = {}

local preShip = true
local noBooster = true

local softlocked = nil

local hints = {
	{
        customTrigger = "console_no_win",
        hint = {"The console requires a warp drive, a phase displacer, and two laser batteries."},
        hint = {"> The console requires a warp drive, a phase displacer, and two laser batteries."},
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
        hint = {"Press Ctrl + R to restart."},
        colorOverride = notifyColor,
        duration = 50000000000000000000,
    },
	{
        distanceTrigger = 1200,
        hint = {"Move around your ship by holding the left mouse button.","Grab floating components by moving close to them."},
        duration = 15,
        waitTime = 1,
    },
    {
        distanceTrigger = 2500,
        hint = {"> Collect the components listed in the bottom-right","to build a warp drive and win the game!"},
        duration = 9,
        waitTime = 2,
        doFunc = function ()     
            if util.GetObjectives().IsEmpty() then
                util.AddObjective("A warp drive", "warp_drive", 1)
                util.AddObjective("A phase displacer", "displacer", 1)
                util.AddObjective("A navigation console", "console", 1)
                util.AddObjective("Two laser batteries", "laser_battery", 2)
            end
        end
    },    
    {
        compTrigger = {{"booster","booster"},{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
        hint = {"> Move around your ship by holding the left mouse button.","Grab floating components by moving close to them."},
        duration = 8,
        waitTime = 0.5,
    },
    {
        compTrigger = {{"booster","booster"},{"ion_engine","thruster"},{"push_missile","rocket"},{"red_rocket","rocket"}},
        hint = {"> Assign a key to your new $NAME,","then hold down that key to activate it."},
        duration = 8,
        waitTime = 9,
    },
    {
        compTrigger = {{"tractor_wheel","tractor wheel"},{"gyro","stabiliser"},{"displacer","displacement device"}},
        hint = {"> Activate or deactivate the $NAME","by pressing its assigned key."},
        duration = 9,
        waitTime = 2,
    },
    {
        compTrigger = "navigation",
        hint = "> The scanner points towards the nearest objective component.",
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
            -- 1 revolution per second on a ship = softlock
            if math.abs(player.ship.body:getAngularVelocity()) > math.pi then isSoftlocked = true end
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