repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
_G.AutoFarmActive = false
local TARGET_STAGE = "17"
local FARM_YIELD_DELAY = 1.8

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(0.5)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIStroke = Instance.new("UIStroke")

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

ScreenGui.Name = "Delta_AIEngine_UI"
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "AIFarmToggle"
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 160, 0, 45)
ToggleButton.Position = UDim2.new(0.03, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
ToggleButton.Text = "Delta AI Farm: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 16
ToggleButton.ClipsDescendants = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleButton

UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = ToggleButton

local function smoothTweenToPad(targetPart)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp and targetPart then
        local distance = (hrp.Position - targetPart.Position).Magnitude
        local dynamicSpeed = 140
        local duration = distance / dynamicSpeed
        local targetCFrame = targetPart.CFrame * CFrame.new(0, 3, 0)
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})

        tween:Play()

        local connection
        connection = RunService.Heartbeat:Connect(function()
            if tween.PlaybackState == Enum.TweenStatus.Playing then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            else
                connection:Disconnect()
            end
        end)

        tween.Completed:Wait()
        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end
end

task.spawn(function()
    while true do
        if _G.AutoFarmActive then
            local targetWinPad = nil
            local stagesDirectory = workspace:FindFirstChild("Stages") or workspace:FindFirstChild("Worlds") or workspace:FindFirstChild("Maps")

            if stagesDirectory then
                local targetStageFolder = stagesDirectory:FindFirstChild(TARGET_STAGE)
                if targetStageFolder then
                    targetWinPad = targetStageFolder:FindFirstChildWhichIsA("BasePart")
                        or targetStageFolder:FindFirstChild("Win")
                        or targetStageFolder:FindFirstChild("Pad")
                        or targetStageFolder:FindFirstChild("Goal")
                end
            end

            if not targetWinPad then
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Name == TARGET_STAGE then
                        targetWinPad = obj
                        break
                    elseif obj:IsA("Model") and obj.Name == TARGET_STAGE then
                        targetWinPad = obj:FindFirstChildWhichIsA("BasePart")
                        break
                    end
                end
            end

            if not targetWinPad then
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon and obj.Size.X > 4 then
                        local name = obj.Name:lower()
                        if name:find("win") or name:find("pad") or name:find("finish") then
                            targetWinPad = obj
                            break
                        end
                    end
                end
            end

            if targetWinPad then
                smoothTweenToPad(targetWinPad)
                task.wait(FARM_YIELD_DELAY)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

ToggleButton.MouseButton1Click:Connect(function()
    _G.AutoFarmActive = not _G.AutoFarmActive

    if _G.AutoFarmActive then
        ToggleButton.Text = "Delta AI Farm: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        print("[DELTA LOG]: Stage 17 Auto-Farm Engine engaged successfully.")
    else
        ToggleButton.Text = "Delta AI Farm: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        print("[DELTA LOG]: Auto-Farm Engine disabled manually.")

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end
    end
end)
