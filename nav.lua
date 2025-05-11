local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Purge hub",
   LoadingTitle = "Purge OT",
   LoadingSubtitle = "สร้างโดย Lxwnu",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "W"
   },
   KeySystem = false,
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Purge hub keys",
      Note = "No method of obtaining the key is provided",
      FileName = "hub",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {""}
   }
})

local MainTab = Window:CreateTab("หน้าหลัก", nil)
local MainSection = MainTab:CreateSection("เมนูหลัก")

-- Aimbot variables
local AimbotEnabled = false
local AimbotFOV = 100
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotFOV
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = true

-- Update circle position every frame
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Find closest player in FOV
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = AimbotFOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

-- Add to UI
MainTab:CreateToggle({
    Name = "เปิด/ปิด Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        AimbotEnabled = Value
    end,
})

MainTab:CreateSlider({
    Name = "ปรับขนาด FOV",
    Range = {50, 300},
    Increment = 10,
    Suffix = "px",
    CurrentValue = AimbotFOV,
    Callback = function(Value)
        AimbotFOV = Value
        FOVCircle.Radius = AimbotFOV
    end,
})
