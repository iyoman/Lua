local UserInputService = game:GetService("UserInputService")
local cas = game:GetService("ContextActionService")
local runservice = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvent = ReplicatedStorage:WaitForChild("KeyPress")
local invokePlacement = ReplicatedStorage:WaitForChild("invokePlacement")
local Building = require(ReplicatedStorage.Building)
local keyslist = {}
local sendlist = {}
local watchkeys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.LeftShift}

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:FindFirstChild("Humanoid")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Root = script.Parent:WaitForChild("HumanoidRootPart")
local UpperTorso = script.Parent:WaitForChild("UpperTorso")

local toolgui = player.PlayerGui.toolGui
toolgui.Enabled = false
local canBuild = false
local hasTool = false
local stepmode = true
local snap = true
local grot = true
local rotate = CFrame.Angles(0,0,0)
local zrotate = CFrame.Angles(0,0,0)


cas:UnbindAction("RbxCameraKeypress")

local function InputChanged(input, gameProcessed)
	keyslist = UserInputService:GetKeysPressed()
	sendlist.shift = false
	sendlist.W = false
	sendlist.A = false
	sendlist.S = false
	sendlist.D = false
	sendlist.E = false
	sendlist.Q = false
	sendlist.C = false
	sendlist.LeftAlt = false
	for _, key in ipairs(keyslist) do
		if key.KeyCode == Enum.KeyCode.LeftShift then
			sendlist.shift = true
		end
		if key.KeyCode == Enum.KeyCode.W then
			sendlist.W = true
		end
		if key.KeyCode == Enum.KeyCode.A then
			sendlist.A = true
		end
		if key.KeyCode == Enum.KeyCode.S then
			sendlist.S = true
		end
		if key.KeyCode == Enum.KeyCode.D then
			sendlist.D = true
		end
		if key.KeyCode == Enum.KeyCode.E then
			sendlist.E = true
		end
		if key.KeyCode == Enum.KeyCode.Q then
			sendlist.Q = true
		end
		if key.KeyCode == Enum.KeyCode.C then
			sendlist.C = true
		end
		if key.KeyCode == Enum.KeyCode.LeftAlt then
			sendlist.LeftAlt = true
		end
	end
	remoteEvent:FireServer(sendlist)
	
	toolgui.Manipulator.pos.Text = tostring(Root.Position)  
	
	if (hasTool and hum.Health > 0) then
		--make humanoid root rotate to mouse on x and z axis and make waist bend up and down
		hum.AutoRotate = false
		Root.CFrame = CFrame.new(Root.Position, Vector3.new(Mouse.Hit.p.X, Root.Position.Y, Mouse.Hit.p.Z))
		--UpperTorso.Waist.C0 = CFrame.new(UpperTorso.Position, Vector3.new(Mouse.Hit.p.X, Mouse.Hit.p.Y, Mouse.Hit.p.Z))
		local sub = Mouse.Hit.p-UpperTorso.Position
		local hordist = math.sqrt(sub.X*sub.X+sub.Z*sub.Z)  
		local ang = math.atan2(sub.Y,hordist)
		UpperTorso.Waist.C0 = CFrame.Angles(ang,0,0)

		if (canBuild) then
			local model = ReplicatedStorage.buildObjects.wall
			norm = 0
			if not pcall(raycast) then
				norm = Vector3.new(0,0,0)
			end
			
			local newcf = CFrame.new(Mouse.Hit.p, Mouse.Hit.p+norm)*rotate
			if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				Building:Place(model, (zrotate*(newcf-newcf.p))+newcf.p, Mouse.Target, norm, snap)
			else
				Building:Ghost(model, (zrotate*(newcf-newcf.p))+newcf.p, Mouse.Target, norm, snap)
			end
		end

		--place ghost or object

	else
		hum.AutoRotate = true
		UpperTorso.Waist.C0 = CFrame.Angles(0,0,0)
	end
	
	
	
end

runservice.Heartbeat:Connect(InputChanged)
--UserInputService.InputBegan:Connect(InputChanged)
--UserInputService.InputEnded:Connect(InputChanged)
--Mouse.Move:Connect(InputChanged)

char.ChildAdded:Connect(function(NewChild)
	if NewChild:IsA("Tool") then
		hasTool = true
		toolgui.Enabled = true
		toolgui.Weapon.Visible = false
		toolgui.Manipulator.Visible = false
		if NewChild.Name == "Manipulator" then
			toolgui.Manipulator.Visible = true
			canBuild = true
			local urot = CFrame.Angles(0,0,0)
			local jrot = CFrame.Angles(0,0,0)
			local hrot = CFrame.Angles(0,0,0)
			local krot = CFrame.Angles(0,0,0)
			

			cas:BindActionAtPriority("buildRotation",cfunc,false,100000,Enum.KeyCode.Y,Enum.KeyCode.H,Enum.KeyCode.G,Enum.KeyCode.J,Enum.KeyCode.T,Enum.KeyCode.U)
		else
			toolgui.Weapon.Visible = true
			toolgui.Weapon.gunname.Text = NewChild.Name
		end
	end
end)

--then to detect if the tool is unequipped you do the opposite
char.ChildRemoved:Connect(function(RemovedChild)
	if RemovedChild:IsA("Tool") then
		hasTool = false
		
		canBuild = false
		cas:UnbindAction("buildRotation")
		toolgui.Enabled = false
		workspace.ghosts:ClearAllChildren()
		rotate = CFrame.Angles(0,0,0)
		zrotate = CFrame.Angles(0,0,0)
	end
end)

--buttons
local buttonconnections = {}

local rotatestep = math.pi/4
local rotatenostep = 0.1


--toolgui setup
local guioncolor = Color3.new(0.223529, 1, 0.168627)
local guioffcolor = Color3.new(0.764706, 0.764706, 0.764706)
toolgui.Manipulator.togglerot.BackgroundColor3 = guioncolor
toolgui.Manipulator.togglesnap.BackgroundColor3 = guioncolor
toolgui.Manipulator.togglegrot.BackgroundColor3 = guioncolor

function buttonhandler(Frame)
	for key, item in pairs(Frame:GetChildren()) do
		if item:IsA("TextButton") then
			buttonconnections[key] = item.MouseButton1Click:Connect(function()
				if item.Name == "togglerot" then
					if stepmode == false then
						item.BackgroundColor3 = guioncolor
						stepmode = true
						print("stepmode on")
					else
						item.BackgroundColor3 = guioffcolor
						stepmode = false
						print("stepmode off")
					end
				end
				if item.Name == "togglesnap" then
					snap = not snap
					if snap == true then
						item.BackgroundColor3 = guioncolor
					else
						item.BackgroundColor3 = guioffcolor
					end
				end
				if item.Name == "togglegrot" then
					grot = not grot
					if grot then
						item.BackgroundColor3 = guioncolor
					else
						item.BackgroundColor3 = guioffcolor
					end
				end
			end)
		end
	end
end

buttonhandler(toolgui.Manipulator)

function raycast()
	local rayOrigin = workspace.CurrentCamera.CFrame.Position
	local rayDirection = (Mouse.Hit.p-workspace.CurrentCamera.CFrame.Position)*1.1


	-- Build a "RaycastParams" object and cast the ray
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {char}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	norm = workspace:Raycast(rayOrigin, rayDirection, raycastParams).Normal
end




local urot = CFrame.Angles(0,0,0)
local jrot = CFrame.Angles(0,0,0)
local hrot = CFrame.Angles(0,0,0)
local krot = CFrame.Angles(0,0,0)
local turning = false
local beatloop = {}
local lim = math.pi/4


--build buttons handler
function cfunc(actionName, inputState, inputObject)
	
	if inputState == Enum.UserInputState.Begin then
		
		local camvec = workspace.CurrentCamera.CFrame.LookVector
		local ang = math.atan2(camvec.Z,camvec.X)
		-- if desired take atan2 of lookvector on zrotate to reverse u/j directions based on camera 
		
		--if ang<lim and ang>-lim then
		--	urot = rotate*CFrame.Angles(rotatestep,0,0)
		--	jrot = rotate*CFrame.Angles(-rotatestep,0,0)
		--	print("1")
		--elseif ang>lim and ang<(3*lim) then
		--	urot = rotate*CFrame.Angles(0,rotatestep,0)
		--	jrot = rotate*CFrame.Angles(0,-rotatestep,0)
		--	print('2')
		--elseif ang<-lim and ang>(-3*lim) then
		--	urot = rotate*CFrame.Angles(0,-rotatestep,0)
		--	jrot = rotate*CFrame.Angles(0,rotatestep,0)
		--	print('4')
		--else
		--	urot = rotate*CFrame.Angles(-rotatestep,0,0)
		--	jrot = rotate*CFrame.Angles(rotatestep,0,0)
		--	print("3")
		--end
		
		local kc = inputObject.KeyCode

		--step mode
		if stepmode == true then
			buildkeys(kc, rotatestep, grot)
		end

		--no step mode
		if stepmode == false then
			table.insert(beatloop, runservice.Heartbeat:Connect(function(step)
				buildkeys(kc, rotatenostep, grot)
			end))
		end
	end
	if inputState == Enum.UserInputState.End then
		table.foreach(beatloop,function(key,value)
			value:Disconnect()
		end)
	end
end

function buildkeys(kc, rotstp, grot) 
	if kc == Enum.KeyCode.Y then
		--rotate = urot
		rotate = rotate*CFrame.Angles(rotstp,0,0)
	end
	if kc == Enum.KeyCode.H then
		--rotate = jrot
		rotate = rotate*CFrame.Angles(-rotstp,0,0)
	end
	if kc == Enum.KeyCode.G then
		if grot then
			zrotate = zrotate*CFrame.Angles(0,rotstp,0)
		else
			rotate = rotate*CFrame.Angles(0, 0, rotstp)
		end
	end
	if kc == Enum.KeyCode.J then
		if grot then
			zrotate = zrotate*CFrame.Angles(0,-rotstp,0)
		else
			rotate = rotate*CFrame.Angles(0, 0, -rotstp)
		end
	end
	if kc == Enum.KeyCode.T then
		rotate = rotate*CFrame.Angles(0,-rotstp,0)
	end
	if kc == Enum.KeyCode.U then
		rotate = rotate*CFrame.Angles(0,rotstp,0)
	end
end
