local externalFunc = {}

local cameraX, cameraY, cameraScale = 0, 0, 1
local smoothCameraFactor = 0.25
local softlockDelay = 4
local softlockPeriod = 3.6

local starfield = require("starfield")
local animations = IterableMap.New()

local consoleText = {}
local consoleTimer = {}
local consoleColorR = {}
local consoleColorG = {}
local consoleColorB = {}

function externalFunc.sendToConsole (text, timer, color)
    
    if timer == nil then
        timer = 5
    end

    if color == nil then
        color = {}
        color.r = 1
        color.g = 1
        color.b = 1
    end
    
    table.insert(consoleText, text)
    table.insert(consoleTimer, timer)
    table.insert(consoleColorR, color.r)
    table.insert(consoleColorG, color.g)
    table.insert(consoleColorB, color.b)
end

function externalFunc.drawConsole()
    for i = #consoleText, 1, -1 do

        love.graphics.setColor(
            consoleColorR[#consoleText + 1 - i],
            consoleColorG[#consoleText + 1 - i],
            consoleColorB[#consoleText + 1 - i],
            math.min(1,consoleTimer[#consoleText + 1 - i]))
        
        font.SetSize(2)
        
        love.graphics.print(consoleText[#consoleText + 1 - i], 50, 730 - (i * 25))
        
        love.graphics.setColor(1,1,1)
    end
end

function externalFunc.removeFromConsole(index)
    table.remove(consoleText, index)
    table.remove(consoleTimer, index)
    table.remove(consoleColorR, index)
    table.remove(consoleColorG, index)
    table.remove(consoleColorB, index)
end

local function pulse(t, duration)
    t = (t % duration) / duration
    if t < 0.1 then return 0
    elseif t < 0.2 then return (t - 0.1) / (0.2 - 0.1)
    elseif t < 0.8 then return 1
    elseif t < 0.9 then return (0.9 - t) / (0.9 - 0.8)
    else return 0 end
end

function externalFunc.drawGoalConsole(player, objectives, softlocked, _timer)
    if not objectives then
        return
    end
    
    local vnext = 730
    local winAlpha = 1
    if util.GetWinTimerProgress(player) then
        winAlpha = (5.5 - util.GetWinTimerProgress(player))/5.5
        if winAlpha < 0 then
            winAlpha = 0
        end
    end
    
    for _, obj in objectives.Iterator() do
        love.graphics.setColor(1,1,1, winAlpha*math.max(0, ((_timer - 20) / 1.5)))
        
        if obj.satisfied then
            love.graphics.setColor(0,1,0, winAlpha*math.max(0, ((_timer - 20) / 1.5)))
        end
        
        font.SetSize(2)
        local text = love.graphics.newText(font.GetFont(), obj.humanName .. ((obj.satisfied and " [x]") or " [  ]"))
        vnext = vnext - 25
        --love.graphics.print(obj.humanName .. ((obj.satisfied and " [x]") or " [  ]"), 974 - text:getWidth(1), 730 - (obj.index * 25))
        love.graphics.print(obj.humanName .. ((obj.satisfied and " [x]") or " [  ]"), 974 - text:getWidth(1), vnext)
        
        love.graphics.setColor(1,1,1,1)
    end
    
    if softlocked then
        local intensity = (softlocked > softlockDelay) and pulse(softlocked - softlockDelay, softlockPeriod) or 0
        love.graphics.setColor(1,0,0,winAlpha*intensity)
        font.SetSize(2)
        local text = love.graphics.newText(font.GetFont(), "Press Ctrl-R to restart the game")
        vnext = vnext - 25
        love.graphics.print("Press Ctrl-R to restart the game", 974 - text:getWidth(1), vnext)
        love.graphics.setColor(1,1,1,1)
    end
end


local function paintShadows (bodyList, lightSource, minDistance)
    
    --bodies
    for i = 1, #bodyList do
        fixtures = bodyList[i]:getFixtures()
        
        --fixtures
        for j = 1, #fixtures do
            
            local shadowPoints = {}
            
            local shape = fixtures[j]:getShape()
            
            --points for fixture
            local points = {shape:getPoints()}
            local _points = {junkList[i]:getWorldPoints(points[1], points[2], points[3], points[4], points[5], points[6], points[7], points[8])}
            
            for i = 1, #_points / 2 do
                if Dist(_points[2 * i - 1], _points[2 * i], lightSource.x, lightSource.y) < minDistance then
                    goto continue
                end
            end
            
            local angles = getAngles(_points, lightSource.x, lightSource.y)
            local compAngles = {}
            
            for i = 1, #angles do
                compAngles[i] = angles[i]
            end
            
            table.sort(angles)
            
            minAngle = angles[1]
            maxAngle = angles[#angles]
            
            local maxAngleNo = 0
            local minAngleNo = 0
            
            for i = 1, #angles do
                if compAngles[i] == minAngle then
                    minAngleNo = i
                end
                
                if compAngles[i] == maxAngle then
                    maxAngleNo = i
                end
                
            end

            edgePoints = {}
            edgePoints[1] = _points[(2 * minAngleNo) - 1]
            edgePoints[2] = _points[2 * minAngleNo]
            edgePoints[3] = _points[(2 * maxAngleNo) - 1]
            edgePoints[4] = _points[2 * maxAngleNo]
            
            shadowPoints[1] = edgePoints[3]
            shadowPoints[2] = edgePoints[4]
            shadowPoints[3] = edgePoints[1]
            shadowPoints[4] = edgePoints[2]

            --draw lines tracing from shape edges
            for i = 1, 2 do
                --project line to edge of screen
                --top or bottom?
                local angle = math.atan2(lightSource.y - edgePoints[2 * i], lightSource.x - edgePoints[(2 * i) - 1])
                
                if angle > 0 and angle < math.pi then
                    --top
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, winWidth, 0)
                
                elseif angle < 0 and angle > - math.pi then
                    --bottom
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, winHeight, winWidth, winHeight)
                    
                else
                    --direct horizontal, skip this step and move to left or right
                    if angle == 0 then
                        --right
                        intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], winWidth, 0, winWidth, winHeight)
                    else
                        --left
                        intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, 0, winHeight)
                        
                    end     
                end
                     
                if intersectX < 0 then
                    --left
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], 0, 0, 0, winHeight)
                        
                elseif intersectX > winWidth then
                    --right
                    intersectX, intersectY = intersection(lightSource.x, lightSource.y, edgePoints[(2 * i) - 1], edgePoints[2 * i], winWidth, 0, winWidth, winHeight)
                    
                end
                                
                shadowPoints[3 + (2 * i)] = intersectX
                shadowPoints[4 + (2 * i)] = intersectY
            end    
            
            --draw the shadow shape  
            love.graphics.polygon("fill", shadowPoints)
        end
        
        ::continue::
    end
end

--------------------------------------------------
-- Ship Drawing
--------------------------------------------------

local function DrawShipVectors(ship)
    for _, comp in ship.components.Iterator() do
        local ox, oy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        local vx, vy = comp.def.activationOrigin[1], comp.def.activationOrigin[2]
        local angle = ship.body:getAngle() + comp.angle
        vx, vy = util.RotateVector(vx, vy, ship.body:getAngle() + comp.angle)
        local dx, dy = ox + vx, oy + vy
        love.graphics.line(dx, dy, dx + 20*math.cos(angle), dy + 20*math.sin(angle))
        love.graphics.circle("line", dx, dy, 10)
    end
end

local function DrawDebug(world, player)
    love.graphics.setColor(1,0,0,1)
    local bodies = world:getBodies()
    for i = 1, #bodies do
        local fixtures = bodies[i]:getFixtures()
        for j = 1, #fixtures do
            local shape = fixtures[j]:getShape()
            local shapeType = shape:getType()
            if shapeType == "polygon" then
                local points = {bodies[i]:getWorldPoints(shape:getPoints())}
                love.graphics.polygon("line", points)
            elseif shapeType == "circle" then
                local x, y = bodies[i]:getWorldPoint(shape:getPoint())
                love.graphics.circle("line", x, y, shape:getRadius())
            end
        end
    end

    if player.ship then
        DrawShipVectors(player.ship)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

local function DrawShip(player, ship, debugEnabled, dt)
    if not ship then
        return
    end
    
    dt = dt or 0

    local winAlpha = 1
    if util.GetWinTimerProgress(player) and (ship.playerShip or ship.isPlayer) then
        winAlpha = (5.5 - util.GetWinTimerProgress(player))/5.5
        if winAlpha < 0 then
            winAlpha = 0
        end
    end

    -- Draw girders
    for _, comp in ship.components.Iterator() do
        if comp.def.isGirder then
            local dx, dy = ship.body:getWorldPoint(comp.xOff, comp.yOff)

            if comp.phaseState then
                love.graphics.setColor(1, 1, 1, (1 - 0.75*comp.phaseState)*winAlpha)
            end

            local image = ((comp.activated or comp.winTimer) and comp.def.imageOn) or comp.def.imageOff
            local drawScale = comp.scaleFactor

            love.graphics.draw(image, dx, dy, ship.body:getAngle() + comp.angle, 
                comp.def.imageScale[1]*(comp.xScale or 1)*drawScale, comp.def.imageScale[2]*drawScale, comp.def.imageOrigin[1], comp.def.imageOrigin[2])

            if comp.phaseState then
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end

    -- Draw other things
    for _, comp in ship.components.Iterator() do

        local dx, dy = ship.body:getWorldPoint(comp.xOff, comp.yOff)
        if not comp.def.isGirder then
        
            if comp.def.imageAnimateOnFrames and comp.def.imageFrameDuration and comp.animationTimer and comp.currentFrame then
                comp.animationTimer = comp.animationTimer + dt
                comp.currentFrame = (comp.currentFrame + math.floor(comp.animationTimer / comp.def.imageFrameDuration) - 1) % comp.def.imageAnimateOnFrames + 1
                comp.animationTimer = comp.animationTimer % comp.def.imageFrameDuration
            end
        
            local image = ((comp.activated or comp.winTimer) and (comp.currentFrame and comp.def.imageOnAnim[comp.currentFrame] or comp.def.imageOn)) or comp.def.imageOff

            if comp.phaseState then
                love.graphics.setColor(1, 1, 1, (1 - 0.75*comp.phaseState)*winAlpha)
            end

            local totalDrawAngle = ship.body:getAngle() + comp.angle + (comp.drawAngle or 0)
            love.graphics.draw(image, dx, dy, totalDrawAngle, 
                comp.def.imageScale[1]*(comp.xScale or 1)*comp.scaleFactor, comp.def.imageScale[2]*comp.scaleFactor, comp.def.imageOrigin[1], comp.def.imageOrigin[2])

            if comp.def.imageDmg then
                local healthBucket = comp.def.damBuckets - math.ceil(comp.def.damBuckets*comp.health/comp.maxHealth)
                if healthBucket > 0 and comp.def.imageDmg[healthBucket] then
                    love.graphics.draw(comp.def.imageDmg[healthBucket], dx, dy, totalDrawAngle, 
                        comp.def.imageScale[1]*(comp.xScale or 1)*comp.scaleFactor, comp.def.imageScale[2]*comp.scaleFactor, comp.def.imageOrigin[1], comp.def.imageOrigin[2])
                end
            end

            if comp.def.text ~= nil and comp.playerShip then
                local textDef = comp.def.text
                local keyName = comp.activeKey or "?"
                
                love.graphics.setColor(comp.def.text.color[1], comp.def.text.color[2], comp.def.text.color[3], comp.def.text.color[4]*winAlpha)
                font.SetSize(3)
                love.graphics.print(string.upper(keyName), dx, dy, totalDrawAngle + textDef.rotation, textDef.scale[1], textDef.scale[2], textDef.pos[1], textDef.pos[2])
                love.graphics.setColor(1,1,1,1)
            end
            
            if comp.phaseState then
                love.graphics.setColor(1, 1, 1, 1)
            end
        end

        if (SUPER_DEBUG_ENABLED or debugEnabled) and not comp.nbhd.IsEmpty() then
            love.graphics.setColor(0, 1, 0, 1)
            for _, other in comp.nbhd.Iterator() do
                local ox, oy = ship.body:getWorldPoint(other.xOff, other.yOff)
                love.graphics.line(dx, dy, ox, oy)
            end
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    
    for _, comp in ship.components.Iterator() do
        local dx, dy = ship.body:getWorldPoint(comp.xOff, comp.yOff)

        if comp.aimX and comp.activated then
            love.graphics.setColor(0,1,0,0.7*winAlpha)
            love.graphics.setLineStyle("rough")
            love.graphics.setLineWidth(6)
            
            
            love.graphics.line(comp.emitX, comp.emitY, comp.aimX, comp.aimY)
                
            love.graphics.setColor(1,1,1)
            love.graphics.setLineStyle("smooth")
            love.graphics.setLineWidth(1)
        end
        
        if not comp.def.isGirder then
            if comp.def.imageExtra and comp.extraAngle then
                love.graphics.draw(comp.def.imageExtra[1], dx, dy, comp.extraAngle, 
                    comp.def.imageScale[1]*(comp.xScale or 1)*comp.scaleFactor, comp.def.imageScale[2]*comp.scaleFactor, comp.def.imageOrigin[1], comp.def.imageOrigin[2])
            end
        end
    end
end

--------------------------------------------------
-- Camera and smoothness
--------------------------------------------------

local function UpdateCameraPos(player, scale)
    local ship = (player.ship or player.guy)
    local px, py = ship.body:getWorldCenter()
    if util.GetWinTimerProgress(player) then
        local timer = util.GetWinTimerProgress(player)
        local factor = timer*smoothCameraFactor/3
        if factor < 0 then
            factor = 0
        end
        cameraX = (1 - factor)*cameraX + factor*px
        cameraY = (1 - factor)*cameraY + factor*py
        cameraScale = (1 - factor)*cameraScale + factor*scale
    else
        cameraX = (1 - smoothCameraFactor)*cameraX + smoothCameraFactor*px
        cameraY = (1 - smoothCameraFactor)*cameraY + smoothCameraFactor*py
        cameraScale = (1 - smoothCameraFactor)*cameraScale + smoothCameraFactor*scale
    end

    return cameraX, cameraY, cameraScale
end

function externalFunc.WindowSpaceToWorldSpace(wx, wy)
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()
    return cameraX + (wx-(winWidth/2))/cameraScale, cameraY + (wy-(winHeight/2))/cameraScale
end

--------------------------------------------------
-- Animation
--------------------------------------------------

local function DoAnimation(_, data, _, dt)
    if data.t >= data.def.duration then
        return true
    end
    local frame = math.floor(#data.def.quads*data.t/data.def.duration) + 1
    love.graphics.draw(data.def.spriteSheet, data.def.quads[frame], data.x, data.y, data.rotation, data.scale, data.scale, data.def.xOff, data.def.yOff)
    data.t = data.t + dt

    return false
end

local animationIndex = 0
function externalFunc.PlayAnimation(name, x, y)
    local def = animationDefs[name]
    if not def then
        return
    end
    animationIndex = animationIndex + 1
    animations.Add(animationIndex, {def = def, x = x, y = y, scale = def.scaleMin + math.random()*(def.scaleMax - def.scaleMin), rotation = math.random()*2*math.pi, t = 0})
end

--------------------------------------------------
-- Draw Loop
--------------------------------------------------

function externalFunc.draw(world, player, junkList, debugEnabled, dt) 
    local winWidth  = love.graphics:getWidth()
    local winHeight = love.graphics:getHeight()

    love.graphics.push()

    local wantedScale = 80/(((player.ship or player.guy).components.GetIndexMax())^0.78 + 80)
    if introTimer < 12.6 then
        wantedScale = wantedScale/0.6
    elseif introTimer < 14 then
        wantedScale = wantedScale/(0.6 + 0.4*(introTimer - 12.6)/1.4)
    end

    local cx, cy, cScale = UpdateCameraPos(player, wantedScale)
    local stars = starfield.locations(cx, cy, cScale)
    love.graphics.points(stars)

    love.graphics.scale(cScale)
    love.graphics.translate(winWidth/(2*cameraScale) - cx, winHeight/(2*cameraScale) - cy)

    util.DrawBullets()

    -- Worldspace
    for _, junk in pairs(junkList) do
        DrawShip(player, junk, debugEnabled, dt)
    end

    DrawShip(player, player.ship, debugEnabled, dt)
    DrawShip(player, player.guy, debugEnabled, dt)

    if debugEnabled then
        DrawDebug(world, player)
    end

    animations.Apply(DoAnimation, dt)

    love.graphics.pop()
    -- UI space

    if player.needKeybind then
        --font.SetSize(1)
        --love.graphics.print("Press any key to bind component controls.", 10, 10, 0, 1, 1)
    end
    
    if consoleTimer then
        for i = #consoleTimer, 1, -1 do
            consoleTimer[i] = consoleTimer[i] - dt
            
            --[[
            if consoleTimer[1] < 1 and i ~= 1 then
                consoleTimer[i] = math.max(consoleTimer[i], 1)
            end
            ]]--
            
            if consoleTimer[i] < 0 then
                externalFunc.removeFromConsole(i)
            end
        end
    end
    
    if goalConsoleTimer then        
        for i = #goalConsoleTimer, 1, -1 do
            --goalConsoleTimer[i] = goalConsoleTimer[i] - dt
            
            --[[
            if goalConsoleTimer[1] < 1 and i ~= 1 then
                goalConsoleTimer[i] = math.max(goalConsoleTimer[i], 1)
            end
            ]]--
            
            if goalConsoleTimer[i] < 0 then
                externalFunc.removeFromGoalConsole(i)
            end
        end
    end
end

function externalFunc.reset()
    animationIndex = 0
    animations = IterableMap.New()

    -- Camera is intentionally not reset.
    consoleText = {}
    consoleTimer = {}
    consoleColorR = {}
    consoleColorG = {}
    consoleColorB = {}
end

return externalFunc

