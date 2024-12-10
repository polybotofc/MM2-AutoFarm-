local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ButtonOn = Instance.new("TextButton")
local ButtonOff = Instance.new("TextButton")
local ModeSelector = Instance.new("TextLabel")
local Title = Instance.new("TextLabel") 
local Credits = Instance.new("TextLabel") 

-- Langsung tempatkan ScreenGui di PlayerGui
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = player.PlayerGui 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false 

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
Frame.Size = UDim2.new(0, 200, 0, 150) 
Frame.Position = UDim2.new(0.5, -100, 0.8, -75) 
Frame.Visible = true

-- Judul
Title.Parent = Frame
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Size = UDim2.new(0, 180, 0, 20)
Title.Position = UDim2.new(0.1, 0, 0.05, 0)
Title.Text = "Auto Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

ButtonOn.Parent = Frame
ButtonOn.Size = UDim2.new(0, 80, 0, 40)
ButtonOn.Position = UDim2.new(0.1, 0, 0.2, 0)
ButtonOn.Text = "ON"
ButtonOn.BackgroundColor3 = Color3.fromRGB(0, 170, 0) 
ButtonOn.TextColor3 = Color3.fromRGB(255, 255, 255)
ButtonOn.Font = Enum.Font.SourceSansBold

ButtonOff.Parent = Frame
ButtonOff.Size = UDim2.new(0, 80, 0, 40)
ButtonOff.Position = UDim2.new(0.6, 0, 0.2, 0)
ButtonOff.Text = "OFF"
ButtonOff.BackgroundColor3 = Color3.fromRGB(170, 0, 0) 
ButtonOff.TextColor3 = Color3.fromRGB(255, 255, 255)
ButtonOff.Font = Enum.Font.SourceSansBold

ModeSelector.Parent = Frame
ModeSelector.Size = UDim2.new(0, 180, 0, 30)
ModeSelector.Position = UDim2.new(0.1, 0, 0.6, 0)
ModeSelector.Text = "Mode: Nearest"
ModeSelector.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ModeSelector.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeSelector.Font = Enum.Font.SourceSans

-- Credits
Credits.Parent = Frame
Credits.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Credits.Size = UDim2.new(0, 180, 0, 20)
Credits.Position = UDim2.new(0.1, 0, 0.75, 0) 
Credits.Text = "Made by: LuthfiDev" 
Credits.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits.Font = Enum.Font.SourceSans
Credits.TextSize = 14

-- Variabel untuk mengontrol auto-farm
local farming = false
local tweenService = game:GetService("TweenService")
local baseSpeed = 25 

-- Fungsi untuk memeriksa apakah tas penuh
local function isBagFull()
    local backpack = player.Backpack

    local totalCoins = 0
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == "Coin" then
            totalCoins = totalCoins + 1
        end
    end

    return totalCoins >= 40 
end

-- Fungsi untuk mendapatkan koin terdekat
local function getNearestCoin(coinContainer)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    local nearestCoin = nil
    local nearestDistance = math.huge

    for _, coin in pairs(coinContainer:GetChildren()) do
        if coin.Name == "Coin_Server" and humanoidRootPart then
            local distance = (coin.Position - humanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestCoin = coin
            end
        end
    end

    return nearestCoin
end

-- Fungsi untuk mengaktifkan farm coin
local function startFarming()
    farming = true
    while farming do
        for _, map in pairs(game.Workspace:GetChildren()) do
            if map:IsA("Model") and map:FindFirstChild("CoinContainer") then
                local coinContainer = map.CoinContainer

                local coinToCollect = getNearestCoin(coinContainer)

                if coinToCollect then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CanCollide = false

                        if isBagFull() then
                            stopFarming() 
                            return
                        end

                        local distance = (coinToCollect.Position - character.HumanoidRootPart.Position).Magnitude

                        local tweenDuration = distance / baseSpeed + 0.1 

                        local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear)

                        local tween = tweenService:Create(
                            character.HumanoidRootPart,
                            tweenInfo,
                            {CFrame = coinToCollect.CFrame}
                        )
                        tween:Play()
                        tween.Completed:Wait() 

                        coinToCollect:Destroy()

                        wait(0) 
                    end
                end
            end
        end
        task.wait(0) 
    end
end

-- Fungsi untuk menghentikan farm coin
local function stopFarming()
    farming = false
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = 16
        character.HumanoidRootPart.CanCollide = true
    end
end

-- Menghubungkan tombol GUI
ButtonOn.MouseButton1Click:Connect(function()
    if not farming then
        startFarming()
    end
end)

ButtonOff.MouseButton1Click:Connect(function()
    if farming then
        stopFarming()
    end
end)

-- Membuat GUI menjadi draggable
local function makeDraggable(frame)
    local dragging
    local dragInput
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(Frame)