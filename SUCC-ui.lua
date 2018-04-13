-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

-- SUCC-ui essentials
function SUCC_uiDefaults()
	local a = {}
	a.stancePages = {}
	a.multiPages = {}
	a.stancePages[0] = 3 -- Humanoid form
	a.stancePages[1] = 5 -- battle stance, bear, stealh
	a.stancePages[2] = 5 -- defensive stance, seal
	a.stancePages[3] = 6 -- cat
	a.stancePages[4] = 7 -- travel
	a.stancePages[5] = 8 -- mind controlled
	a.multiPages[1] = 11
	a.multiPages[2] = 12
	return a
end

local function SUCC_uiSetHw(a, b, c) -- frame, height, width
	a:SetHeight(b)
	a:SetWidth(c)
end

local function SUCC_uiRemoveFrame(a) -- frame
	if (a:GetObjectType() ~= 'Texture') then
		a:SetScript('OnEvent', nil)
		a:UnregisterAllEvents()
	end
	a:ClearAllPoints()
	a:SetPoint('BOTTOMRIGHT', UIParent, 'TOPLEFT', -100, 100)
	a:SetParent(nil)
	a:Hide()
end

local function SUCC_uiSetupButton(a, b, c, d, e, f) -- button, parent, h/w, nt, nth/w, prev
	if b then a:SetParent(b) end
	if c then SUCC_uiSetHw(a, c, c) end
	a:ClearAllPoints()
	a:SetNormalTexture(d)
	a:SetFrameLevel(5)
	SUCC_uiSetHw(a:GetNormalTexture(), e, e)
	a:GetNormalTexture():SetDrawLayer('OVERLAY')
	a:GetPushedTexture():SetDrawLayer('OVERLAY')
	a:GetCheckedTexture():SetDrawLayer('ARTWORK')
	getglobal(a:GetName()..'HotKey'):SetDrawLayer('OVERLAY')
	getglobal(a:GetName()..'Cooldown'):SetFrameLevel(5)
	if f then
		a:SetPoint(unpack(f))
	else
		a:SetPoint('TOPLEFT', 0, 0)
	end
end

local function SUCC_uiReplace(a)
	local function _xpBarSetup(k, l) -- frame, parent
		k:ClearAllPoints()
		k:SetParent(l)
		SUCC_uiSetHw(k, 13, 418)
		k:SetPoint('BOTTOM', 0, 0)
	end
	local function _stanceButtonSetup(k, l)
		local prev = nil
		if l then prev = {'LEFT', l, 'RIGHT', 6, 0} end
		SUCC_uiSetupButton(k, a.stanceBar, nil, a.texturePath.slot, 54, prev)
	end

	-- globals
	UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil
	NUM_MULTIBAR_BUTTONS = 10
	NUM_ACTIONBAR_BUTTONS = 10
	NUM_BONUS_ACTION_SLOTS = NUM_ACTIONBAR_BUTTONS
	BONUSACTIONBAR_XPOS = 0
	BONUSACTIONBAR_YPOS = 37
	NUM_ACTIONBAR_PAGES = 1
	LEFT_ACTIONBAR_PAGE = a.settings.multiPages[1]
	RIGHT_ACTIONBAR_PAGE = a.settings.multiPages[2]

	-- removing unwanted frames
	for i=0, 3 do
		SUCC_uiRemoveFrame(getglobal('MainMenuXPBarTexture'..i))
	end
	SUCC_uiRemoveFrame(BonusActionBarTexture0)
	SUCC_uiRemoveFrame(BonusActionBarTexture1)
	SUCC_uiRemoveFrame(MainMenuBarMaxLevelBar)
	SUCC_uiRemoveFrame(MultiBarRightButton11)
	SUCC_uiRemoveFrame(MultiBarRightButton12)
	SUCC_uiRemoveFrame(MultiBarLeftButton11)
	SUCC_uiRemoveFrame(MultiBarLeftButton12)
	SUCC_uiRemoveFrame(BonusActionButton11)
	SUCC_uiRemoveFrame(BonusActionButton12)
	SUCC_uiRemoveFrame(MultiBarBottomRight)
	SUCC_uiRemoveFrame(MultiBarBottomLeft)
	SUCC_uiRemoveFrame(MainMenuBar)

	-- moving default frames
	_xpBarSetup(MainMenuExpBar, a.xpBar)
	_xpBarSetup(ReputationWatchBar, a.xpBar)
	ExhaustionTick:SetParent(MainMenuExpBar)
	MainMenuBarOverlayFrame:SetFrameStrata('MEDIUM')
	MainMenuBarOverlayFrame:SetFrameLevel(3)
	ReputationWatchBar:SetFrameLevel(4)
	MainMenuExpBar:SetFrameLevel(2)
	ReputationWatchStatusBar:ClearAllPoints()
	ReputationWatchStatusBar:SetAllPoints()
	MainMenuExpBar:SetScript('OnEnter', function()
		local k, _, _, _, _ = GetWatchedFactionInfo()
		if (k) then
			ReputationWatchBar:Show()
			MainMenuExpBar:Hide()
		else
			TextStatusBar_UpdateTextString()
			ShowTextStatusBarText(this)
			ExhaustionTick.timer = 1
			GameTooltip_AddNewbieTip(XPBAR_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_XPBAR, 1)
			GameTooltip.canAddRestStateLine = 1
		end
	end)
	ReputationWatchBar:SetScript('OnLeave', function()
		ReputationWatchBar:Hide()
		MainMenuExpBar:Show()
	end)
	BonusActionBarFrame:SetParent(a.actionBar)
	BonusActionBarFrame:ClearAllPoints()
	BonusActionBarFrame:SetAllPoints()
	MultiBarRight:ClearAllPoints()
	MultiBarRight:SetPoint('BOTTOMRIGHT', -3, 45)
	MultiBarLeft:ClearAllPoints()
	MultiBarLeft:SetPoint('TOPRIGHT', MultiBarRight, 'TOPLEFT', -4, 0)

	-- reuse action buttons and bars
	local z, y, x, w, v, u = {}, {}, {}, {}, {}, {}
	for i=1, NUM_ACTIONBAR_BUTTONS do
		w[i] = getglobal('ActionButton'..i)
		x[i] = getglobal('BonusActionButton'..i)
		y[i] = getglobal('MultiBarLeftButton'..i)
		z[i] = getglobal('MultiBarRightButton'..i)
		local prev = {nil, nil, nil, nil}
		if i > 1 then
			prev[1] = {'LEFT', w[i-1], 'RIGHT', 4, 0}
			prev[2] = {'LEFT', x[i-1], 'RIGHT', 4, 0}
			prev[3] = {'TOP', y[i-1], 'BOTTOM', 0, -4}
			prev[4] = {'TOP', z[i-1], 'BOTTOM', 0, -4}
		end
		SUCC_uiSetupButton(w[i], a.actionBar.default, 37, a.texturePath.slot, 64,
		prev[1], 1)
		SUCC_uiSetupButton(x[i], nil, 37, a.texturePath.slot, 64, prev[2], 2)
		SUCC_uiSetupButton(y[i], nil, 37, a.texturePath.slot, 64, prev[3], 1)
		SUCC_uiSetupButton(z[i], nil, 37, a.texturePath.slot, 64, prev[4], 1)
	end
	for i=1, NUM_PET_ACTION_SLOTS do
		v[i] = getglobal('PetActionButton'..i)
		_stanceButtonSetup(v[i], v[i-1])
		getglobal('PetActionButton'..i..'AutoCast'):SetFrameLevel(5)
	end
	for i=1, NUM_SHAPESHIFT_SLOTS do
		u[i] = getglobal('ShapeshiftButton'..i)
		_stanceButtonSetup(u[i], u[i-1])
	end
	-- cooline addon additional settings, does't work for all screen resolutions and if using UI scale
	if cooline_theme then
		cooline_theme.width = 406
		cooline_theme.bgcolor = { 0, 0, 0, 0 }
		if cooline_settings then
			cooline_settings.x = 0
			-- no idea
			cooline_settings.y = -355
		end
	end
	print('|cFFF5A3FFSUCC-ui loaded.')
end

-- SUCC-ui variables
local SUCC_ui = {}
SUCC_ui.settings = SUCC_uiOptions or SUCC_uiDefaults()
SUCC_ui.texturePath = {}
SUCC_ui.texturePath.xp = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-xp-bar-regular-51232-1.0'
SUCC_ui.texturePath.slot = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-slot-exact-6440-1.0'
SUCC_ui.texturePath.slotBg = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-slot-empty-exact-6440-1.0'
SUCC_ui.texturePath.stanceBar = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-xp-bar-reduced-5123216-1.0'

-- SUCC_ui frames
-- xp bar
SUCC_ui.xpBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.xpBar:SetFrameLevel(5)
SUCC_ui.xpBar:SetWidth(604) SUCC_ui.xpBar:SetHeight(25)
SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
SUCC_ui.xpBar.textureMiddle = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.xpBar.textureMiddle:SetWidth(512) SUCC_ui.xpBar.textureMiddle:SetHeight(32)
SUCC_ui.xpBar.textureMiddle:SetPoint('BOTTOM', SUCC_ui.xpBar)
SUCC_ui.xpBar.textureMiddle:SetTexture(SUCC_ui.texturePath.xp)
-- stance or pet action bar
SUCC_ui.stanceBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.stanceBar:SetPoint('BOTTOMLEFT', SUCC_ui.xpBar, 'BOTTOMRIGHT', 10, 0)
SUCC_ui.stanceBar:SetHeight(38)
SUCC_ui.stanceBar:Hide()
SUCC_ui.stanceBar.textureLeft = SUCC_ui.stanceBar:CreateTexture(nil, 'ARTWORK')
SUCC_uiSetHw(SUCC_ui.stanceBar.textureLeft, 16, 48)
SUCC_ui.stanceBar.textureLeft:SetTexCoord(0.03125, 0.125, 0.5, 1)
SUCC_ui.stanceBar.textureLeft:SetPoint('BOTTOMRIGHT',SUCC_ui.stanceBar, 'BOTTOMLEFT', 11, 0)
SUCC_ui.stanceBar.textureLeft:SetTexture(SUCC_ui.texturePath.stanceBar)
SUCC_ui.stanceBar.textureRight = SUCC_ui.stanceBar:CreateTexture(nil, 'ARTWORK')
SUCC_uiSetHw(SUCC_ui.stanceBar.textureRight, 16, 48)
SUCC_ui.stanceBar.textureRight:SetTexCoord(0.875, 0.96875, 0.5, 1)
SUCC_ui.stanceBar.textureRight:SetPoint('BOTTOMLEFT',SUCC_ui.stanceBar, 'BOTTOMRIGHT', -11, 0)
SUCC_ui.stanceBar.textureRight:SetTexture(SUCC_ui.texturePath.stanceBar)
SUCC_ui.stanceBar.textureMiddle = SUCC_ui.stanceBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.stanceBar.textureMiddle:SetHeight(16)
SUCC_ui.stanceBar.textureMiddle:SetTexCoord(0.25, 0.55, 0.5, 1)
SUCC_ui.stanceBar.textureMiddle:SetPoint('BOTTOMLEFT', SUCC_ui.stanceBar, 11, 0)
SUCC_ui.stanceBar.textureMiddle:SetPoint('BOTTOMRIGHT', SUCC_ui.stanceBar, -11, 0)
SUCC_ui.stanceBar.textureMiddle:SetTexture(SUCC_ui.texturePath.stanceBar)
SUCC_ui.stanceBar.textureMark = {}
for i = 2, NUM_SHAPESHIFT_SLOTS do
	SUCC_ui.stanceBar.textureMark[i] = SUCC_ui.stanceBar:CreateTexture(nil, 'OVERLAY')
	SUCC_uiSetHw(SUCC_ui.stanceBar.textureMark[i], 16, 16)
	SUCC_ui.stanceBar.textureMark[i]:SetTexCoord(0, 0.03125, 0, 0.5)
	if i < 3 then
		SUCC_ui.stanceBar.textureMark[i]:SetPoint('BOTTOMLEFT', 25, -6)
	else
		SUCC_ui.stanceBar.textureMark[i]:SetPoint('LEFT', SUCC_ui.stanceBar.textureMark[i-1], 'RIGHT', 20, 0)
	end
	SUCC_ui.stanceBar.textureMark[i]:SetTexture(SUCC_ui.texturePath.stanceBar)
	SUCC_ui.stanceBar.textureMark[i]:Hide()
end
-- action bar
SUCC_ui.actionBar = CreateFrame('Frame', nil, UIParent)
SUCC_uiSetHw(SUCC_ui.actionBar, 37, 406)
SUCC_ui.actionBar:SetPoint('BOTTOM', 0, 20)
SUCC_ui.actionBar.default = CreateFrame('Frame', nil, SUCC_ui.actionBar)
SUCC_ui.actionBar.default:SetAllPoints()

-- SUCC_ui overrides
local OLD_PetActionBar_Update = PetActionBar_Update
PetActionBar_Update = function()
	OLD_PetActionBar_Update()
	local a
	if PetHasActionBar() then
		SUCC_ui.stanceBar:SetWidth((NUM_PET_ACTION_SLOTS-1)*36 + 30)
		for i = 2, NUM_PET_ACTION_SLOTS do
			SUCC_ui.stanceBar.textureMark[i]:Show()
		end
	end
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		a = getglobal('PetActionButton'..i)
		local _, _, b = GetPetActionInfo(i)
		if b then
			a:SetNormalTexture(SUCC_ui.texturePath.slot)
		else
			a:SetNormalTexture(SUCC_ui.texturePath.slotBg)
		end
	end
end

local OLD_ShowPetActionBar = ShowPetActionBar
ShowPetActionBar = function()
	OLD_ShowPetActionBar()
	if PetHasActionBar() and PetActionBarFrame.showgrid == 0 and (PetActionBarFrame.mode ~= "show") and not PetActionBarFrame.locked and not PetActionBarFrame.ctrlPressed then
		SUCC_ui.stanceBar:Show()
	end
end

local OLD_ReputationWatchBar_Update = ReputationWatchBar_Update
ReputationWatchBar_Update = function(newLevel)
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	OLD_ReputationWatchBar_Update(newLevel)
	if ( newLevel < MAX_PLAYER_LEVEL ) then
		ReputationWatchStatusBar:SetHeight(13)
		ReputationWatchBar:ClearAllPoints()
		ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar)
		ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1)
		ReputationWatchBarTexture0:Hide()
		ReputationWatchBarTexture1:Hide()
		ReputationWatchBarTexture2:Hide()
		ReputationWatchBarTexture3:Hide()
		ReputationWatchBar:Hide()
		MainMenuExpBar:Show()
	else
		SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
		ReputationWatchBar:Show()
		ReputationWatchStatusBar:SetHeight(13)
		ReputationWatchBar:ClearAllPoints()
		ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar)
		ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1)
		ReputationXPBarTexture0:Hide()
		ReputationXPBarTexture1:Hide()
		ReputationXPBarTexture2:Hide()
		ReputationXPBarTexture3:Hide()
		ExhaustionTick:Hide()
		MainMenuExpBar:Hide()
	end
end

local OLD_ActionButton_ShowGrid = ActionButton_ShowGrid
ActionButton_ShowGrid = function(button)
	if ( not button ) then
		button = this
	end
	OLD_ActionButton_ShowGrid(button)
	getglobal(button:GetName().."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0, 1)
end

local OLD_ActionButton_Update = ActionButton_Update
ActionButton_Update = function()
	OLD_ActionButton_Update()
	local texture = GetActionTexture(ActionButton_GetPagedID(this))
	if texture then
		this:SetNormalTexture(SUCC_ui.texturePath.slot)
		if ( this.isBonus ) then
			this.texture = texture
		end
	else
		this:SetNormalTexture(SUCC_ui.texturePath.slotBg)
	end
end

local OLD_ShapeshiftBar_Update = ShapeshiftBar_Update
ShapeshiftBar_Update = function()
	OLD_ShapeshiftBar_Update()
	local n = GetNumShapeshiftForms()
	if n > 0 then
		SUCC_ui.stanceBar:SetWidth((n-1)*36 + 30)
		for i = 2, n do
			SUCC_ui.stanceBar.textureMark[i]:Show()
		end
		SUCC_ui.stanceBar:Show()
	elseif not PetHasActionBar() then
		SUCC_ui.stanceBar:Hide()
	end
end

local OLD_ShowBonusActionBar = ShowBonusActionBar
ShowBonusActionBar = function()
	if BonusActionBarFrame.mode ~= "show" and BonusActionBarFrame.state ~= "top" then
		if SUCC_ui.actionBar.default:IsShown() then
			SUCC_ui.actionBar.default:Hide()
		end
	end
	OLD_ShowBonusActionBar()
end

local OLD_HideBonusActionBar = HideBonusActionBar
HideBonusActionBar = function()
	if ( BonusActionBarFrame:IsShown() ) then
		if not SUCC_ui.actionBar.default:IsShown() then
			SUCC_ui.actionBar.default:Show()
		end
	end
	OLD_HideBonusActionBar()
end

-- event watcher
local function SUCC_uiBarUpdate(n)
	if (IsShiftKeyDown()) then
		if (CURRENT_ACTIONBAR_PAGE == 1 or n) then
			CURRENT_ACTIONBAR_PAGE = SUCC_ui.settings.stancePages[GetBonusBarOffset()]
			ChangeActionBarPage()
		end
	else
		if ( CURRENT_ACTIONBAR_PAGE ~= 1 ) then
			CURRENT_ACTIONBAR_PAGE = 1
			ChangeActionBarPage()
		end
	end
end

local SUCC_uiWatcher = CreateFrame('Frame', nil)
SUCC_uiWatcher:RegisterEvent('ADDON_LOADED')
SUCC_uiWatcher:SetScript("OnEvent", function()
	if event == 'UPDATE_BONUS_ACTIONBAR' then
		SUCC_uiBarUpdate(1)
	elseif event == 'UPDATE_SHAPESHIFT_FORMS' then
		ShapeshiftBar_Update()
	elseif ( event == 'PET_BAR_UPDATE' or (event == 'UNIT_PET' and arg1 == 'player') ) then
		if PetHasActionBar() then
			SUCC_ui.stanceBar:Show()
		elseif GetNumShapeshiftForms() < 1 then
			SUCC_ui.stanceBar:Hide()
		end
	elseif event == 'ADDON_LOADED' and arg1 == 'SUCC-ui' then
		this:UnregisterEvent('ADDON_LOADED')
		this:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
		this:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
		this:RegisterEvent('PET_BAR_UPDATE')
		this:RegisterEvent('UNIT_PET')
		SUCC_uiReplace(SUCC_ui)
	end
end)
SUCC_uiWatcher:SetScript('OnUpdate', SUCC_uiBarUpdate)
