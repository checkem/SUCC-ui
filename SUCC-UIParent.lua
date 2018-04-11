UIParent_ManageFramePositions = function()
	-- Frames that affect offsets in y axis
	local yOffsetFrames = {};
	-- Frames that affect offsets in x axis
	local xOffsetFrames = {};

	-- Set up flags
	if ( SHOW_MULTI_ACTIONBAR_1 or SHOW_MULTI_ACTIONBAR_2 ) then
		tinsert(yOffsetFrames, "bottomEither");
	end
	if ( SHOW_MULTI_ACTIONBAR_2) then
		tinsert(yOffsetFrames, "bottomRight");
	end
	if ( SHOW_MULTI_ACTIONBAR_1 ) then
		tinsert(yOffsetFrames, "bottomLeft");
	end

	if ( MultiBarLeft:IsShown() ) then
		tinsert(xOffsetFrames, "rightLeft");
	elseif ( MultiBarRight:IsShown() ) then
		tinsert(xOffsetFrames, "rightRight");
	end

	if ( ( PetActionBarFrame and PetActionBarFrame:IsShown() ) or ( ShapeshiftBarFrame and ShapeshiftBarFrame:IsShown() ) ) then
		tinsert(yOffsetFrames, "pet");
	end
	-- if ( ReputationWatchBar:IsShown() and MainMenuExpBar:IsShown() ) then
	-- 	tinsert(yOffsetFrames, "reputation");
	-- end
	if ( MainMenuBarMaxLevelBar:IsShown() ) then
		tinsert(yOffsetFrames, "maxLevel");
	end

	-- Iterate through frames and set anchors according to the flags set
	local frame, xOffset, yOffset, anchorTo, point, rpoint;
	for index, value in UIPARENT_MANAGED_FRAME_POSITIONS do
		frame = getglobal(index);
		if ( frame ) then
			-- Always start with base as the base offset or default to zero if no "none" specified
			xOffset = 0;
			if ( value["baseX"] ) then
				xOffset = value["baseX"];
			elseif ( value["xOffset"] ) then
				xOffset = value["xOffset"];
			end
			yOffset = 0;
			if ( value["baseY"] ) then
				yOffset = value["baseY"];
			end

			-- Iterate through frames that affect y offsets
			local hasBottomLeft, hasPetBar;
			for flag, flagValue in yOffsetFrames do
				if ( value[flagValue] ) then
					if ( flagValue == "bottomLeft" ) then
						hasBottomLeft = 1;
					elseif ( flagValue == "pet" ) then
						hasPetBar = 1;
					elseif ( flagValue == "bottomRight" ) then
						hasBottomRight = 1;
					end
					yOffset = yOffset + value[flagValue];
				end
			end

			if ( hasBottomLeft and hasPetBar ) then
				yOffset = yOffset + 23;
			end

			-- Iterate through frames that affect x offsets
			for flag, flagValue in xOffsetFrames do
				if ( value[flagValue] ) then
					xOffset = xOffset + value[flagValue];
				end
			end

			-- Set up anchoring info
			anchorTo = value["anchorTo"];
			point = value["point"];
			rpoint = value["rpoint"];
			if ( not anchorTo ) then
				anchorTo = "UIParent";
			end
			if ( not point ) then
				point = "BOTTOM";
			end
			if ( not rpoint ) then
				rpoint = "BOTTOM";
			end

			-- Anchor frame
			if ( value["isVar"] ) then
				if ( value["isVar"] == "xAxis" ) then
					setglobal(index, xOffset);
				else
					setglobal(index, yOffset);
				end
			else
				if ((frame == ChatFrame1 or frame == ChatFrame2) and SIMPLE_CHAT == "1") then
					frame:SetPoint(point, anchorTo, rpoint, xOffset, yOffset);
				elseif ( not(frame:IsObjectType("frame") and frame:IsUserPlaced()) ) then
					frame:SetPoint(point, anchorTo, rpoint, xOffset, yOffset);
				end
			end
		end
	end

	-- Custom positioning not handled by the loop
	-- Set battlefield minimap position
	if ( BattlefieldMinimapTab and not BattlefieldMinimapTab:IsUserPlaced() ) then
		BattlefieldMinimapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -225-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
	end

	-- If petactionbar is already shown have to set its point is addition to changing its y target
	if ( PetActionBarFrame:IsShown() ) then
		PetActionBarFrame:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
	end

	-- Setup y anchors
	local anchorY = 0;
	-- Capture bars
	if ( NUM_EXTENDED_UI_FRAMES ) then
		local captureBar;
		local numCaptureBars = 0;
		for i=1, NUM_EXTENDED_UI_FRAMES do
			captureBar = getglobal("WorldStateCaptureBar"..i);
			if ( captureBar and captureBar:IsShown() ) then
				captureBar:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
				anchorY = anchorY - captureBar:GetHeight();
			end
		end
	end
	-- Quest timers
	QuestTimerFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
	if ( QuestTimerFrame:IsShown() ) then
		anchorY = anchorY - QuestTimerFrame:GetHeight();
	end
	-- Setup durability offset
	if ( DurabilityFrame ) then
		local durabilityOffset = 0;
		if ( DurabilityShield:IsShown() or DurabilityOffWeapon:IsShown() or DurabilityRanged:IsShown() ) then
			durabilityOffset = 20;
		end
		DurabilityFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X-durabilityOffset, anchorY);
		if ( DurabilityFrame:IsShown() ) then
			anchorY = anchorY - DurabilityFrame:GetHeight();
		end
	end

	QuestWatchFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);

	-- Update chat dock since the dock could have moved
	FCF_DockUpdate();
	updateContainerFrameAnchors();
end
