-- // Constants \\ --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- // Functions \\ --
local function ConvertToScale(Child, Parent)
	local AbsoluteSize = Child.AbsoluteSize
	local AbsolutePosition = UDim2.new(0, Child.AbsolutePosition.X - AbsoluteSize.X*Child.AnchorPoint.X, 0, Child.AbsolutePosition.Y - AbsoluteSize.Y*Child.AnchorPoint.Y)
end

-- // DragModule \\ --
local DragModule = {}
DragModule.__index = DragModule

function DragModule.Create(Frame, Sensitivity)
	local NewObject = {}
	setmetatable(NewObject, DragModule)

	-- [ Info ] --
	NewObject.Frame = Frame
	NewObject.Dragging = false
	NewObject.DragEnabled = true
	NewObject.Sensitivity = Sensitivity

	-- [ Events ] --
	NewObject.DragStart = Instance.new("BindableEvent")
	NewObject.DragEnd = Instance.new("BindableEvent")
	NewObject.Changed = Instance.new("BindableEvent")
	NewObject.ObjectDragged = Instance.new("BindableEvent")

	NewObject.DragStart.Name = "DragStart"
	NewObject.DragEnd.Name = "DragEnd"
	NewObject.Changed.Name = "Changed"
	NewObject.ObjectDragged.Name = "ObjectDragged"

	-- [ Drag ] --
	-- Info --
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil
	
	-- Frame Clicked --
	Frame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			NewObject.Dragging = true
			NewObject.DragStart:Fire()
			NewObject.Changed:Fire(true)
			
			DragStart = Input.Position
			StartPosition = Frame.Position
		end
	end)
	
	-- Frame Released --
	Frame.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			NewObject.Dragging = false
			NewObject.DragEnd:Fire()
			NewObject.Changed:Fire(false)
		end
	end)
	
	-- Frame Moved --
	UserInputService.InputChanged:Connect(function(Input)
		if NewObject.Dragging and NewObject.DragEnabled and Input == DragInput then
			local Updated = Input.Position - DragStart
			local FinalPosition = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Updated.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Updated.Y)
			TweenService:Create(Frame, TweenInfo.new(NewObject.Sensitivity), {Position = FinalPosition}):Play()
			NewObject.ObjectDragged:Fire(FinalPosition)
		elseif Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
			DragInput = Input	
		end
	end)

	return NewObject
end

return DragModule
