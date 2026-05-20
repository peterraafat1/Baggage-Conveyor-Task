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
	local defaultInterval = 1.0 

	task.wait()

	local function updateSliderVisuals(percentage)
		local frameSize = frame.AbsoluteSize.X
		local btnSize = sliderBtn.AbsoluteSize.X
		local maxOffset = frameSize - btnSize
		
		local targetOffset = percentage * maxOffset
		sliderBtn.Position = UDim2.new(0, targetOffset, sliderBtn.Position.Y.Scale, sliderBtn.Position.Y.Offset)
	end

	local initialPercentage = (defaultInterval - minInterval) / (maxInterval - minInterval)
	updateSliderVisuals(initialPercentage)
	textLabel.Text = "Interval: " .. tostring(defaultInterval) .. "s"
	
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
			local btnSize = sliderBtn.AbsoluteSize.X
			
			local maxMovement = frameSize - btnSize
			local relativePos = math.clamp(mousePos - framePos, 0, maxMovement)
			
			local percentage = relativePos / maxMovement
			updateSliderVisuals(percentage)
			
			local currentInterval = minInterval + ((maxInterval - minInterval) * percentage)
			currentInterval = math.floor(currentInterval * 10) / 10
			
			textLabel.Text = "Interval: " .. tostring(currentInterval) .. "s"
			changeIntervalRemote:FireServer(currentInterval)
		end
	end)
	
	frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local currentIntervalVal = tonumber(string.match(textLabel.Text, "%d+%.%d")) or defaultInterval
		local currentPerc = (currentIntervalVal - minInterval) / (maxInterval - minInterval)
		updateSliderVisuals(currentPerc)
	end)
end