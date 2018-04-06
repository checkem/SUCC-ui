function SUCC_uiDefaults()
	SUCC_uiOptions = {}
	return SUCC_bagOptions
end

-- debug
local function print(mes)
	DEFAULT_CHAT_FRAME:AddMessage(mes)
end

--  SUCC UI

local SUCC_ui = {}
SUCC_ui.texturePath = {}
SUCC_ui.texturePath.xp = 'Interface\\AddOns\\SUCC-ui\\Textures\\exports-XP-bar-1-0-rle-bl'

-- XP bar frame

SUCC_ui.xpBar = CreateFrame('Frame', nil, UIParent)
SUCC_ui.xpBar:SetFrameLevel(3)
SUCC_ui.xpBar:SetWidth(604) SUCC_ui.xpBar:SetHeight(25)
SUCC_ui.xpBar:SetPoint('BOTTOM', UIParent)
SUCC_ui.xpBar.textureMiddle = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.xpBar.textureMiddle:SetWidth(256) SUCC_ui.xpBar.textureMiddle:SetHeight(32)
SUCC_ui.xpBar.textureMiddle:SetPoint('BOTTOM', SUCC_ui.xpBar)
SUCC_ui.xpBar.textureMiddle:SetTexture(SUCC_ui.texturePath.xp)
SUCC_ui.xpBar.textureMiddle:SetTexCoord(0, 1, 0.25, 0.5)
SUCC_ui.xpBar.textureLeft = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.xpBar.textureLeft:SetPoint('BOTTOMRIGHT', SUCC_ui.xpBar.textureMiddle, 'BOTTOMLEFT')
SUCC_ui.xpBar.textureLeft:SetWidth(174) SUCC_ui.xpBar.textureLeft:SetHeight(32)
SUCC_ui.xpBar.textureLeft:SetTexture(SUCC_ui.texturePath.xp)
SUCC_ui.xpBar.textureLeft:SetTexCoord(0.3203125, 1, 0 , 0.25)
SUCC_ui.xpBar.textureRight = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
SUCC_ui.xpBar.textureRight:SetPoint('BOTTOMLEFT', SUCC_ui.xpBar.textureMiddle, 'BOTTOMRIGHT')
SUCC_ui.xpBar.textureRight:SetWidth(174) SUCC_ui.xpBar.textureRight:SetHeight(32)
SUCC_ui.xpBar.textureRight:SetTexture(SUCC_ui.texturePath.xp)
SUCC_ui.xpBar.textureRight:SetTexCoord(0, 0.6796875, 0.75, 1)
SUCC_ui.xpBar:SetScale(768/1080)

local function xpBarSetup(qBar)
	qBar:ClearAllPoints()
	qBar:SetParent(SUCC_ui.xpBar)
	qBar:SetWidth(540)
	qBar:SetHeight(14)
	qBar:SetPoint('BOTTOM', SUCC_ui.xpBar, 'BOTTOM')
end

xpBarSetup(MainMenuExpBar)
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
	-- if(not ReputationWatchBar.textLocked) then
	-- 	ReputationWatchStatusBarText:Hide();
	-- end
end)
MainMenuXPBarTexture0:Hide()
MainMenuXPBarTexture1:Hide()
MainMenuXPBarTexture2:Hide()
MainMenuXPBarTexture3:Hide()
ExhaustionTick:SetParent(MainMenuExpBar)
xpBarSetup(ReputationWatchBar)
ReputationWatchBar:Hide();
MainMenuBarOverlayFrame:SetFrameStrata('MEDIUM')
MainMenuBarOverlayFrame:SetFrameLevel(1)
MainMenuExpBar:SetFrameLevel(0)
ReputationWatchBar:SetFrameLevel(2)
ReputationWatchStatusBar:ClearAllPoints()
ReputationWatchStatusBar:SetAllPoints()

ReputationWatchBarTexture0:Hide()
ReputationWatchBarTexture1:Hide()
ReputationWatchBarTexture2:Hide()
ReputationWatchBarTexture3:Hide()

ReputationXPBarTexture0:Hide()
ReputationXPBarTexture1:Hide()
ReputationXPBarTexture2:Hide()
ReputationXPBarTexture3:Hide()

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

		-- If the player is max level then replace the xp bar with the watched reputation, otherwise stack the reputation watch bar on top of the xp bar
		ReputationWatchStatusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
		if ( newLevel < MAX_PLAYER_LEVEL ) then
			-- Reconfigure reputation bar
			ReputationWatchStatusBar:SetHeight(15);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);

			-- Show the XP bar
			MainMenuExpBar:Show();

			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		else
			-- Replace xp bar
			ReputationWatchStatusBar:SetHeight(15);
			ReputationWatchBar:ClearAllPoints();
			ReputationWatchBar:SetPoint("BOTTOM", SUCC_ui.xpBar);
			ReputationWatchStatusBarText:SetPoint("CENTER", ReputationWatchBarOverlayFrame, "CENTER", 0, 1);

			ExhaustionTick:Hide();

			-- Hide the XP bar
			MainMenuExpBar:Hide();

			-- Hide max level bar
			MainMenuBarMaxLevelBar:Hide();
		end

	else
		if ( ReputationWatchBar:IsShown() ) then
			visibilityChanged = 1;
		end
		ReputationWatchBar:Hide();
		if ( newLevel == MAX_PLAYER_LEVEL ) then
			MainMenuExpBar:Hide();
			MainMenuBarMaxLevelBar:Show();
			ExhaustionTick:Hide();
		else
			MainMenuExpBar:Show();
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
-- action bar frame

-- ActionButton1:ClearAllPoints()
-- ActionButton1NormalTexture:SetTexCoord(0,0,0,0)
-- ActionButton1:SetParent(SUCC_ui.actionBar)
-- ExhaustionTick:SetParent(SUCC_ui.actionBar)
-- BonusActionBarFrame:SetParent(SUCC_ui.actionBar)
-- BonusActionBarFrame:ClearAllPoints()
-- BonusActionBarFrame:SetPoint('BOTTOMLEFT', 43, 24)
-- BonusActionBarTexture0:hide()
-- BonusActionBarTexture1:hide()
-- local abd = 41
-- ActionButton1:SetPoint('BOTTOMLEFT', 43, 24)
-- ActionButton1HotKey:SetWidth(abd)
-- ActionButton1Cooldown:SetWidth(65)
-- ActionButton1:SetHeight(abd) ActionButton1:SetWidth(abd)
-- ActionButton1:SetFrameStrata('BACKGROUND')
-- for i=2, 10 do
-- 	_G["ActionButton"..i]:SetParent(SUCC_ui.actionBar)
-- 	_G["ActionButton"..i.."NormalTexture"]:SetTexCoord(0,0,0,0)
-- 	_G["ActionButton"..i.."HotKey"]:SetWidth(abd)
-- 	_G["ActionButton"..i.."Cooldown"]:SetWidth(abd + 4)
-- 	_G["ActionButton"..i.."Cooldown"]:SetHeight(abd + 4)
-- 	_G["ActionButton"..i]:SetFrameStrata('BACKGROUND')
-- 	_G["ActionButton"..i]:SetHeight(abd)
-- 	_G["ActionButton"..i]:SetWidth(abd)
-- 	_G["ActionButton"..i]:SetPoint('LEFT', _G["ActionButton"..i-1], 'RIGHT', 12, 0)
-- 	-- newFrame = CreateFrame("frameType"[, "frameName"[, parentFrame[, "inheritsFrame"]]])
-- end

-- REFERENCE TEXTURE

-- SUCC_ui.xpBar.textureRef = SUCC_ui.xpBar:CreateTexture(nil, 'ARTWORK')
-- SUCC_ui.xpBar.textureRef:SetWidth(256) SUCC_ui.xpBar.textureRef:SetHeight(128)
-- SUCC_ui.xpBar.textureRef:SetPoint('CENTER', UIParent)
-- SUCC_ui.xpBar.textureRef:SetTexture(SUCC_ui.texturePath.xp)

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
