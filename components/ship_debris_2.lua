local SCALE = 0.16/0.06

local conf = {
    imageOff = "Images/ship debris 2.png",
    imageOn = "Images/ship debris 2.png",
    imageOrigin = {464, 400}, 
    imageScale = {SCALE*0.06, SCALE*0.06},
    activationOrigin = {0, 0},
	shapeCoords = { SCALE*11,SCALE*8, SCALE*8,SCALE*1, SCALE*-3,SCALE*-10, SCALE*-10,SCALE*-9, SCALE*-10,SCALE*-1, SCALE*-6,SCALE*10, SCALE*6,SCALE*0 },
    walkRadius = 20,
    maxHealth = 1400,
    scaleMax = 1,
    scaleMin = 0.7,
    density = 2.5,
    humanName = "a sturdy piece of hull plating.",
    getOccurrence = function (dist)
        return util.InterpolateOccurrenceDensity(dist, 0.1, 0.12, 0.18, 0.2)
    end,
}

return conf