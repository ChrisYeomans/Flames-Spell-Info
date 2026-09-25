local addon = CreateFrame("Frame")
SpellInfo = SpellInfo or {}

local manaCostOverlays = {}
local actionButtonPrefixes = {
	"ActionButton",
	"MainMenuBarActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
}

local getSpellPowerCost = GetSpellPowerCost
if not getSpellPowerCost and C_Spell then
	getSpellPowerCost = C_Spell.GetSpellPowerCost
end

local function getManaCost(spellID)
	if not spellID or not getSpellPowerCost then
		return nil
	end

	local powerCosts = getSpellPowerCost(spellID)
	if not powerCosts then
		return nil
	end

	for _, powerCost in ipairs(powerCosts) do
		if powerCost.type == 0 and powerCost.cost and powerCost.cost > 0 then
			return powerCost.cost
		end
	end

	return nil
end

local function playerUsesMana()
	if not UnitPowerMax then
		return true
	end

	local manaType = Enum and Enum.PowerType and Enum.PowerType.Mana or 0
	local maximumMana = UnitPowerMax("player", manaType)
	if issecretvalue and issecretvalue(maximumMana) then
		return false
	end

	return maximumMana and maximumMana > 0
end

SpellInfo.PlayerUsesMana = playerUsesMana

local function getActionSpell(button)
	local actionSlot
	if ActionButton_GetPagedID then
		actionSlot = ActionButton_GetPagedID(button)
	end
	if not actionSlot then
		actionSlot = tonumber(button.action or button:GetAttribute("action"))
	end

	if not actionSlot then
		return nil
	end

	local actionType, spellID
	if C_ActionBar and C_ActionBar.GetActionInfo then
		local actionInfo = C_ActionBar.GetActionInfo(actionSlot)
		if type(actionInfo) == "table" then
			actionType = actionInfo.actionType or actionInfo.type
			spellID = actionInfo.spellID or actionInfo.id
		end
	end

	if not actionType and GetActionInfo then
		actionType, spellID = GetActionInfo(actionSlot)
	end

	return actionType == "spell" and spellID or nil
end

local function updateButton(button)
	if not button then
		return
	end

	local overlay = manaCostOverlays[button]
	if not overlay then
		overlay = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		overlay:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
		overlay:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
		overlay:SetJustifyH("CENTER")
		overlay:SetJustifyV("BOTTOM")
		overlay:SetJustifyV("MIDDLE")
		overlay:SetTextColor(0.25, 0.65, 1, 1)
		overlay:SetShadowOffset(1, -1)
		manaCostOverlays[button] = overlay
	end

	local spellID = getActionSpell(button)
	local manaCost = getManaCost(spellID)

	overlay:SetText(manaCost and tostring(manaCost) or "")
	overlay:SetShown(manaCost ~= nil)
end

local function updateActionButtons()
	for _, prefix in ipairs(actionButtonPrefixes) do
		for index = 1, 12 do
			updateButton(_G[prefix .. index])
		end
	end
end

local function hookActionButton(button)
	if not button or button.abilityManaCostHooked then
		return
	end

	button.abilityManaCostHooked = true
	button:HookScript("OnShow", updateButton)
	button:HookScript("OnAttributeChanged", updateButton)
	updateButton(button)
end

local function hookKnownActionButtons()
	for _, prefix in ipairs(actionButtonPrefixes) do
		for index = 1, 12 do
			hookActionButton(_G[prefix .. index])
		end
	end
end

if ActionButton_Update then
	hooksecurefunc("ActionButton_Update", updateButton)
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
addon:RegisterEvent("SPELLS_CHANGED")
addon:RegisterEvent("SPELL_UPDATE_USABLE")
addon:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
addon:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
addon:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
addon:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" then
		hookKnownActionButtons()
	end

	updateActionButtons()
end)

local refreshTimer = 0
addon:SetScript("OnUpdate", function(_, elapsed)
	refreshTimer = refreshTimer + elapsed
	if refreshTimer >= 0.5 then
		refreshTimer = 0
		hookKnownActionButtons()
		updateActionButtons()
	end
end)