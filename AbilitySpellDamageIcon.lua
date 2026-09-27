local damageOverlays = {}
local damageCache = {}
SpellInfo = SpellInfo or {}
local tooltip = CreateFrame("GameTooltip", "AbilityManaCostIconDamageTooltip", nil, "GameTooltipTemplate")
SpellInfo.DamageAnalysisTooltip = tooltip
tooltip:SetOwner(UIParent, "ANCHOR_NONE")

tooltip:Hide()

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

local parseSpellEffect = SpellInfo.ParseSpellEffectText

local function getSpellDamage(spellID)
	if not spellID or (issecretvalue and issecretvalue(spellID)) then
		return nil
	end
	local cached = damageCache[spellID]
	if cached then
		return cached.value, cached.healing, cached.alternateHealing, cached.duration
	end

	local damage, healing, alternateHealing, effectDuration
	if C_Spell and C_Spell.GetSpellDescription then
		local description = C_Spell.GetSpellDescription(spellID)
		damage, healing, alternateHealing, effectDuration = parseSpellEffect(description)
	end

	if not damage and C_TooltipInfo and C_TooltipInfo.GetSpellByID then
		local tooltipData = C_TooltipInfo.GetSpellByID(spellID)
		if tooltipData and tooltipData.lines then
			for _, line in ipairs(tooltipData.lines) do
				local leftDamage, leftHealing, leftAlternateHealing, leftDuration = parseSpellEffect(line.leftText)
				local rightDamage, rightHealing, rightAlternateHealing, rightDuration = parseSpellEffect(line.rightText)
				damage = leftDamage or rightDamage
				if damage then
					if leftDamage then
						healing, alternateHealing, effectDuration = leftHealing, leftAlternateHealing, leftDuration
					else
						healing, alternateHealing, effectDuration = rightHealing, rightAlternateHealing, rightDuration
					end
					break
				end
			end
		end
	end

	if not damage and tooltip.SetSpellByID then
		tooltip:SetSpellByID(spellID)
		for index = 1, tooltip:NumLines() do
			local leftLine = _G[tooltip:GetName() .. "TextLeft" .. index]
			local rightLine = _G[tooltip:GetName() .. "TextRight" .. index]
			local leftText = leftLine and leftLine:GetText()
			local rightText = rightLine and rightLine:GetText()
			local leftDamage, leftHealing, leftAlternateHealing, leftDuration = parseSpellEffect(leftText)
			local rightDamage, rightHealing, rightAlternateHealing, rightDuration = parseSpellEffect(rightText)
			damage = leftDamage or rightDamage
			if damage then
				if leftDamage then
					healing, alternateHealing, effectDuration = leftHealing, leftAlternateHealing, leftDuration
				else
					healing, alternateHealing, effectDuration = rightHealing, rightAlternateHealing, rightDuration
				end
				break
			end
		end
		tooltip:Hide()
	end

	if damage then
		damageCache[spellID] = {
			value = damage,
			healing = healing,
			alternateHealing = alternateHealing,
			duration = effectDuration,
		}
	end
	return damage, healing, alternateHealing, effectDuration
end

SpellInfo.GetSpellDamage = getSpellDamage

local function formatMetric(value)
	if value == math.floor(value) then
		return string.format("%.0f", value)
	end

	if value >= 100 then
		return string.format("%.0f", value)
	elseif value >= 10 then
		return string.format("%.1f", value)
	end
	return string.format("%.2f", value)
end

local function updateButton(button)
	if not button then
		return
	end
	if SpellInfo.GetOption and not SpellInfo.GetOption("showSpellEffect") then
		local existingOverlay = damageOverlays[button]
		if existingOverlay then
			existingOverlay:SetText("")
			existingOverlay:SetShown(false)
		end
		return
	end
	if SpellInfo.PlayerUsesMana and not SpellInfo.PlayerUsesMana() then
		local existingOverlay = damageOverlays[button]
		if existingOverlay then
			existingOverlay:SetText("")
			existingOverlay:SetShown(false)
		end
		return
	end

	local overlay = damageOverlays[button]
	if not overlay then
		overlay = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		overlay:SetPoint("TOP", button, "TOP", 0, -12)
		overlay:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
		overlay:SetJustifyH("CENTER")
		overlay:SetJustifyV("TOP")
		overlay:SetShadowOffset(1, -1)
		damageOverlays[button] = overlay
	end

	local damage, healing = getSpellDamage(getActionSpell(button))
	overlay:SetTextColor(healing and 0.2 or 1, healing and 1 or 0.55, healing and 0.35 or 0.1, 1)
	overlay:SetText(damage and formatMetric(damage) or "")
	overlay:SetShown(damage ~= nil)
end

local function updateActionButtons()
	for _, prefix in ipairs(actionButtonPrefixes) do
		for index = 1, 12 do
			updateButton(_G[prefix .. index])
		end
	end
end

local function hookActionButton(button)
	if not button or button.abilitySpellDamageHooked then
		return
	end

	button.abilitySpellDamageHooked = true
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

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
addon:RegisterEvent("SPELLS_CHANGED")
addon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
addon:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
addon:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
addon:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
addon:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
addon:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:SetScript("OnEvent", function(_, event)
	damageCache = {}
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
		if refreshTimer >= 2.7 then
			refreshTimer = 0
			refreshActionButtons()
		end
	end)
end
