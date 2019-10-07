local externalFunc = {}

local preShip = true

local hints = {
    {
        distance = 1200,
        hint = "distance!",
        duration = 15,
    },
    {
        getComponent = "booster",
        hint = "booster!",
        duration = 15,
    },
    {
        getComponent = "booster",
        hint = "booster!",
        duration = 15,
    },
    {
        getComponent = "booster",
        doFunc = function ()

        end,
        duration = 15,
    },
    {
        getComponent = "booster",
        doFunc = function ()

        end,
        duration = 15,
    },
    {
        noBooster = true,
        hint = "Pres Ctrl + R to restart",
        repeatTime = 10,
        duration = 2,
    },
}

local hintSent = {}
local hintSentTime = {}

local function ProcessHint(index, data, player, dt)
    if hintSent[index] and not data.repeatTime then
        return
    end

    if hintSentTime[index] then
        hintSentTime[index] = hintSentTime[index] - dt
        if hintSentTime[index] < 0 then
            hintSentTime[index] = false
        end
    end

    if data.repeatTime and hintSentTime[index] then
        return
    end

end

function externalFunc.Update(player, dt)
    if player.ship then
        preShip = false
    end

    local ship = (player.ship or player.guy)
    local px, py = ship.body:getWorldCenter()

    for i = 1, #hints do
        ProcessHint(i, hints[i], px, py, i)
    end
end


function externalFunc.reset()
    hintSent = {}
    hintSentTime = {}
    preShip = true
end

return externalFunc