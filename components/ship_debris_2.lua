local SCALE = 0.16/0.06

local conf = {
    imageOff = "images/ship debris 2.png",
    imageOn = "images/ship debris 2.png",
    imageOrigin = {464, 400}, 
    imageScale = {SCALE*0.06, SCALE*0.06},
    activationOrigin = {0, 0},
	shapeCoords = { SCALE*11,SCALE*8, SCALE*8,SCALE*1, SCALE*-3,SCALE*-10, SCALE*-10,SCALE*-9, SCALE*-10,SCALE*-1, SCALE*-6,SCALE*10, SCALE*6,SCALE*0 },
    walkRadius = 20,
    maxHealth = 1100,
    scaleMax = 1,
    scaleMin = 0.7,
    density = 2.5,
    humanName = "a piece of hull plating",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.4, 0.3, 0.1, 0.05)
    end,
}

return conf