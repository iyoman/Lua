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

function Building:Place(model, cf, mousetarg)
	if (isServer) and deb == true then
		goffset = Vector3.new(0,0,0)
		if mousetarg.Size.X == 1 then
			goffset = Vector3.new(0.5,0,0)
		end
		if mousetarg.Size.Y == 1 then
			goffset = Vector3.new(0,0.5,0)
		end
		if mousetarg.Size.Z == 1 then
			goffset = Vector3.new(0,0,0.5)
		end
		
		local clone = model:Clone()

		local relcf = mousetarg.CFrame:ToObjectSpace(cf)
		
		local newrnd = Vector3.new(round(relcf.X+goffset.X),round(relcf.Y+goffset.Y),round(relcf.Z+goffset.Z))
		newrnd = newrnd-goffset
		local relrnd = CFrame.lookAt(newrnd,newrnd+relcf.LookVector,relcf.UpVector)
		

		local relnew = mousetarg.CFrame:ToWorldSpace(relrnd)

		local snaptween = tween:Create(workspace.snap,tweeninfo,{
			CFrame = relnew
		})
		snaptween:Play()

		clone.CFrame = relnew*CFrame.Angles(math.pi/2,0,0) + relnew.LookVector*model:GetAttribute("offset").Y + relnew.UpVector*model:GetAttribute("offset").Z
		clone.Parent = workspace
		Arrows:Draw(clone)
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

	if (not isServer) then
		invokePlacement:FireServer(model, cf, mousetarg)
	end
end

function Building:Ghost(model, cf, mousetarg)
	if (not isServer) then
		local clone = model:Clone()
		if cghost then
			cghost:Remove()
		end
		physicsService:SetPartCollisionGroup(clone, "ghosts")
		if mousetarg then
			local relnorm = Vector3.new(0,0,0)
			ghostoffset = Vector3.new(0,0,0)
			if mousetarg.Size.X % 2 ~= 0 then
				ghostoffset += Vector3.new(0.5*1,0,0)
			end
			if mousetarg.Size.Y % 2 ~= 0 then
				ghostoffset += Vector3.new(0,0.5,0)
			end
			if mousetarg.Size.Z % 2 ~= 0 then
				ghostoffset += Vector3.new(0,0,0.5*1)
			end
			
			
			
			local relcf = mousetarg.CFrame:ToObjectSpace(cf)
			local relcflookv = relcf.LookVector
			
			local max = math.max(relcflookv.X,relcflookv.Y,relcflookv.Z)
			local newrnd
			if relcflookv.X == max then
				relnorm = Vector3.new(0,1,1)
			end
			if relcflookv.Y == max then
				relnorm = Vector3.new(1,0,1)
			end
			if relcflookv.Z == max then
				relnorm = Vector3.new(1,1,0)
			end
			newrnd = Vector3.new(round(relcf.X+ghostoffset.X),round(relcf.Y+ghostoffset.Y),round(relcf.Z+ghostoffset.Z))
			newrnd = newrnd-ghostoffset
			local relrnd = CFrame.lookAt(newrnd,newrnd+relcf.LookVector,relcf.UpVector)


			local relnew = mousetarg.CFrame:ToWorldSpace(relrnd)
			--clone.CFrame = cf
			clone.CFrame = relnew*CFrame.Angles(math.pi/2,0,0) + relnew.LookVector*model:GetAttribute("offset").Y + relnew.UpVector*model:GetAttribute("offset").Z
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

return Building
