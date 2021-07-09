local part = script.Parent
local clickDetector = part.ClickDetector
local ServerStorage = game:GetService("ServerStorage")
local missile = ServerStorage.Missile
local initspeed = 1

function onMouseClick()
	local copy = missile:Clone()
	local rot = CFrame.Angles(0,math.rad(60),math.rad(0))
	local offset = CFrame.new(0,0,-3)
	copy.Parent = workspace
	copy.CFrame = part.CFrame
	copy.CFrame = copy.CFrame:ToWorldSpace(rot)
	copy.CFrame = copy.CFrame:ToWorldSpace(offset)
	local bestvar = copy.CFrame*CFrame.Angles(math.rad(0),math.rad(0),math.rad(90))
	bestvar = bestvar.lookVector
	copy:ApplyImpulse(bestvar*100*initspeed)
end

clickDetector.MouseClick:connect(onMouseClick)
