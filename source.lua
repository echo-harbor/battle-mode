if not game.ReplicatedStorage:FindFirstChild("GameData") or game.ReplicatedStorage.GameData.Floor.Value ~= "Party" then
	warn("this script can only be executed in battle mode")
	return
end

local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

player.PlayerGui:WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game")
task.wait(0.05)

local mainUI = player.PlayerGui.MainUI
local main_game = require(mainUI.Initiator.Main_Game)
print("injected into main_game")

if main_game._injectedPartyScript then
	warn("script already ran")
	return
end
main_game._injectedPartyScript = true

local function sysmsg(msg, data)
	game.TextChatService.TextChannels.RBXSystem:DisplaySystemMessage(msg, data)
end

local function caption(text, ctype)
	local captype = ctype == true and "info" or ctype
	local ctype_final = ctype == false and "warning" or ctype or "info"
	if ctype_final ~= "thought" then
		coroutine.wrap(function()
			for _, stuff in mainUI.CaptionHolder:GetChildren() do
				if stuff.Name == "LiveCaption" then
					stuff.TextTransparency = stuff.TextTransparency + 0.25
					stuff.TextStrokeTransparency = stuff.TextStrokeTransparency + 0.25
					stuff.BackgroundTransparency = stuff.BackgroundTransparency + 0.075
					if stuff.Text == text then
						stuff:Destroy()
					end
				end
			end
			if text ~= "" and (text ~= " " and text ~= nil) then
				local livecapt = mainUI.MainFrame.NewCaption:Clone()
				livecapt.Name = "LiveCaption"
				livecapt.Visible = true
				livecapt.Text = text
				local backgroundTransparency = 1
				local strokeTransparency = 0
				livecapt.TextTransparency = 1
				livecapt.TextStrokeTransparency = 1
				livecapt.BackgroundTransparency = 1
				livecapt.MaxVisibleGraphemes = 0
				if ctype_final == "thought" then
					livecapt.TextColor3 = Color3.fromRGB(229, 224, 218)
					livecapt.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
					livecapt.LayoutOrder = livecapt.LayoutOrder + 5
					strokeTransparency = 0.6
				elseif ctype_final == "info" then
					livecapt.TextColor3 = Color3.fromRGB(255, 222, 189)
					livecapt.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					livecapt.LayoutOrder = livecapt.LayoutOrder + 5
					strokeTransparency = 0.7
				elseif ctype_final == "warning" then
					livecapt.TextColor3 = Color3.fromRGB(225, 177, 138)
					livecapt.FontFace = Font.new("rbxasset://fonts/families/Oswald.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
					livecapt.BackgroundColor3 = Color3.fromRGB(36, 28, 26)
					livecapt.LayoutOrder = livecapt.LayoutOrder - 5
					backgroundTransparency = 0.75
					strokeTransparency = 0.7
				end
				sysmsg("[\xF0\x9F\x9A\xAA]: ".. text)
				livecapt.Parent = mainUI.CaptionHolder
				game.Debris:AddItem(livecapt, 10)
				mainUI.Initiator.Main_Game.Reminder.Caption:Play()
				tweenService:Create(livecapt, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					["BackgroundTransparency"] = backgroundTransparency,
					["TextTransparency"] = 0,
					["TextStrokeTransparency"] = strokeTransparency
				}):Play()
				local ti = TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
				local tweenStuff = {}
				local _text = text
				tweenStuff.MaxVisibleGraphemes = string.len(_text)
				tweenService:Create(livecapt, ti, tweenStuff):Play()
				task.wait(8)
				if livecapt then
					tweenService:Create(livecapt, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						["BackgroundTransparency"] = 1,
						["TextTransparency"] = 1,
						["TextStrokeTransparency"] = 1
					}):Play()
				end
			end
		end)()
	end
end

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
	StopSign = "A-90's Stop Sign",
	RushMoving = "Rush",
	AmbushMoving = "Ambush",
	BackdoorRush = "Blitz",
	StarVial = "Vial of Starlight",
	StarBottle = "Bottle of Starlight",
	StarShield = "Starlight Shield",
}
local autoPickupItems = {"Gold Blaster", "Moonlight Smoothie", "Bottle of Starlight", "Big Bomb", "Boxing Gloves", "Donut"}
local autoHealItems = {"Smoothie", "Moonlight Smoothie", "Bottle of Starlight", "Donut", "Vial of Starlight", "Bread", "Cheese", "Nanner"}
local trashItems = {"Flashlight"}

print("these items will be auto-picked up:", table.concat(autoPickupItems, ", "))
print("these items will be auto-used when medium hp:", table.concat(autoHealItems, ", "))
print("these items are TRASH:", table.concat(trashItems, ", "))

local char = player.Character or player.CharacterAdded:Wait()
local root = char and char:FindFirstChild("HumanoidRootPart")

local espConfig = {
	Gold = {
		Color = Color3.fromRGB(241, 226, 143)
	}
}

local espStuff = {}

local function translateItem(name)
	if not name then return nil end
	return ItemTranslations[name] or name
end

local function createBillboard(parent, color)
	if not parent then return end
	if parent:FindFirstChild("_PartyDebug") then return end

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
	label.Text = "Loading..."

	return label
end

local function createESP(targetPart, text, color)
	if not targetPart or not text then return end

	local label = createBillboard(targetPart, color)
	if not label then return end

	table.insert(espStuff, {Target = targetPart, Label = label, Text = text})
end

local function handleDrop(item)
	if not item:IsA("Model") then return end

	for i = 1, 10000 do
		task.wait(.1)
		if (item:GetAttribute("Pickup") or item:GetAttribute("GoldValue")) and item.PrimaryPart then
			break
		end
	end

	if not item.PrimaryPart then return end

	local label
	local color

	if item:GetAttribute("Pickup") then
		label = translateItem(item:GetAttribute("Pickup"))
	elseif item:GetAttribute("GoldValue") then
		label = item:GetAttribute("GoldValue").." Gold"
		color = espConfig.Gold.Color
	end

	if item:GetAttribute("Pickup") and table.find(trashItems, label) then
		warn("TRASH ITEM", label, "DELETE NOW!!")
		item:Destroy()
		return
	end

	if label then
		if (not (item:GetAttribute("PlayerName") == player.Name)) and (item:GetAttribute("GoldValue") or (game.ReplicatedStorage.GameData.LatestRoom.Value <= 2) or (((#player.Backpack:GetChildren() + (player.Character:FindFirstChildOfClass("Tool") and 1 or 0)) < 6) or (item:GetAttribute("CanStack") and not item:GetAttribute("CanOwnMultiple"))) and item:FindFirstChildOfClass("ProximityPrompt") and table.find(autoPickupItems, label) and (not (player.Backpack:FindFirstChild(item.Name) or player.Character:FindFirstChild(item.Name)) or item:GetAttribute("CanStack")) and not item:GetAttribute("CanOwnMultiple")) then
			task.spawn(function()
				task.wait()
				for i=1,1000000 do
					if item.Parent == nil then
						break
					end
					fireproximityprompt(item:FindFirstChildOfClass("ProximityPrompt"))
					task.wait(.03)
				end
			end)
		end
		createESP(item.PrimaryPart,label,color)
	end
end

local function handleRoom(room)
	if room:FindFirstChild("ItemPads") then
		for _, pad in ipairs(room.ItemPads:GetChildren()) do
			local pickupType = pad:GetAttribute("PickupType")
			local color = pad.Pickups:WaitForChild(pickupType, 2)
			local highlight = workspace.Drops.Highlight:Clone()

			if pickupType and pad.PrimaryPart and color then
				createESP(pad.PrimaryPart,translateItem(pickupType), color.Color)
				highlight.Parent = pad
				highlight.OutlineColor = color.Color
				highlight.FillColor = color.Color
				if pad:FindFirstChild("Hitbox") then
					firetouchinterest(pad.Hitbox, game.Players.LocalPlayer.Character.HumanoidRootPart, 0)
					task.wait()
					firetouchinterest(pad.Hitbox, game.Players.LocalPlayer.Character.HumanoidRootPart, 1)
				end
			end
		end
	end

	for _, Stuff in ipairs(room:GetDescendants()) do
        if Stuff:IsA("Model") then
			if Stuff.Name == "GiggleCeiling" or Stuff.Name == "Snare" then
            	Stuff:WaitForChild("Hitbox", 9999999)
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
		local prefix = ""
		local color = Color3.fromRGB(171, 128, 111)
		if room.Door:WaitForChild("FiredampSign", 1) then
			prefix = "Firedamp "
			color = Color3.fromRGB(252, 151, 108)
		end
		createESP(room.Door.PrimaryPart,prefix.."Room ".. (tonumber(room.Name) + 1), color)
		local highlight = workspace.Drops.Highlight:Clone()
		highlight.Parent = room.Door.Door
		highlight.OutlineColor = color
		highlight.FillColor = color

		if room.Door:FindFirstChild("ClientBreakDoor") and room.Door.Door:FindFirstChildOfClass("ProximityPrompt") then
			print("breakable door")
			room.Door.Door:FindFirstChildOfClass("ProximityPrompt").Triggered:Once(function()
				print("triggered")
				room.Door:FindFirstChild("ClientBreakDoor"):FireServer()
			end)
		end
	end
end

local function handleKey(key)
	if key.Name ~= "KeyObtain" then return end

	local hitbox = key:FindFirstChild("Hitbox")
	if not hitbox then return end

	local handle = hitbox:FindFirstChild("Handle")
	if not handle then return end

	createESP(handle,"Key")

	task.spawn(function()
		for i=1,1000000 do
			if key.Parent == nil then
				break
			end
			fireproximityprompt(key:FindFirstChild("ModulePrompt", true))
			task.wait(.03)
		end
	end)
end

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

local function doChildStuff(c)
	if c.Name == "NannerPeel" then
		task.wait()
		handleNannerPeel(c)
	end

	if (c.Name == "RushMoving" or c.Name == "AmbushMoving" or c.Name == "BackdoorRush") then
    	local msg = translateItem(c.Name) .. " has spawned, hide quickly!"
    	caption(msg, "warning")

    	local part = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")

    	if part then
    	    createESP(part, translateItem(c.Name), Color3.fromRGB(255, 0, 4))
   		end

    	task.spawn(function()
    	    while c.PrimaryPart do
				print("i am rushing!")
        	    if root and c.PrimaryPart.Parent ~= nil then
					print("we are countering!")
        	        local dist = (root.Position - c.PrimaryPart.Position).Magnitude
      	          	if dist < 100 and not char:GetAttribute("Hiding") then
                   	 	local crucifix = player.Backpack:FindFirstChild("Crucifix") or char:FindFirstChild("Crucifix")
                   		local hidingBox = player.Backpack:FindFirstChild("SnakeBox") or char:FindFirstChild("SnakeBox")
                    	if crucifix then
                    	    char.Humanoid:EquipTool(crucifix)
                    	elseif hidingBox then
                    	    char.Humanoid:EquipTool(hidingBox)
							if hidingBox:FindFirstChild("Remote") then
								hidingBox.Remote:FireServer()
							end
                    	else
                    	    print("ur Done. Lol")
                    	end
                    	break
                	end
            	end
            	task.wait(0.1)
        	end
    	end)
	end
end

print("did the functions!")

for _, item in ipairs(workspace.Drops:GetChildren()) do
	handleDrop(item)
end
print("func part 0")
workspace.Drops.ChildAdded:Connect(handleDrop)

print("func part 1")

for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
	handleRoom(room)
end
workspace.CurrentRooms.ChildAdded:Connect(function(room)
	task.wait(0.5)
	handleRoom(room)
end)

print("func part 2")

for _, desc in ipairs(workspace:GetDescendants()) do
	if desc.Name == "KeyObtain" then
		task.wait()
		handleKey(desc)
	end
end

workspace.CurrentRooms.DescendantAdded:Connect(function(desc)
	if desc.Name == "KeyObtain" then
		task.wait()
		handleKey(desc)
	end
end)

for _, children in ipairs(workspace:GetChildren()) do
	doChildStuff(children)
end

workspace.ChildAdded:Connect(doChildStuff)

print("did the stuff!")

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

A90Hook = hookfunction(require(mainUI.Initiator.Main_Game.RemoteListener.Modules.A90), function(...)
    game.ReplicatedStorage.RemotesFolder.A90:FireServer("didnt")
	return
end)
ScreechHook = hookfunction(require(mainUI.Initiator.Main_Game.RemoteListener.Modules.Screech), function(...)
	game.ReplicatedStorage.RemotesFolder.Screech:FireServer(true)
    return
end)

print("attached hooks")

local bypassanticheat = false
local backpackdebounce = false

local function doBackpackStuff(c)
	if backpackdebounce then return end
	if c:IsA("Tool") then
		if player.Character.Humanoid.Health <= 150 then
			print("IS ITEM AUTO HEAL?", table.find(autoHealItems, (translateItem(c.Name))) ~= nil)
			if table.find(autoHealItems, (translateItem(c.Name))) then
				print("HAS REMOTE?", c:FindFirstChild("Remote") ~= nil)
				if c:FindFirstChild("Remote") then
					backpackdebounce = true
					task.delay(2, function()
						backpackdebounce = false
					end)
					if c.Parent ~= player.Character then
						player.Character.Humanoid:EquipTool(c)
					end
					c:FindFirstChild("Remote"):FireServer()
				end
			end
		end
	end
end

print("doing backpack")

char.ChildAdded:Connect(doBackpackStuff)
player.Backpack.ChildAdded:Connect(doBackpackStuff)

char:GetAttributeChangedSignal("Stunned"):Connect(function()
	if root then
        root.AssemblyLinearVelocity = char:GetAttribute("Stunned") and root.CFrame.LookVector * 99999 or Vector3.zero
    end
end)

print("doing rendersteped")

task.spawn(function()
	while true do
		task.wait(.5)
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
	end
end)

task.spawn(function()
	while true do
		task.wait(.05)

		for i = #espStuff, 1, -1 do
    		local stuff = espStuff[i]
    		if not stuff.Target.Parent or not stuff.Label.Parent then
    		    table.remove(espStuff, i)
   			end
		end

		for _, stuff in ipairs(espStuff) do
			local targetPart = stuff.Target
			local label = stuff.Label
			local text = stuff.Text

			if targetPart.Parent ~= nil then
				if root then
					local dist = (root.Position - targetPart.Position).Magnitude
					label.Text = text.." ["..math.floor(dist).."m]"
				else
					label.Text = ""
				end
			end
		end
	end
end)

game.ReplicatedStorage.GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    task.wait(1)
    for i = #espStuff, 1, -1 do
        local stuff = espStuff[i]
        local target = stuff.Target
        if target and target.Parent then
            local rayParams = RaycastParams.new()
            rayParams.CollisionGroup = "BaseCheck"
            local result = workspace:Raycast(target.Position, Vector3.new(0, -300, 0), rayParams)
            if not result then
                table.remove(espStuff, i)
                local billboard = target:FindFirstChild("_PartyDebug")
                if billboard then
                    billboard:Destroy()
                end
            end
        end
    end
end)

local function removeFog(fog)
	if fog:IsA("Atmosphere") then
		fog:Destroy()
	end
end

game.Lighting.ChildAdded:Connect(removeFog)
for _, fog in ipairs(game.Lighting:GetChildren()) do
	removeFog(fog)
end

game:GetService("RunService").RenderStepped:Connect(function()
	if bypassanticheat then
		player.Character:PivotTo(player.Character:GetPivot() + workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1) * -100)
	end

	game.Lighting.Ambient = Color3.fromRGB(100,100,100)
end)

print("doing userinput")

userInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.T and not processed then
		warn("killing anti-cheat")
		bypassanticheat = true
	end
end)

userInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.T then
		bypassanticheat = false
	end
end)

caption("initiated integrated assist mode!", "warning")
