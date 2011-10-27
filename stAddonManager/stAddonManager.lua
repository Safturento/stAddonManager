------------------------------------------------------
-- MEDIA & CONFIG ------------------------------------
------------------------------------------------------
local font = { [[Interface\AddOns\stAddonManager\media\SEMPRG__.TTF]], 8, "MONOCHROMEOUTLINE" }
local barTex = [[Interface\AddOns\stAddonManager\media\normTex.tga]]
local blankTex = [[Interface\AddOns\stAddonManager\media\blankTex.tga]]
local glowTex = [[Interface\AddOns\stAddonManager\media\glowTex.tga]]

local bordercolor = {0, 0, 0, 1}
local backdropcolor = {0.05, 0.05, 0.05, 0.9}
local backdrop = {
	bgFile = blankTex, 
	edgeFile =  blankTex, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = 1, right = 1, top = 1, bottom = 1},
}

------------------------------------------------------
-- INITIAL FRAME CREATION ----------------------------
------------------------------------------------------
stAddonManager = CreateFrame("Frame", "stAddonManager", UIParent)
stAddonManager.header = CreateFrame("Frame", "stAddonmanager_Header", stAddonManager)

stAddonManager.header:SetPoint("CENTER", UIParent, "CENTER", 0, 50)
stAddonManager:SetPoint("TOP", stAddonManager.header, "TOP", 0, 0)

------------------------------------------------------
-- FUNCTIONS -----------------------------------------
------------------------------------------------------
local function SkinFrame(frame, shadowed)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(unpack(backdropcolor))
	frame:SetBackdropBorderColor(unpack(bordercolor))
	
	if shadowed and not frame.shadow then
		local shadow = CreateFrame("Frame", nil, frame)
		shadow:SetFrameLevel(frame:GetFrameLevel())
		shadow:SetFrameStrata(frame:GetFrameStrata())
		shadow:SetPoint("TOPLEFT", -3, 3)
		shadow:SetPoint("BOTTOMLEFT", -3, -3)
		shadow:SetPoint("TOPRIGHT", 3, 3)
		shadow:SetPoint("BOTTOMRIGHT", 3, -3)
		shadow:SetBackdrop( { 
			edgeFile = glowTex, edgeSize = 3,
			insets = {left = 5, right = 5, top = 5, bottom = 5},
		})
		shadow:SetBackdropColor(0, 0, 0, 0)
		shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		frame.shadow = shadow
	end
end

local function CreateBackdrop(frame, shadowed)
	if not frame.backdrop then
		local backdrop = CreateFrame("Frame", nil, frame)
		backdrop:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 1, 1)
		backdrop:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -1, -1)
		SkinFrame(backdrop, shadowed)
		backdrop:SetFrameLevel(frame:GetFrameLevel()>0 and frame:GetFrameLevel()-1 or 0)
		backdrop:SetFrameStrata(frame:GetFrameStrata())
		
		frame.backdrop = backdrop
	end
end

local function StripTextures(object, kill)
	for i=1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region:GetObjectType() == "Texture" then
			if kill then
				region:Kill()
			else
				region:SetTexture(nil)
			end
		end
	end		
end

local function SkinScrollBar(frame, thumbTrim)
	if _G[frame:GetName().."BG"] then _G[frame:GetName().."BG"]:SetTexture(nil) end
	if _G[frame:GetName().."Track"] then  _G[frame:GetName().."Track"]:SetTexture(nil) end
	
	if _G[frame:GetName().."Top"] then
		_G[frame:GetName().."Top"]:SetTexture(nil)
		_G[frame:GetName().."Bottom"]:SetTexture(nil)
		_G[frame:GetName().."Middle"]:SetTexture(nil)
	end

	local uScroll = _G[frame:GetName().."ScrollUpButton"]
	local dScroll = _G[frame:GetName().."ScrollDownButton"]
	local track = _G[frame:GetName().."Track"]
	
	if uScroll and dScroll then
		StripTextures(uScroll)		
		StripTextures(dScroll)
		dScroll:EnableMouse(false)
		uScroll:EnableMouse(false)
		
		if not frame.trackbg then
			frame.trackbg = CreateFrame("Frame", nil, frame)
			frame.trackbg:SetPoint("TOPLEFT", uScroll, "TOPLEFT", 0, 0)
			frame.trackbg:SetPoint("BOTTOMRIGHT", dScroll, "BOTTOMRIGHT", 0, 0)
			SkinFrame(frame.trackbg)
		end
		
		if frame:GetThumbTexture() then
			frame:GetThumbTexture():SetTexture(nil)
			if not frame.thumbbg then
				frame.thumbbg = CreateFrame("Frame", nil, frame)
				frame.thumbbg:SetPoint("TOPLEFT", frame:GetThumbTexture(), "TOPLEFT", 2, 14)
				frame.thumbbg:SetPoint("BOTTOMRIGHT", frame:GetThumbTexture(), "BOTTOMRIGHT", -2, -14)
				SkinFrame(frame.thumbbg)
				if frame.trackbg then
					frame.thumbbg:SetFrameLevel(frame.trackbg:GetFrameLevel()+2)
				end
			end
		end	
	end	
end

function stAddonManager:UpdateAddonList(queryString)
	local addons = {}
	for i=1, GetNumAddOns() do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
		local lwrTitle, lwrName = strlower(title), strlower(name)
		if (queryString and (strfind(lwrTitle,strlower(queryString)) or strfind(lwrName,strlower(queryString)))) or (not queryString) then
			addons[i] = {}
			addons[i].name = name
			addons[i].title = title
			addons[i].notes = notes
			addons[i].enabled = enabled
		end
	end
	return addons
end

local function LoadWindow()
	if not stAddonManager.Loaded then
		local window = stAddonManager
		local header = window.header
		
		tinsert(UISpecialFrames,window:GetName());
		
		window:SetSize(300,300)
		header:SetSize(300,20)
		
		SkinFrame(window)
		SkinFrame(header)
		
		header:EnableMouse(true)
		header:SetMovable(true)
		header:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		header:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
		
		local hTitle = stAddonManager.header:CreateFontString(nil, "OVERLAY")
		hTitle:SetFont(unpack(font))
		hTitle:SetPoint("CENTER")
		hTitle:SetText("|cff00aaffst|rAddonManager")
		header.title = hTitle 

		local close = CreateFrame("Button", nil, header)
		close:SetPoint("RIGHT", header, "RIGHT", 0, 0)
		close:SetFrameLevel(header:GetFrameLevel()+2)
		close:SetSize(20, 20)
		close.text = close:CreateFontString(nil, "OVERLAY")
		close.text:SetFont(unpack(font))
		close.text:SetText("x")
		close.text:SetPoint("CENTER", close, "CENTER", 0, 0)
		close:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		close:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		close:SetScript("OnClick", function() window:Hide() end)
		header.close = close
		
		--Create scroll frame (God damn these things are a pain)
		local scrollFrame = CreateFrame("ScrollFrame", window:GetName().."_ScrollFrame", window, "UIPanelScrollFrameTemplate")
		scrollFrame:SetPoint("TOPLEFT", header, "TOPLEFT", 10, -50)
		scrollFrame:SetWidth(window:GetWidth()-43)
		SkinFrame(scrollFrame)
		scrollFrame:SetHeight(window:GetHeight()-60)
		SkinScrollBar(_G[window:GetName().."_ScrollFrameScrollBar"])
		scrollFrame:SetFrameLevel(window:GetFrameLevel()+1)
		
		scrollFrame.Anchor = CreateFrame("Frame", window:GetName().."_ScrollAnchor", scrollFrame)
		scrollFrame.Anchor:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, -3)
		scrollFrame.Anchor:SetWidth(scrollFrame:GetWidth())
		scrollFrame.Anchor:SetHeight(scrollFrame:GetHeight())
		scrollFrame.Anchor:SetFrameLevel(scrollFrame:GetFrameLevel()+1)
		scrollFrame:SetScrollChild(scrollFrame.Anchor)
	
		--Load up addon information
		stAddonManager.AllAddons = stAddonManager:UpdateAddonList()
		stAddonManager.FilteredAddons = stAddonManager:UpdateAddonList()
		stAddonManager.showEnabled = true
		stAddonManager.showDisabled = true
		
		stAddonManager.Buttons = {}
		
		--Create initial list
		for i, addon in pairs(stAddonManager.AllAddons) do
			local button = CreateFrame("Frame", nil, scrollFrame.Anchor)
			button:SetFrameLevel(scrollFrame.Anchor:GetFrameLevel() + 1)
			button:Size(16, 16)
			SkinFrame(button)
			if addon.enabled then
				button:SetBackdropColor(0/255, 170/255, 255/255)
			end
			
			if i == 1 then
				button:SetPoint("TOPLEFT", scrollFrame.Anchor, "TOPLEFT", 5, -5)
			else
				button:SetPoint("TOP", stAddonManager.Buttons[i-1], "BOTTOM", 0, -5)
			end
			button.text = button:CreateFontString(nil, "OVERLAY")
			button.text:SetFont(unpack(font))
			button.text:SetJustifyH("LEFT")
			button.text:SetPoint("LEFT", button, "RIGHT", 8, 0)
			button.text:SetPoint("RIGHT", scrollFrame.Anchor, "RIGHT", 0, 0)
			button.text:SetText(addon.title)
			
			button:SetScript("OnEnter", function(self)
				--tooltip stuff
			end)
			
			button:SetScript("OnMouseDown", function(self)
				if addon.enabled then
					self:SetBackdropColor(unpack(backdropcolor))
					DisableAddOn(addon.name)
					addon.enabled = false
				else
					self:SetBackdropColor(0/255, 170/255, 255/255)
					EnableAddOn(addon.name)
					addon.enabled = true
				end
			end)
			
			stAddonManager.Buttons[i] = button
		end
		
		local function UpdateList(AddonsTable)
			--Start off by hiding all of the buttons
			for _, b in pairs(stAddonManager.Buttons) do b:Hide() end
			
			local bIndex = 1
			for i, addon in pairs(AddonsTable) do
				local button = stAddonManager.Buttons[bIndex]
				button:Show()
				if addon.enabled then
					button:SetBackdropColor(0/255, 170/255, 255/255)
				else
					button:SetBackdropColor(unpack(backdropcolor))
				end
				
				button:SetScript("OnMouseDown", function(self)
					if addon.enabled then
						self:SetBackdropColor(unpack(backdropcolor))
						DisableAddOn(addon.name)
						addon.enabled = false
					else
						self:SetBackdropColor(0/255, 170/255, 255/255)
						EnableAddOn(addon.name)
						addon.enabled = true
					end
				end)
				
				button.text:SetText(addon.title)
				bIndex = bIndex+1
			end
		end
		
		--Search Bar
		local searchBar = CreateFrame("EditBox", window:GetName().."_SearchBar", window)
		searchBar:SetFrameLevel(window:GetFrameLevel()+1)
		searchBar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -5)
		searchBar:SetWidth(200)
		searchBar:SetHeight(20)
		SkinFrame(searchBar)
		searchBar:SetFont(unpack(font))
		searchBar:SetText("Search")
		searchBar:SetAutoFocus(false)
		searchBar:SetTextInsets(3, 0, 0 ,0)
		searchBar:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
		searchBar:SetScript("OnEscapePressed", function(self) searchBar:SetText("Search") UpdateList(stAddonManager.AllAddons) searchBar:ClearFocus() end)
		searchBar:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
		searchBar:SetScript("OnTextChanged", function(self, input)
			if input then
				stAddonManager.FilteredAddons = stAddonManager:UpdateAddonList(self:GetText())
				UpdateList(stAddonManager.FilteredAddons)
			end
		end)
		
		local sbClear = CreateFrame("Button", nil, searchBar)
		sbClear:SetPoint("RIGHT", searchBar, "RIGHT", 0, 0)
		sbClear:SetFrameLevel(searchBar:GetFrameLevel()+2)
		sbClear:SetSize(20, 20)
		sbClear.text = sbClear:CreateFontString(nil, "OVERLAY")
		sbClear.text:SetFont(unpack(font))
		sbClear.text:SetText("x")
		sbClear.text:SetPoint("CENTER", sbClear, "CENTER", 0, 0)
		sbClear:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		sbClear:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		sbClear:SetScript("OnClick", function(self) searchBar:SetText("Search") UpdateList(stAddonManager.AllAddons) searchBar:ClearFocus() end)
		searchBar.clear = sbClear

		local reloadButton = CreateFrame("Button", window:GetName().."_ReloadUIButton", window)
		reloadButton:SetPoint("LEFT", searchBar, "RIGHT", 5, 0)
		reloadButton:SetWidth(window:GetWidth()-25-searchBar:GetWidth())
		reloadButton:SetHeight(searchBar:GetHeight())
		reloadButton.text = reloadButton:CreateFontString(nil, "OVERLAY")
		reloadButton.text:SetPoint("CENTER")
		reloadButton.text:SetFont(unpack(font))
		reloadButton.text:SetText("ReloadUI")
		reloadButton:SetScript("OnEnter", function(self) self.text:SetTextColor(0/255, 170/255, 255/255) end)
		reloadButton:SetScript("OnLeave", function(self) self.text:SetTextColor(255/255, 255/255, 255/255) end)
		reloadButton:SetScript("OnClick", function(self)
			if InCombatLockdown() then return end
			ReloadUI()
		end)
		SkinFrame(reloadButton)
		
		stAddonManager.Loaded = true
	else
		stAddonManager:Show()
	end
end

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stam", "/staddon"
SlashCmdList["STADDONMANAGER"] = LoadWindow