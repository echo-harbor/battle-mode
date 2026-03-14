if not game.ReplicatedStorage:FindFirstChild("GameData") or game.ReplicatedStorage.GameData.Floor.Value ~= "Party" then
	warn("This script can only be executed in battle mode")
	return
end

local Players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")

local player = Players.LocalPlayer

print("waiting for main_game...")
player.PlayerGui:WaitForChild("MainUI"):WaitForChild("Initiator"):WaitForChild("Main_Game")
task.wait(0.05)

local mainUI = player.PlayerGui.MainUI
local main_game = require(mainUI.Initiator.Main_Game)

if main_game._injectedPartyScript then
	warn("script already ran")
	return
end
main_game._injectedPartyScript = true
print("Injected into main_game")

local ambientColor = Color3.fromRGB(100, 100, 100)
local captionSound = mainUI.Initiator.Main_Game.Reminder.Caption
local captionHolder = mainUI.CaptionHolder
local newCaptionTemplate = mainUI.MainFrame.NewCaption
local rbxSystem = game.TextChatService.TextChannels.RBXSystem

local function sysmsg(msg, data)
	rbxSystem:DisplaySystemMessage(msg, data)
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

local autoPickupSet = {
	["Gold Blaster"] = true,
	["Moonlight Smoothie"] = true,
	["Bottle of Starlight"] = true,
	["Big Bomb"] = true,
	["Boxing Gloves"] = true,
	["Donut"] = true,
}
local autoHealSet = {
	["Smoothie"] = true,
	["Moonlight Smoothie"] = true,
	["Bottle of Starlight"] = true,
	["Donut"] = true,
	["Vial of Starlight"] = true,
	["Bread"] = true,
	["Cheese"] = true,
	["Nanner"] = true,
}
local trashSet = {
	["Flashlight"] = true,
	["Lockpick"] = true,
	["SkeletonKey"] = true,
	["TipJar"] = true,
}

local function pconcat(t, seperator)
	local final = ""
	
	for name, _ in pairs(t) do
		if final == "" then
			final = name
		else
			final = final .. seperator .. name
		end
	end
	
	return final
end

print("Loading config...")
print("these items will be auto-picked up:", pconcat(autoPickupSet, ", "))
print("these items will be used automatically when low hp:", pconcat(autoHealSet, ", "))
warn("these items are TRASH, :Destroy() NOW!:", pconcat(trashSet, ", "))

print("waiting for character")

local char = player.Character or player.CharacterAdded:Wait()
local root = char:FindFirstChild("HumanoidRootPart")

local espConfig = {
	Gold = { Color = Color3.fromRGB(241, 226, 143) }
}

local espStuff = {}
local lookAwayStuff = {}

local function translateItem(name)
	if not name then return nil end
	return ItemTranslations[name] or name
end

local function createBillboard(parent, color)
	if not parent then return end
	if parent:FindFirstChild("_PartyDebug") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "_PartyDebug"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = math.huge
	billboard.Parent = parent

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.Oswald
	label.TextColor3 = color or workspace.Drops.Highlight.OutlineColor
	label.TextStrokeTransparency = 0
	label.TextSize = 22
	label.Text = "Loading..."
	label.Parent = billboard

	return label
end

local function createESP(targetPart, text, color)
	if not targetPart or not text then return end
	local label = createBillboard(targetPart, color)
	if not label then return end
	table.insert(espStuff, { Target = targetPart, Label = label, Text = text })
end

local function tryAutoPickup(item, label)
	task.spawn(function()
		local prompt = item:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then return end

		while item.Parent ~= nil do
			if player.Backpack:FindFirstChild(item.Name) or char:FindFirstChild(item.Name) then
				break
			end
			fireproximityprompt(prompt)
			task.wait(0.2)
		end
	end)
end

local function handleDrop(item)
	if not item:IsA("Model") then return end

	local waited = 0
	while not ((item:GetAttribute("Pickup") or item:GetAttribute("GoldValue")) and item.PrimaryPart) do
		task.wait(0.1)
		waited += 0.1
		if waited >= 10 then return end
	end

	if not item.PrimaryPart then return end

	local label, color

	if item:GetAttribute("Pickup") then
		label = translateItem(item:GetAttribute("Pickup"))
	elseif item:GetAttribute("GoldValue") then
		label = item:GetAttribute("GoldValue") .. " Gold"
		color = espConfig.Gold.Color
	end

	if not label then return end

	if item:GetAttribute("Pickup") and trashSet[label] then
		item:Destroy()
		return
	end

	local isOwnedByUs = item:GetAttribute("PlayerName") == player.Name
	local backpackCount = #player.Backpack:GetChildren() + (char:FindFirstChildOfClass("Tool") and 1 or 0)
	local canStack = item:GetAttribute("CanStack")
	local canOwnMultiple = item:GetAttribute("CanOwnMultiple")
	local alreadyHave = player.Backpack:FindFirstChild(item.Name) or char:FindFirstChild(item.Name)
	local hasPrompt = item:FindFirstChildOfClass("ProximityPrompt")

	local shouldPickup = not isOwnedByUs
		and autoPickupSet[label]
		and hasPrompt
		and not canOwnMultiple
		and (canStack or not alreadyHave)
		and (item:GetAttribute("GoldValue") or game.ReplicatedStorage.GameData.LatestRoom.Value <= 2 or backpackCount < 6 or canStack)

	if shouldPickup then
		tryAutoPickup(item, label)
	end

	createESP(item.PrimaryPart, label, color)
end

local dropsHighlight = workspace.Drops.Highlight

local function handleRoom(room)
	room:WaitForChild("Door", 9999)
	room:WaitForChild("ItemPads", 1)

	if room:FindFirstChild("ItemPads") then
		for _, pad in ipairs(room.ItemPads:GetChildren()) do
			local pickupType = pad:GetAttribute("PickupType")
			local color = pad.Pickups:WaitForChild(pickupType, 2)

			if pickupType and pad.PrimaryPart and color then
				createESP(pad.PrimaryPart, translateItem(pickupType), color.Color)
				local highlight = dropsHighlight:Clone()
				highlight.OutlineColor = color.Color
				highlight.FillColor = color.Color
				highlight.Parent = pad

				local hitbox = pad:FindFirstChild("Hitbox")
				if hitbox then
					local hrp = char.HumanoidRootPart
					firetouchinterest(hitbox, hrp, 0)
					task.wait()
					firetouchinterest(hitbox, hrp, 1)
				end
			end
		end
	end

	for _, Stuff in ipairs(room:GetDescendants()) do
		if Stuff:IsA("Model") then
			if Stuff.Name == "GiggleCeiling" or Stuff.Name == "Snare" then
				local hitbox = Stuff:WaitForChild("Hitbox", 10)
				if hitbox then hitbox.CanTouch = false end
			end
			if Stuff.Name == "DoorFake" then
				if Stuff:FindFirstChild("Hidden") then
					Stuff.Hidden.CanTouch = false
				end
				if Stuff:FindFirstChild("LockPart") and Stuff.LockPart:FindFirstChild("UnlockPrompt") then
					Stuff.LockPart.UnlockPrompt.Enabled = false
				end
			end
		end
	end

	local door = room:FindFirstChild("Door")
	if door and door.PrimaryPart then
		local prefix = ""
		local color = Color3.fromRGB(171, 128, 111)
		if door:WaitForChild("FiredampSign", 1) then
			prefix = "Firedamp "
			color = Color3.fromRGB(252, 151, 108)
		end
		createESP(door.PrimaryPart, prefix .. "Room " .. (tonumber(room.Name) + 1), color)

		local highlight = dropsHighlight:Clone()
		highlight.OutlineColor = color
		highlight.FillColor = color
		highlight.Parent = door.Door

		local breakDoor = door:FindFirstChild("ClientBreakDoor")
		local doorPrompt = door.Door:FindFirstChildOfClass("ProximityPrompt")
		if breakDoor and doorPrompt then
			doorPrompt.Triggered:Once(function()
				breakDoor:FireServer()
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

	createESP(handle, "Key")

	task.spawn(function()
		local prompt = key:FindFirstChild("ModulePrompt", true)
		if not prompt then return end

		while key.Parent ~= nil do
			fireproximityprompt(prompt)
			task.wait(0.2)
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

	local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
	if targetPart then
		createESP(targetPart, "Nanner Peel")
	end
end

local function doChildStuff(c)
	if c.Name == "NannerPeel" then
		task.wait()
		handleNannerPeel(c)
	elseif c.Name == "RushMoving" or c.Name == "AmbushMoving" or c.Name == "BackdoorRush" then
		local translatedName = translateItem(c.Name)
		caption(translatedName .. " has spawned, hide quickly!", "warning")

		local part = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")
		if part then
			createESP(part, translatedName, Color3.fromRGB(255, 0, 4))
		end

		task.spawn(function()
			while c.PrimaryPart do
				if root and c.PrimaryPart.Parent ~= nil then
					local dist = (root.Position - c.PrimaryPart.Position).Magnitude
					if dist < 100 and not char:GetAttribute("Hiding") then
						local crucifix = player.Backpack:FindFirstChild("Crucifix") or char:FindFirstChild("Crucifix")
						local hidingBox = player.Backpack:FindFirstChild("SnakeBox") or char:FindFirstChild("SnakeBox")
						if crucifix then
							char.Humanoid:EquipTool(crucifix)
						elseif hidingBox then
							char.Humanoid:EquipTool(hidingBox)
							local remote = hidingBox:FindFirstChild("Remote")
							if remote then remote:FireServer() end
						end
						break
					end
				end
				task.wait(0.1)
			end
		end)
	elseif c.Name == "Eyes" or c.Name == "BackdoorLookman" then
		table.insert(lookAwayStuff, c)
	end
end

print("initiating script")

char:WaitForChild("HumanoidRootPart")
local ogphysics = char.HumanoidRootPart.CustomPhysicalProperties
local newphysics = PhysicalProperties.new(100, 0.7, 0, 100, 100)
char.HumanoidRootPart.CustomPhysicalProperties = newphysics

local collisionCloned = char:WaitForChild("CollisionPart"):Clone()
collisionCloned.Parent = char
collisionCloned.CollisionGroup = "Player"
collisionCloned.CanCollide = false
collisionCloned.CanQuery = false
if not collisionCloned:FindFirstChild("Weld") then
	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, 0.056, 0)
	weld.Part0 = collisionCloned
	weld.Part1 = char.PrimaryPart
end

for _, item in ipairs(workspace.Drops:GetChildren()) do
	handleDrop(item)
end
workspace.Drops.ChildAdded:Connect(handleDrop)

for _, room in ipairs(workspace.CurrentRooms:GetChildren()) do
	task.spawn(handleRoom, room)
end
workspace.CurrentRooms.ChildAdded:Connect(function(room)
	task.wait(0.5)
	handleRoom(room)
end)

for _, desc in ipairs(workspace:GetDescendants()) do
	if desc.Name == "KeyObtain" then
		task.spawn(handleKey, desc)
	end
end
workspace.CurrentRooms.DescendantAdded:Connect(function(desc)
	if desc.Name == "KeyObtain" then
		task.wait()
		handleKey(desc)
	end
end)

for _, child in ipairs(workspace:GetChildren()) do
	doChildStuff(child)
end
workspace.ChildAdded:Connect(doChildStuff)

local namecall
namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = { ... }

	if method == "FireServer" then
		local remote = self.Name
		if remote == "Underwater" then
			args[1] = false
		elseif remote == "Screech" then
			return
		elseif remote == "A90" then
			args[1] = "didnt"
		elseif remote == "ShadeResult" then
			return
		end
		return namecall(self, unpack(args))
	end

	return namecall(self, ...)
end))

A90Hook = hookfunction(require(mainUI.Initiator.Main_Game.RemoteListener.Modules.A90), function(...)
	game.ReplicatedStorage.RemotesFolder.A90:FireServer("didnt")
end)
ScreechHook = hookfunction(require(mainUI.Initiator.Main_Game.RemoteListener.Modules.Screech), function(...)
	return
end)

local backpackdebounce = false

local function doBackpackStuff(c)
	if backpackdebounce or not c:IsA("Tool") then return end
	if player.Character.Humanoid.Health > 150 then return end

	local translated = translateItem(c.Name)
	if not autoHealSet[translated] then return end

	local remote = c:FindFirstChild("Remote")
	if not remote then return end

	backpackdebounce = true
	task.delay(2, function() backpackdebounce = false end)

	if c.Parent ~= player.Character then
		player.Character.Humanoid:EquipTool(c)
	end
	remote:FireServer()
end

char.ChildAdded:Connect(doBackpackStuff)
player.Backpack.ChildAdded:Connect(doBackpackStuff)

char:GetAttributeChangedSignal("Stunned"):Connect(function()
	if root then
		root.AssemblyLinearVelocity = char:GetAttribute("Stunned") and (root.CFrame.LookVector * 99999) or Vector3.zero
	end
end)

task.spawn(function()
	while true do
		task.wait()
		if char:GetAttribute("ScreechOn") then continue end
		local shouldFire = false
		if not char:GetAttribute("Hiding") then
			for _, v in ipairs(lookAwayStuff) do
				local core = v:FindFirstChild("Core")
				local ambience = core and core:FindFirstChild("Ambience")
				if ambience and ambience.Playing then
					shouldFire = true
					break
				end
			end
		end
		if shouldFire then
			game.ReplicatedStorage.RemotesFolder.MotorReplication:FireServer(-650)
		end
	end
end)

task.spawn(function()
	while player:GetAttribute("Alive") do
		task.wait(1/20)
		collisionCloned.Massless = not collisionCloned.Massless

		for i = #espStuff, 1, -1 do
			local stuff = espStuff[i]
			if not stuff.Target.Parent or not stuff.Label.Parent then
				table.remove(espStuff, i)
			end
		end

		if not root then continue end
		local rootPos = root.Position

		for _, stuff in ipairs(espStuff) do
			if stuff.Target.Parent then
				local dist = (rootPos - stuff.Target.Position).Magnitude
				stuff.Label.Text = stuff.Text .. " [" .. math.floor(dist) .. "m]"
			end
		end
	end
end)

game.ReplicatedStorage.GameData.LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
	task.wait(1)
	local rayParams = RaycastParams.new()
	rayParams.CollisionGroup = "BaseCheck"

	for i = #espStuff, 1, -1 do
		local stuff = espStuff[i]
		local target = stuff.Target
		if target and target.Parent then
			local result = workspace:Raycast(target.Position, Vector3.new(0, -300, 0), rayParams)
			if not result then
				table.remove(espStuff, i)
				local billboard = target:FindFirstChild("_PartyDebug")
				if billboard then billboard:Destroy() end
			end
		end
	end
end)

local function removeFog(fog)
	if fog:IsA("Atmosphere") then fog:Destroy() end
end
game.Lighting.ChildAdded:Connect(removeFog)
for _, fog in ipairs(game.Lighting:GetChildren()) do
	removeFog(fog)
end

local bypassanticheat = false

runService.RenderStepped:Connect(function()
	if bypassanticheat then
		player.Character:PivotTo(
			player.Character:GetPivot()
				+ workspace.CurrentCamera.CFrame.LookVector * Vector3.new(1, 0, 1) * -100
		)
	end
	game.Lighting.Ambient = ambientColor
end)

userInputService.InputBegan:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.T and not processed then
		bypassanticheat = true
	end
end)
userInputService.InputEnded:Connect(function(input, processed)
	if input.KeyCode == Enum.KeyCode.T then
		bypassanticheat = false
	end
end)

task.spawn(function()
	while true do
		task.wait()
		--char:SetAttribute("ScreechOn", true)
		char:SetAttribute("SpeedBoostExtra", 20)
		if char:GetAttribute("Sliding") then
			char:SetAttribute("SpeedBoostExtra", 50)
			--char.HumanoidRootPart.CustomPhysicalProperties = ogphysics
		else
			char.HumanoidRootPart.CustomPhysicalProperties = newphysics
		end
	end
end)

caption("initiated integrated assist mode!", "warning")
