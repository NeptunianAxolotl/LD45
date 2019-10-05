local me = {}

local closeCross = 3 -- how many screens of movement are required to move the closest stars from one side of the screen to the other
local farCross = 15 -- how many screens of movement are required to move the furthest stars from one side of the screen to the other
local fieldWidth = 2 -- how many screens' worth of stars are generated

local star = {}
for i = 1, 200 do
  star[#star + 1] = {x = math.random() * fieldWidth, y = math.random() * fieldWidth, z = math.random()} 
end

local function projection(px, py, star)
  local prj = {}
  prj.x = (star.x - px / (star.z * farCross + (1-star.z) * closeCross)) % (fieldWidth)
  prj.y = (star.y - py / (star.z * farCross + (1-star.z) * closeCross)) % (fieldWidth)
  return prj
end

local function locations(px, py)
  
  local winWidth  = love.graphics:getWidth()
  local winHeight = love.graphics:getHeight()
  local largestDim = math.max(winWidth,winHeight)
  local xRatio = winWidth / largestDim
  local yRatio = winHeight / largestDim
  
  local vx = px / largestDim
  local vy = py / largestDim
  
  local onscreenStars = {}
  for i = 1, #star do
    local prj = projection(vx, vy, star[i])
    if prj.x < xRatio and prj.y < yRatio then
      onscreenStars[#onscreenStars+1] = {math.floor(prj.x * largestDim), math.floor(prj.y * largestDim), 1, 1, 1, 1}
    end
  end
  return onscreenStars
end

me.locations = locations

return me