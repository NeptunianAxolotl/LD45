local bigFont
local medFont
local smallFont

local externalFunc = {}

function externalFunc.SetSize(size)
    if not bigFont then
        externalFunc.Load()
    end
    if size == 1 then
        love.graphics.setFont(bigFont)
    elseif size == 2 then
        love.graphics.setFont(medFont)
    elseif size == 3 then
        love.graphics.setFont(smallFont)
    end
end

function externalFunc.Load()
    bigFont = love.graphics.newFont('Resources/fonts/FreeSansBold.ttf', 28)
    medFont = love.graphics.newFont('Resources/fonts/FreeSansBold.ttf', 16)
    smallFont = love.graphics.newFont('Resources/fonts/FreeSansBold.ttf', 16)
end

return externalFunc