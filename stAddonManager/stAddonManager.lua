local _, st = ...

local stAM = CreateFrame("Frame", "stAddonManager", UIParent)

stAM.pageNum = 0
stAM.perPage = 10

local function strtrim(string)
	return string:gsub("^%s*(.-)%s*$", "%1")
end

function stAM.Initialize(self, event, ...)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	if GameMenuButtonAddons then return end

	local menu = _G.GameMenuFrame
	local macros = _G.GameMenuButtonMacros
	local ratings = _G.GameMenuButtonRatings
	local logout = _G.GameMenuButtonLogout

	local addons = CreateFrame("Button", "GameMenuButtonAddons", menu, "GameMenuButtonTemplate")
	
	if Tukui then addons:SkinButton(true) end
	
	addons:SetPoint("TOP", ratings:IsShown() and ratings or macros, "BOTTOM", 0, -1)
	addons:SetSize(logout:GetWidth(), logout:GetHeight())
	addons:SetText("AddOns")

	logout:ClearAllPoints()
	local anchorTo = SkinOptionsButton or addons
	logout:SetPoint("TOP", anchorTo, "BOTTOM", 0, -14)
	menu:SetHeight(menu:GetHeight() + addons:GetHeight() + 15)

	addons:SetScript("OnClick", function() self:LoadWindow() end)
end

function stAM.UpdateAddonList(self)
	for i = 1, self.perPage do
		local addonIndex = (self.pageNum*self.perPage) + i
		local button = self.addons.buttons[i]

		if self.pageNum <= 0 then
			self.prevPage:Hide()
		else
			self.prevPage:Show()
		end

		if (self.pageNum+1)*self.perPage >= GetNumAddOns() then
			self.nextPage:Hide()
		else
			self.nextPage:Show()
		end

		if addonIndex <= GetNumAddOns() then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
			button.text:SetText(title)
			button:Show()

			if enabled then
				button.enabled:SetVertexColor(0.3, 1, 0.3, 0.5)
			else
				button.enabled:SetVertexColor(1, 0.3, 0.3, 0.5)
			end
			button:SetScript("OnClick", function()
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				self:UpdateAddonList()
			end)
		else
			button:Hide()
		end
	end
end

function stAM.UpdateSearchQuery(self, search, userInput)
	local query = strlower(strtrim(search:GetText()))

	--Revert to regular addon list if:
	-- 1) Query text was not input by a user (e.g. text was changed by search:SetText())
	-- 2) The query text contains nothing but spaces
	if (not userInput) or (strlen(query) == 0) then self:UpdateAddonList() return end

	--store all addons that match the query in here
	local addonList = {}
	for i = 1, GetNumAddOns() do
		local name, title = GetAddOnInfo(i)
		name = strlower(name)
		title = strlower(title)

		if strfind(name, query) or strfind(title, query) then
			tinsert(addonList, i)
		end
	end


	--Load addons the same way as UpdateAddonList, but with the filtered table this time
	for i = 1, self.perPage do
		local pgOff = (self.pageNum*self.perPage)
		local addonIndex = addonList[pgOff + i]
		local button = self.addons.buttons[i]

		if self.pageNum <= 0 then
			self.prevPage:Hide()
		else
			self.prevPage:Show()
		end

		if (self.pageNum+1)*self.perPage >= #addonList then
			self.nextPage:Hide()
		else
			self.nextPage:Show()
		end

		if addonIndex and addonIndex <= GetNumAddOns() then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
			button.text:SetText(title)
			button:Show()

			if enabled then
				button.enabled:SetVertexColor(0.3, 1, 0.3, 0.5)
			else
				button.enabled:SetVertexColor(1, 0.3, 0.3, 0.5)
			end
			button:SetScript("OnClick", function()
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				self:UpdateAddonList()
			end)
		else
			button:Hide()
		end
	end
end

function stAM.LoadWindow(self)
	if GameMenuFrame:IsShown() then HideUIPanel(GameMenuFrame) end
	if self.loaded then ToggleFrame(self) return end

	self:SetSize(225, 10 + self.perPage * 25 + 40)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self:SetTemplate("Transparent")
	self:SetClampedToScreen(true)
	self:SetMovable(true)
	self:EnableMouse(true)
	self:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	self:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	local title = CreateFrame("Frame", nil, self)
	title:SetPoint('TOPLEFT')
	title:SetPoint('TOPRIGHT')
	title:SetHeight(20)
	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:SetPoint("CENTER")
	title.text:SetPixelFont()
	title.text:SetText("stAddonManager")
	self.title = title
	
	local close = CreateFrame("Button", nil, title)
	close:SetPoint("RIGHT", -3, 0)
	close:SetSize(18,18)
	close.text = close:CreateFontString(nil, "OVERLAY")
	close.text:SetPixelFont()
	close.text:SetText('x')
	close.text:SetPoint("CENTER", 0, 0)
	close:SetScript("OnMouseDown", function() self:Hide() end)
	close:SetScript("OnEnter", function(self) self.text:SetModifiedColor() end)
	close:SetScript("OnLeave", function(self) self.text:SetOriginalColor() end)
	title.close = close

	local search = CreateFrame("EditBox", nil, self)
	search:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 10, -5)
	search:SetPoint('TOPRIGHT', title, 'BOTTOMRIGHT', -10, -5)
	search:SetHeight(20)
	search:SetPixelFont()
	search:SetTemplate()
	search:SetAutoFocus(false)
	search:SetTextInsets(3, 0, 0, 0)
	search:SetText("Search")
	search:SetScript("OnEnterPressed", function(self)
		if strlen(strtrim(self:GetText())) == 0 then
			stAM:UpdateAddonList()
			self:SetText("Search")
		end
		self:ClearFocus()
	end)
	search:SetScript('OnEscapePressed', function(self)
		stAM:UpdateAddonList()
		self:SetText("Search")
		self:ClearFocus()
	end)
	search:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
	search:SetScript("OnTextChanged", function(self, userInput) stAM:UpdateSearchQuery(self, userInput) end)

	local addons = CreateFrame("Frame", nil, self)
	addons:SetHeight(self.perPage*23 + 15)
	addons:SetPoint('TOPLEFT', search, 'BOTTOMLEFT', 0, -5)
	addons:SetPoint('TOPRIGHT', search, 'BOTTOMRIGHT', 0, -5)
	addons:SetTemplate()
	addons.buttons = {}
	self.addons = addons

	local profiles = CreateFrame('Button', nil, self)
	profiles:SetSize(70, 20)
	profiles:SetTemplate()
	profiles.text = profiles:CreateFontString(nil, 'OVERLAY')
	profiles.text:SetPixelFont()
	profiles.text:SetPoint('CENTER')
	profiles.text:SetText('Profiles')
	profiles:SetPoint('TOPRIGHT', addons, 'BOTTOMRIGHT', 0, -10)
	profiles:Hide()
	self.profiles = profiles

	local reload = CreateFrame("Button", nil, self)
	reload:SetTemplate()
	reload:SetSize(70, 20)
	reload:SetPoint("TOPLEFT", addons, "BOTTOMLEFT", 0, -10)
	reload.text = reload:CreateFontString(nil, 'OVERLAY')
	reload.text:SetPixelFont()
	reload.text:SetText("Reload")
	reload.text:SetPoint("CENTER", 1, 0)
	reload:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
	reload:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
	reload:SetScript("OnClick", function() 
		if InCombatLockdown() then return end
		ReloadUI()
	end)
	self.reload = reload

	local paging = CreateFrame("Frame", nil, self)
	paging:SetTemplate()
	paging:SetSize(40, 20)
	paging:SetPoint('TOP', addons, 'BOTTOM', 0, -10)

	local prevPage = CreateFrame("Frame", nil, paging)
	local nextPage = CreateFrame("Frame", nil, paging)

	for i,b in pairs({prevPage, nextPage}) do
		b:SetSize(20, 20)
		b.text = b:CreateFontString(nil, 'OVERLAY')
		b.text:SetPixelFont()
		
		b:SetScript("OnMouseDown", function() end)
		b:SetScript("OnEnter", function(self) self.text:SetModifiedColor() end)
		b:SetScript("OnLeave", function(self) self.text:SetOriginalColor() end)

		if i == 1 then
			b:SetScript("OnMouseDown", function() 
				self.pageNum = self.pageNum - 1
				self:UpdateAddonList()
			end)
			b.text:SetText('<')
			b:SetPoint("LEFT", paging, "LEFT", 0, 0)
			b.text:SetPoint("LEFT", b, "LEFT", 8, 1)
		else
			b:SetScript("OnMouseDown", function() 
				self.pageNum = self.pageNum + 1
				self:UpdateAddonList()
			end)
			b.text:SetText('>')
			b:SetPoint("RIGHT", paging, "RIGHT", 0, 0)
			b.text:SetPoint("RIGHT", b, "RIGHT", -5, 1)
		end
	end
	
	self.prevPage = prevPage
	self.nextPage = nextPage

	for i=1, self.perPage do
		local button = CreateFrame("Button", self:GetName().."Page"..i, addons)
		button:SetTemplate()
		button:SetSize(22, 18)
		button:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
		button:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
		if i == 1 then
			button:SetPoint("TOPLEFT", addons, "TOPLEFT", 10, -10)
		else
			button:SetPoint("TOP", addons.buttons[i-1], "BOTTOM", 0, -5)
		end
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:SetPixelFont()
		button.text:SetPoint("LEFT", button, "RIGHT", 10, 0)
		button.text:SetPoint("TOP", button, "TOP")
		button.text:SetPoint("BOTTOM", button, "BOTTOM")
		button.text:SetPoint("RIGHT", addons, "RIGHT", -10, 0)
		button.text:SetJustifyH("LEFT")
		button.enabled = button:CreateTexture(nil, 'OVERLAY')
		button.enabled:SetInside(button)
		button.enabled:SetTexture(1, 1, 1)

		addons.buttons[i] = button
	end

	self:UpdateAddonList()

	self:SetHeight(title:GetHeight() + 5 + search:GetHeight() + 5  + addons:GetHeight() + 10 + profiles:GetHeight() + 10)

	tinsert(UISpecialFrames, self:GetName())
	self.loaded = true
end

stAM:RegisterEvent("PLAYER_ENTERING_WORLD")
stAM:SetScript("OnEvent", function(self, event, ...) self:Initialize(event, ...) end)

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stAM", "/staddon"
SlashCmdList["STADDONMANAGER"] = function() stAM:LoadWindow() end