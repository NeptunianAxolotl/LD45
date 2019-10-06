local me = {}

local lprime = 1031
local fields = {{bsize = 128, minf = 10, maxf = 25, probs = {0.9,0.6,0.3,0.1}},{bsize = 128, minf = 25, maxf = 100, probs = {0.5,0.2,0.1}},{bsize = 128, minf = 100, maxf = 1000, probs = {0.25,0.05}}} -- determines z-distance and frequency of stars
local winkProb = 0.25 -- probability of getting brighter or less bright on any given frame
local greyness = 0.47 -- between 0 and 1, decrease this for more blue/red stars

local function starsInBox(bx,by,field)

  local bsize = field.bsize
  local probs = field.probs

  r = 1021 * bx + 929 * by + field.minf + 7 * field.maxf
  
  for i = 1,10 do
	r = (137 * r + 61) % lprime
  end
  
  local density = r / lprime
  
  local nstars = 0
  for i = 1, #probs do
	if density < probs[i] then nstars = nstars + 1 end
  end
  
  local stars = {}
  for i = 1, nstars do
    r = (137 * r + 61) % lprime
	while r > math.floor(lprime/bsize)*bsize do r = (137 * r + 61) % lprime end
	sx = r % bsize
	
	r = (137 * r + 61) % lprime
	while r > math.floor(lprime/bsize)*bsize do r = (137 * r + 61) % lprime end
	sy = r % bsize
	
	r = (137 * r + 61) % lprime
	sz = r / lprime
	
	r = (137 * r + 61) % lprime
	sm = r / lprime
	
	r = (137 * r + 61) % lprime
	sc = r / lprime
	
	stars[#stars + 1] = {x=sx,y=sy,z=sz,mag=sm,col=sc}
  end

  return stars
end


local function locations(px, py, cameraScale)

  cameraScale = cameraScale or 1
  
  local cutoff = (1 - cameraScale * cameraScale) * 0.99
  local margin = math.min(0.07,(1-cutoff)*0.9)
  
  local winWidth  = love.graphics:getWidth()
  local winHeight = love.graphics:getHeight()
  
  local onscreenStars = {}
  for f = 1, #fields do
	  local bsize = fields[f].bsize
  
  	  local x1 = math.floor((px/fields[f].maxf - (winWidth/2) / cameraScale) / bsize)
	  local x2 = math.ceil((px/fields[f].maxf + (winWidth/2) / cameraScale) / bsize)
	  
	  local y1 = math.floor((py/fields[f].maxf - (winHeight/2) / cameraScale) / bsize)
	  local y2 = math.ceil((py/fields[f].maxf + (winHeight/2) / cameraScale) / bsize)
	  
	  
	  for i = x1, x2 do
		for j = y1, y2 do
			stars = starsInBox(i,j,fields[f])
			for s = 1, #stars do
				local sx = bsize * i + stars[s].x
				local sy = bsize * j + stars[s].y
				local sz = stars[s].z
				local sm = stars[s].mag
				local sc = stars[s].col
				
				local prjx = (sx - px/(sz*fields[f].maxf + (1-sz)*fields[f].minf)) * cameraScale + winWidth/2
				local prjy = (sy - py/(sz*fields[f].maxf + (1-sz)*fields[f].minf)) * cameraScale + winHeight/2
				
				local bright = 0
				if sm > cutoff + margin then bright = 1
				elseif sm > cutoff - margin then bright = (sm-(cutoff-margin))/(margin*2)
				end
				
				if bright > 0.05 then 
					local light = (math.random() < winkProb) and bright*0.7 or ((math.random() < winkProb) and math.min(bright*1.3,1) or bright)
					local cred = (sc < 0.5) and 1 or (sc-0.5)*2*(greyness-1)+1
					local cblu = (sc < 0.5) and (0.5-sc)*2*(greyness-1)+1 or 1
					local cgrn = (sc < 0.5) and (0.5-sc)*2*(greyness-1)+1 or (sc-0.5)*2*(greyness-1)+1
					onscreenStars[#onscreenStars+1] = {prjx, prjy, light*cred, light*cgrn, light*cblu, 1}
				end
			end
		end
	  end
  end

  return onscreenStars
end

me.locations = locations

return me