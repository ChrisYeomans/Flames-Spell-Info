local addon = CreateFrame("Frame")
SpellInfo = SpellInfo or {}

local energyCostOverlays = {}
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

local function getEnergyCost(spellID)
	if not spellID or not getSpellPowerCost then
		return nil
	end

	local powerCosts = getSpellPowerCost(spellID)
	if not powerCosts then
		return nil
	end

	local energyType = Enum and Enum.PowerType and Enum.PowerType.Energy or 3
	for _, powerCost in ipairs(powerCosts) do
		if powerCost.type == energyType and powerCost.cost and powerCost.cost > 0 then
			return powerCost.cost
		end
	end

	return nil
end

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

	return SpellInfo.GetActionSpell and SpellInfo.GetActionSpell(actionSlot)
end

local function updateButton(button)
	if not button then
		return
	end
	if SpellInfo.GetOption and not SpellInfo.GetOption("showManaCost") then
		local existingOverlay = energyCostOverlays[button]
		if existingOverlay then
			existingOverlay:SetText("")
			existingOverlay:SetShown(false)
		end
		return
	end
	if SpellInfo.PlayerUsesEnergy and not SpellInfo.PlayerUsesEnergy() then
		local existingOverlay = energyCostOverlays[button]
		if existingOverlay then
			existingOverlay:SetText("")
			existingOverlay:SetShown(false)
		end
		return
	end

	local overlay = energyCostOverlays[button]
	if not overlay then
		overlay = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		overlay:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
		overlay:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
		overlay:SetJustifyH("CENTER")
		overlay:SetJustifyV("MIDDLE")
		overlay:SetTextColor(1, 0.85, 0.1, 1)
		overlay:SetShadowOffset(1, -1)
		energyCostOverlays[button] = overlay
	end

	local energyCost = getEnergyCost(getActionSpell(button))
	overlay:SetText(energyCost and tostring(energyCost) or "")
	overlay:SetShown(energyCost ~= nil)
end

local function updateActionButtons()
	for _, prefix in ipairs(actionButtonPrefixes) do
		for index = 1, 12 do
			updateButton(_G[prefix .. index])
		end
	end
end

local function hookActionButton(button)
	if not button or button.abilityEnergyCostHooked then
		return
	end

	button.abilityEnergyCostHooked = true
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

local function refreshActionButtons()
	hookKnownActionButtons()
	updateActionButtons()
end

if C_Timer and C_Timer.NewTicker then
	C_Timer.NewTicker(2, refreshActionButtons)
else
	local refreshTimer = 0
	addon:SetScript("OnUpdate", function(_, elapsed)
		refreshTimer = refreshTimer + elapsed
		if refreshTimer >= 2.3 then
			refreshTimer = 0
			refreshActionButtons()
		end
	end)
end
