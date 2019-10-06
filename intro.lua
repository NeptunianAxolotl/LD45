local intro = true
local introTimer = 0

local function setIntro (_intro)
    intro = _intro
end

local function loadIntro ()
end

local function updateIntro(dt)
    if not intro then
        return false
    end

    introTimer = introTimer + dt
    return true
end

local function drawIntro ()
    if not intro then
        return false
    end
    
    love.graphics.setColor(math.min(introTimer, 1), math.min(introTimer, 1), math.min(introTimer, 1))
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("They told you the freighter was safe.  The shipping lanes had seen more piracy lately, but the pilot swore he could outrace them.", 50, 50)
    love.graphics.print("They didn’t bother splurging for an escort, and better weapons would have wiped their margin clean.", 50, 70)
    love.graphics.setColor(1,1,1)            
          
    love.graphics.setColor(math.min((introTimer - 2) * 3, 3)/3, math.min((introTimer - 2) * 3, 3)/3, math.min((introTimer - 2) * 3, 3)/3)
       
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("You knew better.  You hadn’t boarded a commercial flight in years without an emergency pressure suit stashed in your carry-on.", 50, 120)
    love.graphics.print("After all, it’s not paranoia if you really are surrounded by incompetents.", 50, 140)
    love.graphics.setColor(1,1,1)   

    love.graphics.setColor(math.min((introTimer - 4) * 5, 5)/5, math.min((introTimer - 4) * 5, 5)/5, math.min((introTimer - 4) * 5, 5)/5)
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("You sprang into action the moment the klaxons went off, sealing the suit as you ran for the escape pods –", 50, 200)
    love.graphics.print("but the hull blew out before you reached safety, sending you spiralling out into space.", 50, 220)
    love.graphics.setColor(1,1,1) 

    love.graphics.setColor(math.min((introTimer - 7) * 8, 8)/8, math.min((introTimer - 7) * 8, 8)/8, math.min((introTimer - 7) * 8, 8)/8)
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("The freighter exploded behind you, showering local space with debris.", 50, 280)
    love.graphics.setColor(1,1,1) 

    love.graphics.setColor(math.min((introTimer - 10) * 11, 11)/11, math.min((introTimer - 10) * 11, 11)/11, math.min((introTimer - 10) * 11, 11)/11)
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("Now, you have nothing.", 50, 350)
    love.graphics.setColor(1,1,1) 

    love.graphics.setColor(math.min((introTimer - 14) * 15, 15)/15, math.min((introTimer - 14) * 15, 15)/15, math.min((introTimer - 14) * 15, 15)/15)
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("But maybe you can salvage something from this wreck.", 50, 430)
    love.graphics.setColor(1,1,1) 
    
    love.graphics.setColor(math.min((introTimer - 1) * 2, 2)/2, math.min((introTimer - 1) * 2, 2)/2, math.min((introTimer - 1) * 2, 2)/2)
    
    if introTimer > 20 then
        love.graphics.setColor(math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1), math.min((1 - (introTimer - 20) / 1), 1))
    end
    
    love.graphics.print("ESC to skip", 920, 730)
    love.graphics.setColor(1,1,1) 
    
    if introTimer > 21 then
        intro = false
    end
        
    return true
end

return {
    loadIntro = loadIntro,
    updateIntro = updateIntro,
    drawIntro = drawIntro,
    setIntro = setIntro,
}



