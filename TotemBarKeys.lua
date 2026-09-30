-- TotemBarKeys: key bindings for Blizzard's totem bar.
--
-- Select: a key opens the selection flyout of a slot or of the call spells.
--         While it was opened by key, the number keys 1-9 pick the entry (like
--         clicking it: the totem is assigned to the slot, not dropped) and
--         ESC closes it.
-- Drop:   one key per slot drops the totem assigned to it, plus one key each
--         for the call spell (drop all) and Totemic Recall.
--
-- The number keys are redirected with override bindings. In combat those can
-- only be set from secure code, so these keys run through a SecureHandler
-- button (BUTTON_NAME) whose "mouse button" names the action:
-- open<N>, pick<N>, close.

local ADDON_NAME = ...

if select(2, UnitClass("player")) ~= "SHAMAN" then return end
local bar = _G.MultiCastActionBarFrame
if not bar then return end

local BUTTON_NAME = "TotemBarKeysButton"
local CAST_NAME   = "TotemBarKeysCast"
local NUM_SLOTS   = 4
local NUM_KEYS    = 9
local PAGE        = 5   -- open5: the Call of the Elements / Ancestors / Spirits selection

local InCombatLockdown = InCombatLockdown
local GetActionInfo    = GetActionInfo
local GetSpellName     = C_Spell and C_Spell.GetSpellName or function(id) return (GetSpellInfo(id)) end
local issecretvalue    = issecretvalue or function(_) return false end

for pos = 1, NUM_SLOTS do
	_G["BINDING_NAME_CLICK " .. BUTTON_NAME .. ":open" .. pos] = ("Slot %d: open totem selection"):format(pos)
	_G["BINDING_NAME_CLICK " .. CAST_NAME .. pos .. ":LeftButton"] = ("Slot %d: drop totem"):format(pos)
end
_G["BINDING_NAME_CLICK " .. BUTTON_NAME .. ":open" .. PAGE] = "Open call spell selection"
_G["BINDING_NAME_CLICK MultiCastSummonSpellButton:LeftButton"] = "Drop all totems (call spell)"
_G["BINDING_NAME_CLICK MultiCastRecallSpellButton:LeftButton"] = "Recall totems"

--------------------------------------------------------------------------------
-- Drop: one secure action button per position on the bar
--------------------------------------------------------------------------------

-- the bar's action button at this position on its current page
local function ActionButton(pos)
	local page = bar.currentPage
	if not page or issecretvalue(page) or page < 1 then page = 1 end
	return _G["MultiCastActionButton" .. ((page - 1) * NUM_SLOTS + pos)]
end

local function ActionSlot(pos)
	local b = ActionButton(pos)
	if not b then return end
	local action = b.action
	if not action and b.CalculateAction then action = b:CalculateAction() end
	if not action and ActionButton_CalculateAction then action = ActionButton_CalculateAction(b) end
	if action and not issecretvalue(action) and action > 0 then return action end
end

local castButtons = {}
for pos = 1, NUM_SLOTS do
	local b = CreateFrame("Button", CAST_NAME .. pos, UIParent, "SecureActionButtonTemplate")
	b:RegisterForClicks("AnyDown")
	-- trigger on key down regardless of ActionButtonUseKeyDown
	b:SetAttribute("pressAndHoldAction", true)
	castButtons[pos] = b
end

-- Points every cast button at the action of the bar's current page. Attributes
-- of secure buttons cannot be changed in combat, so a page switch in combat
-- only takes effect here once combat ends.
local function UpdateCastButtons()
	if InCombatLockdown() then return end
	for pos = 1, NUM_SLOTS do
		local b = castButtons[pos]
		local action = ActionSlot(pos)
		if action then
			b:SetAttribute("type", "action")
			b:SetAttribute("action", action)
		else
			b:SetAttribute("type", "click")
			b:SetAttribute("clickbutton", ActionButton(pos))
		end
	end
end

--------------------------------------------------------------------------------
-- Select: secure button that owns the temporary number-key bindings
--------------------------------------------------------------------------------

local btn = CreateFrame("Button", BUTTON_NAME, UIParent, "SecureHandlerClickTemplate")
btn:RegisterForClicks("AnyUp")
btn:SetAttribute("_onclick", ([[
	local kind, n = strmatch(button, "^(%%a+)(%%d*)$")
	if kind == "open" and self:GetAttribute("open") ~= n then
		for i = 1, %d do
			self:SetBindingClick(true, tostring(i), self:GetName(), "pick" .. i)
		end
		self:SetBindingClick(true, "ESCAPE", self:GetName(), "close")
		self:SetAttribute("open", n)
	else
		self:ClearBindings()
		self:SetAttribute("open", nil)
	end
]]):format(NUM_KEYS))

local labels = setmetatable({}, { __mode = "k" })   -- flyout button -> key label
local switching   -- true while the flyout is being opened by a key

local function Flyout()
	return _G.MultiCastFlyoutFrame
end

local function FlyoutButton(i)
	local flyout = Flyout()
	local buttons = flyout and flyout.buttons
	return (buttons and buttons[i]) or _G["MultiCastFlyoutButton" .. i]
end

local function HideLabels()
	for _, label in next, labels do label:Hide() end
end

local function ShowLabels()
	for i = 1, NUM_KEYS do
		local b = FlyoutButton(i)
		if not b then break end
		local label = labels[b]
		if not label then
			label = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
			label:SetPoint("TOPRIGHT", -1, -2)
			label:SetText(i)
			labels[b] = label
		end
		label:Show()
	end
end

-- drops the number-key bindings; only possible out of combat from here
local function ReleaseKeys()
	if InCombatLockdown() then return end
	ClearOverrideBindings(btn)
	btn:SetAttribute("open", nil)
end

local function HideFlyout()
	local flyout = Flyout()
	if flyout and flyout:IsShown() then flyout:Hide() end
end

local function OpenFlyout(n)
	local flyout = Flyout()
	local parent = (n == PAGE) and _G.MultiCastSummonSpellButton or _G["MultiCastSlotButton" .. n]
	local active = bar.numActiveSlots
	if issecretvalue(active) then active = nil end
	if not flyout or not parent or not bar:IsShown() or (n ~= PAGE and active and n > active) then
		return ReleaseKeys()
	end
	if flyout:IsShown() and flyout.parent == parent then
		return ShowLabels()
	end
	local kind = (n == PAGE) and "page" or "slot"
	switching = true
	if MultiCastFlyoutFrame_ToggleFlyout then
		MultiCastFlyoutFrame_ToggleFlyout(flyout, kind, parent)
	else
		-- same path as hovering the button and clicking the arrow above it
		local arrow = _G.MultiCastFlyoutFrameOpenButton
		if arrow and MultiCastFlyoutFrameOpenButton_Show then
			MultiCastFlyoutFrameOpenButton_Show(arrow, kind, parent)
			arrow:Click()
		end
	end
	switching = false
	if flyout:IsShown() then ShowLabels() else ReleaseKeys() end
end

local function PickFlyout(n)
	local flyout = Flyout()
	if not (flyout and flyout:IsShown()) then return end
	local b = FlyoutButton(n)
	if b and b:IsShown() then b:Click() end
	HideFlyout()
end

btn:HookScript("OnClick", function(self, button)
	local kind, n = button:match("^(%a+)(%d*)$")
	n = tonumber(n)
	if kind == "open" and n and self:GetAttribute("open") then
		OpenFlyout(n)
	elseif kind == "pick" and n then
		PickFlyout(n)
	else
		HideFlyout()
	end
end)

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

local hooked
local function Hook()
	if hooked then return end
	local flyout = Flyout()
	if not flyout then return end
	hooked = true
	-- a flyout closed by other means gives the number keys back
	flyout:HookScript("OnHide", function()
		HideLabels()
		if not switching then ReleaseKeys() end
	end)
	if MultiCastActionBarFrame_Update then
		hooksecurefunc("MultiCastActionBarFrame_Update", UpdateCastButtons)
	end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
pcall(events.RegisterEvent, events, "UPDATE_MULTI_CAST_ACTIONBAR")
events:SetScript("OnEvent", function(_, event)
	Hook()
	UpdateCastButtons()
	if event == "PLAYER_REGEN_ENABLED" then
		local flyout = Flyout()
		if not (flyout and flyout:IsShown()) then ReleaseKeys() end
	end
end)

--------------------------------------------------------------------------------
-- Slash command: shows what the addon sees on the bar
--------------------------------------------------------------------------------

SLASH_TOTEMBARKEYS1 = "/tbk"
SlashCmdList.TOTEMBARKEYS = function()
	local tag = "|cff66dd99" .. ADDON_NAME .. ":|r "
	print(tag .. "Assign keys under Options -> Keybindings -> Totem Bar Keys.")
	print("  Select: open the selection by key, then 1-" .. NUM_KEYS .. ", ESC closes. Drop: one key per slot.")
	print(("  Flyout: %s, ToggleFlyout: %s, arrow: %s, active slots: %s, page: %s, open: %s"):format(
		tostring(Flyout() ~= nil), tostring(MultiCastFlyoutFrame_ToggleFlyout ~= nil),
		tostring(_G.MultiCastFlyoutFrameOpenButton ~= nil),
		issecretvalue(bar.numActiveSlots) and "<secret>" or tostring(bar.numActiveSlots),
		issecretvalue(bar.currentPage) and "<secret>" or tostring(bar.currentPage),
		tostring(btn:GetAttribute("open"))))
	for pos = 1, NUM_SLOTS do
		local action = ActionSlot(pos)
		local _, id = nil, nil
		if action then _, id = GetActionInfo(action) end
		local name = id and not issecretvalue(id) and (GetSpellName(id) or id) or "no totem"
		print(("  Slot %d: action %s, totem %s, drop key: %s %s"):format(
			pos, tostring(action), tostring(name),
			tostring(castButtons[pos]:GetAttribute("type")), tostring(castButtons[pos]:GetAttribute("action") or "")))
	end
end
