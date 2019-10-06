local conf = {
    imageOff = "images/push_missile/push_missile_unused.png",
	imageBetween = "images/push_missile/push_missile_launch.png",
    imageOn = "images/push_missile/push_missile_firing.png",
    imageOrigin = {30, 89},
    imageScale = {0.5, 0.5},
    activationOrigin = {-20, 0},
    shapeCoords = {30,-29, 23,-79, 9,-89, -9,-89, -23,-79, -30,-29, -30,33, -24,48, -11,53, 11,53, 24,48, 30,33},
    density = 1,
    text =
    {
        pos = {5, 0},
        rotation = math.pi/2,
        scale = {1,1},
        color = {0.8,0.1,0.1,1},
    },
    onFunction = function (self, body, activeX, activeY, activeAngle)
    end,
}

return conf