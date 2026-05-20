local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local changeIntervalRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"):WaitForChild("ChangeInterval")

local playerGui = player:WaitForChild("PlayerGui")
local controlPanel = playerGui:WaitForChild("ControlPanel", 99999) 

if controlPanel then
	local frame = controlPanel:WaitForChild("Frame")
	local sliderBtn = frame:WaitForChild("SliderButton")
	local textLabel = frame:WaitForChild("IntervalText")
	
	local dragging = false
	local minInterval = 0.1
	local maxInterval = 5.0
	
	sliderBtn.MouseButton1Down:Connect(function()
		dragging = true
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local mousePos = UserInputService:GetMouseLocation().X
			local framePos = frame.AbsolutePosition.X
			local frameSize = frame.AbsoluteSize.X
			
			local relativePos = math.clamp(mousePos - framePos, 0, frameSize)
			local percentage = relativePos / frameSize
			
			sliderBtn.Position = UDim2.new(percentage, 0, sliderBtn.Position.Y.Scale, sliderBtn.Position.Y.Offset)
			
			local currentInterval = minInterval + ((maxInterval - minInterval) * percentage)
			
			currentInterval = math.floor(currentInterval * 10) / 10
			
			textLabel.Text = "Interval: " .. tostring(currentInterval) .. "s"
			
			changeIntervalRemote:FireServer(currentInterval)
		end
	end)
end