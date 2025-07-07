--[[
	vUI Library - Enhanced Version
	Features:
	- No button movement animation
	- Multi-select dropdown
	- Dynamic code block updates
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

-- Utility Functions
local function CreateTween(object, info, properties)
    return TweenService:Create(object, info, properties)
end

local function RippleEffect(button, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.ZIndex = button.ZIndex + 1
    ripple.Parent = button
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    local expandTween = CreateTween(ripple, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    })
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:new(config)
    local self = setmetatable({}, Window)
    
    -- Create ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "vUI_" .. (config.Title or "Window")
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.Gui.Parent = CoreGui
    
    -- Main Frame
    self.Main = Instance.new("Frame")
    self.Main.Name = "Main"
    self.Main.Size = config.Config and config.Config.Size or UDim2.new(0, 500, 0, 400)
    self.Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    self.Main.BorderSizePixel = 0
    self.Main.Parent = self.Gui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.Main
    
    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "vUI Window"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.TitleBar
    
    -- Close Button
    if config.CloseUIButton and config.CloseUIButton.Enabled then
        local closeBtn = Instance.new("TextButton")
        closeBtn.Name = "CloseButton"
        closeBtn.Size = UDim2.new(0, 30, 0, 30)
        closeBtn.Position = UDim2.new(1, -35, 0, 5)
        closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "×"
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeBtn.TextSize = 18
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.Parent = self.TitleBar
        
        local closeBtnCorner = Instance.new("UICorner")
        closeBtnCorner.CornerRadius = UDim.new(0, 4)
        closeBtnCorner.Parent = closeBtn
        
        closeBtn.MouseButton1Click:Connect(function()
            self.Gui:Destroy()
        end)
    end
    
    -- Content Frame
    self.Content = Instance.new("ScrollingFrame")
    self.Content.Name = "Content"
    self.Content.Size = UDim2.new(1, 0, 1, -40)
    self.Content.Position = UDim2.new(0, 0, 0, 40)
    self.Content.BackgroundTransparency = 1
    self.Content.BorderSizePixel = 0
    self.Content.ScrollBarThickness = 4
    self.Content.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    self.Content.Parent = self.Main
    
    -- Layout
    self.Layout = Instance.new("UIListLayout")
    self.Layout.SortOrder = Enum.SortOrder.LayoutOrder
    self.Layout.Padding = UDim.new(0, 5)
    self.Layout.Parent = self.Content
    
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- Make draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return self
end

function Window:Tab(config)
    local tab = {}
    
    -- Tab Button
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = config.Title
    tabBtn.Size = UDim2.new(1, -10, 0, 35)
    tabBtn.Position = UDim2.new(0, 5, 0, 0)
    tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = config.Title
    tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.Parent = self.Content
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabBtn
    
    -- Tab Content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = config.Title .. "_Content"
    tabContent.Size = UDim2.new(1, -10, 1, -100)
    tabContent.Position = UDim2.new(0, 5, 0, 50)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tabContent.Visible = false
    tabContent.Parent = self.Content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = tabContent
    
    -- Tab functions
    function tab:Section(config)
        local section = Instance.new("TextLabel")
        section.Name = "Section"
        section.Size = UDim2.new(1, 0, 0, 25)
        section.BackgroundTransparency = 1
        section.Text = config.Title
        section.TextColor3 = Color3.fromRGB(150, 150, 150)
        section.TextSize = 12
        section.Font = Enum.Font.GothamBold
        section.TextXAlignment = Enum.TextXAlignment.Left
        section.Parent = tabContent
    end
    
    function tab:Button(config)
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(1, 0, 0, 35)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.BorderSizePixel = 0
        button.Text = config.Title
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.Parent = tabContent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        -- Remove movement animation, only add ripple effect
        button.MouseButton1Click:Connect(function()
            RippleEffect(button, Color3.fromRGB(100, 100, 100))
            if config.Callback then
                config.Callback()
            end
        end)
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            CreateTween(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            CreateTween(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)
        
        return button
    end
    
    function tab:Toggle(config)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = "Toggle"
        toggleFrame.Size = UDim2.new(1, 0, 0, 35)
        toggleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        toggleFrame.BorderSizePixel = 0
        toggleFrame.Parent = tabContent
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 6)
        toggleCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -50, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.Title
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleFrame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -45, 0.5, -10)
        toggle.BackgroundColor3 = config.Value and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = toggleFrame
        
        local toggleBtnCorner = Instance.new("UICorner")
        toggleBtnCorner.CornerRadius = UDim.new(0, 10)
        toggleBtnCorner.Parent = toggle
        
        local state = config.Value or false
        
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
            if config.Callback then
                config.Callback(state)
            end
        end)
    end
    
    function tab:Textbox(config)
        local textbox = Instance.new("TextBox")
        textbox.Name = "Textbox"
        textbox.Size = UDim2.new(1, 0, 0, 35)
        textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        textbox.BorderSizePixel = 0
        textbox.Text = config.Value or ""
        textbox.PlaceholderText = config.Placeholder or ""
        textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textbox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        textbox.TextSize = 14
        textbox.Font = Enum.Font.Gotham
        textbox.Parent = tabContent
        
        local textboxCorner = Instance.new("UICorner")
        textboxCorner.CornerRadius = UDim.new(0, 6)
        textboxCorner.Parent = textbox
        
        if config.ClearTextOnFocus then
            textbox.Focused:Connect(function()
                textbox.Text = ""
            end)
        end
        
        textbox.FocusLost:Connect(function()
            if config.Callback then
                config.Callback(textbox.Text)
            end
        end)
    end
    
    function tab:Slider(config)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Name = "Slider"
        sliderFrame.Size = UDim2.new(1, 0, 0, 50)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = tabContent
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 6)
        sliderCorner.Parent = sliderFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = config.Title .. ": " .. (config.Value or config.Min)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 4)
        sliderBg.Position = UDim2.new(0, 10, 1, -15)
        sliderBg.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = sliderFrame
        
        local sliderBgCorner = Instance.new("UICorner")
        sliderBgCorner.CornerRadius = UDim.new(0, 2)
        sliderBgCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((config.Value - config.Min) / (config.Max - config.Min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderBg
        
        local sliderFillCorner = Instance.new("UICorner")
        sliderFillCorner.CornerRadius = UDim.new(0, 2)
        sliderFillCorner.Parent = sliderFill
        
        local dragging = false
        local currentValue = config.Value or config.Min
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouse = UserInputService:GetMouseLocation()
                local relativeX = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                currentValue = config.Min + (config.Max - config.Min) * relativeX
                
                if config.Rounding then
                    currentValue = math.floor(currentValue * (10 ^ config.Rounding)) / (10 ^ config.Rounding)
                else
                    currentValue = math.floor(currentValue)
                end
                
                sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                label.Text = config.Title .. ": " .. currentValue
                
                if config.Callback then
                    config.Callback(currentValue)
                end
            end
        end)
    end
    
    function tab:Dropdown(config)
        local dropdownFrame = Instance.new("Frame")
        dropdownFrame.Name = "Dropdown"
        dropdownFrame.Size = UDim2.new(1, 0, 0, 35)
        dropdownFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        dropdownFrame.BorderSizePixel = 0
        dropdownFrame.Parent = tabContent
        
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 6)
        dropdownCorner.Parent = dropdownFrame
        
        local dropdownBtn = Instance.new("TextButton")
        dropdownBtn.Size = UDim2.new(1, 0, 1, 0)
        dropdownBtn.BackgroundTransparency = 1
        dropdownBtn.Text = config.Title .. ": " .. (config.MultiSelect and "Multiple" or (config.Value or "Select"))
        dropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdownBtn.TextSize = 14
        dropdownBtn.Font = Enum.Font.Gotham
        dropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
        dropdownBtn.Parent = dropdownFrame
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -25, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(200, 200, 200)
        arrow.TextSize = 12
        arrow.Font = Enum.Font.Gotham
        arrow.Parent = dropdownFrame
        
        local dropdownList = Instance.new("Frame")
        dropdownList.Name = "DropdownList"
        dropdownList.Size = UDim2.new(1, 0, 0, 0)
        dropdownList.Position = UDim2.new(0, 0, 1, 5)
        dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        dropdownList.BorderSizePixel = 0
        dropdownList.Visible = false
        dropdownList.ZIndex = 10
        dropdownList.Parent = dropdownFrame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0, 6)
        listCorner.Parent = dropdownList
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = dropdownList
        
        local isOpen = false
        local selectedItems = config.MultiSelect and {} or nil
        
        -- Multi-select support
        if config.MultiSelect then
            if config.Value and type(config.Value) == "table" then
                selectedItems = config.Value
            end
        end
        
        local function updateDropdownText()
            if config.MultiSelect then
                if #selectedItems > 0 then
                    dropdownBtn.Text = config.Title .. ": " .. table.concat(selectedItems, ", ")
                else
                    dropdownBtn.Text = config.Title .. ": None selected"
                end
            end
        end
        
        local function createListItem(item)
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            itemBtn.BorderSizePixel = 0
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            itemBtn.TextSize = 12
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.Parent = dropdownList
            
            -- Multi-select checkbox
            if config.MultiSelect then
                local checkbox = Instance.new("Frame")
                checkbox.Size = UDim2.new(0, 15, 0, 15)
                checkbox.Position = UDim2.new(1, -20, 0.5, -7.5)
                checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                checkbox.BorderSizePixel = 1
                checkbox.BorderColor3 = Color3.fromRGB(100, 100, 100)
                checkbox.Parent = itemBtn
                
                local checkboxCorner = Instance.new("UICorner")
                checkboxCorner.CornerRadius = UDim.new(0, 2)
                checkboxCorner.Parent = checkbox
                
                local checkmark = Instance.new("TextLabel")
                checkmark.Size = UDim2.new(1, 0, 1, 0)
                checkmark.BackgroundTransparency = 1
                checkmark.Text = "✓"
                checkmark.TextColor3 = Color3.fromRGB(0, 255, 0)
                checkmark.TextSize = 10
                checkmark.Font = Enum.Font.GothamBold
                checkmark.Visible = false
                checkmark.Parent = checkbox
                
                -- Check if item is already selected
                for _, selected in ipairs(selectedItems) do
                    if selected == item then
                        checkmark.Visible = true
                        checkbox.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                        break
                    end
                end
                
                itemBtn.MouseButton1Click:Connect(function()
                    local isSelected = false
                    local selectedIndex = nil
                    
                    for i, selected in ipairs(selectedItems) do
                        if selected == item then
                            isSelected = true
                            selectedIndex = i
                            break
                        end
                    end
                    
                    if isSelected then
                        table.remove(selectedItems, selectedIndex)
                        checkmark.Visible = false
                        checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    else
                        table.insert(selectedItems, item)
                        checkmark.Visible = true
                        checkbox.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    end
                    
                    updateDropdownText()
                    
                    if config.Callback then
                        config.Callback(selectedItems)
                    end
                end)
            else
                itemBtn.MouseButton1Click:Connect(function()
                    dropdownBtn.Text = config.Title .. ": " .. item
                    dropdownList.Visible = false
                    isOpen = false
                    arrow.Text = "▼"
                    
                    if config.Callback then
                        config.Callback(item)
                    end
                end)
            end
            
            itemBtn.MouseEnter:Connect(function()
                itemBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            end)
            
            itemBtn.MouseLeave:Connect(function()
                itemBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end)
        end
        
        for _, item in ipairs(config.List) do
            createListItem(item)
        end
        
        dropdownList.Size = UDim2.new(1, 0, 0, #config.List * 30)
        
        if config.MultiSelect then
            updateDropdownText()
        end
        
        dropdownBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            dropdownList.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
        end)
        
        -- Return dropdown object with update method
        local dropdownObj = {}
        function dropdownObj:UpdateList(newList)
            -- Clear existing items
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Add new items
            for _, item in ipairs(newList) do
                createListItem(item)
            end
            
            dropdownList.Size = UDim2.new(1, 0, 0, #newList * 30)
        end
        
        return dropdownObj
    end
    
    function tab:Code(config)
        local codeFrame = Instance.new("Frame")
        codeFrame.Name = "Code"
        codeFrame.Size = UDim2.new(1, 0, 0, 150)
        codeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        codeFrame.BorderSizePixel = 0
        codeFrame.Parent = tabContent
        
        local codeCorner = Instance.new("UICorner")
        codeCorner.CornerRadius = UDim.new(0, 6)
        codeCorner.Parent = codeFrame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = config.Title or "Code"
        title.TextColor3 = Color3.fromRGB(200, 200, 200)
        title.TextSize = 12
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = codeFrame
        
        local codeText = Instance.new("TextLabel")
        codeText.Size = UDim2.new(1, -20, 1, -35)
        codeText.Position = UDim2.new(0, 10, 0, 30)
        codeText.BackgroundTransparency = 1
        codeText.Text = config.Code or ""
        codeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        codeText.TextSize = 11
        codeText.Font = Enum.Font.Code
        codeText.TextXAlignment = Enum.TextXAlignment.Left
        codeText.TextYAlignment = Enum.TextYAlignment.Top
        codeText.TextWrapped = true
        codeText.Parent = codeFrame
        
        -- Return code object with update method
        local codeObj = {}
        function codeObj:SetCode(newCode)
            codeText.Text = newCode
        end
        
        return codeObj
    end
    
    -- Tab switching
    tabBtn.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, otherTab in pairs(self.Tabs) do
            otherTab.content.Visible = false
            otherTab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        
        -- Show current tab
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        self.CurrentTab = tab
    end)
    
    -- Store tab
    tab.content = tabContent
    tab.button = tabBtn
    self.Tabs[config.Title] = tab
    
    -- Show first tab by default
    if not self.CurrentTab then
        tabContent.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        self.CurrentTab = tab
    end
    
    return tab
end

function Window:Line()
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(1, -10, 0, 1)
    line.Position = UDim2.new(0, 5, 0, 0)
    line.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    line.BorderSizePixel = 0
    line.Parent = self.Content
end

function Window:Notify(config)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -320, 1, -100)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notification.BorderSizePixel = 0
    notification.Parent = self.Gui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -10, 0, 25)
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = config.Title or "Notification"
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 14
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notification
    
    local notifDesc = Instance.new("TextLabel")
    notifDesc.Size = UDim2.new(1, -10, 1, -30)
    notifDesc.Position = UDim2.new(0, 10, 0, 25)
    notifDesc.BackgroundTransparency = 1
    notifDesc.Text = config.Desc or ""
    notifDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifDesc.TextSize = 12
    notifDesc.Font = Enum.Font.Gotham
    notifDesc.TextXAlignment = Enum.TextXAlignment.Left
    notifDesc.TextYAlignment = Enum.TextYAlignment.Top
    notifDesc.TextWrapped = true
    notifDesc.Parent = notification
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 0, 1, -100)
    CreateTween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    
    -- Auto dismiss
    task.delay(config.Time or 3, function()
        CreateTween(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 1, -100)
        }):Play()
        
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
end

-- Library main function
function Library:Window(config)
    return Window:new(config)
end

return Library