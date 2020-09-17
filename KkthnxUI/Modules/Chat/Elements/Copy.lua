local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Chat")

-- Sourced: NDui (siweia)

local _G = _G
local sring_format = _G.string.format
local string_gsub = _G.string.gsub
local table_concat = _G.table.concat
local tostring = _G.tostring

local CreateFrame = _G.CreateFrame
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local PlaySound = _G.PlaySound
local STATUS = _G.STATUS
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local SlashCmdList = _G.SlashCmdList
local UIParent = _G.UIParent

local lines, menu, frame, editBox = {}
local CopyChatFont = K.GetFont(C["UIFonts"].ChatFonts)
local menuFrame = CreateFrame("Frame", "KKUI_QuickMenu", UIParent, "UIDropDownMenuTemplate")
local leftButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local rightButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

local menuList = {
	{text = K.SystemColor..OPTIONS_MENU.."|r", isTitle = true, notCheckable = true},
	{text = "", notClickable = true, notCheckable = true},
	{text = STATUS, notCheckable = true, func = function()
			SlashCmdList["KKUI_STATUSREPORT"]()
	end},

	{text = L["Install"], notCheckable = true, func = function()
			SlashCmdList["KKUI_INSTALLER"]()
	end},

	{text = L["MoveUI"], notCheckable = true, func = function()
			SlashCmdList["KKUI_MOVEUI"]()
	end},

	{text = L["Profiles"], notCheckable = true, func = function()
			SlashCmdList["KKUI_UIPROFILES"]("list")
	end},

	{text = L["Changelog"], notCheckable = true, func = function()
			SlashCmdList["KKUI_CHANGELOG"]()
	end},

	{text = RELOADUI, notCheckable = true, func = function()
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
				return
			end
			ReloadUI()
	end},

	{text = BINDING_NAME_TOGGLECOMBATLOG, notCheckable = true, func = function()
			if not LoggingCombat() then
				LoggingCombat(true)
				K.Print("|cffffff00"..COMBATLOGENABLED.."|r")
			elseif LoggingCombat() then
				LoggingCombat(false)
				K.Print("|cffffff00"..COMBATLOGDISABLED.."|r")
			end
	end},

	{text = L["Discord"], notCheckable = true, func = function()
			K.StaticPopup_Show("KKUI_DISCORD_LINK", nil, nil, L["Discord URL"])
	end},
	{text = "", notClickable = true, notCheckable = true},

	{text = "Micro Menu:", hasArrow = true, notCheckable = true,
		menuList = {
			{text = _G.CHARACTER_BUTTON, notCheckable = true,
			func = function() ToggleCharacter("PaperDollFrame") end},
			{text = _G.SPELLBOOK_ABILITIES_BUTTON, notCheckable = true,
				func = function()
					if not _G.SpellBookFrame:IsShown() then
						ShowUIPanel(_G.SpellBookFrame)
					else
						HideUIPanel(_G.SpellBookFrame)
					end
			end},

			{text = _G.TALENTS_BUTTON, notCheckable = true,
				func = function()
					if not _G.PlayerTalentFrame then
						_G.TalentFrame_LoadUI()
					end

					local PlayerTalentFrame = _G.PlayerTalentFrame
					if not PlayerTalentFrame:IsShown() then
						ShowUIPanel(PlayerTalentFrame)
					else
						HideUIPanel(PlayerTalentFrame)
					end
			end},
			{text = _G.COLLECTIONS, notCheckable = true,
			func = ToggleCollectionsJournal},
			{text = _G.CHAT_CHANNELS, notCheckable = true,
			func = _G.ToggleChannelFrame},
			{text = _G.TIMEMANAGER_TITLE, notCheckable = true,
			func = function() ToggleFrame(_G.TimeManagerFrame) end},
			{text = _G.ACHIEVEMENT_BUTTON, notCheckable = true,
			func = ToggleAchievementFrame},
			{text = _G.SOCIAL_BUTTON, notCheckable = true,
			func = ToggleFriendsFrame},
			{text = CALENDAR_VIEW_EVENT,
			func = function() if (not CalendarFrame) then LoadAddOn("Blizzard_Calendar") end Calendar_Toggle() end, notCheckable = true},
			{text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, notCheckable = true,
			func = function() GarrisonLandingPageMinimapButton_OnClick() end},
			{text = _G.ACHIEVEMENTS_GUILD_TAB, notCheckable = true,
			func = ToggleGuildFrame},
			{text = _G.LFG_TITLE, notCheckable = true,
			func = ToggleLFDParentFrame},
			{text = _G.ENCOUNTER_JOURNAL, notCheckable = true,
			func = function() if not IsAddOnLoaded('Blizzard_EncounterJournal') then 	_G.EncounterJournal_LoadUI() end ToggleFrame(_G.EncounterJournal) end},
			{text = _G.MAINMENU_BUTTON, notCheckable = true,
				func = function()
					if not _G.GameMenuFrame:IsShown() then
						if _G.VideoOptionsFrame:IsShown() then
							_G.VideoOptionsFrameCancel:Click();
						elseif _G.AudioOptionsFrame:IsShown() then
							_G.AudioOptionsFrameCancel:Click();
						elseif _G.InterfaceOptionsFrame:IsShown() then
							_G.InterfaceOptionsFrameCancel:Click();
						end

						CloseMenus();
						CloseAllWindows()
						PlaySound(850) --IG_MAINMENU_OPEN
						ShowUIPanel(_G.GameMenuFrame);
					else
						PlaySound(854) --IG_MAINMENU_QUIT
						HideUIPanel(_G.GameMenuFrame);
						MainMenuMicroButton_SetNormal();
					end
			end},

			{text = MOUNTS,
				func = function()
					ToggleCollectionsJournal(1)
				end,
			notCheckable = true},

			{text = PETS,
				func = function()
					ToggleCollectionsJournal(2)
				end,
			notCheckable = true},

			{text = TOY_BOX,
				func = function() ToggleCollectionsJournal(3) end,
			notCheckable = true},

			{text = HEIRLOOMS,
				func = function()
					ToggleCollectionsJournal(4)
				end,
			notCheckable = true},

			{text = SOCIAL_BUTTON,
				func = function()
					ToggleFriendsFrame(1)
				end,
			notCheckable = true},

			{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE.." / "..COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
				func = function()
					PVEFrame_ToggleFrame()
				end,
			notCheckable = true},


			{text = "", notClickable = true, notCheckable = true},
			{text = "|CFFFF3333"..CLOSE.."|r", notCheckable = true, func = function() end},
		},
	},


	{text = TASKS_COLON, hasArrow = true, notCheckable = true,
		menuList = {
			{text = "Delete "..QUESTS_LABEL.." From Tracker", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_ABANDONQUESTS"]()
			end},

			{text = "Delete |ccf00ccff"..HEIRLOOMS.."|r From Bags", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_DELETEHEIRLOOMS"]()
			end},

			{text = "Delete |cffffd200"..AUCTION_CATEGORY_QUEST_ITEMS.."|r From Bags", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_DELETEQUESTITEMS"]()
			end},

		},
	},

	{text = "Details", hasArrow = true, notCheckable = true,
		menuList = {
			{text = "Reset Details", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end

					if IsAddOnLoaded("Details") then
						_G.KkthnxUIData["ResetDetails"] = true
						K.StaticPopup_Show("KKUI_CHANGES_RELOAD")
					else
						K.Print("Details is not loaded!")
					end
			end},

			{text = "Toggle Details", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end

					if IsAddOnLoaded("Details") then
						PlaySound(21968)
						_G._detalhes:ToggleWindows()
					else
						K.Print("Details is not loaded!")
					end
			end},
		},
	},

	{text = "Skada", hasArrow = true, notCheckable = true,
		menuList = {
			{text = "Toggle Skada", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end

					if IsAddOnLoaded("Skada") then
						PlaySound(21968)
						_G.Skada:ToggleWindow()
					else
						K.Print("Skada is not loaded!")
					end
			end},
		},
	},

	{text = "", notClickable = true, notCheckable = true},
	{text = "|CFFFF3333"..CLOSE.."|r", notCheckable = true, func = function() end},
}

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function colorReplace(msg, r, g, b)
	local hexRGB = K.RGBToHex(r, g, b)
	local hexReplace = sring_format("|r%s", hexRGB)
	msg = string_gsub(msg, "|r", hexReplace)
	msg = sring_format("%s%s|r", hexRGB, msg)

	return msg
end

function Module:GetChatLines()
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = colorReplace(msg, r, g, b)

			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	return index - 1
end

function Module:ChatCopy_OnClick(btn)
	if btn == "LeftButton" then
		if not frame:IsShown() then
			local chatframe = _G.SELECTED_DOCK_FRAME
			local _, fontSize = chatframe:GetFont()
			FCF_SetChatWindowFontSize(chatframe, chatframe, .01)
			PlaySound(21968)
			frame:Show()

			local lineCt = Module.GetChatLines(chatframe)
			local text = table_concat(lines, " \n", 1, lineCt)
			FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
			editBox:SetText(text)
		else
			frame:Hide()
		end
	elseif btn == "RightButton" then
		K.TogglePanel(menu)
		C["Chat"].ChatMenu = menu:IsShown()
	end
end

function Module:ChatCopy_CreateMenu()
	menu = CreateFrame("Frame", "KKUI_ChatMenu", UIParent)
	menu:SetSize(18, ChatFrame1:GetHeight() - 6)
	menu:SetPoint("TOPRIGHT", _G.ChatFrame1, 18, -5)
	menu:SetShown(C["Chat"].ChatMenu)

	_G.ChatFrameMenuButton:ClearAllPoints()
	_G.ChatFrameMenuButton:SetPoint("TOP", menu)
	_G.ChatFrameMenuButton:SetParent(menu)

	_G.ChatFrameChannelButton:ClearAllPoints()
	_G.ChatFrameChannelButton:SetPoint("TOP", _G.ChatFrameMenuButton, "BOTTOM", 0, -6)
	_G.ChatFrameChannelButton:SetParent(menu)

	_G.ChatFrameToggleVoiceDeafenButton:ClearAllPoints()
	_G.ChatFrameToggleVoiceDeafenButton:SetPoint("TOP", _G.ChatFrameChannelButton, "BOTTOM", 0, -6)
	_G.ChatFrameToggleVoiceDeafenButton:SetParent(menu)

	_G.ChatFrameToggleVoiceMuteButton:ClearAllPoints()
	_G.ChatFrameToggleVoiceMuteButton:SetPoint("TOP", _G.ChatFrameToggleVoiceDeafenButton, "BOTTOM", 0, -6)
	_G.ChatFrameToggleVoiceMuteButton:SetParent(menu)

	_G.QuickJoinToastButton:SetParent(menu)

	_G.ChatAlertFrame:ClearAllPoints()
	_G.ChatAlertFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1Tab, "TOPLEFT", 5, 25)
end

function Module:ChatCopy_Create()
	frame = CreateFrame("Frame", "KKUI_CopyChat", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	K.CreateMoverFrame(frame)
	frame:CreateBorder()

	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)
	frame.close:SkinCloseButton()

	local scrollArea = CreateFrame("ScrollFrame", "KKUI_CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 12, -40)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 20)
	KKUI_CopyChatScrollFrameScrollBar:SkinScrollBar()

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(CopyChatFont)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(400)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)

	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)

	local copy = CreateFrame("Button", "KKUI_ChatCopyButton", UIParent)
	copy:SetPoint("BOTTOM", menu)
	copy:CreateBorder()
	copy:SetSize(16, 16)
	copy:SetAlpha(0.25)

	copy.Texture = copy:CreateTexture(nil, "ARTWORK")
	copy.Texture:SetAllPoints()
	copy.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", self.ChatCopy_OnClick)

	copy:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], "Copy Chat", 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], "Chat Menu", 1, 1, 1)

		GameTooltip:Show()
	end)

	copy:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- Create Configbutton
	local kkuiconfig = CreateFrame("Button", "kkuiconfig", UIParent)
	kkuiconfig:SetPoint("BOTTOM", copy, "TOP", 0, 6)
	kkuiconfig:SkinButton()
	kkuiconfig:SetSize(16, 16)
	kkuiconfig:SetAlpha(0.25)

	kkuiconfig.Texture = kkuiconfig:CreateTexture(nil, "ARTWORK")
	kkuiconfig.Texture:SetPoint("CENTER", kkuiconfig, "CENTER", 0, 0)
	kkuiconfig.Texture:SetSize(32, 16)
	kkuiconfig.Texture:SetTexture(C["Media"].Logo)
	kkuiconfig:RegisterForClicks("AnyUp")
	kkuiconfig:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			PlaySound(111)
			_G.EasyMenu(menuList, menuFrame, kkuiconfig, 24, 290, "MENU", 2)
		elseif btn == "RightButton" then
			K.GUI:Toggle()
		end
	end)

	kkuiconfig:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Toggle Quick Menu"], 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], L["Toggle KkthnxUI Config"], 1, 1, 1)
		GameTooltip:Show()
	end)

	kkuiconfig:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)
end

function Module:CreateCopyChat()
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end