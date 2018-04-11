function SUCC_uiDefaults()
	SUCC_uiOptions = {}
	SUCC_uiOptions.stancePages = {}
	SUCC_uiOptions.multiPages = {}
	SUCC_uiOptions.stancePages[0] = 3 -- Humanoid form
	SUCC_uiOptions.stancePages[1] = 4 -- battle stance, bear, stealh
	SUCC_uiOptions.stancePages[2] = 5 -- defensive stance, seal
	SUCC_uiOptions.stancePages[3] = 6 -- cat
	SUCC_uiOptions.stancePages[4] = 7 -- travel
	SUCC_uiOptions.stancePages[5] = 8 -- mind controlled
	SUCC_uiOptions.multiPages[1] = 11
	SUCC_uiOptions.multiPages[2] = 12
	return SUCC_uiOptions
end

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

--  SUCC UI

local SUCC_ui = {}
SUCC_ui.settings = SUCC_uiDefaults()
SUCC_ui.texturePath = {}
SUCC_ui.texturePath.xp = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-xp-bar-regular-51232-nc'
SUCC_ui.texturePath.slot = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-slot-exact-6440'
SUCC_ui.texturePath.slot1 = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-slot-rounded-good-6440'
SUCC_ui.texturePath.slotBg = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-slot-rounded-bigger-6440'
SUCC_ui.texturePath.stanceBar = 'Interface\\AddOns\\SUCC-ui\\Textures\\37-e-xp-bar-reduced-5123216'

-- XP bar frame

SUCC_ui.xpBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.xpBar:SetFrameLevel(5)
SUCC_ui.xpBar:SetWidth(604) SUCC_ui.xpBar:SetHeight(25)
SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
SUCC_ui.xpBar.textureMiddle = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.xpBar.textureMiddle:SetWidth(512) SUCC_ui.xpBar.textureMiddle:SetHeight(32)
SUCC_ui.xpBar.textureMiddle:SetPoint('BOTTOM', SUCC_ui.xpBar)
SUCC_ui.xpBar.textureMiddle:SetTexture(SUCC_ui.texturePath.xp)

local function SUCC_uiSetHw(f, h, w)
	f:SetHeight(h)
	f:SetWidth(w)
end

local function xpBarSetup(qBar)
	qBar:ClearAllPoints()
	qBar:SetParent(SUCC_ui.xpBar)
	SUCC_uiSetHw(qBar, 13, 416)
	qBar:SetPoint('BOTTOM', SUCC_ui.xpBar, 'BOTTOM')
end

xpBarSetup(MainMenuExpBar)
ExhaustionTick:SetParent(MainMenuExpBar)
xpBarSetup(ReputationWatchBar)
ReputationWatchBar:Hide()
MainMenuBarOverlayFrame:SetFrameStrata('MEDIUM')
MainMenuBarOverlayFrame:SetFrameLevel(3)
MainMenuExpBar:SetFrameLevel(2)
ReputationWatchBar:SetFrameLevel(4)
ReputationWatchStatusBar:ClearAllPoints()
ReputationWatchStatusBar:SetAllPoints()

ReputationWatchBar_Update = function(newLevel)
	local name, reaction, min, max, value = GetWatchedFactionInfo();
	local visibilityChanged = nil;
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	if ( name ) then
		-- See if it was already shown or not
		if ( not ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end

		-- Normalize values
		max = max - min;
		value = value - min;
		min = 0;
		ReputationWatchStatusBar:SetMinMaxValues(min, max);
		ReputationWatchStatusBar:SetValue(value);
		ReputationWatchStatusBarText:SetText(name.." "..value.." / "..max);
		local color = FACTION_BAR_COLORS[reaction];
		ReputationWatchStatusBar:SetStatusBarColor(color.r, color.g, color.b);

		-- If the player is max level then replace the xp bar with the watched reputation,
		-- otherwise stack the reputation watch bar on top of the xp bar
		ReputationWatchStatusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
		if ( newLevel < MAX_PLAYER_LEVEL ) then
			-- Reconfigure reputation bar
			ReputationWatchStatusBar:SetHeight(15);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);

			-- Show the XP bar
			MainMenuExpBar:Show();

			MainMenuExpBar:SetScript('OnEnter', function()
				local a, b, c, d, e = GetWatchedFactionInfo()
				if (a) then
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
			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		else
			-- Replace xp bar
			SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
			ReputationWatchBar:Show()
			ReputationWatchStatusBar:SetHeight(15);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);

			ExhaustionTick:Hide();

			-- Hide the XP bar
			MainMenuExpBar:Hide();

			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
			MainMenuExpBar:SetScript('OnEnter', nil)
			ReputationWatchBar:SetScript('OnLeave', nil)
		end
	else
		if ( ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		ReputationWatchBar:Hide();
		if ( newLevel == MAX_PLAYER_LEVEL ) then
			MainMenuExpBar:Hide();
			SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent, 0, -12)
			ExhaustionTick:Hide();
		else
			MainMenuExpBar:Show();
			SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
			MainMenuBarMaxLevelBar:Hide();
		end
	end
	-- if ( visibilityChanged ) then
	-- 	UIParent_ManageFramePositions();
	-- 	updateContainerFrameAnchors();
	-- end
end

MainMenuBar:Hide()
MainMenuBar:SetParent(nil)

-- REFERENCE TEXTURE

-- SUCC_ui.xpBar.textureRef = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
-- SUCC_ui.xpBar.textureRef:SetWidth(32) SUCC_ui.xpBar.textureRef:SetHeight(16)
-- SUCC_ui.xpBar.textureRef:SetTexCoord(0.75, 1, 0, 1)
-- SUCC_ui.xpBar.textureRef:SetPoint('CENTER', UIParent)
-- SUCC_ui.xpBar.textureRef:SetTexture(SUCC_ui.texturePath.ref)

-- player unit frame

-- SUCC_ui.unitFrame = CreateFrame('Frame', nil, UIParent)
-- SUCC_ui.unitFrame:SetPoint('BOTTOM', UIParent, 0, 45)
-- SUCC_ui.unitFrame:SetWidth(362) SUCC_ui.unitFrame:SetHeight(76)
-- SUCC_ui.unitFrame.texture = SUCC_ui.unitFrame:CreateTexture(nil, 'ARTWORK')
-- SUCC_ui.unitFrame.texture:SetAllPoints(SUCC_ui.unitFrame)
-- SUCC_ui.unitFrame.texture:SetTexture(SUCC_ui.texturePath)
-- SUCC_ui.unitFrame.texture:SetTexCoord(0,0.70703125,0.578125,0.875)

-- status indicator

-- SUCC_ui.unitFrame.status = CreateFrame('Frame', nil)

-- move player status bars to the SUCC_ui frame
-- PlayerFrameHealthBar:ClearAllPoints()
-- PlayerFrameHealthBar:SetParent(SUCC_ui.unitFrame)
-- PlayerFrameHealthBar:SetPoint('TOPLEFT', SUCC_ui.unitFrame, 'TOP', 2, -9)
-- PlayerFrameHealthBar:SetWidth(170)
-- PlayerFrameManaBar:ClearAllPoints()
-- PlayerFrameManaBar:SetParent(SUCC_ui.unitFrame)
-- PlayerFrameManaBar:SetPoint('TOPRIGHT', SUCC_ui.unitFrame, 'TOP', -2, -9)
-- PlayerFrameManaBar:SetWidth(170)

function SUCC_uiActionButton_ShowGrid(button)
	if ( not button ) then
		button = this
	end
	button.showgrid = button.showgrid+1
	button:Show()
end

MultiActionBar_UpdateGrid = function(barName, show)
	for i=1, NUM_MULTIBAR_BUTTONS do
		if ( show ) then
			SUCC_uiActionButton_ShowGrid(getglobal(barName.."Button"..i));
		else
			ActionButton_HideGrid(getglobal(barName.."Button"..i));
		end

	end
end

local function SUCC_uiActionButton_Update()
	-- Special case code for bonus bar buttons
	-- Prevents the button from updating if the bonusbar is still in an animation transition
	if ( this.isBonus and this.inTransition ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		return;
	end

	local icon = getglobal(this:GetName().."Icon");
	local buttonCooldown = getglobal(this:GetName().."Cooldown");
	local texture = GetActionTexture(ActionButton_GetPagedID(this));
	if ( texture ) then
		icon:SetTexture(texture);
		icon:Show();
		this.rangeTimer = -1
		-- this:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
		this:SetNormalTexture(SUCC_ui.texturePath.slot1)
		-- this:GetNormalTexture():SetVertexColor(0, 0, 0, 0);
		if ( this.isBonus ) then
			this.texture = texture;
		end
	else
		icon:Hide();
		buttonCooldown:Hide();
		this.rangeTimer = nil;
		this:SetNormalTexture(SUCC_ui.texturePath.slotBg)
		getglobal(this:GetName().."HotKey"):SetVertexColor(0.6, 0.6, 0.6);
	end
	ActionButton_UpdateCount();
	if ( HasAction(ActionButton_GetPagedID(this)) ) then
		this:RegisterEvent("ACTIONBAR_UPDATE_STATE");
		this:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
		this:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
		this:RegisterEvent("UPDATE_INVENTORY_ALERTS");
		this:RegisterEvent("PLAYER_AURAS_CHANGED");
		this:RegisterEvent("PLAYER_TARGET_CHANGED");
		this:RegisterEvent("UNIT_INVENTORY_CHANGED");
		this:RegisterEvent("CRAFT_SHOW");
		this:RegisterEvent("CRAFT_CLOSE");
		this:RegisterEvent("TRADE_SKILL_SHOW");
		this:RegisterEvent("TRADE_SKILL_CLOSE");
		this:RegisterEvent("PLAYER_ENTER_COMBAT");
		this:RegisterEvent("PLAYER_LEAVE_COMBAT");
		this:RegisterEvent("START_AUTOREPEAT_SPELL");
		this:RegisterEvent("STOP_AUTOREPEAT_SPELL");

		this:Show();
		ActionButton_UpdateState();
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
		ActionButton_UpdateFlash();
	else
		this:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
		this:UnregisterEvent("ACTIONBAR_UPDATE_USABLE");
		this:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
		this:UnregisterEvent("UPDATE_INVENTORY_ALERTS");
		this:UnregisterEvent("PLAYER_AURAS_CHANGED");
		this:UnregisterEvent("PLAYER_TARGET_CHANGED");
		this:UnregisterEvent("UNIT_INVENTORY_CHANGED");
		this:UnregisterEvent("CRAFT_SHOW");
		this:UnregisterEvent("CRAFT_CLOSE");
		this:UnregisterEvent("TRADE_SKILL_SHOW");
		this:UnregisterEvent("TRADE_SKILL_CLOSE");
		this:UnregisterEvent("PLAYER_ENTER_COMBAT");
		this:UnregisterEvent("PLAYER_LEAVE_COMBAT");
		this:UnregisterEvent("START_AUTOREPEAT_SPELL");
		this:UnregisterEvent("STOP_AUTOREPEAT_SPELL");

		if ( this.showgrid == 0 ) then
			this:Hide();
		else
			buttonCooldown:Hide();
		end
	end

	-- Add a green border if button is an equipped item
	local border = getglobal(this:GetName().."Border");
	if ( IsEquippedAction(ActionButton_GetPagedID(this)) ) then
		border:SetVertexColor(0, 1.0, 0, 0.35);
		border:Show();
	else
		border:Hide();
	end

	if ( GameTooltip:IsOwned(this) ) then
		ActionButton_SetTooltip();
	else
		this.updateTooltip = nil;
	end

	-- Update Macro Text
	local macroName = getglobal(this:GetName().."Name");
	macroName:SetText(GetActionText(ActionButton_GetPagedID(this)));
end

local function SUCC_uiActionButton_OnEvent(event)
	if ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		if ( arg1 == 0 or arg1 == ActionButton_GetPagedID(this) ) then
			SUCC_uiActionButton_Update();
		end
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" or event == "ACTIONBAR_PAGE_CHANGED" ) then
		SUCC_uiActionButton_Update();
		return;
	end
	if ( event == "UPDATE_BONUS_ACTIONBAR" ) then
		if ( this.isBonus ) then
			SUCC_uiActionButton_Update();
		end
		return;
	end
	if ( event == "ACTIONBAR_SHOWGRID" ) then
		SUCC_uiActionButton_ShowGrid();
		return;
	end
	if ( event == "ACTIONBAR_HIDEGRID" ) then
		ActionButton_HideGrid();
		return;
	end
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(this.buttonType);
		return;
	end

	-- All event handlers below this line are only set when the button has an action

	if ( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_AURAS_CHANGED" ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateHotkeys(this.buttonType);
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			SUCC_uiActionButton_Update();
		end
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		ActionButton_UpdateState();
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_INVENTORY_ALERTS" or event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		ActionButton_UpdateUsable();
		ActionButton_UpdateCooldown();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		ActionButton_UpdateState();
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StopFlash();
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StartFlash();
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( ActionButton_IsFlashing() and not IsAttackAction(ActionButton_GetPagedID(this)) ) then
			ActionButton_StopFlash();
		end
	end
end

local function SUCC_uiRemoveFrame(a)
	if (a:GetObjectType() ~= 'Texture') then
		a:SetScript("OnEvent", nil)
	end
	a:SetParent(nil)
	a:Hide()
end

SUCC_ui.stanceBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.stanceBar:SetPoint('BOTTOMLEFT', SUCC_ui.xpBar, 'BOTTOMRIGHT', 10, 0)
SUCC_ui.stanceBar:SetHeight(16)
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
SUCC_ui.stanceBar.pet = {}
SUCC_ui.stanceBar.pet.done = false
SUCC_ui.stanceBar.pet.textureMark = {}
ShapeshiftBar_UpdatePosition = function()
	-- what
end

local function SUCC_uiReplace()
	for i=0, 3 do
		SUCC_uiRemoveFrame(getglobal('ReputationWatchBarTexture'..i))
		SUCC_uiRemoveFrame(getglobal('ReputationXPBarTexture'..i))
		SUCC_uiRemoveFrame(getglobal('MainMenuXPBarTexture'..i))
	end
	SUCC_uiRemoveFrame(getglobal("BonusActionButton11"))
	SUCC_uiRemoveFrame(getglobal("BonusActionButton12"))
	SUCC_uiRemoveFrame(getglobal("MultiBarLeftButton11"))
	SUCC_uiRemoveFrame(getglobal("MultiBarLeftButton12"))
	SUCC_uiRemoveFrame(getglobal("MultiBarRightButton11"))
	SUCC_uiRemoveFrame(getglobal("MultiBarRightButton12"))
	NUM_MULTIBAR_BUTTONS = 10
	SUCC_uiRemoveFrame(MultiBarBottomLeft)
	SUCC_uiRemoveFrame(MultiBarBottomRight)
	MultiBarBottomLeft:SetParent(MainMenuBar)
	MultiBarBottomRight:SetParent(MainMenuBar)
	MultiBarRight:ClearAllPoints()
	MultiBarRight:SetPoint('BOTTOMRIGHT', -3, 45)
	MultiBarLeft:ClearAllPoints()
	MultiBarLeft:SetPoint('TOPRIGHT', MultiBarRight, 'TOPLEFT', -4, 0)
	local b = {}
	local c = {}
	local d = {}
	local e = {}
	for i=1, 10 do
		-- REUSE
		b[i] = getglobal("ActionButton"..i)
		c[i] = getglobal("BonusActionButton"..i)
		d[i] = getglobal("MultiBarRightButton"..i)
		e[i] = getglobal("MultiBarLeftButton"..i)
		b[i]:SetParent(SUCC_ui.actionBar.default)
		for _, v in ipairs({b[i], c[i], d[i], e[i]}) do
				SUCC_uiSetHw(v, 37, 37)
				v:ClearAllPoints()
				v:SetNormalTexture(SUCC_ui.texturePath.slot)
				SUCC_uiSetHw(v:GetNormalTexture(), 64, 64)
				v:GetNormalTexture():SetDrawLayer('OVERLAY')
				v:GetPushedTexture():SetDrawLayer('OVERLAY')
				-- v:GetHighlightTexture():SetDrawLayer('ARTWORK')
				getglobal(v:GetName()..'Cooldown'):SetFrameLevel(5)
		end
		if i > 1 then
			c[i]:SetPoint('LEFT', c[i-1], 'RIGHT', 4, 0)
			b[i]:SetPoint('LEFT', b[i-1], 'RIGHT', 4, 0)
			d[i]:SetPoint('TOP', d[i-1], 'BOTTOM', 0, -4)
			e[i]:SetPoint('TOP', e[i-1], 'BOTTOM', 0, -4)
		else
			c[i]:SetPoint('TOPLEFT', 0, 0)
			b[i]:SetPoint('BOTTOMLEFT', 0, 0)
			d[i]:SetPoint('TOPLEFT', 0, 0)
			e[i]:SetPoint('TOPLEFT', 0, 0)
		end
		b[i]:SetScript('OnEvent', function() SUCC_uiActionButton_OnEvent(event) end)
		d[i]:SetScript('OnEvent', function() SUCC_uiActionButton_OnEvent(event) end)
		e[i]:SetScript('OnEvent', function() SUCC_uiActionButton_OnEvent(event) end)
		c[i]:SetScript('OnEvent', function()
			SUCC_uiActionButton_OnEvent(event)
			BonusActionButton_OnEvent(event)
		end)
	end
end

local OLD_PetActionBar_Update = PetActionBar_Update
PetActionBar_Update = function()
	OLD_PetActionBar_Update()
	local a
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		a = getglobal('PetActionButton'..i)
		local _, _, b = GetPetActionInfo(i)
		if b then
			a:SetNormalTexture(SUCC_ui.texturePath.slot1)
		else
			a:SetNormalTexture(SUCC_ui.texturePath.slotBg)
		end
	end
end

local function SUCC_uiPetBarReplace()
	local b = {}
	for i=1, NUM_PET_ACTION_SLOTS do
		b[i] = getglobal('PetActionButton'..i)
		b[i]:SetParent(SUCC_ui.stanceBar)
		b[i]:SetNormalTexture(SUCC_ui.texturePath.slot1)
		SUCC_uiSetHw(b[i]:GetNormalTexture(), 54, 54)
		b[i]:GetNormalTexture():SetDrawLayer('OVERLAY')
		if i == 1 then
				w = 30
				b[i]:ClearAllPoints()
				b[i]:SetPoint('BOTTOMLEFT', 0, 8)
		else
			b[i]:SetPoint('LEFT', b[i-1], 'RIGHT', 6, 0)
			w = w + 36
			if not SUCC_ui.stanceBar.pet.textureMark[i] then
				SUCC_ui.stanceBar.pet.textureMark[i] = SUCC_ui.stanceBar:CreateTexture(nil, 'OVERLAY')
				SUCC_uiSetHw(SUCC_ui.stanceBar.pet.textureMark[i], 16, 16)
				SUCC_ui.stanceBar.pet.textureMark[i]:SetTexCoord(0, 0.03125, 0, 0.5)
				SUCC_ui.stanceBar.pet.textureMark[i]:SetPoint('TOPRIGHT', b[i], 'BOTTOMLEFT', 5, 2)
				SUCC_ui.stanceBar.pet.textureMark[i]:SetTexture(SUCC_ui.texturePath.stanceBar)
			else
				SUCC_ui.stanceBar.pet.textureMark[i]:Show()
			end
		end
	end
	SUCC_ui.stanceBar.pet.done = true
	SUCC_ui.stanceBar:SetWidth(w)
	SUCC_ui.stanceBar:Show()
end
ShapeshiftBar_Update = function()
	local n = GetNumShapeshiftForms()
	local b = {}
	if ( n > 0 ) then
		local w = 0
		for i = 1, n do
			b[i] = getglobal('ShapeshiftButton'..i)
			getglobal('ShapeshiftButton'..i..'Cooldown'):SetFrameLevel(2)
			b[i]:SetParent(SUCC_ui.stanceBar)
			b[i]:SetNormalTexture(SUCC_ui.texturePath.slot1)
			SUCC_uiSetHw(b[i]:GetNormalTexture(), 54, 54)
			b[i]:GetNormalTexture():SetDrawLayer('OVERLAY')
			if i == 1 then
					w = 30
					b[i]:ClearAllPoints()
					b[i]:SetPoint('BOTTOMLEFT', 0, 8)
			else
				b[i]:SetPoint('LEFT', b[i-1], 'RIGHT', 6, 0)
				w = w + 36
				if not SUCC_ui.stanceBar.textureMark[i] then
					SUCC_ui.stanceBar.textureMark[i] = b[i]:CreateTexture(nil, 'OVERLAY')
					SUCC_uiSetHw(SUCC_ui.stanceBar.textureMark[i], 16, 16)
					SUCC_ui.stanceBar.textureMark[i]:SetTexCoord(0, 0.03125, 0, 0.5)
					SUCC_ui.stanceBar.textureMark[i]:SetPoint('TOPRIGHT', b[i], 'BOTTOMLEFT', 5, 2)
					SUCC_ui.stanceBar.textureMark[i]:SetTexture(SUCC_ui.texturePath.stanceBar)
				else
					SUCC_ui.stanceBar.textureMark[i]:Show()
				end
			end
		end
		SUCC_ui.stanceBar:SetWidth(w)
		SUCC_ui.stanceBar:Show()
	elseif not PetHasActionBar() then
		SUCC_ui.stanceBar:Hide()
	end
	ShapeshiftBar_UpdateState()
end

-- action bar frame

SUCC_ui.actionBar = CreateFrame('Frame', nil, UIParent)
SUCC_uiSetHw(SUCC_ui.actionBar, 37, 406)
SUCC_ui.actionBar:SetPoint('BOTTOM', 0, 20)
SUCC_ui.actionBar.default = CreateFrame('Frame', nil, SUCC_ui.actionBar)
SUCC_ui.actionBar.default:SetAllPoints()
BonusActionBarFrame:SetParent(SUCC_ui.actionBar)
BonusActionBarFrame:ClearAllPoints()
BonusActionBarFrame:SetAllPoints()
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()
BONUSACTIONBAR_XPOS = 0
BONUSACTIONBAR_YPOS = 37
NUM_BONUS_ACTION_SLOTS = 10
NUM_ACTIONBAR_BUTTONS = 10


ShowBonusActionBar = function()
	BonusActionBar_SetButtonTransitionState(nil);
	if ( BonusActionBarFrame.mode ~= "show" and BonusActionBarFrame.state ~= "top") then
		if SUCC_ui.actionBar.default:IsShown() then
			SUCC_ui.actionBar.default:Hide()
		end
		BonusActionBarFrame:Show()
		if ( BonusActionBarFrame.completed ) then
			BonusActionBarFrame.slideTimer = 0
		end
		BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME
		BonusActionBarFrame.yTarget = BONUSACTIONBAR_YPOS
		BonusActionBarFrame.mode = "show"
	end
end

HideBonusActionBar = function()
	if ( BonusActionBarFrame:IsShown() ) then
		if not SUCC_ui.actionBar.default:IsShown() then
			SUCC_ui.actionBar.default:Show()
		end
		BonusActionBar_SetButtonTransitionState(1);
		if ( BonusActionBarFrame.completed ) then
			BonusActionBarFrame.slideTimer = 0;
		end
		BonusActionBarFrame.timeToSlide = BONUSACTIONBAR_SLIDETIME;
		BonusActionBarFrame.yTarget = BONUSACTIONBAR_YPOS;
		BonusActionBarFrame.mode = 'hide';
	end
end
ActionButton_GetPagedID = function(button)
	if ( button.isBonus and CURRENT_ACTIONBAR_PAGE == 1 ) then
		local offset = GetBonusBarOffset();
		if ( offset == 0 and BonusActionBarFrame and BonusActionBarFrame.lastBonusBar ) then
			offset = BonusActionBarFrame.lastBonusBar;
		end
		return (button:GetID() + ((NUM_ACTIONBAR_PAGES + offset - 1) * NUM_ACTIONBAR_BUTTONS));
	end

	local parentName = button:GetParent():GetName();
	if ( parentName == "MultiBarBottomLeft" ) then
		return (button:GetID() + ((BOTTOMLEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarBottomRight" ) then
		return (button:GetID() + ((BOTTOMRIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarLeft" ) then
		return (button:GetID() + ((LEFT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	elseif ( parentName == "MultiBarRight" ) then
		return (button:GetID() + ((RIGHT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS));
	else
		return (button:GetID() + ((CURRENT_ACTIONBAR_PAGE - 1) * NUM_ACTIONBAR_BUTTONS))
	end
end
NUM_ACTIONBAR_PAGES = 1
local stanceChanged
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
	-- elseif event == 'UPDATE_SHAPESHIFT_FORM' then
		-- print("==========11============")
	elseif ( event == 'PET_BAR_UPDATE' or (event == 'UNIT_PET' and arg1 == 'player') ) then
		if PetHasActionBar() then
			if not SUCC_ui.stanceBar.pet.done then
				SUCC_uiPetBarReplace()
			else
				SUCC_ui.stanceBar:Show()
			end
		elseif GetNumShapeshiftForms() < 1 then
			SUCC_ui.stanceBar:Hide()
		end
	elseif event == 'ADDON_LOADED' and arg1 == 'SUCC-ui' then
		this:UnregisterEvent('ADDON_LOADED')
		this:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
		this:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
		-- this:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
		-- SUCC_uiStanceBar()
		if PetHasActionBar() then
			SUCC_uiPetBarReplace()
		end
		this:RegisterEvent('PET_BAR_UPDATE')
		this:RegisterEvent('UNIT_PET')
		print('|cFFF5A3FFSUCC-ui loaded.')
		SUCC_uiReplace()
	end
end)
SUCC_uiWatcher:SetScript('OnUpdate', SUCC_uiBarUpdate)
