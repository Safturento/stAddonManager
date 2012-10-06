local _, st = ...

local stam = CreateFrame("Frame", "stAddonManager", UIParent)

stam.pageNum = 0
stam.perPage = 10
stam.buttons = {}

function stam.Initialize()
	local menu = _G.GameMenuFrame
	local macros = _G.GameMenuButtonMacros
	local ratings = _G.GameMenuButtonRatings
	local logout = _G.GameMenuButtonLogout

	local addons = CreateFrame("Button", "GameMenuButtonAddons", menu, "GameMenuButtonTemplate")

	addons:SetPoint("TOP", ratings:IsShown() and ratings or macros, "BOTTOM", 0, -3)
	addons:SetSize(logout:GetWidth(), logout:GetHeight())
	addons:SetText("AddOns")

	logout:ClearAllPoints()
	logout:SetPoint("TOP", addons, "BOTTOM", 0, -3)

	addons:SetScript("OnClick", stam.LoadWindow)
end

function stam.UpdateAddonList()
	for i = 1, stam.perPage do
		local addonIndex = (stam.pageNum*stam.perPage) + i
		local page = stam.buttons[i]

		if stam.pageNum <= 0 then
			stam.prevPage:Hide()
		else
			stam.prevPage:Show()
		end

		if (stam.pageNum+1)*stam.perPage >= GetNumAddOns() then
			stam.nextPage:Hide()
		else
			stam.nextPage:Show()
		end

		if addonIndex <= GetNumAddOns() then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIndex)
			page.text:SetText(title)
			page:Show()

			if enabled then
				page.enabled:SetVertexColor(0.3, 1, 0.3, 0.5)
			elseif loadable then
				page.enabled:SetVertexColor(1, 0.8, 0, 0.5)
			else
				page.enabled:SetVertexColor(1, 0.3, 0.3, 0.5)
			end
			page:SetScript("OnMouseDown", function(self)
				if enabled then
					DisableAddOn(name)
				else
					EnableAddOn(name)
				end
				stam.UpdateAddonList()
			end)
		else
			page:Hide()
		end
	end
end

function stam.LoadWindow()
	if GameMenuFrame:IsShown() then GameMenuFrame:Hide() end
	if stam.loaded then ToggleFrame(stam) return end

	local titleBar = CreateFrame("Frame", nil, stam)
	stam:SetSize(225, 10 + stam.perPage * 25 + 40)
	titleBar:SetSize(stam:GetWidth(), 20)

	titleBar:SetPoint("CENTER", UIParent, "CENTER", 0, stam:GetHeight()/2)
	stam:SetPoint("TOP", titleBar, "BOTTOM", 0, -3)

	stam:SetTemplate("Transparent")
	titleBar:SetTemplate()

	titleBar.text = titleBar:CreateFontString(nil, "OVERLAY")
	titleBar.text:SetPoint("CENTER")
	titleBar.text:SetPixelFont()
	titleBar.text:SetText("stAddonManager")

	titleBar:SetMovable(true)
	titleBar:EnableMouse(true)
	titleBar:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	titleBar:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

	local close = CreateFrame("Button", nil, titleBar)
	close:SetPoint("RIGHT", -3, 0)
	close:SetSize(18,18)
	local text = close:CreateFontString(nil, "OVERLAY")
	text:SetPixelFont()
	text:SetText('x')
	text:SetPoint("CENTER", 0, 0)
	close.text = text
	close:SetScript("OnMouseDown", function() stam:Hide() end)
	close:SetScript("OnEnter", function() text:SetModifiedColor() end)
	close:SetScript("OnLeave", function() text:SetOriginalColor() end)
	titleBar.close = close

	local paging = CreateFrame("Frame", nil, stam)
	paging:SetTemplate()
	paging:SetSize(40, 20)
	paging:SetPoint("BOTTOM", stam, "BOTTOM", 0, 10)

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
				stam.pageNum = stam.pageNum - 1
				stam.UpdateAddonList()
			end)
			b.text:SetText('<')
			b:SetPoint("LEFT", paging, "LEFT", 0, 0)
			b.text:SetPoint("LEFT", b, "LEFT", 8, 1)
		else
			b:SetScript("OnMouseDown", function() 
				stam.pageNum = stam.pageNum + 1
				stam.UpdateAddonList()
			end)
			b.text:SetText('>')
			b:SetPoint("RIGHT", paging, "RIGHT", 0, 0)
			b.text:SetPoint("RIGHT", b, "RIGHT", -5, 1)
		end
	end
	
	stam.prevPage = prevPage
	stam.nextPage = nextPage

	local prev
	for i=1, stam.perPage do
		local button = CreateFrame("Frame", stam:GetName().."Page"..i, stam)
		button:SetTemplate(nil, true)
		button:SetSize(20, 20)
		button:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
		button:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
		if i == 1 then
			button:SetPoint("TOPLEFT", stam, "TOPLEFT", 10, -10)
		else
			button:SetPoint("TOP", stam.buttons[i-1], "BOTTOM", 0, -5)
		end
		button.text = button:CreateFontString(nil, 'OVERLAY')
		button.text:SetPixelFont()
		button.text:SetPoint("LEFT", button, "RIGHT",10, 0)
		button.text:SetPoint("TOP", button, "TOP")
		button.text:SetPoint("BOTTOM", button, "BOTTOM")
		button.text:SetPoint("RIGHT", stam, "RIGHT", -10, 0)
		button.text:SetJustifyH("LEFT")
		button.enabled = button:CreateTexture(nil, 'OVERLAY')
		button.enabled:SetInside(button)
		button.enabled:SetTexture(st.blankTex)

		stam.buttons[i] = button
	end


	reload = CreateFrame("Button", nil, stam)
	reload:SetTemplate()
	reload:SetSize(30, 20)
	reload:SetPoint("BOTTOMLEFT", stam, "BOTTOMLEFT", 10, 10)
	reload.text = reload:CreateFontString(nil, 'OVERLAY')
	reload.text:SetPixelFont()
	reload.text:SetText("RL")
	reload.text:SetPoint("CENTER", 1, 0)
	reload:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
	reload:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
	reload:SetScript("OnClick", function() 
		if InCombatLockdown() then return end
		ReloadUI()
	end)
	stam.reload = reload

	stam.UpdateAddonList()

	tinsert(UISpecialFrames, stam:GetName())
	stam.loaded = true
end

stam:RegisterEvent("PLAYER_ENTERING_WORLD")
stam:SetScript("OnEvent", stam.Initialize)

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stam", "/staddon"
SlashCmdList["STADDONMANAGER"] = stam.LoadWindow