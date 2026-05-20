local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
local remotesFolder = sharedFolder:WaitForChild("Remotes")

local changeIntervalRemote = Instance.new("RemoteEvent")
changeIntervalRemote.Name = "ChangeInterval"
changeIntervalRemote.Parent = remotesFolder

local spawnBagRemote = Instance.new("RemoteEvent")
spawnBagRemote.Name = "SpawnBag"
spawnBagRemote.Parent = remotesFolder

local bagClickedRemote = Instance.new("RemoteEvent")
bagClickedRemote.Name = "BagClicked"
bagClickedRemote.Parent = remotesFolder

local MAX_BAGS = 30
local spawnInterval = 1
local activeBags = {}
local activeBagsCount = 0

local CONVEYOR_LENGTH = 50
local CONVEYOR_SPEED = 10 
local TRANSIT_TIME = CONVEYOR_LENGTH / CONVEYOR_SPEED

local materials = {
	Enum.Material.Plastic, Enum.Material.Wood, Enum.Material.Neon,
	Enum.Material.Fabric, Enum.Material.Metal, Enum.Material.SmoothPlastic
}

local function spawnBag()
	if activeBagsCount >= MAX_BAGS then return end
	
	local bagId = HttpService:GenerateGUID(false)
	local randomColor = Color3.new(math.random(), math.random(), math.random())
	local randomMaterial = materials[math.random(1, #materials)]
	
	activeBags[bagId] = {
		color = randomColor,
		material = randomMaterial
	}
activeBagsCount = activeBagsCount + 1
	
	spawnBagRemote:FireAllClients(bagId, randomColor, randomMaterial)
	
	task.delay(TRANSIT_TIME, function()
		if activeBags[bagId] then
			activeBags[bagId] = nil
			activeBagsCount = activeBagsCount - 1
		end
	end)
end

task.spawn(function()
	while true do
		spawnBag()
		task.wait(spawnInterval)
	end
end)

bagClickedRemote.OnServerEvent:Connect(function(player, bagId)
	if activeBags[bagId] then
		print(string.format("[Server] Player %s clicked bag ID: %s", player.Name, bagId))
	end
end)

local uiAssigned = false

Players.PlayerAdded:Connect(function(newPlayer)
	if not uiAssigned then
		uiAssigned = true
		local uiTemplate = game:GetService("ServerStorage"):WaitForChild("ControlPanel")
		local uiClone = uiTemplate:Clone()
		uiClone.Parent = newPlayer:WaitForChild("PlayerGui")
	end
end)

changeIntervalRemote.OnServerEvent:Connect(function(player, newInterval)
	if type(newInterval) == "number" and newInterval >= 0.1 and newInterval <= 5 then
		spawnInterval = newInterval
		print(string.format("[Server] Interval changed to %s by %s", tostring(newInterval), player.Name))
	end
end)