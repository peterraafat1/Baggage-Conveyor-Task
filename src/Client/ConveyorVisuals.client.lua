local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local remotesFolder = sharedFolder:WaitForChild("Remotes")
local spawnBagRemote = remotesFolder:WaitForChild("SpawnBag")
local bagClickedRemote = remotesFolder:WaitForChild("BagClicked")

local CONVEYOR_START = Vector3.new(0, 5, 0) 
local CONVEYOR_END = Vector3.new(0, 5, 50) 
local CONVEYOR_SPEED = 10
local TRANSIT_TIME = 50 / CONVEYOR_SPEED

local BAG_SIZE = Vector3.new(2, 2, 2)
local localBags = {} 

local function createBagVisual(bagId, color, material)
	local bag = Instance.new("Part")
	bag.Name = "Bag_" .. bagId
	bag.Size = Vector3.new(0, 0, 0) 
	bag.Position = CONVEYOR_START + Vector3.new(0, 5, 0) 
	bag.Color = color
	bag.Material = material
	bag.Anchored = true
	bag.CanCollide = false 
	bag.Parent = workspace
	
	local idValue = Instance.new("StringValue")
	idValue.Name = "UUID"
	idValue.Value = bagId
	idValue.Parent = bag

	localBags[bagId] = bag

	local spawnInfo = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local spawnTween = TweenService:Create(bag, spawnInfo, {
		Size = BAG_SIZE,
		Position = CONVEYOR_START
	})
	spawnTween:Play()

	spawnTween.Completed:Connect(function()
		local moveInfo = TweenInfo.new(TRANSIT_TIME, Enum.EasingStyle.Linear)
		local moveTween = TweenService:Create(bag, moveInfo, {
			Position = CONVEYOR_END
		})
		moveTween:Play()

		moveTween.Completed:Connect(function()
			local despawnInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local despawnTween = TweenService:Create(bag, despawnInfo, {
				Size = Vector3.new(0, 0, 0),
				Transparency = 1
			})
			despawnTween:Play()

			despawnTween.Completed:Connect(function()
				bag:Destroy()
				localBags[bagId] = nil
			end)
		end)
	end)
end

spawnBagRemote.OnClientEvent:Connect(function(bagId, color, material)
	createBagVisual(bagId, color, material)
end)

mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target and target:FindFirstChild("UUID") then
		local bagId = target.UUID.Value
		print("[Client] Clicked Bag ID:", bagId)
		bagClickedRemote:FireServer(bagId)
	end
end)