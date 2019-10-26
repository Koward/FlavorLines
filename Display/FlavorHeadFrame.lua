function FlavorHeadFrame_OnLoad(self)
    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
        self:RegisterEvent("TALKINGHEAD_REQUESTED");
    end
    self:RegisterEvent("SOUNDKIT_FINISHED");
    self:RegisterEvent("LOADING_SCREEN_ENABLED");
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    self:RegisterForClicks("RightButtonUp");

    self.NameFrame.Name:SetPoint("TOPLEFT", self.PortraitFrame.Portrait, "TOPRIGHT", 2, -19);
    self.TextFrame.Text:SetFontObjectsToTry(SystemFont_Shadow_Large, SystemFont_Shadow_Med2, SystemFont_Shadow_Med1);

    local alertSystem = AlertFrame:AddExternallyAnchoredSubSystem(self);
    AlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function FlavorHeadFrame_OnShow(self)
    UIParent_ManageFramePositions();
end

function FlavorHeadFrame_OnHide(self)
    UIParent_ManageFramePositions();
end

local function CloseAfterVO(self)
    -- Close after some time only
    C_Timer.After(0.5, FlavorHeadFrame_Close)
end

function FlavorHeadFrame_OnEvent(self, event, ...)
    if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and event == "TALKINGHEAD_REQUESTED") then
        FlavorHeadFrame_CloseImmediately(); -- Blizzard content has priority over the frame
    elseif (event == "SOUNDKIT_FINISHED") then
        local voHandle = ...;
        if (self.voHandle == voHandle) then
            -- Stop talking animation
            FlavorHeadFrame_VOComplete(self.MainFrame.Model);
            self.voHandle = nil;

            CloseAfterVO()
        end
    elseif (event == "LOADING_SCREEN_ENABLED") then
        FlavorHeadFrame_Reset(FlavorHeadFrame);
        FlavorHeadFrame_CloseImmediately();
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and self.attachedGUID) then
        local timestamp, type, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
        if (type == "UNIT_DIED" and destGUID == self.attachedGUID) then
            FlavorHeadFrame_Close()
        end
    end
end

function FlavorHeadFrame_CloseImmediately()
    local frame = FlavorHeadFrame;
    if (frame.finishTimer) then
        frame.finishTimer:Cancel();
        frame.finishTimer = nil;
    end
    frame:Hide();
    if (frame.voHandle) then
        StopSound(frame.voHandle, 2000);
        frame.voHandle = nil;
    end
end

function FlavorHeadFrame_OnClick(self, button)
    if (button == "RightButton") then
        FlavorHeadFrame_CloseImmediately();
        return true;
    end

    return false;
end

function FlavorHeadFrame_FadeinFrames()
    local frame = FlavorHeadFrame;
    frame.MainFrame.TalkingHeadsInAnim:Play();
    C_Timer.After(0.5, function()
        frame.NameFrame.Fadein:Play();
    end);
    C_Timer.After(0.75, function()
        frame.TextFrame.Fadein:Play();
    end);
    frame.BackgroundFrame.Fadein:Play();
    frame.PortraitFrame.Fadein:Play();
end

function FlavorHeadFrame_FadeoutFrames()
    local frame = FlavorHeadFrame;
    frame.MainFrame.Close:Play();
    frame.NameFrame.Close:Play();
    frame.TextFrame.Close:Play();
    frame.BackgroundFrame.Close:Play();
    frame.PortraitFrame.Close:Play();
end

function FlavorHeadFrame_Reset(frame, text, name)
    -- set alpha for all animating textures
    frame:StopAnimating();
    frame.BackgroundFrame.TextBackground:SetAlpha(0.01);
    frame.NameFrame.Name:SetAlpha(0.01);
    frame.TextFrame.Text:SetAlpha(0.01);
    frame.MainFrame.Sheen:SetAlpha(0.01);
    frame.MainFrame.TextSheen:SetAlpha(0.01);

    frame.MainFrame.Model:SetAlpha(0.01);
    frame.MainFrame.Model.PortraitBg:SetAlpha(0.01);
    frame.PortraitFrame.Portrait:SetAlpha(0.01);
    frame.MainFrame.Overlay.Glow_LeftBar:SetAlpha(0.01);
    frame.MainFrame.Overlay.Glow_RightBar:SetAlpha(0.01);
    frame.MainFrame.CloseButton:SetAlpha(0.01);

    frame.MainFrame:SetAlpha(1);
    frame.NameFrame.Name:SetText(name);
    frame.TextFrame.Text:SetText(text);
end

FlavorHeadData = {
    currentLineInfo = {},
    currentLineAnimationInfo = {}
}

function FlavorHeadData:SetCurrentLineInfo(duration, name, text, isNewTalkingHead, textureKitID)
    self.currentLineInfo = { duration, name, text, isNewTalkingHead, textureKitID }
end

function FlavorHeadData:SetCurrentLineAnimationInfo(animKit, animIntro, animLoop, lineDuration)
    self.currentLineAnimationInfo = { animKit, animIntro, animLoop, lineDuration }
end

function FlavorHeadData:GetCurrentLineInfo()
    return unpack(self.currentLineInfo)
end
function FlavorHeadData:GetCurrentLineAnimationInfo()
    return unpack(self.currentLineAnimationInfo)
end

local function StopOldTimerAndVO()
    local frame = FlavorHeadFrame;
    if (frame.finishTimer) then
        frame.finishTimer:Cancel();
        frame.finishTimer = nil;
    end
    if (frame.voHandle) then
        StopSound(frame.voHandle);
        frame.voHandle = nil;
    end
end

local function SetFrameTextures(textureKitID)
    local talkingHeadTextureKitRegionFormatStrings = {
        ["TextBackground"] = "%s-TextBackground",
        ["Portrait"] = "%s-PortraitFrame",
    }
    local talkingHeadDefaultAtlases = {
        ["TextBackground"] = "TalkingHeads-TextBackground",
        ["Portrait"] = "TalkingHeads-Alliance-PortraitFrame",
    }
    local talkingHeadFontColor = {
        ["TalkingHeads-Horde"] = { Name = CreateColor(0.28, 0.02, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0) },
        ["TalkingHeads-Alliance"] = { Name = CreateColor(0.02, 0.17, 0.33), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0) },
        ["TalkingHeads-Neutral"] = { Name = CreateColor(0.33, 0.16, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0) },
        ["Normal"] = { Name = CreateColor(1, 0.82, 0.02), Text = CreateColor(1, 1, 1), Shadow = CreateColor(0.0, 0.0, 0.0, 1.0) },
    }

    local frame = FlavorHeadFrame;
    local textureKit;

    if (textureKitID ~= 0) then
        SetupTextureKits(textureKitID, frame.BackgroundFrame, talkingHeadTextureKitRegionFormatStrings, false, true);
        SetupTextureKits(textureKitID, frame.PortraitFrame, talkingHeadTextureKitRegionFormatStrings, false, true);
        textureKit = GetUITextureKitInfo(textureKitID);
    else
        SetupAtlasesOnRegions(frame.BackgroundFrame, talkingHeadDefaultAtlases, true);
        SetupAtlasesOnRegions(frame.PortraitFrame, talkingHeadDefaultAtlases, true);
        textureKit = "Normal";
    end

    local nameColor = talkingHeadFontColor[textureKit].Name;
    local textColor = talkingHeadFontColor[textureKit].Text;
    local shadowColor = talkingHeadFontColor[textureKit].Shadow;
    frame.NameFrame.Name:SetTextColor(nameColor:GetRGB());
    frame.NameFrame.Name:SetShadowColor(shadowColor:GetRGBA());
    frame.TextFrame.Text:SetTextColor(textColor:GetRGB());
    frame.TextFrame.Text:SetShadowColor(shadowColor:GetRGBA());
end

local function SetFrameModel(displayInfo, cameraID, unitId)
    local frame = FlavorHeadFrame;
    local model = frame.MainFrame.Model;
    local currentDisplayInfo = model:GetDisplayInfo();
    if (displayInfo and currentDisplayInfo ~= displayInfo) then
        -- New display info
        model.uiCameraID = cameraID;
        model:SetDisplayInfo(displayInfo);
    elseif (unitId) then
        model:ClearModel()
        model:SetUnit(unitId)
        frame.attachedGUID = UnitGUID(unitId)
    else
        if (model.uiCameraID ~= cameraID) then
            -- New camera
            model.uiCameraID = cameraID;
            Model_ApplyUICamera(model, model.uiCameraID);
        end
        FlavorHeadFrame_SetupAnimations(model);
    end

end

local function UpdateTextualContent(name, textFormatted)
    local frame = FlavorHeadFrame;
    if (name ~= frame.NameFrame.Name:GetText()) then
        -- Fade out the old name and fade in the new name
        frame.NameFrame.Fadeout:Play();
        C_Timer.After(0.25, function()
            frame.NameFrame.Name:SetText(name);
        end);
        C_Timer.After(0.5, function()
            frame.NameFrame.Fadein:Play();
        end);

        frame.MainFrame.TalkingHeadsInAnim:Play();
    end

    if (textFormatted ~= frame.TextFrame.Text:GetText()) then
        -- Fade out the old text and fade in the new text
        frame.TextFrame.Fadeout:Play();
        C_Timer.After(0.25, function()
            frame.TextFrame.Text:SetText(textFormatted);
        end);
        C_Timer.After(0.5, function()
            frame.TextFrame.Fadein:Play();
        end);
    end
end

function FlavorHeadFrame_PrepareModel(displayData, cameraID)
    local displayInfo, unitId
    if (type(displayData) == "number") then
        displayInfo = displayData
    elseif (type(displayData) == "string") then
        unitId = displayData
    end
    local hasModel = (displayInfo and displayInfo ~= 0) or unitId
    if (hasModel) then
        SetFrameModel(displayInfo, cameraID, unitId)
    end
end

function FlavorHeadFrame_PlayCurrent()
    -- TODO Queuing system to add multiple lines ?
    StopOldTimerAndVO()
    local duration, name, text, isNewTalkingHead, textureKitID = FlavorHeadData:GetCurrentLineInfo();

    local textFormatted = string.format(text);
    local frame = FlavorHeadFrame;
    SetFrameTextures(textureKitID)
    frame:Show();

    if (isNewTalkingHead) then
        FlavorHeadFrame_Reset(frame, textFormatted, name);
        FlavorHeadFrame_FadeinFrames();
    else
        UpdateTextualContent(name, textFormatted)
    end

    if (duration and duration > 0) then
        C_Timer.After(duration, function()
            CloseAfterVO()
        end);
    end

end

function FlavorHeadFrame_Close()
    local frame = FlavorHeadFrame;
    FlavorHeadFrame_VOComplete(frame.MainFrame.Model);
    FlavorHeadFrame_IdleAnim(frame.MainFrame.Model);
    if (frame.voHandle) then
        if (frame.finishTimer) then
            frame.finishTimer:Cancel();
        end
        StopSound(frame.voHandle);
        frame.finishTimer = C_Timer.NewTimer(1, function()
            FlavorHeadFrame_FadeoutFrames();
            frame.finishTimer = nil;
            frame.voHandle = nil;
        end
        );
    else
        FlavorHeadFrame_FadeoutFrames();
        frame.finishTimer = nil;
    end

    frame.voHandle = nil;
end

function FlavorHeadFrame_OnModelLoaded(self)
    self:RefreshCamera();
    if self.uiCameraID then
        Model_ApplyUICamera(self, self.uiCameraID);
    else
        self:SetPortraitZoom(0.85)
    end

    FlavorHeadFrame_SetupAnimations(self);
end

function FlavorHeadFrame_SetupAnimations(self)
    local animKit, animIntro, animLoop, lineDuration = FlavorHeadData:GetCurrentLineAnimationInfo();
    if (animKit == nil) then
        return ;
    end
    if (animKit ~= self.animKit) then
        self:StopAnimKit();
        self.animKit = nil;
    end

    if (animKit > 0) then
        self.animKit = animKit;
        -- If intro is 0 (stand) we are assuming that is no-op and skipping to loop.
    elseif (animIntro > 0) then
        self.animIntro = animIntro;
        self.animLoop = animLoop;
    else
        self.animLoop = animLoop;
    end

    if (self.animKit) then
        self:PlayAnimKit(self.animKit, true);
        self:SetScript("OnAnimFinished", nil);
        self.shouldLoop = false;
    elseif (self.animIntro) then
        self:SetAnimation(self.animIntro, 0);
        self.shouldLoop = true;
        self:SetScript("OnAnimFinished", FlavorHeadFrame_IdleAnim);
    else
        self:SetAnimation(self.animLoop, 0);
        self.shouldLoop = true;
        self:SetScript("OnAnimFinished", FlavorHeadFrame_IdleAnim);
    end

    self.lineAnimDone = false;
    if (lineDuration and self.shouldLoop) then
        -- Value taken from Blizzard_TalkingHeadUI.lua
        if (lineDuration > 1.5) then
            C_Timer.After(lineDuration - 1.5, function()
                self.shouldLoop = false;
            end);
        end
    end
end

function FlavorHeadFrame_VOComplete(self)
    self.shouldLoop = false;
end

function FlavorHeadFrame_IdleAnim(self)
    if (self.lineAnimDone) then
        return ;
    end

    -- Stop the animKit
    if (self.animKit) then
        self:StopAnimKit();
        self.animKit = nil;
    end
    -- Keep looping
    if (self.animLoop and self.shouldLoop) then
        self:SetAnimation(self.animLoop, 0);
        self:SetScript("OnAnimFinished", FlavorHeadFrame_IdleAnim);
    else
        self:SetAnimation(AnimIDs.Stand, 0);
        self:SetScript("OnAnimFinished", nil);
        self.lineAnimDone = true;
    end
end

function FlavorHeadFrame_Close_OnFinished(self)
    FlavorHeadFrame:Hide();
end