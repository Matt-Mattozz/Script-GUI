local GUI = {}
GUI.__index = GUI
--[[
    INPUT:
    - string obj : la classe dell'oggetto
    - string title : la scritta contenuta nell'oggetto
    - array extra : 

    OUTPUT:
    - Instance inst : l'oggetto creato

    COSA FA:
    - crea un oggetto (deve avere la proprietà .Text) con i parametri specificati
]]
function NewObject(obj, title, extra)
	local inst = Instance.new(obj)
	inst.Name = title
	inst.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	inst.Font = Enum.Font.SourceSans
	inst.Text = title
	inst.TextColor3 = Color3.fromRGB(255, 255, 255)
	inst.BorderColor3 = Color3.fromRGB(255, 156, 16)
	inst.BackgroundTransparency = 1
	inst.BorderSizePixel = 0
	inst.TextSize = 14
	if extra then
		for i,v in pairs(extra) do
			inst[i] = v
		end
	end
	return inst
end
--
--[[
    INPUT:
    - string title : il nome e il contenuto del testo dell'oggetto
    - array extra : parametri aggiuntivi da assegnare all'oggetto

    OUTPUT:
    - l'oggetto di classe TextLabel con i parametri specificati

    COSA FA:
    - vedi function NewObject
]]
function NewLabel(title, extra)
	return NewObject("TextLabel", title, extra)
end
--
--[[
    INPUT:
    - string title : il nome e il contenuto del testo dell'oggetto
    - array extra : parametri aggiuntivi da assegnare all'oggetto

    OUTPUT:
    - l'oggetto di classe TextButton con i parametri specificati

    COSA FA:
    - vedi function NewObject
]]
function NewButton(title, extra)
	return NewObject("TextButton", title, extra)
end
--
--[[
    INPUT:
    - string title : la scritta che compare in cima alla GUI

    OUTPUT:
    - array tab : l'oggetto GUI

    COSA FA:
    - crea una ScreenGui con un titolo e un Frame che può contenere dei Frame aggiuntivi (es: dei toggle)
    - restituisce l'oggetto GUI che permette di aggiungere dei componenti aggiuntivi alla GUI (es: dei toggle)
]]
function GUI.new(title)
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local SubFrame = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local UIListLayout= Instance.new("UIListLayout")
	NewLabel(title, {TextSize = 20, BackgroundTransparency = 0, BorderSizePixel = 1, Size = UDim2.new(1, 0, 1, 0)}).Parent = Frame -- titolo della GUI

	ScreenGui.Parent = game.CoreGui
	
	Frame.Size = UDim2.new(0, 150, 0, 45)
	Frame.Position = UDim2.new(1, -170, 0, 30)
	Frame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	Frame.BorderColor3 = Color3.fromRGB(255, 156, 16)
	Frame.BorderSizePixel = 1
	Frame.Parent = ScreenGui

	SubFrame.Name = "SubFrame"
	SubFrame.Size = UDim2.new(1, 0, 0, 0)
	SubFrame.Position = UDim2.new(0, 0, 1, 0)
	SubFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	SubFrame.BorderColor3 = Color3.fromRGB(255, 156, 16)
	SubFrame.BorderSizePixel = 1
	SubFrame.Parent = Frame

	UIListLayout.Parent = SubFrame

	-- spostamento della gui
	local conn = nil
	Frame.MouseEnter:Connect(function()
		local conn2 = nil
		conn = game:GetService("UserInputService").InputBegan:Connect(function(input, bool)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local LastPos = {game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y}
				conn2 = game:GetService("RunService").Stepped:Connect(function()
					Frame.Position = UDim2.new(
						Frame.Position.X.Scale + (game.Players.LocalPlayer:GetMouse().X - LastPos[1]) / workspace.CurrentCamera.ViewportSize.X, 0,
						Frame.Position.Y.Scale + (game.Players.LocalPlayer:GetMouse().Y - LastPos[2]) / workspace.CurrentCamera.ViewportSize.Y, 0
					)
					LastPos = {game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y}
				end)
			end
		end)
		game:GetService("UserInputService").InputEnded:Connect(function(input, bool)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if conn2 then conn2:Disconnect() end
				conn2 = nil
			end
		end)
	end)
	Frame.MouseLeave:Connect(function()
		conn:Disconnect()
		conn = nil
	end)

	local tab = {ScreenGui = ScreenGui, Frame = Frame}
	setmetatable(tab, GUI)

	return tab
end
--
--[[
    INPUT:
    - string title : la scritta che compare vicino al bottone on/off
    - Enum.KeyCode extraButton : tasto che quando schiacciato aziona il toggle (equivalente al click del bottone on/off)

    OUTPUT:
    - BoolValue val : rappresenta lo stato del toggle (on/off)

    COSA FA:
    - aggiunge alla GUI un Frame contente un TextLabel e un TextButton (titolo e bottone toggle)
    - restituisce un BoolValue contente lo stato del toggle
]]
function GUI:NewToggle(title, extraButton)
	local Label = NewLabel(title, {Name = title.."Label"})
	local Toggle = NewButton(title, {Name = title.."Toggle"})
	local BoolValue = Instance.new("BoolValue")
	local Frame = Instance.new("Frame")
	-- il codice tiene in considerazione la presenza di un UIListLayout come child di SubFrame
	Label.Size = UDim2.new(0.6, 0, 1, 0)
	Label.Parent = Frame
	Toggle.Name = title.."Toggle"
	Toggle.Size = UDim2.new(0.4, 0, 1, 0)
	Toggle.Position = UDim2.new(0.6, 0, 0, 0)
	Toggle.Text = "Off"
	Toggle.Parent = Frame
	BoolValue.Parent = Toggle
	BoolValue.Value = false
	-- questo parenting è messo appositamente antecedente alle proprietà! non toccare!
	Frame.Parent = self.Frame.SubFrame
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 0, 35)
	Frame.Position = UDim2.new(0, 0, 0, (#self.Frame.SubFrame:GetChildren()-1)*35)

	self.Frame.SubFrame.Size = UDim2.new(self.Frame.SubFrame.Size.X.Scale, 0, 0, (#self.Frame.SubFrame:GetChildren()-1)*35)

	local function FireToggle()
		BoolValue.Value = not BoolValue.Value
		Toggle.Text = BoolValue.Value and "On" or "Off"
	end

	Toggle.MouseButton1Click:Connect(FireToggle)
	if extraButton then
		game:GetService("UserInputService").InputBegan:Connect(function(input, bool)
			if input.KeyCode == extraButton then
				FireToggle()
			end
		end)
	end

	return BoolValue
end
--
--[[
    INPUT:
    - string title : la scritta che compare nel TextLabel

    OUTPUT:
    -

    COSA FA:
    - aggiunge alla GUI un Frame contente un TextLabel
]]
function GUI:NewLabel(title)
	local Label = NewLabel(title, {Name = title.."Label"})
	local Frame = Instance.new("Frame")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.Parent = Frame
	Frame.Parent = self.Frame.SubFrame
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 0, 35)
	Frame.Position = UDim2.new(0, 0, 0, (#self.Frame.SubFrame:GetChildren()-1)*35)
end

return GUI
