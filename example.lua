--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Load UI Library
local Library = loadstring(game:HttpGet("https://github.com/TDAIP/vUI/raw/refs/heads/main/main.lua"))()

-- Create Main Window
local Window = Library:Window({
    Title = "x2zu [ Stellar ]",
    Desc = "x2zu on top",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "x2zu"
    }
})

-- Tab
local Tab = Window:Tab({Title = "Main", Icon = "star"}) do
    -- Section
    Tab:Section({Title = "All UI Components"})

    -- Toggle
    Tab:Toggle({
        Title = "Enable Feature",
        Desc = "Toggle to enable or disable the feature",
        Value = false,
        Callback = function(v)
            print("Toggle:", v)
        end
    })

    -- Button (No movement animation, only ripple effect)
    local CodeBlock -- Declare CodeBlock variable first
    
    Tab:Button({
        Title = "Run Action",
        Desc = "Click to perform something",
        Callback = function()
            print("Button clicked!")
            -- Update code block when button is clicked
            if CodeBlock then
                CodeBlock:SetCode('print("button")')
            end
            Window:Notify({
                Title = "Button",
                Desc = "Action performed successfully and code updated.",
                Time = 3
            })
        end
    })

    -- Textbox
    Tab:Textbox({
        Title = "Input Text",
        Desc = "Type something here",
        Placeholder = "Enter value",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(text)
            print("Textbox value:", text)
        end
    })

    -- Slider
    Tab:Slider({
        Title = "Set Speed",
        Min = 0,
        Max = 100,
        Rounding = 0,
        Value = 25,
        Callback = function(val)
            print("Slider:", val)
        end
    })

    -- Multi-select Dropdown
    Tab:Dropdown({
        Title = "Choose Multiple Options",
        List = {"Option 1", "Option 2", "Option 3", "Option 4"},
        MultiSelect = true,
        Value = {"Option 1"}, -- Pre-selected items
        Callback = function(selectedItems)
            print("Selected items:", table.concat(selectedItems, ", "))
        end
    })

    -- Regular Dropdown
    Tab:Dropdown({
        Title = "Choose Single Option",
        List = {"Single 1", "Single 2", "Single 3"},
        Value = "Single 1",
        Callback = function(choice)
            print("Selected:", choice)
        end
    })

    -- Code Display (Now can be updated dynamically)
    CodeBlock = Tab:Code({
        Title = "Dynamic Code Block",
        Code = "-- This code block can be updated dynamically\nprint('Hello world')"
    })

    -- Button to update code block with different content
    Tab:Button({
        Title = "Update Code Block",
        Desc = "Click to change code content",
        Callback = function()
            CodeBlock:SetCode("-- Code updated!\nlocal message = 'Updated content'\nprint(message)")
            Window:Notify({
                Title = "Code Updated",
                Desc = "Code block content has been changed.",
                Time = 2
            })
        end
    })
end

-- Line Separator
Window:Line()

-- Another Tab Example
local Extra = Window:Tab({Title = "Extra", Icon = "tag"}) do
    Extra:Section({Title = "About"})
    Extra:Button({
        Title = "Show Message",
        Desc = "Display a popup",
        Callback = function()
            Window:Notify({
                Title = "Fluent UI",
                Desc = "Everything works fine!",
                Time = 3
            })
        end
    })
    
    -- Multi-select dropdown in Extra tab
    local extraDropdown = Extra:Dropdown({
        Title = "Multi-Select Features",
        List = {"Feature A", "Feature B", "Feature C", "Feature D", "Feature E"},
        MultiSelect = true,
        Callback = function(selected)
            print("Extra features selected:", table.concat(selected, ", "))
        end
    })
    
    -- Button to update dropdown list
    Extra:Button({
        Title = "Update Dropdown List",
        Desc = "Add more options to dropdown",
        Callback = function()
            extraDropdown:UpdateList({"New Option 1", "New Option 2", "New Option 3", "Updated Feature"})
            Window:Notify({
                Title = "Dropdown Updated",
                Desc = "New options have been added to the dropdown.",
                Time = 2
            })
        end
    })
end

Window:Line()

local Settings = Window:Tab({Title = "Settings", Icon = "wrench"}) do
    Settings:Section({Title = "Configuration"})
    
    -- Code block in settings that can be updated
    local SettingsCode = Settings:Code({
        Title = "Settings Code",
        Code = "-- Settings configuration\nlocal config = {\n    theme = 'dark',\n    version = '1.0'\n}"
    })
    
    Settings:Button({
        Title = "Update Settings Code",
        Desc = "Update the settings code block",
        Callback = function()
            SettingsCode:SetCode("-- Updated settings\nlocal newConfig = {\n    theme = 'light',\n    version = '2.0',\n    features = {'multi-select', 'dynamic-updates'}\n}")
            Window:Notify({
                Title = "Settings Updated",
                Desc = "Settings code has been updated with new configuration.",
                Time = 3
            })
        end
    })
end

-- Final Notification
Window:Notify({
    Title = "x2zu Enhanced UI",
    Desc = "All components loaded with new features: No button animations, multi-select dropdowns, and dynamic code blocks!",
    Time = 5
})