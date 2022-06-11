local gui = {}
gui.__index = gui

function NewObject(obj, title, extra)
	local Inst = Instance.new(obj)
	Inst.Name = title
	Inst.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	Inst.Font = Enum.Font.SourceSans
	Inst.Text = title
	Inst.TextColor3 = Color3.fromRGB(255, 255, 255)
	Inst.BorderColor3 = Color3.fromRGB(255, 156, 16)
	Inst.BackgroundTransparency = 1
	Inst.BorderSizePixel = 0
	Inst.TextSize = 14
	if extra then
		for i,v in pairs(extra) do
			Inst[i] = v
		end
	end
	return Inst
end

function NewLabel(title, extra)
	return NewObject("TextLabel", title, extra)
end

function NewButton(title, extra)
	return NewObject("TextButton", title, extra)
end
-- crea il frame contenente la gui
function gui.new(title)
	local ScreenGui = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local SubFrame = Instance.new("Frame")
	local Label = Instance.new("TextLabel")
	local UIListLayout= Instance.new("UIListLayout")
	NewLabel(title, {TextSize = 20, BackgroundTransparency = 0, BorderSizePixel = 1, Size = UDim2.new(1, 0, 0.25, 0)}).Parent = Frame -- titolo della GUI
	
	ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
	
	Frame.BackgroundTransparency = 0
	Frame.Size = UDim2.new(0, 158, 0, 189)
	Frame.Position = UDim2.new(0.783, 0, 0.413, 0)
	Frame.Parent = ScreenGui
	Frame.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	Frame.BorderColor3 = Color3.fromRGB(255, 156, 16)
	Frame.BorderSizePixel = 1
	
	SubFrame.Name = "SubFrame"
	SubFrame.BackgroundTransparency = 1
	SubFrame.Size = UDim2.new(1, 0, 0.75, 0)
	SubFrame.Position = UDim2.new(0, 0, 0.25, 0)
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
	---
	
	local tab = {ScreenGui = ScreenGui, Frame = Frame}
	setmetatable(tab, gui)
	
	return tab
end
-- crea un bottone on/off che restituisce una boolvalue
function gui:NewToggle(title)
	local Label = NewLabel(title, {Name = title.."Label"})
	local Toggle = NewButton(title, {Name = title.."Toggle"})
	local BoolValue = Instance.new("BoolValue")
	local Frame = Instance.new("Frame")
	
	Label.Size = UDim2.new(0.6, 0, 1, 0)
	Label.Parent = Frame
	Toggle.Name = title.."Toggle"
	Toggle.Size = UDim2.new(0.4, 0, 1, 0)
	Toggle.Position = UDim2.new(0.6, 0, 0, 0)
	Toggle.Text = "Off"
	Toggle.Parent = Frame
	BoolValue.Parent = Toggle
	BoolValue.Value = false

	Frame.BackgroundTransparency = 1
	Frame.Parent = self.Frame.SubFrame
	
	for i,v in pairs(self.Frame.SubFrame:GetChildren()) do
		if v:IsA("Frame") then
			v.Size = UDim2.new(1, 0, 1/(#self.Frame.SubFrame:GetChildren()-1), 0)
			v.Position = UDim2.new(0, 0, 0, 1/(#self.Frame.SubFrame:GetChildren()-1) * i)
		end	
	end
	
	Toggle.MouseButton1Click:Connect(function()
		BoolValue.Value = not BoolValue.Value
		Toggle.Text = BoolValue.Value and "On" or "Off"
	end)
	return BoolValue
end


return gui