local st = ...
------------------------------------------------------
-- MEDIA & CONFIG ------------------------------------
------------------------------------------------------
local font = { Tukui[2].media.pixelfont or [[Interface\AddOns\stAddonManager\media\SEMPRG__.TTF]], 8, "MONOCHROMEOUTLINE" }
local barTex = Tukui[2].media.normTex or [[Interface\AddOns\stAddonManager\media\normTex.tga]]
local blankTex = [[Interface\AddOns\stAddonManager\media\blankTex.tga]]
local glowTex = [[Interface\AddOns\stAddonManager\media\glowTex.tga]]

local bordercolor = Tukui[2].general.bordercolor or {0, 0, 0, 1}
local backdropcolor = Tukui[2].general.backdropcolor or {0.05, 0.05, 0.05, 0.9}
local backdrop = {
	bgFile = blankTex, 
	edgeFile =  blankTex, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = 1, right = 1, top = 1, bottom = 1},
}


------------------------------------------------------
-- INITIAL FRAME CREATION ----------------------------
------------------------------------------------------
local stam = CreateFrame("Frame", "stAddonManager", UIParent)

stam.pageNum = 0
stam.perPage = 14
stam.pages = {}

function stam.UpdateAddonList()
	for i = 1, stam.perPage do
		local addonIndex = (stam.pageNum*stam.perPage) + i
		local page = stam.pages[i]

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
				page.enabled:SetVertexColor(0, 1, 0, 0.05)
				-- page.enabled:SetGradientAlpha("VERTICAL", 0/255, 255/255, 0/255, .2, 0, 0, 0, 0)
			elseif loadable then
				page.enabled:SetVertexColor(1, 0.8, 0, 0.15)
				-- page.enabled:SetGradientAlpha("VERTICAL", 255/255, 180/255, 0/255, .15, 0, 0, 0, 0)
			else
				page.enabled:SetVertexColor(1, 0, 0, 0.05)
				-- page.enabled:SetGradientAlpha("VERTICAL", 255/255, 0/255, 0/255, .2, 0, 0, 0, 0)
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
	if stam.loaded then ToggleFrame(stam) return end

	local titleBar = CreateFrame("Frame", nil, stam)
	stam:SetSize(200, 400)
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
	paging:SetPoint("BOTTOM", stam, "BOTTOM", 0, 12)

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
		local page = CreateFrame("Frame", stam:GetName().."Page"..i, stam)
		page:SetTemplate(nil, true)
		page:SetSize(stam:GetWidth()-20, 20)
		page:SetScript("OnEnter", function(self) self:SetModifiedColor() end)
		page:SetScript("OnLeave", function(self) self:SetOriginalColor() end)
		if i == 1 then
			page:SetPoint("TOP", stam, "TOP", 0, -10)
		else
			page:SetPoint("TOP", stam.pages[i-1], "BOTTOM", 0, -5)
		end
		page.text = page:CreateFontString(nil, 'OVERLAY')
		page.text:SetPixelFont()
		page.text:SetInside(page)
		page.enabled = page:CreateTexture(nil, 'OVERLAY')
		page.enabled:SetInside(page)
		page.enabled:SetTexture(blankTex)

		stam.pages[i] = page
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

	stam.loaded = true
end

SLASH_STADDONMANAGER1, SLASH_STADDONMANAGER2, SLASH_STADDONMANAGER3 = "/staddonmanager", "/stam", "/staddon"
SlashCmdList["STADDONMANAGER"] = stam.LoadWindow