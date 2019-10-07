local externalFunc = {}

local sounds = IterableMap.New()

function externalFunc.load ()
end

local volMult = {
    booster = 1,
    ion = 1,
    redrocket = 1,
    pushmissile = 1,
    tractor = 0.8,
    displacer_on = 1,
    displacer_off = 1,
    grab1 = 0.8,
    grab2 = 0.8,
    grab3 = 0.8,
    bulletfire = 0.34,
    bullethit = 0.25,
    explosion = 0.15,
}

function addSource(name, id)
    if name == "booster" then
        return love.audio.newSource("SFX/booster.wav", "static")
    elseif name == "ion" then
        return love.audio.newSource("SFX/ion.wav", "static")
    elseif name == "redrocket" then
        return love.audio.newSource("SFX/redrocket.wav", "static")
    elseif name == "pushmissile" then
        return love.audio.newSource("SFX/pushmissile.wav", "static")
    elseif name == "tractor" then
        return love.audio.newSource("SFX/tractor.wav", "static")
    elseif name == "displacer_on" then
        return love.audio.newSource("SFX/displacer_on.wav", "static")
    elseif name == "displacer_off" then
        return love.audio.newSource("SFX/displacer_off.wav", "static")
    elseif name == "grab1" then
        return love.audio.newSource("SFX/grab_lrg.wav", "static")
    elseif name == "grab2" then
        return love.audio.newSource("SFX/grab_med.wav", "static")
    elseif name == "grab3" then
        return love.audio.newSource("SFX/grab_sml.wav", "static")
    elseif name == "bulletfire" then
        return love.audio.newSource("SFX/bulletfire.wav", "static")
    elseif name == "bullethit" then
        return love.audio.newSource("SFX/bullethit.wav", "static")
    elseif name == "explosion" then
        return love.audio.newSource("SFX/explosion.wav", "static")
    end
end

function externalFunc.playSound(name, id, noLoop)
    local soundData = sounds.Get(id)
    if not soundData then
        soundData = {
            name = name,
            want = 1,
            have = 0,
            source = addSource(name, id),
        }
        soundData.source:setLooping(not noLoop)
        sounds.Add(id, soundData)
    end
    love.audio.play(soundData.source)
    soundData.want = 1
end

function externalFunc.Update(player, dt)
    for _, soundData in sounds.Iterator() do
        if soundData.want > soundData.have then
            soundData.have = soundData.have + 10*dt
            if soundData.have > soundData.want then
                soundData.have = soundData.want
            end
            soundData.source:setVolume(soundData.have*volMult[soundData.name])
        end

        if soundData.want < soundData.have then
            soundData.have = soundData.have - 10*dt
            if soundData.have < soundData.want then
                soundData.have = soundData.want
            end
            soundData.source:setVolume(soundData.have*volMult[soundData.name])
        end

        local winTimer = util.GetWinTimerProgress(player)
        if winTimer and winTimer > 2 then
            local wantedVolume = math.max(0, (7 - winTimer)/5)
            soundData.source:setVolume(soundData.have*wantedVolume*volMult[soundData.name])
        end
    end
end

function externalFunc.stopSound(id, death)
    local soundData = sounds.Get(id)
    if not soundData then
        return
    end
    soundData.want = 0
    if death then
        soundData.source:stop()
    end
end

function externalFunc.reset()
    for _, soundData in sounds.Iterator() do
        soundData.source:stop()
    end
    sounds = IterableMap.New()
end

return externalFunc
