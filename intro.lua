local intro = false
local introTimer = 0

local function loadIntro ()
end

local function updateIntro(dt)
    if not intro then
        return false
    end

    introTimer = introTimer + dt    
end

local function drawIntro ()
    if not intro then
        return false
    end
    
    print (introTimer)
    
    if introTimer > 1 then        
        love.graphics.setColor(math.min(introTimer - 2, 3)/3, math.min(introTimer - 2, 3)/3, math.min(introTimer - 2, 3)/3)
        print(love.graphics.getColor())
        love.graphics.print("They told you the freighter was safe.  The shipping lanes had seen more piracy lately, but the pilot swore he could outrace them.  They didn’t bother splurging for an escort, and better weapons would have wiped their margin clean.", 50, 100)
        love.graphics.setColor(1,1,1)            
    end
    
    if introTimer > 8 then            
        love.graphics.setColor(math.min(0, math.max(introTimer - 2, 10))/10, math.min(0, math.max(introTimer - 2, 10))/10, math.min(0, math.max(introTimer - 2, 10))/10)
        love.graphics.print("You knew better.  You hadn’t boarded a commercial flight in years without an emergency pressure suit stashed in your carry-on.  After all, it’s not paranoia if you really are surrounded by incompetents.", 250, 900)
        love.graphics.setColor(1,1,1)   
    end
    
    if introTimer > 13 then
        love.graphics.setColor(math.min(0, math.max(introTimer - 2, 15))/15, math.min(0, math.max(introTimer - 2, 15))/15, math.min(0, math.max(introTimer - 2, 15))/15)
        love.graphics.print("You sprang into action the moment the klaxons went off, sealing the suit as you ran for the escape pods – but the hull blew out before you reached safety, sending you spiralling out into space.", 450, 900)
        love.graphics.setColor(1,1,1) 
    end
    
    if introTimer > 18 then
        love.graphics.setColor(math.min(0, math.max(introTimer - 2, 20))/20, math.min(0, math.max(introTimer - 2, 20))/20, math.min(0, math.max(introTimer - 2, 20))/20)
        love.graphics.print("The freighter exploded behind you, showering local space with debris.", 650, 900)
        love.graphics.setColor(1,1,1) 
    end
    
    if introTimer > 21 then
        love.graphics.setColor(math.min(0, math.max(introTimer - 2, 22.5))/22.5, math.min(0, math.max(introTimer - 2, 22.5))/22.5, math.min(0, math.max(introTimer - 2, 22.5))/22.5)
        love.graphics.print("Now, you have nothing.", 900, 900)
        love.graphics.setColor(1,1,1) 
    end
    
    if introTimer > 24 then
                    love.graphics.setColor(math.min(0, math.max(introTimer - 2, 25.5))/25.5, math.min(0, math.max(introTimer - 2, 25.5))/25.5, math.min(0, math.max(introTimer - 2, 25.5))/25.5)
        love.graphics.print("But maybe you can salvage something from this wreck.", 1000, 900)
        love.graphics.setColor(1,1,1) 
        
    end
    
    if introTimer > 30 then
        intro = false
    end
        
    return true
end

return {
    loadIntro = loadIntro,
    updateIntro = updateIntro,
    drawIntro = drawIntro,
}



