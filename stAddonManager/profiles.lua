local addon, st = ...

local stAM = st[1]

function stAM.NewAddonProfile(self, popup, data, data2)
	local name = popup.editBox:GetText()
	if stAM_Profiles[name] then print('There is already a profile named \'' .. name .. '\'.') return end

	local addonList = {}
	for i = 1, GetNumAddOns() do
		local addonName, _,_, isEnabled = GetAddOnInfo(i)
		if isEnabled then
			tinsert(addonList, addonName)
		end
	end
	stAM_Profiles[name] = addonList

	self.profileMenu.pullout:Hide()
	self:UpdateProfiles()
end 

StaticPopupDialogs['STADDONMANAGER_NEWPROFILE'] = {
	text = "Enter a name for your new Addon Profile:",
	button1 = 'Create',
	button2 = 'Cancel',
	timeout = 0,
	hasEditBox = true,
	whileDead = true,
	hideOnEscape = true,
	OnAccept = function(self, data, data2) stAM:NewAddonProfile(self, data, data2) end,
	preferredIndex = 3,
}

function stAM.InitProfiles(self)
	if self.profileMenu then return end

	local profileMenu = CreateFrame('Frame', self:GetName()..'_ProfileMenu', self)
	profileMenu:SetAllPoints(self.addons)
	profileMenu:SetTemplate()
	profileMenu:SetFrameLevel(self.addons.buttons[1]:GetFrameLevel()+1)

	----------------------------------------------------
	-- PULLOUT MENU ------------------------------------
	----------------------------------------------------
	local pullout = CreateFrame('Frame', profileMenu:GetName()..'_', profileMenu)
	pullout:SetWidth(stAM:GetWidth() - stAM.buttonWidth - 45)
	pullout:SetHeight(stAM.buttonHeight)
	pullout:Hide()
	

	--[[ "SET TO" BUTTON ]]
	local setTo = CreateFrame('Button', profileMenu:GetName().."_SetToButton", pullout)
	setTo:SetPoint('LEFT', pullout, 0, 0)
	setTo:SetScript('OnClick', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		--if shift key is pressed, don't disable current addons
		if not IsShiftKeyDown() then
			for i=1, GetNumAddOns() do DisableAddOn(i) end
		end
		for _,addon in pairs(stAM_Profiles[profileName]) do
			EnableAddOn(addon)
		end
		stAM:ToggleProfiles()
	end)
	pullout.setTo = setTo

	--[[ "REMOVE FROM" BUTTON ]]
	local removeFrom = CreateFrame('Button', profileMenu:GetName().."_RemoveButton", pullout)
	removeFrom:SetPoint('LEFT', setTo, 'RIGHT', 5, 0)
	removeFrom:SetScript('OnClick', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		for _,addon in pairs(stAM_Profiles[profileName]) do
			DisableAddOn(addon)
		end
		stAM:ToggleProfiles()
	end)


	--[[ "DELETE PROFILE" DIALOG ]]
	StaticPopupDialogs['STADDONMANAGER_DELETECONFIRMATION'] = {
			text = "Are you sure you want to delete ???????",
			button1 = 'Delete',
			button2 = 'Cancel',
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
			OnAccept = function(self, data, data2) end,
			preferredIndex = 3,
		}

	--[[ "DELETE PROFILE" BUTTON ]]
	local deleteProfile = CreateFrame('Button', profileMenu:GetName().."_DeleteProfileButton", pullout)
	deleteProfile:SetPoint('LEFT', removeFrom, 'RIGHT', 5, 0)
	deleteProfile:SetScript('OnClick', function(self, btn)
		local profileName = self:GetParent():GetParent().text:GetText()
		local dialog = StaticPopupDialogs['STADDONMANAGER_DELETECONFIRMATION']
		
		--Modify static popup information to specific button
		dialog.text = "Are you sure you want to delete"..self:GetParent():GetParent().text:GetText()
		dialog.OnAccept = function(self, data, data2)
			stAM_Profiles[profileName] = nil
			stAM:UpdateProfiles()
		end
		StaticPopup_Show('STADDONMANAGER_DELETECONFIRMATION')
	end)
	
	--[[ GENERAL PULLOUT BUTTON SKINNING ]]
	for _,button in pairs({setTo, removeFrom, deleteProfile}) do
		button:SetTemplate()
		button:SetHeight(stAM.buttonHeight)
		button:SetWidth((pullout:GetWidth()-10)/3)
		button:SetScript('OnEnter', function(self) self:SetModifiedColor() end)
		button:SetScript('OnLeave', function(self) self:SetOriginalColor() end)
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:SetPixelFont()
		button.text:SetPoint('CENTER', 1, 1)
	end

	-- [[ PULLOUT BUTTON LABELS ]]
	setTo.text:SetText('Set to')
	removeFrom.text:SetText('Remove')
	deleteProfile.text:SetText('Delete')

	--[[ ANCHOR FUNCTION - Used to change which button the pullout is set to ]]
	pullout.AnchorToButton = function(self, button)
		local profileName = button.text:GetText()
		self:SetParent(button)
		self:SetPoint('LEFT', button, 'RIGHT', 5, 0)
		self:Show()
	end

	profileMenu.pullout = pullout


	----------------------------------------------------
	-- TOP MENU BUTTONS --------------------------------
	----------------------------------------------------
	for i,name in pairs({'EnableAll', 'DisableAll'}) do
		local button = CreateFrame('Button', profileMenu:GetName()..'_'..name, profileMenu)
		button:SetTemplate()
		button:SetHeight(stAM.buttonHeight)
		if i == 1 then
			button:SetPoint('TOPLEFT', profileMenu, 'TOPLEFT', 10, -10)
			button:SetPoint('TOPRIGHT', profileMenu, 'TOP', -3, -10)
		else
			button:SetPoint('TOPRIGHT', profileMenu, 'TOPRIGHT', -10, -10)
			button:SetPoint('TOPLEFT', profileMenu, 'TOP', 2, -10)
		end
		
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:SetPixelFont()
		button.text:SetPoint('CENTER', 1, 1)
		button.text:SetText(i == 1 and 'Enable All' or 'Disable All')

		button:SetScript('OnEnter', function(self) self:SetModifiedColor() end)
		button:SetScript('OnLeave', function(self) self:SetOriginalColor() end)
		button:SetScript('OnClick', function(self)
			for i=1, GetNumAddOns() do
				if i == 1 then
					EnableAddOn(i)
				elseif not (GetAddOnInfo(i) == addon) then -- Disable all addons except this one
					DisableAddOn(i)
				end
			end

		end)
		
		profileMenu[name] = button
	end

	local newButton = CreateFrame('Button', profileMenu:GetName()..'_NewProfileButton', profileMenu)
	newButton:SetTemplate()
	newButton:SetHeight(stAM.buttonHeight)
	newButton:SetPoint('TOPLEFT', profileMenu.EnableAll, 'BOTTOMLEFT', 0, -5)
	newButton:SetPoint('TOPRIGHT', profileMenu.DisableAll, 'BOTTOMRIGHT', 0, -5)
	newButton:SetScript('OnEnter', function(self) self:SetModifiedColor() end)
	newButton:SetScript('OnLeave', function(self) self:SetOriginalColor() end)
	newButton:SetScript('OnClick', function(self) StaticPopup_Show('STADDONMANAGER_NEWPROFILE') end)

	newButton.text = newButton:CreateFontString(nil, 'OVERLAY')
	newButton.text:SetPixelFont()
	newButton.text:SetPoint('CENTER',1 , 1)
	newButton.text:SetText('New Profile..')
	profileMenu.newButton = newButton


	----------------------------------------------------
	-- PROFILE BUTTONS ---------------------------------
	----------------------------------------------------
	profileMenu.buttons = {}
	for i=1, self.perPage-2 do
		local button = CreateFrame("Button", self:GetName().."Page"..i, profileMenu)
		button:SetTemplate()
		button:SetSize(stAM.buttonWidth, stAM.buttonHeight)
		button:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
		button:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
		button:SetScript("OnClick", function(self) 
			if (pullout:GetParent() == self and pullout:IsShown()) then 
				pullout:Hide() 
			else 
				pullout:AnchorToButton(self) 
			end
		end)
		
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:SetPixelFont()
		button.text:SetPoint("LEFT", button, "RIGHT", 10, 0)
		button.text:SetPoint("TOP", button, "TOP")
		button.text:SetPoint("BOTTOM", button, "BOTTOM")
		button.text:SetPoint("RIGHT", profileMenu, "RIGHT", -10, 0)
		button.text:SetJustifyH("LEFT")

		if i == 1 then
			pullout:AnchorToButton(button)
			pullout:Hide()
			button:SetPoint("TOPLEFT", profileMenu.newButton, "BOTTOMLEFT", 0, -5)
		else
			button:SetPoint("TOP", profileMenu.buttons[i-1], "BOTTOM", 0, -5)
		end
		button.arrow = button:CreateFontString(nil, 'OVERLAY')
		button.arrow:SetPixelFont()
		button.arrow:SetPoint("CENTER", 1, 1)
		button.arrow:SetText('>')

		profileMenu.buttons[i] = button
	end

	self.profileMenu = profileMenu
end

function stAM.UpdateProfiles(self)
	local profiles = {}
	local buttons = self.profileMenu.buttons
	for name,_ in pairs(stAM_Profiles) do
		tinsert(profiles, name)
	end

	if self.pageNum <= 0 then
		self.prevPage:Hide()
	else
		self.prevPage:Show()
	end

	if (self.pageNum+1)*self.perPage >= #profiles then
		self.nextPage:Hide()
	else
		self.nextPage:Show()
	end

	local pgOff = (self.pageNum*self.perPage)
	for i = 1, self.perPage-2 do
		if profiles[pgOff + i] then
			buttons[i]:Show()
			buttons[i].text:SetText(profiles[pgOff + i])
		else
			buttons[i]:Hide()
		end
	end

	-- Make sure this is hidden so that it's not accidentally shown on the wrong profile
	if self.profileMenu.pullout:IsShown() then
		self.profileMenu.pullout:Hide()
	end
end

function stAM.ToggleProfiles(self)
	if not self.profileMenu then
		self:InitProfiles()
	else
		ToggleFrame(self.profileMenu)
	end
	self.pageNum = 0
	if self.profileMenu:IsShown() then
		self:UpdateProfiles()
	else
		self:UpdateAddonList()
	end
end