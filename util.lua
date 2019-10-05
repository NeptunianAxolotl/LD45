local function RotateVector(x, y, angle)
	return x*math.cos(angle) - y*math.sin(angle), x*math.sin(angle) + y*math.cos(angle)
end

return {
    RotateVector = RotateVector,
}
