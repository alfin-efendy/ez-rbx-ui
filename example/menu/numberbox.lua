local NumberBox = {}

function NumberBox:Init(_window)
    local tab = _window:AddTab({
        Name = "NumberBox",
        Icon = "🔢"
    })

    -- Basic intro
    tab:AddLabel("NumberBox Component Examples")
    tab:AddSeparator()
    
    -- Accordion: Basic NumberBoxes
    self:AddSectionBasic(tab)
    
    -- Accordion: Range & Validation
    self:AddSectionRange(tab)
    
    -- Accordion: Decimal & Precision
    self:AddSectionDecimals(tab)
    
    -- Accordion: Increment Settings
    self:AddSectionIncrement(tab)
    
    -- Accordion: Practical Examples
    self:AddSectionPractical(tab)
    
    -- Accordion: Advanced Features
    self:AddSectionAdvanced(tab)
    
    -- Accordion: Usage Tips
    self:AddSectionTips(tab)
end

function NumberBox:AddSectionBasic(tab)
    local accordion = tab:AddAccordion({
        Name = "Basic NumberBoxes",
        Icon = "🔢",
    })
    
    accordion:AddLabel("Basic NumberBox usage with default settings:")
    accordion:AddSeparator()

    -- Simple NumberBox
    accordion:AddNumberBox({
        Placeholder = "Enter a number...",
        Default = 0,
        Callback = function(value)
            print("Basic NumberBox:", value)
        end
    })

    -- NumberBox with default value
    accordion:AddNumberBox({
        Placeholder = "Starting value: 10",
        Default = 10,
        Flag = "BasicDefault",
        Callback = function(value)
            print("Default value NumberBox:", value)
        end
    })

    -- NumberBox with custom placeholder
    accordion:AddNumberBox({
        Placeholder = "🎯 Enter your score...",
        Default = 100,
        Flag = "Score",
        Callback = function(value)
            print("Score updated:", value)
        end
    })

    -- Simple integer input
    accordion:AddNumberBox({
        Placeholder = "Age (integer only)",
        Default = 25,
        Min = 0,
        Max = 120,
        Flag = "Age",
        Callback = function(value)
            print("Age set to:", value, "years")
        end
    })
end

function NumberBox:AddSectionRange(tab)
    local accordion = tab:AddAccordion({
        Name = "Range & Validation",
        Icon = "📏",
    })
    
    accordion:AddLabel("NumberBoxes with minimum and maximum value constraints:")
    accordion:AddSeparator()

    -- Limited range NumberBox
    accordion:AddNumberBox({
        Placeholder = "1-10 only",
        Default = 5,
        Min = 1,
        Max = 10,
        Flag = "Range1to10",
        Callback = function(value)
            print("Range 1-10 value:", value)
        end
    })

    -- Percentage input (0-100)
    accordion:AddNumberBox({
        Placeholder = "Percentage (0-100%)",
        Default = 50,
        Min = 0,
        Max = 100,
        Flag = "Percentage",
        Callback = function(value)
            print("Percentage set:", value .. "%")
        end
    })

    -- Positive numbers only
    accordion:AddNumberBox({
        Placeholder = "Positive numbers only",
        Default = 1,
        Min = 0,
        Flag = "PositiveOnly",
        Callback = function(value)
            print("Positive value:", value)
        end
    })

    -- Temperature range (-50 to 50)
    accordion:AddNumberBox({
        Placeholder = "Temperature (-50°C to 50°C)",
        Default = 20,
        Min = -50,
        Max = 50,
        Flag = "Temperature",
        Callback = function(value)
            print("Temperature:", value .. "°C")
        end
    })

    -- No maximum limit
    accordion:AddNumberBox({
        Placeholder = "Min: 100, no max limit",
        Default = 100,
        Min = 100,
        Flag = "MinOnly",
        Callback = function(value)
            print("Value (min 100):", value)
        end
    })
end

function NumberBox:AddSectionDecimals(tab)
    local accordion = tab:AddAccordion({
        Name = "Decimal & Precision",
        Icon = "🔸",
    })
    
    accordion:AddLabel("NumberBoxes with decimal precision settings:")
    accordion:AddSeparator()

    -- 1 decimal place
    accordion:AddNumberBox({
        Placeholder = "1 decimal place",
        Default = 5.5,
        Decimals = 1,
        Flag = "OneDecimal",
        Callback = function(value)
            print("1 decimal:", value)
        end
    })

    -- 2 decimal places (money)
    accordion:AddNumberBox({
        Placeholder = "Price ($0.00)",
        Default = 19.99,
        Min = 0,
        Decimals = 2,
        Flag = "Price",
        Callback = function(value)
            print("Price: $" .. string.format("%.2f", value))
        end
    })

    -- 3 decimal places (precision)
    accordion:AddNumberBox({
        Placeholder = "High precision (3 decimals)",
        Default = 3.141,
        Decimals = 3,
        Flag = "Precision",
        Callback = function(value)
            print("Precision value:", value)
        end
    })

    -- Weight with 2 decimals
    accordion:AddNumberBox({
        Placeholder = "Weight (kg)",
        Default = 70.5,
        Min = 0,
        Max = 500,
        Decimals = 2,
        Flag = "Weight",
        Callback = function(value)
            print("Weight:", value .. " kg")
        end
    })

    -- Percentage with decimals
    accordion:AddNumberBox({
        Placeholder = "Precise percentage",
        Default = 85.75,
        Min = 0,
        Max = 100,
        Decimals = 2,
        Flag = "PrecisePercent",
        Callback = function(value)
            print("Precise percentage:", value .. "%")
        end
    })
end

function NumberBox:AddSectionIncrement(tab)
    local accordion = tab:AddAccordion({
        Name = "Increment Settings",
        Icon = "⬆️",
    })
    
    accordion:AddLabel("NumberBoxes with custom increment/decrement steps:")
    accordion:AddSeparator()

    -- Step by 5
    accordion:AddNumberBox({
        Placeholder = "Increments by 5",
        Default = 10,
        Increment = 5,
        Flag = "StepBy5",
        Callback = function(value)
            print("Step by 5:", value)
        end
    })

    -- Step by 10
    accordion:AddNumberBox({
        Placeholder = "Increments by 10",
        Default = 50,
        Min = 0,
        Max = 1000,
        Increment = 10,
        Flag = "StepBy10",
        Callback = function(value)
            print("Step by 10:", value)
        end
    })

    -- Small decimal increments
    accordion:AddNumberBox({
        Placeholder = "Increments by 0.1",
        Default = 1.0,
        Increment = 0.1,
        Decimals = 1,
        Flag = "SmallStep",
        Callback = function(value)
            print("Small step:", value)
        end
    })

    -- Large increments
    accordion:AddNumberBox({
        Placeholder = "Increments by 100",
        Default = 1000,
        Min = 0,
        Increment = 100,
        Flag = "LargeStep",
        Callback = function(value)
            print("Large step:", value)
        end
    })

    -- Fractional increments
    accordion:AddNumberBox({
        Placeholder = "Increments by 0.25",
        Default = 2.5,
        Increment = 0.25,
        Decimals = 2,
        Flag = "FractionalStep",
        Callback = function(value)
            print("Fractional step:", value)
        end
    })
end

function NumberBox:AddSectionPractical(tab)
    local accordion = tab:AddAccordion({
        Name = "Practical Examples",
        Icon = "🛠️",
    })
    
    accordion:AddLabel("Real-world NumberBox usage examples:")
    accordion:AddSeparator()

    accordion:AddLabel("🎮 Game Settings:")

    -- Volume control
    accordion:AddNumberBox({
        Placeholder = "Volume (0-100)",
        Default = 75,
        Min = 0,
        Max = 100,
        Increment = 5,
        Flag = "Volume",
        Callback = function(value)
            print("🔊 Volume set to:", value .. "%")
        end
    })

    -- FOV setting
    accordion:AddNumberBox({
        Placeholder = "Field of View (60-120)",
        Default = 90,
        Min = 60,
        Max = 120,
        Increment = 5,
        Flag = "FOV",
        Callback = function(value)
            print("👁️ FOV set to:", value .. "°")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("💰 Financial:")

    -- Money input
    accordion:AddNumberBox({
        Placeholder = "Amount ($)",
        Default = 100.00,
        Min = 0,
        Decimals = 2,
        Increment = 0.01,
        Flag = "Money",
        Callback = function(value)
            print("💵 Amount: $" .. string.format("%.2f", value))
        end
    })

    -- Interest rate
    accordion:AddNumberBox({
        Placeholder = "Interest Rate (%)",
        Default = 5.25,
        Min = 0,
        Max = 100,
        Decimals = 2,
        Increment = 0.25,
        Flag = "InterestRate",
        Callback = function(value)
            print("📈 Interest rate:", value .. "%")
        end
    })

    accordion:AddSeparator()
    accordion:AddLabel("⚙️ Technical:")

    -- Speed setting
    accordion:AddNumberBox({
        Placeholder = "Speed multiplier",
        Default = 1.0,
        Min = 0.1,
        Max = 10.0,
        Decimals = 1,
        Increment = 0.1,
        Flag = "SpeedMultiplier",
        Callback = function(value)
            print("⚡ Speed multiplier:", value .. "x")
        end
    })

    -- Resolution width
    accordion:AddNumberBox({
        Placeholder = "Screen Width",
        Default = 1920,
        Min = 640,
        Max = 7680,
        Increment = 10,
        Flag = "ScreenWidth",
        Callback = function(value)
            print("🖥️ Screen width:", value .. "px")
        end
    })
end

function NumberBox:AddSectionAdvanced(tab)
    local accordion = tab:AddAccordion({
        Name = "Advanced Features",
        Icon = "⚙️",
    })
    
    accordion:AddLabel("Advanced NumberBox configurations and use cases:")
    accordion:AddSeparator()

    -- Large number handling
    accordion:AddNumberBox({
        Placeholder = "Large numbers",
        Default = 1000000,
        Min = 0,
        Increment = 1000,
        Flag = "LargeNumber",
        Callback = function(value)
            -- Format large numbers with commas
            local formatted = tostring(value):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            print("🔢 Large number:", formatted)
        end
    })

    -- Scientific/Engineering values
    accordion:AddNumberBox({
        Placeholder = "Scientific value",
        Default = 9.81,
        Decimals = 3,
        Increment = 0.001,
        Flag = "Scientific",
        Callback = function(value)
            print("🔬 Scientific value:", value)
        end
    })

    -- Coordinate input (X)
    accordion:AddNumberBox({
        Placeholder = "X Coordinate",
        Default = 0,
        Min = -1000,
        Max = 1000,
        Decimals = 2,
        Flag = "CoordX",
        Callback = function(value)
            print("📍 X coordinate:", value)
        end
    })

    -- Coordinate input (Y)
    accordion:AddNumberBox({
        Placeholder = "Y Coordinate", 
        Default = 0,
        Min = -1000,
        Max = 1000,
        Decimals = 2,
        Flag = "CoordY",
        Callback = function(value)
            print("📍 Y coordinate:", value)
        end
    })

    -- Angle input (0-360)
    accordion:AddNumberBox({
        Placeholder = "Angle (0-360°)",
        Default = 0,
        Min = 0,
        Max = 360,
        Increment = 15,
        Flag = "Angle",
        Callback = function(value)
            print("🔄 Angle:", value .. "°")
        end
    })

    -- Timer/Duration input
    accordion:AddNumberBox({
        Placeholder = "Duration (seconds)",
        Default = 60,
        Min = 1,
        Max = 3600,
        Flag = "Duration",
        Callback = function(value)
            local minutes = math.floor(value / 60)
            local seconds = value % 60
            print("⏱️ Duration:", minutes .. "m " .. seconds .. "s")
        end
    })
end

function NumberBox:AddSectionTips(tab)
    local accordion = tab:AddAccordion({
        Name = "Usage Tips & Best Practices",
        Icon = "💡",
    })
    
    accordion:AddLabel("📌 NumberBox Configuration Tips:")
    accordion:AddLabel("• Set appropriate Min/Max ranges for validation")
    accordion:AddLabel("• Use Decimals parameter for floating-point precision")
    accordion:AddLabel("• Set logical Increment values for user convenience")
    accordion:AddLabel("• Use Flag parameter for persistent value storage")
    accordion:AddLabel("• Provide clear Placeholder text describing the input")
    
    accordion:AddSeparator()
    accordion:AddLabel("🎯 Best Practices:")
    accordion:AddLabel("• Min/Max: Always set reasonable bounds")
    accordion:AddLabel("• Decimals: Match precision to use case")
    accordion:AddLabel("• Increment: Use round numbers (1, 5, 10, 0.1, etc.)")
    accordion:AddLabel("• Default: Set sensible starting values")
    accordion:AddLabel("• Callback: Validate and format output appropriately")
    
    accordion:AddSeparator()
    accordion:AddLabel("⚡ Performance Tips:")
    accordion:AddLabel("• Use integers when decimals aren't needed")
    accordion:AddLabel("• Set appropriate increment sizes for smooth UX")
    accordion:AddLabel("• Validate ranges to prevent invalid states")
    accordion:AddLabel("• Format large numbers in callbacks for readability")
    
    accordion:AddSeparator()
    accordion:AddLabel("🔧 Common Configurations:")
    accordion:AddLabel("• Percentage: Min=0, Max=100, Decimals=0")
    accordion:AddLabel("• Money: Min=0, Decimals=2, Increment=0.01")
    accordion:AddLabel("• Age: Min=0, Max=120, Decimals=0")
    accordion:AddLabel("• Coordinates: Min=-1000, Max=1000, Decimals=2")
    accordion:AddLabel("• Volume: Min=0, Max=100, Increment=5")
end

return NumberBox