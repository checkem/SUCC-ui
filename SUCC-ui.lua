function SUCC_uiDefaults()
	SUCC_uiOptions = {}
	return SUCC_uiOptions
end

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

--  SUCC UI

local SUCC_ui = {}
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

local function xpBarSetup(qBar)
	qBar:ClearAllPoints()
	qBar:SetParent(SUCC_ui.xpBar)
	qBar:SetWidth(416)
	qBar:SetHeight(13)
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
	if ( visibilityChanged ) then
		UIParent_ManageFramePositions();
		updateContainerFrameAnchors();
	end
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
		button = this;
	end
	button.showgrid = button.showgrid+1;
	getglobal(button:GetName().."NormalTexture"):SetVertexColor(0.5, 0.5, 0.5, 1)

	button:Show();
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

local function SUCC_uiReplace()
	for i=0, 3 do
		SUCC_uiRemoveFrame(getglobal('ReputationWatchBarTexture'..i))
		SUCC_uiRemoveFrame(getglobal('ReputationXPBarTexture'..i))
		SUCC_uiRemoveFrame(getglobal('MainMenuXPBarTexture'..i))
	end
	SUCC_uiRemoveFrame(getglobal("BonusActionButton11"))
	SUCC_uiRemoveFrame(getglobal("BonusActionButton12"))
	for i=1, 10 do
		-- REUSE
		SUCC_ui.actionBar.bonusButtons[i] = getglobal("BonusActionButton"..i)
		SUCC_ui.actionBar.buttons[i] = getglobal("ActionButton"..i)
		SUCC_ui.actionBar.buttons[i]:SetParent(SUCC_ui.actionBar.default)
		SUCC_ui.actionBar.bonusButtons[i]:SetHeight(37)
		SUCC_ui.actionBar.bonusButtons[i]:SetWidth(37)
		SUCC_ui.actionBar.buttons[i]:SetNormalTexture(SUCC_ui.texturePath.slot)
		SUCC_ui.actionBar.bonusButtons[i]:SetNormalTexture(SUCC_ui.texturePath.slot)
		SUCC_ui.actionBar.buttons[i]:GetNormalTexture():SetHeight(64)
		SUCC_ui.actionBar.buttons[i]:GetNormalTexture():SetWidth(64)
		SUCC_ui.actionBar.bonusButtons[i]:GetNormalTexture():SetHeight(64)
		SUCC_ui.actionBar.bonusButtons[i]:GetNormalTexture():SetWidth(64)
		SUCC_ui.actionBar.buttons[i]:GetNormalTexture():SetDrawLayer('OVERLAY')
		SUCC_ui.actionBar.buttons[i]:GetPushedTexture():SetDrawLayer('OVERLAY')
		SUCC_ui.actionBar.buttons[i]:GetHighlightTexture():SetDrawLayer('ARTWORK')
		SUCC_ui.actionBar.buttons[i]:GetNormalTexture():SetDrawLayer('OVERLAY')
		SUCC_ui.actionBar.bonusButtons[i]:GetPushedTexture():SetDrawLayer('OVERLAY')
		SUCC_ui.actionBar.bonusButtons[i]:GetHighlightTexture():SetDrawLayer('ARTWORK')
		getglobal("ActionButton"..i..'Cooldown'):SetFrameLevel(5)
		getglobal("BonusActionButton"..i..'Cooldown'):SetFrameLevel(5)
		SUCC_ui.actionBar.buttons[i]:SetScript('OnEvent', function() SUCC_uiActionButton_OnEvent(event) end)
		SUCC_ui.actionBar.bonusButtons[i]:SetScript('OnEvent', function()
			SUCC_uiActionButton_OnEvent(event)
			BonusActionButton_OnEvent(event)
		end)
		if i > 1 then
			SUCC_ui.actionBar.bonusButtons[i]:SetPoint('LEFT', SUCC_ui.actionBar.bonusButtons[i-1], 'RIGHT', 4, 0)
			SUCC_ui.actionBar.buttons[i]:SetPoint('LEFT', SUCC_ui.actionBar.buttons[i-1], 'RIGHT', 4, 0)
		else
			SUCC_ui.actionBar.bonusButtons[i]:SetPoint('BOTTOMLEFT', 0, 0)
			SUCC_ui.actionBar.buttons[i]:SetPoint('BOTTOMLEFT', 0, 0)
		end
	end
end

SUCC_ui.stanceBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.stanceBar:SetPoint('BOTTOMLEFT', SUCC_ui.xpBar, 'BOTTOMRIGHT', 10, 0)
SUCC_ui.stanceBar:SetHeight(16)
SUCC_ui.stanceBar.textureLeft = SUCC_ui.stanceBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.stanceBar.textureLeft:SetWidth(48) SUCC_ui.stanceBar.textureLeft:SetHeight(16)
SUCC_ui.stanceBar.textureLeft:SetTexCoord(0.03125, 0.125, 0.5, 1)
SUCC_ui.stanceBar.textureLeft:SetPoint('BOTTOMRIGHT',SUCC_ui.stanceBar, 'BOTTOMLEFT', 11, 0)
SUCC_ui.stanceBar.textureLeft:SetTexture(SUCC_ui.texturePath.stanceBar)
SUCC_ui.stanceBar.textureRight = SUCC_ui.stanceBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.stanceBar.textureRight:SetWidth(48) SUCC_ui.stanceBar.textureRight:SetHeight(16)
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
SUCC_ui.stanceBar.buttons = {}
ShapeshiftBar_UpdatePosition = function()
	-- what
end

ShapeshiftBar_Update = function()
	local n = GetNumShapeshiftForms()
	if ( n > 0 ) then
		local w = 0
		for i = 1, n do
			SUCC_ui.stanceBar.buttons[i] = getglobal('ShapeshiftButton'..i)
			getglobal('ShapeshiftButton'..i..'Cooldown'):SetFrameLevel(2)
			SUCC_ui.stanceBar.buttons[i]:SetParent(SUCC_ui.stanceBar)
			SUCC_ui.stanceBar.buttons[i]:SetNormalTexture(SUCC_ui.texturePath.slot1)
			SUCC_ui.stanceBar.buttons[i]:GetNormalTexture():SetWidth(54)
			SUCC_ui.stanceBar.buttons[i]:GetNormalTexture():SetHeight(54)
			SUCC_ui.stanceBar.buttons[i]:GetNormalTexture():SetDrawLayer('OVERLAY')
			if i == 1 then
					w = 30
					SUCC_ui.stanceBar.buttons[i]:ClearAllPoints()
					SUCC_ui.stanceBar.buttons[i]:SetPoint('BOTTOMLEFT', 0, 8)
			else
				SUCC_ui.stanceBar.buttons[i]:SetPoint('LEFT', SUCC_ui.stanceBar.buttons[i-1], 'RIGHT', 6, 0)
				w = w + 36
				if not SUCC_ui.stanceBar.textureMark[i] then
					SUCC_ui.stanceBar.textureMark[i] = SUCC_ui.stanceBar.buttons[i]:CreateTexture(nil, 'OVERLAY')
					SUCC_ui.stanceBar.textureMark[i]:SetHeight(16) SUCC_ui.stanceBar.textureMark[i]:SetWidth(16)
					SUCC_ui.stanceBar.textureMark[i]:SetTexCoord(0, 0.03125, 0, 0.5)
					SUCC_ui.stanceBar.textureMark[i]:SetPoint('TOPRIGHT', SUCC_ui.stanceBar.buttons[i], 'BOTTOMLEFT', 5, 2)
					SUCC_ui.stanceBar.textureMark[i]:SetTexture(SUCC_ui.texturePath.stanceBar)
				else
					SUCC_ui.stanceBar.textureMark[i]:Show()
				end
			end
		end
		SUCC_ui.stanceBar:SetWidth(w)
		SUCC_ui.stanceBar:Show();
	else
		SUCC_ui.stanceBar:Hide();
	end
	ShapeshiftBar_UpdateState();
end

-- action bar frame

SUCC_ui.actionBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.actionBar:SetWidth(406) SUCC_ui.actionBar:SetHeight(37)
SUCC_ui.actionBar:SetPoint('BOTTOM', 0, 20)
SUCC_ui.actionBar.default = CreateFrame('Frame', nil, SUCC_ui.actionBar)
SUCC_ui.actionBar.default:SetAllPoints()
SUCC_ui.actionBar.buttons = {}
SUCC_ui.actionBar.bonusButtons = {}
BonusActionBarFrame:SetParent(SUCC_ui.actionBar)
BonusActionBarFrame:ClearAllPoints()
BonusActionBarFrame:SetAllPoints()
BonusActionBarTexture0:Hide()
BonusActionBarTexture1:Hide()
BONUSACTIONBAR_XPOS = 0
BONUSACTIONBAR_YPOS = 36
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

NUM_ACTIONBAR_PAGES = 7
local stanceChanged
local function SUCC_uiBarUpdate(n)
	if (IsShiftKeyDown()) then
		if (CURRENT_ACTIONBAR_PAGE == 1 or n) then
			CURRENT_ACTIONBAR_PAGE = 2 + GetBonusBarOffset()
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
	elseif event == 'UPDATE_SHAPESHIFT_FORM' then
		print("==========11============")
	elseif event == 'ADDON_LOADED' and arg1 == 'SUCC-ui' then
		this:UnregisterEvent('ADDON_LOADED')
		this:RegisterEvent('UPDATE_BONUS_ACTIONBAR')
		this:RegisterEvent('UPDATE_SHAPESHIFT_FORMS')
		this:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
		-- SUCC_uiStanceBar()
		print('|cFFF5A3FFSUCC-ui loaded.')
		SUCC_uiReplace()
	end
end)
SUCC_uiWatcher:SetScript('OnUpdate', SUCC_uiBarUpdate)
