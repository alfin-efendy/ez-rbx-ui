--[[
	Notification Component Examples
	Demonstrates various notification types and features
]]

local Notification = {}

function Notification:Init(_window)
	local tab = _window:AddTab({
		Name = "Notifications",
		Icon = "🔔"
	})

	-- Basic intro
	tab:AddLabel("Notification Component Examples")
	tab:AddSeparator()

	-- Basic Notifications Section
	local notificationAccordion = tab:AddAccordion({
		Name = "Notification Examples",
		Icon = "🔔",
		Description = "Sonner-style toast notifications with stacking and animations"
	})

	-- Get window reference for notifications
	local windowAPI = _window
	
	-- Info Notification
	notificationAccordion:AddButton({
		Name = "Show Info Notification",
		Description = "Display an informational toast",
		Callback = function()
			windowAPI:ShowInfo(
				"Information",
				"This is an informational notification with some details.",
				3000
			)
		end
	})
	
	-- Success Notification
	notificationAccordion:AddButton({
		Name = "Show Success Notification", 
		Description = "Display a success toast",
		Callback = function()
			windowAPI:ShowSuccess(
				"Success!",
				"Your action completed successfully.",
				4000
			)
		end
	})
	
	-- Warning Notification
	notificationAccordion:AddButton({
		Name = "Show Warning Notification",
		Description = "Display a warning toast",
		Callback = function()
			windowAPI:ShowWarning(
				"Warning",
				"Please review your settings before continuing.",
				5000
			)
		end
	})
	
	-- Error Notification
	notificationAccordion:AddButton({
		Name = "Show Error Notification",
		Description = "Display an error toast",
		Callback = function()
			windowAPI:ShowError(
				"Error Occurred",
				"Something went wrong. Please try again.",
				6000
			)
		end
	})
	
	-- Advanced Features Section
	local advancedAccordion = tab:AddAccordion({
		Name = "Advanced Features",
		Icon = "⚙️",
		Description = "Action buttons, persistence, and custom configuration"
	})
	
	-- Notification with Action
	advancedAccordion:AddButton({
		Name = "Notification with Action",
		Description = "Toast with an action button",
		Callback = function()
			windowAPI:ShowNotification({
				Type = "info",
				Title = "Update Available",
				Message = "A new version is ready to install.",
				Duration = 8000,
				Action = {
					label = "Install",
					callback = function()
						windowAPI:ShowSuccess("Installing", "Update installation started...")
					end
				}
			})
		end
	})
	
	-- Persistent Notification
	advancedAccordion:AddButton({
		Name = "Persistent Notification",
		Description = "Toast that doesn't auto-dismiss",
		Callback = function()
			windowAPI:ShowNotification({
				Type = "warning",
				Title = "Action Required",
				Message = "This notification will stay until manually dismissed.",
				Duration = 0, -- 0 = persistent
				Action = {
					label = "Fix Now",
					callback = function()
						windowAPI:ShowSuccess("Fixed", "Issue has been resolved!")
					end
				}
			})
		end
	})
	
	-- Multiple Notifications
	advancedAccordion:AddButton({
		Name = "Show Multiple Notifications",
		Description = "Demonstrates stacking behavior",
		Callback = function()
			for i = 1, 4 do
				task.wait(0.2)
				windowAPI:ShowInfo(
					"Notification #" .. i,
					"This is notification number " .. i .. " in the stack.",
					3000 + (i * 1000)
				)
			end
		end
	})
	
	-- Custom Notification
	advancedAccordion:AddButton({
		Name = "Custom Notification",
		Description = "Fully customized toast",
		Callback = function()
			windowAPI:ShowNotification({
				Type = "success",
				Title = "Custom Configuration",
				Message = "This notification has custom timing and callbacks.",
				Duration = 5000,
				Action = {
					label = "Details",
					callback = function()
						windowAPI:ShowInfo("Details", "Here are the additional details you requested.")
					end
				},
				OnDismiss = function()
					print("Custom notification was dismissed!")
				end
			})
		end
	})
	
	-- Control Section
	local controlAccordion = tab:AddAccordion({
		Name = "Controls",
		Icon = "🎮", 
		Description = "Clear and manage notifications"
	})
	
	-- Clear All Notifications
	controlAccordion:AddButton({
		Name = "Clear All Notifications",
		Description = "Dismiss all active toasts",
		Callback = function()
			windowAPI:ClearNotifications()
			windowAPI:ShowSuccess("Cleared", "All notifications have been dismissed.")
		end
	})
	
	-- Demo Sequence
	controlAccordion:AddButton({
		Name = "Run Demo Sequence",
		Description = "Show all notification types in sequence",
		Callback = function()
			-- Demo sequence
			windowAPI:ShowInfo("Demo Started", "Running notification demo sequence...")
			
			task.wait(1)
			windowAPI:ShowSuccess("Step 1 Complete", "First step of the demo.")
			
			task.wait(1.5)
			windowAPI:ShowWarning("Caution", "This is a warning in the demo.")
			
			task.wait(2)
			windowAPI:ShowError("Demo Error", "This is not a real error - just part of the demo!")
			
			task.wait(2.5)
			windowAPI:ShowNotification({
				Type = "info",
				Title = "Demo Complete",
				Message = "The notification demo sequence has finished.",
				Action = {
					label = "Awesome!",
					callback = function()
						windowAPI:ShowSuccess("Thanks!", "Glad you enjoyed the demo!")
					end
				}
			})
		end
	})
end

return Notification