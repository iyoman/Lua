local isServer = game:GetService("RunService"):IsServer()
local physicsService = game:GetService("PhysicsService")
local invokePlacement = game:GetService("ReplicatedStorage").invokePlacement
local Arrows = require(game:GetService("ReplicatedStorage").Arrows)
local waiter = 0.3
local tween = game:GetService("TweenService")

local Building = {}
Building.__index = Building
local deb = true
local gdeb = true
local cghost
local snap = true
local tweeninfo = TweenInfo.new()
local goffset = Vector3.new(0,0,0)
local ghostoffset = Vector3.new(0,0,0)

function Building:Place(model, cf, mousetarg, norm)
	if (isServer) and deb == true then
		if mousetarg then
			
			
			local relnew = calcsnap(mousetarg,norm,cf)

			local snaptween = tween:Create(workspace.snap,tweeninfo,{
				CFrame = relnew
			})
			snaptween:Play()
			
			local clone = model:Clone()
			clone.CFrame = relnew*CFrame.Angles(math.pi/2,0,0) + relnew.LookVector*model:GetAttribute("offset").Y + relnew.UpVector*model:GetAttribute("offset").Z + relnew.RightVector*model:GetAttribute("offset").X
			clone.Parent = workspace
			--print(model, mousetarg)
			local weld = Instance.new("WeldConstraint")
			weld.Parent = workspace
			weld.Part0 = clone
			weld.Part1 = mousetarg
			weld.Enabled = true
			local health = Instance.new("NumberValue")
			health.Name = "health"
			health.Value = 500 --change
			health.Parent = clone
			deb = false
			wait(0.2)
			deb = true
		end
	end
	if (not isServer) then
		invokePlacement:FireServer(model, cf, mousetarg, norm)
	end
end

function Building:Ghost(model, cf, mousetarg, norm)
	if (not isServer) then
		local clone = model:Clone()
		if cghost then
			cghost:Remove()
		end
		physicsService:SetPartCollisionGroup(clone, "ghosts")
		if mousetarg then
			
			local relnew = calcsnap(mousetarg,norm,cf)
			--clone.CFrame = cf
			clone.CFrame = relnew*CFrame.Angles(math.pi/2,0,0) + relnew.LookVector*model:GetAttribute("offset").Y + relnew.UpVector*model:GetAttribute("offset").Z + relnew.RightVector*model:GetAttribute("offset").X
			clone.Parent = workspace.ghosts
			clone.Transparency = 0.6
			clone.Anchored = true
			clone.CanCollide = false
			cghost = clone
			gdeb = false
			wait(0.1)
			gdeb = true
		end

	end
end

function round(n)
	return math.floor(n + 0.5)
end

function calcsnap(mousetarg,norm,cf)
	local relnorm = Vector3.new(0,0,0)
	ghostoffset = Vector3.new(0,0,0)
	if mousetarg.Size.X % 2 == 0 then
		ghostoffset += Vector3.new(0.5*1,0,0)
	end
	if mousetarg.Size.Y % 2 == 0 then
		ghostoffset += Vector3.new(0,0.5*1,0)
	end
	if mousetarg.Size.Z % 2 == 0 then
		ghostoffset += Vector3.new(0,0,0.5*1)
	end

	local normrelative = mousetarg.CFrame:ToObjectSpace(CFrame.new(mousetarg.Position,mousetarg.Position+norm)).LookVector
	
	local relcf = mousetarg.CFrame:ToObjectSpace(cf)
	local relcflookv = relcf.LookVector

	local max = math.max(math.abs(relcflookv.X),math.abs(relcflookv.Y),math.abs(relcflookv.Z))
	local newrnd = Vector3.new(round(relcf.X+ghostoffset.X),round(relcf.Y+ghostoffset.Y),round(relcf.Z+ghostoffset.Z))

	if math.abs(relcflookv.X) >= 0.99 then
		newrnd = Vector3.new(relcf.X,round(relcf.Y+ghostoffset.Y),round(relcf.Z+ghostoffset.Z))
		ghostoffset = Vector3.new(0,ghostoffset.Y,ghostoffset.Z)

	end
	if math.abs(relcflookv.Y) >= 0.99 then
		newrnd = Vector3.new(round(relcf.X+ghostoffset.X),relcf.Y,round(relcf.Z+ghostoffset.Z))
		ghostoffset = Vector3.new(ghostoffset.X,0,ghostoffset.Z)

	end
	if math.abs(relcflookv.Z) >= 0.99 then
		newrnd = Vector3.new(round(relcf.X+ghostoffset.X),round(relcf.Y+ghostoffset.Y),relcf.Z)
		ghostoffset = Vector3.new(ghostoffset.X,ghostoffset.Y,0)

	end


	newrnd = newrnd-ghostoffset
	local relrnd = CFrame.lookAt(newrnd,newrnd+relcf.LookVector,relcf.UpVector)


	local relnew = mousetarg.CFrame:ToWorldSpace(relrnd)
	return relnew
end

return Building
