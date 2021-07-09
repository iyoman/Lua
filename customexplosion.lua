local part = script.Parent
local clickDetector = part.ClickDetector
local ServerStorage = game:GetService("ServerStorage")
local testtable = {}
local damage = 10000

local function customExplosion(position, radius, maxDamage)
	local explosion = Instance.new("Explosion")
	explosion.BlastPressure = 0 -- this could be set higher to still apply velocity to parts
	explosion.DestroyJointRadiusPercent = 0 -- joints are safe
	explosion.BlastRadius = 30
	explosion.Position = part.Position
	explosion.Parent = game.Workspace

	local partsHit = {}
	local occluders = {}
	local alive = {}
	local cam = Instance.new("Camera",explosion)
	cam.CFrame = CFrame.new(explosion.Position) 
	
	explosion.Hit:Connect(function(part, distance)
		local targpart = part
		partsHit[targpart] = distance

		local castPoints = {targpart.Position}
		local ignoreList = {targpart}
		occluders[targpart] = cam:GetPartsObscuringTarget(castPoints, ignoreList)
		--remove parts with no health from list of occluders
		--for key, occs in pairs(occluders)  do
		--	for index, occ in ipairs(occs) do
		--		if occ.health.Value <=0 then
		--			table.remove(occluders[key],index)
		--			print("removed")
		--		end
		--	end
		--end
		
		if tablelength(occluders[targpart])==0 and targpart:FindFirstChild("health") then
			targpart.health.Value -= damage
			if targpart.health.Value <= 0  then
				alive[targpart] = false
				--alive[targpart][2] = targpart.health.Value
			else
				alive[targpart] = true
			end
		end
		--local rayOrigin = explosion.Position
		--local rayDirection = part.Position-explosion.Position
		--local raycastParams = RaycastParams.new()
		--raycastParams.FilterDescendantsInstances = {part}
		--raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		--local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
		--if raycastResult then
		--	local hitPart = raycastResult.Instance
		--end
	end)
	
	wait(0.001)
	print('occluders')
	print(occluders)
	for key, occs in pairs(occluders) do
		sorty2(occs, partsHit)
	end
	print(occluders)
	--should run after explosion.hit
	local rep = false
	local iter = 0
	repeat
		rep = false
		iter += 1
		print("ITERATION: "..iter)
		print(alive)
		for key, val in pairs(alive) do
			if alive[key] == false then
				print(key.Name.." is dead and has "..tostring(key.health.Value))
				key.Material = Enum.Material.CorrodedMetal
				local damageleft = key.health.Value * -1
				key.health.Value = 0
				alive[key] = true
				--find parts with this dead part as only occluder
				for okey, occs in pairs(occluders) do
					if occs[1] == key then
						--apply remaining damage
						print(key.Name.."'s damageleft is being applied to "..okey.Name)
						okey.health.Value -= damageleft
						if okey.health.Value <= 0 then
							print(okey.Name.." is now dead from proliferation")
							print(okey.health.Value)
							alive[okey] = false
							rep = true
							print(alive)
						end
					end
				end
			end
		end
		for key, val in pairs(alive) do
			--test if any parts have damage they need to apply
			if key.health.Value < 0 then
				rep = true
			end 
		end
	until rep == false

end

function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

--function deadparts(alive,occluders)
--	for key, val in pairs(alive) do
--		if alive[key] == false then
--			key.Material = Enum.Material.Fabric
--			local damageleft = key.health.Value * -1

--			--find parts with this dead part as only occluder
--			for okey, occs in pairs(occluders) do
--				if tablelength(occs) == 1 and occs[1] == key then
--					--apply remaining damage
--					--print('found occluded object')
--					okey.health.Value -= damageleft
--					if okey.health.Value <= 0 then
--						alive[okey] = false
--						deadparts(alive,occluders)
--					end
--				end
--			end

--			key.health.Value = 0
--		end
--	end
--end

--function deadparts2(alive,occluders,damageleft)
--	for okey, occs in pairs(occluders) do
--		if tablelength(occs) == 1 and occs[1] == key then
--			--apply remaining damage

--			okey.health.Value -= damageleft
--			if okey.health.Value <= 0 then
--				alive[okey] = false
--				deadparts(alive,occluders)
--			end
--		end
--	end
--end
function remove2(t,superkey)
	local newtable = {}
	local index = 0
	for key, val in ipairs(t) do
		if val.health.Value > 0 or val == superkey then
			index += 1
			newtable[index] = val
		else

		end
	end
	return newtable
end

function sorty2(sort,dist)
	table.sort(sort, function (left, right)
		return dist[left] > dist[right]
	end)
end

clickDetector.MouseClick:connect(customExplosion)

local testvar = part.CFrame
local testvar2 = tostring(45)
