local conf = {
    imageOff = "images/ship debris 1.png",
    imageOn = "images/ship debris 1.png",
    imageOrigin = {536, 400}, 
    imageScale = {0.06, 0.06},
    activationOrigin = {0, 0},
	shapeCoords = { -11,8, -8,1, 3,-10, 10,-9, 10,-1, 6,10, -6,0 },
    walkRadius = 20,
    maxHealth = 80,
    humanName = "some ship debris",
    getOccurence = function (dist)
        return 1
    end,
    density = 1,
}

return conf