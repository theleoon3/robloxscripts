-- 📦 Carrega a Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- 📦 Infinity Yield embutido
local success, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
if not success then
    warn("[InfinityYield] Erro ao carregar:", err)
end

-- 🎨 Tema personalizado
local colors = {
    SchemeColor = Color3.fromRGB(0, 255, 255),
    Background = Color3.fromRGB(25, 25, 25),
    Header = Color3.fromRGB(30, 30, 30),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(50, 50, 50)
}

local Window = Library.CreateLib("Léo's Hack Pack PRO", colors)

-- Abas
local mainTab = Window:NewTab("Main")
local miscTab = Window:NewTab("Extras")
local uiTab = Window:NewTab("Config")

local mainSection = mainTab:NewSection("Funções Principais")
local miscSection = miscTab:NewSection("Funções Extras")
local uiSection = uiTab:NewSection("Interface")

-- Estados globais
getgenv().espEnabled = false
getgenv().noclip = false
getgenv().flying = false
getgenv().infJump = false
getgenv().speedMultiplier = 1
getgenv().jumpPower = 50
getgenv().flySpeed = 50

-- ESP
mainSection:NewToggle("ESP Global", "Mostra jogadores no mapa com distância", function(state)
    getgenv().espEnabled = state
    if state then
        game:GetService("RunService").RenderStepped:Connect(function()
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and not player.Character:FindFirstChild("ESPBox") then
                    local box = Instance.new("BillboardGui", player.Character)
                    box.Name = "ESPBox"
                    box.Adornee = player.Character:FindFirstChild("Head")
                    box.Size = UDim2.new(4, 0, 5, 0)
                    box.AlwaysOnTop = true

                    local label = Instance.new("TextLabel", box)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    local distance = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                    label.Text = string.format("%s (%dm)", player.Name, distance)
                    label.TextColor3 = Color3.new(1, 0, 0)
                    label.BackgroundTransparency = 1
                elseif player.Character and player.Character:FindFirstChild("ESPBox") then
                    local label = player.Character.ESPBox:FindFirstChildOfClass("TextLabel")
                    if label then
                        local distance = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                        label.Text = string.format("%s (%dm)", player.Name, distance)
                    end
                end
            end
        end)
    else
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("ESPBox") then
                player.Character.ESPBox:Destroy()
            end
        end
    end
end)

-- Noclip
mainSection:NewToggle("Noclip", "Atravessa tudo", function(state)
    getgenv().noclip = state
end)

game:GetService("RunService").Stepped:Connect(function()
    if getgenv().noclip then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Fly
mainSection:NewToggle("Fly", "Voa sem limites", function(state)
    getgenv().flying = state
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    local bg = Instance.new("BodyGyro", hrp)
    local bv = Instance.new("BodyVelocity", hrp)
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().flying then
            local cam = workspace.CurrentCamera
            local move = Vector3.zero
            local uis = game:GetService("UserInputService")

            if uis:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0, 1, 0) end

            bv.Velocity = move.Magnitude > 0 and move.Unit * getgenv().flySpeed or Vector3.zero
            bg.CFrame = cam.CFrame
        else
            bg:Destroy()
            bv:Destroy()
        end
    end)
end)

miscSection:NewSlider("Fly Speed", "Velocidade do voo", 200, 10, function(val)
    getgenv().flySpeed = val
end)

-- Pulo Infinito
mainSection:NewToggle("Pulo Infinito", "Pule infinitamente", function(state)
    getgenv().infJump = state
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if getgenv().infJump then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- Bypass Avançado
mainSection:NewButton("Bypass Avançado", "Remove LocalScripts suspeitos e registra os removidos", function()
    local removed = {}
    for _, v in pairs(game.Players.LocalPlayer:GetDescendants()) do
        if v:IsA("LocalScript") and not v.Name:lower():find("kavo") then
            table.insert(removed, v.Name)
            v:Destroy()
        end
    end
    print("Scripts removidos:", table.concat(removed, ", "))
end)

-- Velocidade
miscSection:NewSlider("Speed x", "Multiplicador de velocidade", 10, 1, function(s)
    getgenv().speedMultiplier = s
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16 * s
end)

-- Altura do pulo
miscSection:NewSlider("Jump Power", "Força do pulo", 200, 50, function(j)
    getgenv().jumpPower = j
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = j
end)

-- Respawn instantâneo com aviso
miscSection:NewButton("Respawn", "Renasce o personagem (confirma antes)", function()
    local notify = Instance.new("Hint")
    notify.Text = "Pressione 'R' para confirmar respawn."
    notify.Parent = workspace

    local uis = game:GetService("UserInputService")
    local connection
    connection = uis.InputBegan:Connect(function(input, gpe)
        if input.KeyCode == Enum.KeyCode.R then
            local char = game.Players.LocalPlayer.Character
            char:BreakJoints()
            notify:Destroy()
            connection:Disconnect()
        end
    end)

    task.delay(5, function()
        if notify and notify.Parent then
            notify:Destroy()
            if connection then connection:Disconnect() end
        end
    end)
end)

-- Gravidade: Toggle
miscSection:NewToggle("Gravidade Zero", "Ativa ou desativa gravidade", function(state)
    if state then
        workspace.Gravity = 0
    else
        workspace.Gravity = 196.2
    end
end)

-- Color pickers para customizar tema
for theme, color in pairs(colors) do
    uiSection:NewColorPicker(theme, "Cor para " .. theme, color, function(color3)
        Library:ChangeColor(theme, color3)
    end)
end

-- Esconder interface
uiSection:NewKeybind("Toggle UI", "Mostrar/Esconder menu", Enum.KeyCode.RightControl, function()
    Library:ToggleUI()
end)
