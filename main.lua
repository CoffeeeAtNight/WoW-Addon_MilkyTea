-- Initialize SavedVariables
if not MilkyTeaDB then MilkyTeaDB = {} end

-- Initialize frame positions
MilkyTeaDB.framePos1 = MilkyTeaDB.framePos1 or { "CENTER", "CENTER", 0, 0 }
MilkyTeaDB.framePos2 = MilkyTeaDB.framePos2 or { "CENTER", "CENTER", 0, 0 }
MilkyTeaDB.framePos3 = MilkyTeaDB.framePos3 or { "CENTER", "CENTER", 0, 0 }
MilkyTeaDB.framePos4 = MilkyTeaDB.framePos4 or { "CENTER", "CENTER", 0, 0 }
MilkyTeaDB.timePos = MilkyTeaDB.timePos or { "CENTER", "CENTER", 0, 0 }

-- Utility Functions
local function RestoreUIPositions(frame, posKey)
  if MilkyTeaDB[posKey] then
    local point, relativePoint, xOfs, yOfs = unpack(MilkyTeaDB[posKey])
    print("Restoring position for: " .. posKey)
    frame:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
  end
end

local function SavePosition(frame, posKey)
  local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
  MilkyTeaDB[posKey] = { point, relativePoint, xOfs, yOfs }
end

local function ToggleMoveMode(frame, enable)
  if enable then
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
  else
    frame:EnableMouse(false)
    frame:UnregisterForDrag("LeftButton")
  end
end

local function CreateDraggableImage(name, texturePath, width, height, posKey)
  local imageFrame = CreateFrame("Frame", name, UIParent)
  imageFrame:SetSize(width, height)
  imageFrame:SetMovable(true)

  local imageTexture = imageFrame:CreateTexture(nil, "ARTWORK")
  imageTexture:SetTexture(texturePath)
  imageTexture:SetAllPoints(imageFrame)
  imageTexture:SetAlpha(0.9)

  imageFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)

  imageFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition(self, posKey)
  end)

  RestoreUIPositions(imageFrame, posKey)
  return imageFrame
end

-- Helper function to check if unit is a boss
local function IsBossByGUID(guid)
  local unitType = tonumber(strsub(guid, 5, 5), 16)
  return unitType == 3
end

-- Boss Kill Detection Logic
local eventFrame = CreateFrame("Frame")
local function ToggleBossKillDetection(enable)
  if enable then
    eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  else
    eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  end
end

eventFrame:SetScript("OnEvent", function(self, event)
  local _, subevent, _, _, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
  if subevent == "UNIT_DIED" and IsBossByGUID(destGUID) then
    SendChatMessage("Good Job everyone! Boss " .. destName .. " has been defeated! \\owo/", "GUILD")
  end
end)

-- Images
local imageFrame = CreateDraggableImage("Logo", "Interface\\AddOns\\MilkyTea\\Textures\\shiba.png", 160, 150, "framePos1")
local blossomFrame = CreateDraggableImage("blossom", "Interface\\AddOns\\MilkyTea\\Textures\\blossom.png", 320, 180,
  "framePos2")
local moonFrame = CreateDraggableImage("moon", "Interface\\AddOns\\MilkyTea\\Textures\\skull-kid.png", 145, 250,
  "framePos4")
local catFrame = CreateDraggableImage("cat", "Interface\\AddOns\\MilkyTea\\Textures\\cat.png", 200, 200, "framePos3")
-- Main UI Frame
local MilkyTeaUI = CreateFrame("Frame", "MilkyTeaFrame", UIParent, "BasicFrameTemplateWithInset")
MilkyTeaUI:SetSize(500, 250)
MilkyTeaUI:SetPoint("CENTER", UIParent, "CENTER")
MilkyTeaUI:Hide()

-- Title
MilkyTeaUI.title = MilkyTeaUI:CreateFontString(nil, "OVERLAY")
MilkyTeaUI.title:SetFontObject("GameFontHighlight")
MilkyTeaUI.title:SetPoint("CENTER", MilkyTeaUI.TitleBg, "CENTER", 0, 0)
MilkyTeaUI.title:SetText("MilkyTea UI Menu")

-- Button Creator Function
local function CreateButton(parent, label, width, height, point)
  local btn = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
  btn:SetSize(width, height)
  btn:SetPoint(unpack(point))
  btn:SetText(label)
  btn:SetNormalFontObject("GameFontNormal")
  btn:SetHighlightFontObject("GameFontHighlight")
  return btn
end

-- Say Hello Button
local sayHelloBtn = CreateButton(MilkyTeaUI, "Say '\\owo/'", 150, 30, { "CENTER", 0, 0 })
sayHelloBtn:SetScript("OnClick", function()
  SendChatMessage("\\owo/", "GUILD")
end)

-- Close Button
local closeButton = CreateButton(MilkyTeaUI, "Close", 100, 25, { "BOTTOM", 0, 20 })
closeButton:SetScript("OnClick", function()
  MilkyTeaUI:Hide()
end)

-- Toggle Boss Kill Detection
local isBossKillEnabled = false
local bossKillBtn = CreateButton(MilkyTeaUI, "Enable Boss Kill Detection", 200, 30, { "TOP", 0, -20 })
bossKillBtn:SetScript("OnClick", function()
  isBossKillEnabled = not isBossKillEnabled
  ToggleBossKillDetection(isBossKillEnabled)
  bossKillBtn:SetText(isBossKillEnabled and "Disable Boss Kill Detection" or "Enable Boss Kill Detection")
end)

-- Time Display
local timeFrame = CreateFrame("Frame", "clock", UIParent)
timeFrame:SetSize(400, 100)
timeFrame:SetMovable(true)

local timeText = timeFrame:CreateFontString(nil, "OVERLAY")
timeText:SetFont("Interface\\AddOns\\MilkyTea\\Fonts\\honeybee.ttf", 45, "THICK, OUTLINE")
timeText:SetAllPoints(timeFrame)
timeText:SetTextColor(1, 1, 1, 1)

-- OnUpdate to update the time every second
timeFrame:SetScript("OnUpdate", function(self, elapsed)
  self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
  if self.timeSinceLastUpdate >= 1 then
    timeText:SetText(date("%I:%M %p"))
    self.timeSinceLastUpdate = 0
  end
end)

-- Dragging logic for time
timeFrame:SetScript("OnDragStart", function(self)
  self:StartMoving()
end)

timeFrame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  SavePosition(self, "timePos")
end)

-- Restore position and ensure visibility
RestoreUIPositions(timeFrame, "timePos")
timeFrame:Show()

-- Toggle Move Mode Button
local isMovable = false
local moveBtn = CreateButton(MilkyTeaUI, "UI Move Disabled", 150, 30, { "TOP", 0, -50 })
moveBtn:SetScript("OnClick", function()
  isMovable = not isMovable
  ToggleMoveMode(imageFrame, isMovable)
  ToggleMoveMode(blossomFrame, isMovable)
  ToggleMoveMode(catFrame, isMovable)
  ToggleMoveMode(moonFrame, isMovable)
  ToggleMoveMode(timeFrame, isMovable)
  moveBtn:SetText(isMovable and "UI Move Enabled" or "UI Move Disabled")
end)

-- Register Slash Command to Open UI
SLASH_MILKYTEA1 = "/milkytea"
SlashCmdList["MILKYTEA"] = function()
  if MilkyTeaUI:IsShown() then
    MilkyTeaUI:Hide()
  else
    MilkyTeaUI:Show()
  end
end
