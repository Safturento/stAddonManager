local addon, st = ...

---------------------------------------------------------
-- Pulling in some Tukui functions for easier skinning --
---------------------------------------------------------
st.font = { format('[[Interface\AddOns\%s\media\visitor.TTF]]', addon), 12, "MONOCHROMEOUTLINE" }
st.barTex = format('[[Interface\AddOns\%s\media\normTex.tga]]', addon)
st.blankTex = format('[[Interface\AddOns\%s\media\blankTex.tga]]', addon)
st.glowTex = format('[[Interface\AddOns\%s\media\glowTex.tga]]', addon)
st.bordercolor = {0.2, 0.2, 0.2}
st.backdropcolor = {0.05, 0.05, 0.05}

if Tukui then
	local C = Tukui[2]
	st.font = { C.media.pixelfont, 12, "MONOCHROMEOUTLINE" }
	st.barTex = C.media.normTex
	st.backdropcolor = C.general.backdropcolor
	st.bordercolor = C.general.bordercolor
end

local function RegisterEvents(self, events)
	if not type(events) == 'table' then error('Events must be passed as a table') return end

	for _,event in pairs(events) do
		self:RegisterEvent(event)
	end
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
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


local function SetPixelFont(text)
	text:SetFont(unpack(st.font))
	text:SetShadowOffset(0,0)
end

local function CreateBackdrop(f, t, tex)
	if f.backdrop then return end
	if not t then t = "Default" end

	local b = CreateFrame("Frame", nil, f)
	b:Point("TOPLEFT", -2 + inset, 2 - inset)
	b:Point("BOTTOMRIGHT", 2 - inset, -2 + inset)
	b:SetTemplate(t, tex)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end
	
	f.backdrop = b
end

local function SetTemplate(f, t, tex)
	local texture = tex and st.barTex or st.blankTex

	f:SetBackdrop({
	  bgFile = texture, 
	  edgeFile = st.blankTex, 
	  tile = false, tileSize = 0, edgeSize = 1,
	})

	if not noinset and not f.isInsetDone then
		f.insettop = f:CreateTexture(nil, "BORDER")
		f.insettop:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insettop:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, -1)
		f.insettop:SetHeight(1)
		f.insettop:SetTexture(0,0,0)	
		f.insettop:SetDrawLayer("BORDER", -7)
		
		f.insetbottom = f:CreateTexture(nil, "BORDER")
		f.insetbottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, -1)
		f.insetbottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
		f.insetbottom:SetHeight(1)
		f.insetbottom:SetTexture(0,0,0)	
		f.insetbottom:SetDrawLayer("BORDER", -7)
		
		f.insetleft = f:CreateTexture(nil, "BORDER")
		f.insetleft:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 1)
		f.insetleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, -1)
		f.insetleft:SetWidth(1)
		f.insetleft:SetTexture(0,0,0)
		f.insetleft:SetDrawLayer("BORDER", -7)
		
		f.insetright = f:CreateTexture(nil, "BORDER")
		f.insetright:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1, 1)
		f.insetright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, -1)
		f.insetright:SetWidth(1)
		f.insetright:SetTexture(0,0,0)	
		f.insetright:SetDrawLayer("BORDER", -7)

		f.insetinsidetop = f:CreateTexture(nil, "BORDER")
		f.insetinsidetop:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsidetop:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, 1)
		f.insetinsidetop:SetHeight(1)
		f.insetinsidetop:SetTexture(0,0,0)	
		f.insetinsidetop:SetDrawLayer("BORDER", -7)
		
		f.insetinsidebottom = f:CreateTexture(nil, "BORDER")
		f.insetinsidebottom:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
		f.insetinsidebottom:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
		f.insetinsidebottom:SetHeight(1)
		f.insetinsidebottom:SetTexture(0,0,0)	
		f.insetinsidebottom:SetDrawLayer("BORDER", -7)
		
		f.insetinsideleft = f:CreateTexture(nil, "BORDER")
		f.insetinsideleft:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
		f.insetinsideleft:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", -1, 1)
		f.insetinsideleft:SetWidth(1)
		f.insetinsideleft:SetTexture(0,0,0)
		f.insetinsideleft:SetDrawLayer("BORDER", -7)
		
		f.insetinsideright = f:CreateTexture(nil, "BORDER")
		f.insetinsideright:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
		f.insetinsideright:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, 1)
		f.insetinsideright:SetWidth(1)
		f.insetinsideright:SetTexture(0,0,0)	
		f.insetinsideright:SetDrawLayer("BORDER", -7)

		f.isInsetDone = true
	end
	local r, g, b = unpack(st.backdropcolor)
	local a = t == "Transparent" and 0.8 or 1
	f:SetBackdropColor(r, g, b, a)
	r, g, b = unpack(st.bordercolor)
	f:SetBackdropBorderColor(r, g, b)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then obj:ClearAllPoints() end
	
	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function CreateBackdrop(f, t, tex)
	if f.backdrop then return end
	if not t then t = "Default" end

	local b = CreateFrame("Frame", nil, f)
	b:SetPoint("TOPLEFT", -2 + inset, 2 - inset)
	b:SetPoint("BOTTOMRIGHT", 2 - inset, -2 + inset)
	b:SetTemplate(t, tex)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end
	
	f.backdrop = b
end

local function CreateShadow(f, t)
	if f.shadow then return end
			
	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -3, 3)
	shadow:SetPoint("BOTTOMLEFT", -3, -3)
	shadow:SetPoint("TOPRIGHT", 3, 3)
	shadow:SetPoint("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop( { 
		edgeFile = C["media"].glowTex, edgeSize = 3,
		insets = {left = 5, right = 5, top = 5, bottom = 5},
	})
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	f.shadow = shadow
end

local function SetModifiedColor(self)	
	local color = RAID_CLASS_COLORS[select(2, UnitClass('player'))]
	if self.SetTextColor then
		self:SetTextColor(color.r, color.g, color.b)
	else
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	end
end

local function SetOriginalColor(self)
	if self.SetTextColor then
		self:SetTextColor(1,1,1)
	else
		self:SetBackdropBorderColor(unpack(st.bordercolor))
	end
end


local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
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

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.RegisterEvents then mt.RegisterEvents = RegisterEvents end
	if not object.SetPixelFont then mt.SetPixelFont = SetPixelFont end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.SetModifiedColor then mt.SetModifiedColor = SetModifiedColor end
	if not object.SetOriginalColor then mt.SetOriginalColor = SetOriginalColor end
	if not object.Kill then mt.Kill = Kill end
	if not object.StripTextures then mt.StripTextures = StripTextures end

end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end