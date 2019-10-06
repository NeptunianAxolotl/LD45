local conf = {
    imageOff = "images/push_missile/push_missile_unused.png",
	imageBetween = "images/push_missile/push_missile_launch.png",
    imageOn = "images/push_missile/push_missile_firing.png",
    imageOrigin = {30, 89},
    imageScale = {0.5, 0.5},
    activationOrigin = {-20, 0},
    shapeCoords = {30,-70, 14,-89, -14,-89, -30,-70, -30,43, -16,53, 16,53, 30,43},
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