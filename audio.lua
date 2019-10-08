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
    theme1 = 0.75,
    theme2 = 0.75,
    theme2point5 = 0.8,
    theme3 = 0.48,
    themeWin = 0.82,
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
    elseif name == "theme1" then
        return love.audio.newSource("music/theme1.wav", "static")
    elseif name == "theme2" then
        return love.audio.newSource("music/theme2.wav", "static")
    elseif name == "theme2point5" then
        return love.audio.newSource("music/theme2point5.wav", "static")
    elseif name == "theme3" then
        return love.audio.newSource("music/theme3.wav", "static")
    elseif name == "themeWin" then
        return love.audio.newSource("music/themeWin.wav", "static")
    end
end

function externalFunc.playSound(name, id, noLoop, fadeRate, delay)
    local soundData = sounds.Get(id)
    if not soundData then
        soundData = {
            name = name,
            want = 1,
            have = 0,
            source = addSource(name, id),
            fadeRate = fadeRate,
            delay = delay,
        }
        soundData.source:setLooping(not noLoop)
        sounds.Add(id, soundData)
    end

    soundData.want = 1
    soundData.delay = delay
    if not soundData.delay then
        love.audio.play(soundData.source)
    end
end

function externalFunc.Update(player, dt)
    local winTimer = util.GetWinTimerProgress(player)
    local wantedWinVolume
    if winTimer and winTimer > 2 then
        wantedWinVolume = math.max(0, (7 - winTimer)/5)
    end

    for _, soundData in sounds.Iterator() do
        if soundData.delay then
            soundData.delay = soundData.delay - dt
            if soundData.delay < 0 then
                soundData.delay = false
                if soundData.want > 0 then
                    love.audio.play(soundData.source)
                    soundData.source:setVolume(soundData.have*(wantedWinVolume or 1)*volMult[soundData.name])
                end
            end
        else
            if soundData.want > soundData.have then
                soundData.have = soundData.have + (soundData.fadeRate or 10)*dt
                if soundData.have > soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have*volMult[soundData.name])
            end

            if soundData.want < soundData.have then
                soundData.have = soundData.have - (soundData.fadeRate or 10)*dt
                if soundData.have < soundData.want then
                    soundData.have = soundData.want
                end
                soundData.source:setVolume(soundData.have*volMult[soundData.name])
            end

            if wantedWinVolume then
                soundData.source:setVolume(soundData.have*wantedWinVolume*volMult[soundData.name])
            end
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
