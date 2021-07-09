local missile = script.Parent
local grav = missile.grav
grav.Force = Vector3.new(0,workspace.Gravity*missile.AssemblyMass*1,0)
local RunService = game:GetService("RunService")
missile.Anchored = false
local align = missile.AlignOrientation
align.Enabled = false
align.Responsiveness = missile:GetAttribute("alignresp")
align.MaxTorque = missile:GetAttribute("aligntorq")
align.MaxAngularVelocity = missile:GetAttribute("angspeed")
--local beatloop = RunService.Heartbeat:Connect(function()

--end)

function ontouch()
	print(missile.Position)
	missile.Anchored = true
	missile.CanCollide = false
	local explosion = Instance.new("Explosion",game.Workspace)
	explosion.Position = missile.Position
	missile:Destroy()
	explosion.BlastPressure = 100000
	explosion.BlastRadius = 10
	explosion.DestroyJointRadiusPercent = 1
	
end 

missile.target.Value = workspace.AApart

print('new missile active')

missile.thrust.Force = Vector3.new(0,0,-100*0)

missile.Touched:Connect(ontouch)
