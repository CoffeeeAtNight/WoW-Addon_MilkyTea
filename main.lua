-- Create a Frame (GUI)
local MilkyTeaUI = CreateFrame("Frame", "MilkyTeaFrame", UIParent, "BasicFrameTemplateWithInset")
MilkyTeaUI:SetSize(800, 400)
MilkyTeaUI:SetPoint("CENTER", UIParent, "CENTER")

-- Set Title
MilkyTeaUI.title = MilkyTeaUI:CreateFontString(nil, "OVERLAY")
MilkyTeaUI.title:SetFontObject("GameFontHighlight")
MilkyTeaUI.title:SetPoint("CENTER", MilkyTeaUI.TitleBg, "CENTER", 0, 0)
MilkyTeaUI.title:SetText("MilkyTea UI Menu")

-- Say Hello Button
local sayHelloBtn = CreateFrame("Button", nil, MilkyTeaUI, "GameMenuButtonTemplate")
sayHelloBtn:SetPoint("CENTER", MilkyTeaUI, "CENTER", 0, 0)
sayHelloBtn:SetSize(150, 30)
sayHelloBtn:SetText("Say '\\owo/'")
sayHelloBtn:SetNormalFontObject("GameFontNormal")
sayHelloBtn:SetHighlightFontObject("GameFontHighlight")

sayHelloBtn:SetScript("OnClick", function()
  SendChatMessage("\\owo/", "GUILD");
end)

local closeButton = CreateFrame("Button", nil, MilkyTeaUI, "GameMenuButtonTemplate")
closeButton:SetPoint("CENTER", MilkyTeaUI, "BOTTOM", 0, 20)
closeButton:SetSize(100, 25)
closeButton:SetText("Close")
closeButton:SetNormalFontObject("GameFontNormal")
closeButton:SetHighlightFontObject("GameFontHighlight")

closeButton:SetScript("OnClick", function()
  MilkyTeaUI:Hide()
end)

MilkyTeaUI:Hide()


---------------- IMAGES ----------------

local imageFrame = CreateFrame("Frame", "Logo", UIParent)
imageFrame:SetSize(160, 150)
imageFrame:SetPoint("TOPLEFT", UIParent, "LEFT", 0, -95)

local imageTexture = imageFrame:CreateTexture(nil, "ARTWORK")
imageTexture:SetTexture("Interface\\AddOns\\MilkyTea\\Textures\\shiba.png")
imageTexture:SetAllPoints(imageFrame)

imageTexture:SetAlpha(0.9)

local blossomFrame = CreateFrame("Frame", "blossom", UIParent)
blossomFrame:SetSize(320, 180)
blossomFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)

local blossomTexture = blossomFrame:CreateTexture(nil, "ARTWORK")
blossomTexture:SetTexture("Interface\\AddOns\\MilkyTea\\Textures\\blossom.png")
blossomTexture:SetAllPoints(blossomFrame)

blossomTexture:SetAlpha(0.9)

---------------- TIME ----------------

local timeFrame = CreateFrame("Frame", nil, UIParent)
timeFrame:SetSize(400, 100)
timeFrame:SetPoint("TOP", UIParent, "TOP", 0, -10)

local timeText = timeFrame:CreateFontString(nil, "OVERLAY")
timeText:SetFontObject(GameFontNormal)
timeText:SetFont("Interface\\AddOns\\MilkyTea\\Fonts\\honeybee.ttf", 45, "THICK, OUTLINE")
timeText:SetPoint("CENTER", timeFrame, "CENTER")
timeText:SetTextColor(1, 1, 1, 1)

local function UpdateRealTime()
  local realTimeString = date("%I:%M %p")
  timeText:SetText(tostring(realTimeString))
end

timeFrame:SetScript("OnUpdate", function(self, elapsed)
  self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
  if self.timeSinceLastUpdate >= 1 then
    UpdateRealTime()
    self.timeSinceLastUpdate = 0
  end
end)

-- Reactive Boss Kill Message
local eventFrame = CreateFrame("Frame")

-- Start with boss kill detection disabled
local isBossKillEnabled = false

-- Function to toggle boss kill detection
local function ToggleBossKillDetection(enable)
  if enable then
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    print("Boss kill detection ENABLED.")
  else
    eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    print("Boss kill detection DISABLED.")
  end
end

-- Function that handles the boss kill event
eventFrame:SetScript("OnEvent", function(self, event)
  local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID =
      CombatLogGetCurrentEventInfo()

  if subevent == "UNIT_DIED" then
    if IsBossByGUID(destGUID) then
      print("Congratulations! You have defeated " .. destName .. "!")
      SendChatMessage("Good Job everyone! Boss " .. destName .. " has been defeated! \\owo/", "GUILD")
    end
  end
end)

-- Helper function to check if the unit is a boss
function IsBossByGUID(guid)
  local unitType = tonumber(strsub(guid, 5, 5), 16)
  return unitType == 3   -- 3 means boss unit type in WoW GUIDs
end

-- Button to toggle the boss kill detection
local toggleBossKillBtn = CreateFrame("Button", nil, MilkyTeaUI, "GameMenuButtonTemplate")
toggleBossKillBtn:SetPoint("TOP", sayHelloBtn, "BOTTOM", 0, -20)
toggleBossKillBtn:SetSize(200, 30)
toggleBossKillBtn:SetText("Enable Boss Kill Detection")
toggleBossKillBtn:SetNormalFontObject("GameFontNormal")
toggleBossKillBtn:SetHighlightFontObject("GameFontHighlight")

-- Button click handler to enable/disable boss kill detection
toggleBossKillBtn:SetScript("OnClick", function()
  isBossKillEnabled = not isBossKillEnabled
  ToggleBossKillDetection(isBossKillEnabled)
  if isBossKillEnabled then
    toggleBossKillBtn:SetText("Disable Boss Kill Detection")
  else
    toggleBossKillBtn:SetText("Enable Boss Kill Detection")
  end
end)

-- Register a Slash Command
SLASH_MILKYTEA1 = "/milkytea"
SlashCmdList["MILKYTEA"] = function()
  if MilkyTeaUI:IsShown() then
    MilkyTeaUI:Hide()
  else
    MilkyTeaUI:Show()
  end
end
