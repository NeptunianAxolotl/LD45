local externalFunc = {}

local sounds = {}
local sources = {}

function externalFunc.load ()
    sources["booster"] = love.audio.newSource("SFX/booster.wav", "static")
end

function addSource(name, id)
    local source = nil
    
    if name == "booster" then
        source = love.audio.newSource("SFX/booster.wav", "static")
    else
    end

    sources[name .. id] = source
end


function externalFunc.playSound (name, id)
    if sources[name .. id] == nil then
        addSource(name, id)
    end
    
    love.audio.play(sources[name .. id])
    
    if sounds[id] == nil then
        sounds[id] = name
    end
end

function externalFunc.stopSound (id)
    if sounds[id] ~= nil then
        love.audio.pause(sources[sounds[id] .. id])
    end
end

return externalFunc
