local K = unpack(select(2, ...))

local _G = _G
local next = next

local MouseIsOver = _G.MouseIsOver
local SpellFlyout = _G.SpellFlyout
local CreateFrame = _G.CreateFrame

K.fader = {
	fadeInAlpha = 1,
	fadeInDuration = 0.2,
	fadeInSmooth = "OUT",
	fadeOutAlpha = 0.25,
	fadeOutDuration = 0.2,
	fadeOutSmooth = "OUT",
	fadeOutDelay = 0,
}

K.faderOnShow = {
	fadeInAlpha = 1,
	fadeInDuration = 0.2,
	fadeInSmooth = "OUT",
	fadeOutAlpha = 0,
	fadeOutDuration = 0.2,
	fadeOutSmooth = "OUT",
	fadeOutDelay = 0,
	trigger = "OnShow",
}

local function FaderOnFinished(self)
	self.__owner:SetAlpha(self.finAlpha)
end

local function FaderOnUpdate(self)
	self.__owner:SetAlpha(self.__animFrame:GetAlpha())
end

local function CreateFaderAnimation(frame)
	if frame.fader then
		return
	end
	local animFrame = CreateFrame("Frame", nil, frame)
	animFrame.__owner = frame
	frame.fader = animFrame:CreateAnimationGroup()
	frame.fader.__owner = frame
	frame.fader.__animFrame = animFrame
	frame.fader.direction = nil
	frame.fader.setToFinalAlpha = false -- Test If This Will Not Apply The Alpha To All Regions
	frame.fader.anim = frame.fader:CreateAnimation("Alpha")
	frame.fader:HookScript("OnFinished", FaderOnFinished)
	frame.fader:HookScript("OnUpdate", FaderOnUpdate)
end

local function StartFadeIn(frame)
	if frame.fader.direction == "in" then
		return
	end

	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.faderConfig.fadeOutAlpha or 0)
	frame.fader.anim:SetToAlpha(frame.faderConfig.fadeInAlpha or 1)
	frame.fader.anim:SetDuration(frame.faderConfig.fadeInDuration or 0.3)
	frame.fader.anim:SetSmoothing(frame.faderConfig.fadeInSmooth or "OUT")
	-- Start Right Away
	frame.fader.anim:SetStartDelay(frame.faderConfig.fadeInDelay or 0)
	frame.fader.finAlpha = frame.faderConfig.fadeInAlpha
	frame.fader.direction = "in"
	frame.fader:Play()
end

local function StartFadeOut(frame)
	if frame.fader.direction == "out" then
		return
	end

	frame.fader:Pause()
	frame.fader.anim:SetFromAlpha(frame.faderConfig.fadeInAlpha or 1)
	frame.fader.anim:SetToAlpha(frame.faderConfig.fadeOutAlpha or 0)
	frame.fader.anim:SetDuration(frame.faderConfig.fadeOutDuration or 0.3)
	frame.fader.anim:SetSmoothing(frame.faderConfig.fadeOutSmooth or "OUT")
	-- Wait For Some Time Before Starting The Fadeout
	frame.fader.anim:SetStartDelay(frame.faderConfig.fadeOutDelay or 0)
	frame.fader.finAlpha = frame.faderConfig.fadeOutAlpha
	frame.fader.direction = "out"
	frame.fader:Play()
end

local function IsMouseOverFrame(frame)
	if MouseIsOver(frame) then
		return
		true
	end

	if not SpellFlyout:IsShown() then
		return
		false
	end

	if not SpellFlyout.__faderParent then
		return
		false
	end

	if SpellFlyout.__faderParent == frame and MouseIsOver(SpellFlyout) then
		return
		true
	end

	return false
end

local function FrameHandler(frame)
	if IsMouseOverFrame(frame) then
		StartFadeIn(frame)
	else
		StartFadeOut(frame)
	end
end

local function OffFrameHandler(self)
	if not self.__faderParent then
		return
	end
	FrameHandler(self.__faderParent)
end

local function OnShow(self)
	if self.fader then
		StartFadeIn(self)
	end
end

local function OnHide(self)
	if self.fader then
		StartFadeOut(self)
	end
end

local function SpellFlyoutOnShow(self)
	local frame = self:GetParent():GetParent():GetParent()
	if not frame.fader then
		return
	end
	-- Set New Frame Parent
	self.__faderParent = frame
	if not self.__faderHook then
		SpellFlyout:HookScript("OnEnter", OffFrameHandler)
		SpellFlyout:HookScript("OnLeave", OffFrameHandler)
		self.__faderHook = true
	end

	for i = 1, 13 do
		local button = _G["SpellFlyoutButton"..i]
		if not button then
			break
		end
		button.__faderParent = frame
		if not button.__faderHook then
			button:HookScript("OnEnter", OffFrameHandler)
			button:HookScript("OnLeave", OffFrameHandler)
			button.__faderHook = true
		end
	end
end
SpellFlyout:HookScript("OnShow", SpellFlyoutOnShow)

function K:CreateFrameFader(frame, faderConfig)
	if frame.faderConfig then
		return
	end
	frame.faderConfig = faderConfig
	CreateFaderAnimation(frame)

	if faderConfig.trigger and faderConfig.trigger == "OnShow" then
		frame:HookScript("OnShow", OnShow)
		frame:HookScript("OnHide", OnHide)
	else
		frame:EnableMouse(true)
		frame:HookScript("OnEnter", FrameHandler)
		frame:HookScript("OnLeave", FrameHandler)
		FrameHandler(frame)
	end
end

function K:CreateButtonFrameFader(buttonList, faderConfig)
	K:CreateFrameFader(self, faderConfig)
	if faderConfig.trigger and faderConfig.trigger == "OnShow" then
		return
	end

	for _, button in next, buttonList do
		if not button.__faderParent then
			button.__faderParent = self
			button:HookScript("OnEnter", OffFrameHandler)
			button:HookScript("OnLeave", OffFrameHandler)
		end
	end
end