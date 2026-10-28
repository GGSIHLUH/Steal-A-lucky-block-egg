local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local TARGET_POS = Vector3.new(-0.75, 3.00, 177.78)

local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
if parentGui:FindFirstChild("GrabCloneUI") then
    parentGui.GrabCloneUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GrabCloneUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentGui

local Btn = Instance.new("TextButton")
Btn.Name = "GrabButton"
Btn.Size = UDim2.fromOffset(180, 44)
Btn.Position = UDim2.new(0.5, -90, 0.2, 0)
Btn.BackgroundColor3 = Color3.fromRGB(20, 16, 22)
Btn.Text = "Execute Codium"
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 13
Btn.TextColor3 = Color3.fromRGB(255, 240, 246)
Btn.AutoButtonColor = false
Btn.Parent = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = Btn

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = Btn

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 143, 177)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 143, 177))
})
gradient.Parent = stroke

task.spawn(function()
    while Btn.Parent do
        gradient.Rotation = (os.clock() * 180) % 360
        task.wait()
    end
end)

local function performActionWithClone()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local camera = workspace.CurrentCamera
    
    if not (char and hrp and humanoid and camera) then return end
    
    local originCFrame = hrp.CFrame
    
    char.Archivable = true
    local clone = char:Clone()
    
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Script") or d:IsA("LocalScript") then 
            d:Destroy() 
        end
    end
    clone.Name = "GrabberClone"
    
    local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
    local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
    
    if cloneHrp and cloneHumanoid then
        cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        cloneHrp.Anchored = true
        cloneHrp.CFrame = originCFrame
        clone.Parent = workspace
        
        camera.CameraSubject = cloneHumanoid
    end
    
    hrp.CFrame = CFrame.new(TARGET_POS)
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    task.wait(0.8) 
    
    hrp.CFrame = originCFrame
    hrp.AssemblyLinearVelocity = Vector3.zero
    
    camera.CameraSubject = humanoid
    
    if clone then
        clone:Destroy()
    end
end

Btn.MouseButton1Click:Connect(function()
    TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(255, 143, 177), TextColor3 = Color3.fromRGB(20, 16, 22)}):Play()
    task.delay(0.15, function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 16, 22), TextColor3 = Color3.fromRGB(255, 240, 246)}):Play()
    end)
    task.spawn(performActionWithClone)
end)

local dragging, dragStart, startPos
Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Btn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
