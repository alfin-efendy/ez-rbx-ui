local EzUI = require("../output/bundle")
local Label = require("menu/label")
local Button = require("menu/button")
local TextBox = require("menu/textbox")
local NumberBox = require("menu/numberbox")
local Toggle = require("menu/toggle")
local SelectBox = require("menu/selectbox")
local Notification = require("menu/notification")

local window = EzUI:CreateNew({
    Name = "Example",
    Width = 750,
    Height = 400,
    Opacity = 0.9,
    AutoShow = true,
    FolderName = "EzUIExample",
    FileName = "ExampleConfig",
})

-- Initialize component examples
Label:Init(window)
Button:Init(window)
TextBox:Init(window)
NumberBox:Init(window)
Toggle:Init(window)
SelectBox:Init(window)
Notification:Init(window)