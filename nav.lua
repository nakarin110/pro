local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local Window = Rayfield:CreateWindow({
   Name = "🌟 Modern Hub V2",
   LoadingTitle = "Modern Hub Loading...",
   LoadingSubtitle = "by Modern Team",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ModernHubConfig",
      FileName = "ModernHub"
   }
})


local PlayerTab = Window:CreateTab("👤 Player", 6034287594)
-- เพิ่มส่วนควบคุมการแอดเพื่อน
local FriendSection = PlayerTab:CreateSection("👥 Auto Friend")

-- ตัวแปรควบคุมการแอดเพื่อน
local autoFriendEnabled = false
local friendRequests = {}
local acceptedFriends = {}

-- สร้างปุ่มเปิด/ปิดระบบแอดเพื่อนอัตโนมัติ
local AutoFriendToggle = PlayerTab:CreateToggle({
   Name = "Auto Friend All Players",
   CurrentValue = false,
   Flag = "AutoFriendEnabled",
   Callback = function(Value)
      autoFriendEnabled = Value
      if Value then
         -- เริ่มการแอดเพื่อน
         for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                task.spawn(function()
                    local success, err = pcall(function()
                        if not friendRequests[player.UserId] and not acceptedFriends[player.UserId] then
                            game.Players.LocalPlayer:RequestFriendship(player)
                            friendRequests[player.UserId] = true
                            
                            -- แจ้งเตือนการส่งคำขอ
                            Rayfield:Notify({
                                Title = "Friend Request Sent",
                                Content = "Sent request to: " .. player.Name,
                                Duration = 3,
                                Image = 6031075926 -- รูป Friend icon
                            })
                            
                            task.wait(1) -- รอ 1 วินาทีระหว่างการส่งคำขอแต่ละครั้ง
                        end
                    end)
                end)
            end
         end
      end
   end,
})

-- สร้างตัวแสดงสถานะ
local StatusLabel = PlayerTab:CreateLabel("Waiting for friends...")
local FriendStatsLabel = PlayerTab:CreateLabel("Friends Status: Waiting...")

-- ระบบติดตามผู้เล่นใหม่
game.Players.PlayerAdded:Connect(function(player)
    if autoFriendEnabled and player ~= game.Players.LocalPlayer then
        task.wait(1) -- รอให้ผู้เล่นโหลดเสร็จ
        task.spawn(function()
            local success, err = pcall(function()
                if not friendRequests[player.UserId] and not acceptedFriends[player.UserId] then
                    game.Players.LocalPlayer:RequestFriendship(player)
                    friendRequests[player.UserId] = true
                    StatusLabel.Text = "Sent friend request to: " .. player.Name
                    
                    -- แจ้งเตือนเมื่อส่งคำขอให้ผู้เล่นใหม่
                    Rayfield:Notify({
                        Title = "New Player Friend Request",
                        Content = "Sent request to new player: " .. player.Name,
                        Duration = 3,
                        Image = 6031075926
                    })
                end
            end)
        end)
    end
end)

-- อัพเดทสถานะทุก 5 วินาที
task.spawn(function()
    while task.wait(5) do
        if autoFriendEnabled then
            local count = 0
            for _ in pairs(friendRequests) do count = count + 1 end
            StatusLabel.Text = "Total friend requests sent: " .. count
        end
    end
end)

-- อัพเดทสถานะทุก 3 วินาที
task.spawn(function()
    while task.wait(3) do
        if autoFriendEnabled then
            local requestCount = 0
            local acceptedCount = 0
            
            for _ in pairs(friendRequests) do requestCount = requestCount + 1 end
            for _ in pairs(acceptedFriends) do acceptedCount = acceptedCount + 1 end
            
            FriendStatsLabel.Text = string.format(
                "Pending Requests: %d | Accepted Friends: %d",
                requestCount,
                acceptedCount
            )
        end
    end
end)

-- เคลียร์ข้อมูลเมื่อผู้เล่นออก
game.Players.PlayerRemoving:Connect(function(player)
    if friendRequests[player.UserId] then
        friendRequests[player.UserId] = nil
    end
end)

-- ติดตามการตอบรับคำขอเป็นเพื่อน
game.Players.LocalPlayer.FriendStatusChanged:Connect(function(player, status)
    if status == Enum.FriendStatus.Friend then
        acceptedFriends[player.UserId] = true
        friendRequests[player.UserId] = nil
        
        -- แจ้งเตือนเมื่อมีคนรับเป็นเพื่อน
        Rayfield:Notify({
            Title = "New Friend!",
            Content = player.Name .. " accepted your friend request!",
            Duration = 5,
            Image = 6034333083 -- รูป Success icon
        })
    end
end)

local MovementTab = Window:CreateTab("⚡ Movement", 6034996695)
local CombatTab = Window:CreateTab("⚔️ Combat", 7733674079)


local PlayerSection = PlayerTab:CreateSection("Player Controls")
local MovementSection = MovementTab:CreateSection("Movement Controls")
local CombatSection = CombatTab:CreateSection("Combat Controls")
local FlightSection = MovementTab:CreateSection("✈️ Flight Controls")
local LockSection = CombatTab:CreateSection("🎯 Player Lock")

-- เพิ่มตัวแปรสำหรับ Anti Void
local antiVoidEnabled = false
local lastSafePosition = nil
local checkInterval = 0.1 -- ความถี่ในการเช็คตำแหน่ง (วินาที)
local minY = -10 -- ระดับความสูงต่ำสุดก่อนวาร์ป

-- สร้าง Toggle สำหรับ Anti Void
local AntiVoidToggle = MovementTab:CreateToggle({
   Name = "🌟 Anti Void (Auto Teleport)",
   CurrentValue = false,
   Flag = "AntiVoidEnabled",
   Callback = function(Value)
      antiVoidEnabled = Value
      if Value then
         -- เริ่มบันทึกตำแหน่งปลอดภัย
         local character = game.Players.LocalPlayer.Character
         if character and character:FindFirstChild("HumanoidRootPart") then
            lastSafePosition = character.HumanoidRootPart.CFrame
         end
         
         Rayfield:Notify({
            Title = "Anti Void Enabled",
            Content = "You will be teleported back if you fall!",
            Duration = 3,
            Image = 6031075926
         })
      end
   end,
})

-- ระบบติดตามและบันทึกตำแหน่งปลอดภัย
task.spawn(function()
    while task.wait(checkInterval) do
        if antiVoidEnabled then
            local character = game.Players.LocalPlayer.Character
            if character then
                local hrp = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if hrp and humanoid and humanoid.Health > 0 then
                    -- บันทึกตำแหน่งเมื่ออยู่บนพื้นปกติ
                    if hrp.Position.Y > minY then
                        lastSafePosition = hrp.CFrame
                    else
                        -- วาร์ปกลับเมื่อตกลงต่ำเกินไป
                        if lastSafePosition then
                            hrp.CFrame = lastSafePosition
                            Rayfield:Notify({
                                Title = "Anti Void Activated",
                                Content = "Teleported back to safe position!",
                                Duration = 2,
                                Image = 6023426926
                            })
                        end
                    end
                end
            end
        end
    end
end)

-- เพิ่มการรีเซ็ตตำแหน่งปลอดภัยเมื่อตัวละครเกิดใหม่
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if antiVoidEnabled then
        task.wait(1) -- รอให้ตัวละครโหลดเสร็จ
        local hrp = character:WaitForChild("HumanoidRootPart")
        lastSafePosition = hrp.CFrame
    end
end)

local flying = false
local flySpeed = 50
local flyUp = false
local flyDown = false
local lastCFrame = nil

local FlyUpButton = MovementTab:CreateButton({
    Name = "↑ Fly Up",
    Callback = function()
        flyUp = true
        task.wait(0.1)
        flyUp = false
    end,
})

local FlyDownButton = MovementTab:CreateButton({
    Name = "↓ Fly Down",
    Callback = function()
        flyDown = true
        task.wait(0.1)
        flyDown = false
    end,
})

local FlightToggle = MovementTab:CreateToggle({
   Name = "Toggle Flight",
   CurrentValue = false,
   Flag = "FlightEnabled",
   Callback = function(Value)
      flying = Value
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      local hrp = character:WaitForChild("HumanoidRootPart")
      
      if flying then
         lastCFrame = hrp.CFrame
         humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
      else
         lastCFrame = nil
         humanoid:ChangeState(Enum.HumanoidStateType.Landing)
      end
   end,
})

local FlightSpeedSlider = MovementTab:CreateSlider({
   Name = "Flight Speed",
   Range = {1, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlightSpeed",
   Callback = function(Value)
      flySpeed = Value
   end,
})

local speedEnabled = false
local speedValue = 50
local defaultWalkSpeed = 16
local autoResetEnabled = false

local SpeedToggle = MovementTab:CreateToggle({
   Name = "Toggle Speed Hack",
   CurrentValue = false,
   Flag = "SpeedEnabled",
   Callback = function(Value)
      speedEnabled = Value
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      local humanoid = character:WaitForChild("Humanoid")
      
      if speedEnabled then
         humanoid.WalkSpeed = speedValue
      else
         humanoid.WalkSpeed = defaultWalkSpeed
      end
   end,
})

local SpeedSlider = MovementTab:CreateSlider({
   Name = "Speed Multiplier",
   Range = {16, 500},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "SpeedValue",
   Callback = function(Value)
      speedValue = Value
      if speedEnabled then
         local player = game.Players.LocalPlayer
         local character = player.Character
         if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speedValue
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local moveDirection = humanoid.MoveDirection
                    if moveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (moveDirection * (speedValue/500))
                    end
                end
            end
         end
      end
   end,
})

local AutoResetToggle = MovementTab:CreateToggle({
   Name = "Auto Reset Protection",
   CurrentValue = false,
   Flag = "AutoResetEnabled",
   Callback = function(Value)
      autoResetEnabled = Value
   end,
})

-- Auto reset protection
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
   if autoResetEnabled and speedEnabled then
      local humanoid = character:WaitForChild("Humanoid")
      task.wait(0.5) -- Wait a bit to avoid detection
      humanoid.WalkSpeed = speedValue
   end
end)

-- Anti-reset protection
game:GetService("RunService").Heartbeat:Connect(function()
   if autoResetEnabled and speedEnabled then
      local player = game.Players.LocalPlayer
      local character = player.Character
      if character then
         local humanoid = character:FindFirstChild("Humanoid")
         if humanoid and humanoid.WalkSpeed ~= speedValue then
            humanoid.WalkSpeed = speedValue
         end
      end
   end
end)

game:GetService("RunService").Heartbeat:Connect(function()
   if speedEnabled then
      local player = game.Players.LocalPlayer
      local character = player.Character
      if character then
         local humanoid = character:FindFirstChild("Humanoid")
         local hrp = character:FindFirstChild("HumanoidRootPart")
         if humanoid and hrp then
            humanoid.WalkSpeed = speedValue
            local moveDirection = humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDirection * (speedValue/500))
            end
         end
      end
   end
end)

game:GetService("RunService").RenderStepped:Connect(function()
   if flying then
      local player = game.Players.LocalPlayer
      local character = player.Character
      if character then
         local hrp = character:FindFirstChild("HumanoidRootPart")
         local humanoid = character:FindFirstChild("Humanoid")
         if hrp and humanoid then
            if not lastCFrame then
                lastCFrame = hrp.CFrame
            end

            local camera = workspace.CurrentCamera
            local moveDirection = Vector3.new(0, 0, 0)
            
            -- การเคลื่อนที่ตามทิศทางกล้อง
            local moveVector = humanoid.MoveDirection
            if moveVector.Magnitude > 0 then
                -- ใช้ทิศทางกล้องในการคำนวณการเคลื่อนที่
                local camLook = camera.CFrame.LookVector
                local camRight = camera.CFrame.RightVector
                
                -- ปรับทิศทางการบินตามมุมกล้อง
                local verticalAngle = math.asin(camLook.Y)
                local flyUpward = math.sin(verticalAngle) * moveVector.Z
                
                -- แยกการเคลื่อนที่แนวราบและแนวดิ่ง
                local horizontalLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
                local horizontalRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
                
                -- รวมการเคลื่อนที่ทั้งหมด
                moveDirection = moveDirection + (horizontalLook * moveVector.Z)
                moveDirection = moveDirection + (horizontalRight * moveVector.X)
                moveDirection = moveDirection + Vector3.new(0, flyUpward, 0) * flySpeed
            end

            -- ปรับความเร็ว
            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * flySpeed
            end

            -- อัพเดทตำแหน่ง
            if moveDirection.Magnitude > 0 then
                lastCFrame = lastCFrame * CFrame.new(moveDirection * game:GetService("RunService").RenderStepped:Wait())
            end
            
            -- ให้ตัวละครหันไปตามทิศทางกล้อง
            if humanoid.MoveDirection.Magnitude > 0 then
                local lookAt = hrp.Position + camera.CFrame.LookVector
                lastCFrame = CFrame.new(lastCFrame.Position, Vector3.new(lookAt.X, lastCFrame.Position.Y, lookAt.Z))
            end

            -- อัพเดท CFrame และล็อคความเร็ว
            hrp.CFrame = lastCFrame
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            
            -- ป้องกันการตก
            humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
         end
      end
   else
      lastCFrame = nil
   end
end)

-- เพิ่มตัวแปรสำหรับ Noclip
local noclipEnabled = false
local noclipConnection = nil

-- สร้าง Toggle สำหรับ Noclip
local NoclipToggle = MovementTab:CreateToggle({
   Name = "🚶‍♂️ Noclip (Walk Through Walls)",
   CurrentValue = false,
   Flag = "NoclipEnabled",
   Callback = function(Value)
      noclipEnabled = Value
      local player = game.Players.LocalPlayer
      local character = player.Character or player.CharacterAdded:Wait()
      
      if noclipEnabled then
         -- เริ่มใช้งาน Noclip
         if noclipConnection then
            noclipConnection:Disconnect()
         end
         
         -- แจ้งเตือนเมื่อเปิดใช้งาน
         Rayfield:Notify({
            Title = "Noclip Enabled",
            Content = "You can now walk through objects!",
            Duration = 3,
            Image = 6023426926
         })
         
         noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if character and noclipEnabled then
               for _, part in pairs(character:GetDescendants()) do
                  if part:IsA("BasePart") then
                     part.CanCollide = false
                  end
               end
            end
         end)
         
      else
         -- ปิดการใช้งาน Noclip
         if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
         end
         
         -- คืนค่า collision ให้กับตัวละคร
         for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = true
            end
         end
         
         -- แจ้งเตือนเมื่อปิดใช้งาน
         Rayfield:Notify({
            Title = "Noclip Disabled",
            Content = "Collision restored",
            Duration = 3,
            Image = 6031075925
         })
      end
   end,
})

-- เพิ่ม Protection เมื่อตัวละครเกิดใหม่
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
   if noclipEnabled then
      task.wait(0.5) -- รอให้ตัวละครโหลดเสร็จ
      
      -- รีเซ็ต connection เก่า
      if noclipConnection then
         noclipConnection:Disconnect()
      end
      
      -- สร้าง connection ใหม่
      noclipConnection = game:GetService("RunService").Stepped:Connect(function()
         if character and noclipEnabled then
            for _, part in pairs(character:GetDescendants()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end
      end)
   end
end)

Rayfield:Notify({
   Title = "Modern Hub V2 Loaded",
   Content = "UI Framework Ready!",
   Duration = 3,
   Image = 11695805807
})