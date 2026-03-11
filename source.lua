local Players = game:GetService("Players")
local player = Players.LocalPlayer

workspace.Drops.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local ItemTranslations = {
	GoldGun = "Gold Blaster",
	SnakeBox = "Hiding Box",
	BigBomb = "Big Bomb",
	BoxingGloves = "Boxing Gloves",
	RiftSmoothie = "Moonlight Smoothie",
	SpeedBoost = "Speed Boost",
	SkeletonKey = "Skeleton Key",
	GweenSoda = "Gween Soda",
	StopSign = "A-90's Stop Sign"
}

local function translateItem(name)
	if not name then return nil end
	return ItemTranslations[name] or name
end

local function createBillboard(parent, color)
	if not parent then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "_PartyDebug"
	billboard.Size = UDim2.new(0,200,0,50)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = math.huge
	billboard.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1,0,1,0)
	label.Font = Enum.Font.Oswald
	label.TextColor3 = color or workspace.Drops.Highlight.OutlineColor
	label.TextStrokeTransparency = 0
	label.TextSize = 22
	label.Parent = billboard

	return label
end

local function createESP(targetPart,text, color)
	if not targetPart or not text then return end

	local label = createBillboard(targetPart, color)
	if not label then return end

	task.spawn(function()
		while targetPart.Parent do

			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")

			if root then
				local dist = (root.Position - targetPart.Position).Magnitude
				label.Text = text.." ["..math.floor(dist).."m]"
			else
				label.Text = text
			end

			task.wait(0.05)
		end
	end)
end

local function handleDrop(item)

	if not item:IsA("Model") then return end

	repeat task.wait(.1)
	until item:GetAttribute("Pickup") or item:GetAttribute("GoldValue")

	if not item.PrimaryPart then return end

	local label

	if item:GetAttribute("Pickup") then
		label = translateItem(item:GetAttribute("Pickup"))

	elseif item:GetAttribute("GoldValue") then
		label = item:GetAttribute("GoldValue").." Gold"
	end

	if label then
		createESP(item.PrimaryPart,label)
	end
end

for _,item in ipairs(workspace.Drops:GetChildren()) do
	handleDrop(item)
end

workspace.Drops.ChildAdded:Connect(handleDrop)

local function handleRoom(room)

	if room:FindFirstChild("ItemPads") then

		for _,pad in ipairs(room.ItemPads:GetChildren()) do

			local pickupType = pad:GetAttribute("PickupType")
			local color = pad.Pickups:WaitForChild(pickupType, 2)
			local highlight = workspace.Drops.Highlight:Clone()

			if pickupType and pad.PrimaryPart and color then
				createESP(pad.PrimaryPart,translateItem(pickupType), color.Color)
				highlight.Parent = pad
				highlight.OutlineColor = color.Color
				highlight.FillColor = color.Color
			end
		end

	end

	for _, Stuff in ipairs(room:GetChildren()) do
        if Stuff:IsA("Model") then
			if Stuff.Name == "GiggleCeiling" then
            	Stuff:WaitForChild("Hitbox", 9e9)
            	Stuff.Hitbox.CanTouch = false
			end
			if Stuff.Name == "DoorFake" then
				Stuff.Hidden.CanTouch = false

				if Stuff:FindFirstChild("LockPart") and Stuff.LockPart:FindFirstChild("UnlockPrompt") then
					Stuff.LockPart.UnlockPrompt.Enabled = false
				end
			end
        end
    end

	if room:FindFirstChild("Door") and room.Door.PrimaryPart then
		createESP(room.Door.PrimaryPart,"Door", Color3.fromRGB(171, 128, 111))
		local highlight = workspace.Drops.Highlight:Clone()
		highlight.Parent = room.Door.Door
		highlight.OutlineColor = Color3.fromRGB(171, 128, 111)
		highlight.FillColor = Color3.fromRGB(171, 128, 111)
	end
end

for _,room in ipairs(workspace.CurrentRooms:GetChildren()) do
	handleRoom(room)
end

workspace.CurrentRooms.ChildAdded:Connect(function(room)
	task.wait(0.5)
	handleRoom(room)
end)

local function handleKey(key)

	if key.Name ~= "KeyObtain" then return end

	local hitbox = key:FindFirstChild("Hitbox")
	if not hitbox then return end

	local handle = hitbox:FindFirstChild("Handle")
	if not handle then return end

	createESP(handle,"Key")
end

for _,desc in ipairs(workspace:GetDescendants()) do
	if desc.Name == "KeyObtain" then
		handleKey(desc)
	end
end

workspace.DescendantAdded:Connect(function(desc)
	if desc.Name == "KeyObtain" then
		task.wait()
		handleKey(desc)
	end
end)

local function handleNannerPeel(obj)

	if obj.Name ~= "NannerPeel" then return end

	if obj:IsA("BasePart") then
		obj.CanTouch = false
	end

	local hitbox = obj:FindFirstChild("Hitbox")

	if hitbox and hitbox:IsA("BasePart") then
		hitbox.CanTouch = false
	end

	local targetPart = obj

	if obj:IsA("Model") then
		targetPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
	end

	if targetPart then
		createESP(targetPart,"Nanner Peel")
	end
end

for _,v in ipairs(workspace:GetChildren()) do
	if v.Name == "NannerPeel" then
		handleNannerPeel(v)
	end
end

workspace.ChildAdded:Connect(function(child)
	if child.Name == "NannerPeel" then
		task.wait()
		handleNannerPeel(child)
	end
end)

local namecall
namecall = hookmetamethod(game, "__namecall", newcclosure(function(v, ...)
    local method = getnamecallmethod()
    local args = {...}

	if method == "FireServer" then
		if v.Name == "Underwater" then
           args[1] = false
        elseif v.Name == "Screech" then
            local Tool = player.Character:FindFirstChildWhichIsA("Tool")
            args[1] = not (Tool and Tool.Name == "Crucifix") ~= nil
        elseif v.Name == "A90" then
           	args[1] = "didnt"
        elseif v.Name == "ShadeResult" then
            return
        end
        return namecall(v, unpack(args))
    end

    return namecall(v, ...)
end))

A90Hook = hookfunction(require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.A90), function(...)
    game.ReplicatedStorage.RemotesFolder.A90:FireServer("didnt")
	return
end)
ScreechHook = hookfunction(require(LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.Screech), function(...)
	game.ReplicatedStorage.RemotesFolder.Screech:FireServer(true)
    return
end)

game:GetService("RunService").RenderStepped:Connect(function()
	local char = player.Character

	for _, v in ipairs(workspace:GetChildren()) do
		if (v.Name == "Eyes" or v.Name == "BackdoorLookman") then
			local core = v:FindFirstChild("Core")
			local ambience = core and core:FindFirstChild("Ambience")

			if ambience and ambience.Playing and not char:GetAttribute("Hiding") then
				game.ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-650)
				break
			end
		end
	end

	char:SetAttribute("SpeedBoost", 10)
end)
