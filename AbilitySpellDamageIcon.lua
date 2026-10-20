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

	return SpellInfo.GetActionSpell and SpellInfo.GetActionSpell(actionSlot)
end

local parseSpellEffect = SpellInfo.ParseSpellEffectText

local function getSpellName(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo and spellInfo.name and (not issecretvalue or not issecretvalue(spellInfo.name)) then
			return spellInfo.name
		end
	end
	if GetSpellInfo then
		local spellName = GetSpellInfo(spellID)
		if spellName and (not issecretvalue or not issecretvalue(spellName)) then
			return spellName
		end
	end
	return nil
end

local function getCurrentComboPoints()
	local comboPoints
	if GetComboPoints then
		comboPoints = GetComboPoints("player", "target")
	end
	if type(comboPoints) ~= "number" or (issecretvalue and issecretvalue(comboPoints)) then
		comboPoints = nil
	end
	if comboPoints == nil and UnitPower then
		local comboPointType = Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4
		comboPoints = UnitPower("player", comboPointType)
	end
	if type(comboPoints) ~= "number" or (issecretvalue and issecretvalue(comboPoints))
		or comboPoints < 1 then
		return nil
	end
	return comboPoints
end

local function getComboPointDamageFromText(text, comboPoints)
	if not text or (issecretvalue and issecretvalue(text)) then
		return nil
	end

	local foundComboPointRow = false
	local matchingDamage
	for line in string.gmatch(text, "[^\n]+") do
		local rowComboPoints, rowText = string.match(line,
			"^%s*(%d+)%s+combo%s+points?%s*:%s*(.+)$")
		if not rowComboPoints then
			rowComboPoints, rowText = string.match(line, "^%s*(%d+)%s+points?%s*:%s*(.+)$")
		end
		if rowComboPoints then
			foundComboPointRow = true
			local values = {}
			for value in string.gmatch(rowText, "%d[%d,]*") do
				values[#values + 1] = tonumber((string.gsub(value, ",", "")))
			end
			if comboPoints == tonumber(rowComboPoints) and string.find(string.lower(rowText), "damage")
				and #values >= 1 then
				if #values >= 2 then
					matchingDamage = (values[1] + values[2]) / 2
				else
					matchingDamage = values[1]
				end
			end
		end
	end
	return matchingDamage, foundComboPointRow
end

local function getAttackPowerCoefficient(text)
	if not text or (issecretvalue and issecretvalue(text)) then
		return nil
	end

	local coefficient = string.match(string.lower(text),
		"(%d+%.?%d*)%s*%%.-attack power.-per combo point")
	return coefficient and tonumber(coefficient) / 100
end

local function getComboPointDamage(spellID, spellName)
	local comboPoints = getCurrentComboPoints()
	local baseDamage, isComboPointAbility
	local attackPowerCoefficient
	if C_Spell and C_Spell.GetSpellDescription then
		local description = C_Spell.GetSpellDescription(spellID)
		baseDamage, isComboPointAbility = getComboPointDamageFromText(description, comboPoints)
		attackPowerCoefficient = getAttackPowerCoefficient(description)
	end
	if not isComboPointAbility and C_TooltipInfo and C_TooltipInfo.GetSpellByID then
		local tooltipData = C_TooltipInfo.GetSpellByID(spellID)
		if tooltipData and tooltipData.lines then
			for _, line in ipairs(tooltipData.lines) do
				local leftDamage, leftIsCombo = getComboPointDamageFromText(line.leftText, comboPoints)
				local rightDamage, rightIsCombo = getComboPointDamageFromText(line.rightText, comboPoints)
				baseDamage = leftDamage or rightDamage or baseDamage
				isComboPointAbility = leftIsCombo or rightIsCombo or isComboPointAbility
				attackPowerCoefficient = getAttackPowerCoefficient(line.leftText)
					or getAttackPowerCoefficient(line.rightText)
					or attackPowerCoefficient
			end
		end
	end
	if not isComboPointAbility and tooltip.SetSpellByID then
		tooltip:SetSpellByID(spellID)
		for index = 1, tooltip:NumLines() do
			local leftLine = _G[tooltip:GetName() .. "TextLeft" .. index]
			local rightLine = _G[tooltip:GetName() .. "TextRight" .. index]
			local leftText = leftLine and leftLine:GetText()
			local rightText = rightLine and rightLine:GetText()
			local leftDamage, leftIsCombo = getComboPointDamageFromText(leftText, comboPoints)
			local rightDamage, rightIsCombo = getComboPointDamageFromText(rightText, comboPoints)
			baseDamage = leftDamage or rightDamage or baseDamage
			isComboPointAbility = leftIsCombo or rightIsCombo or isComboPointAbility
			attackPowerCoefficient = getAttackPowerCoefficient(leftText)
				or getAttackPowerCoefficient(rightText)
				or attackPowerCoefficient
		end
		tooltip:Hide()
	end
	if not isComboPointAbility then
		return nil, false
	end
	if not comboPoints or not baseDamage then
		return nil, true
	end
	if not attackPowerCoefficient and spellName == "Eviscerate" then
		attackPowerCoefficient = 0.03
	end
	if not attackPowerCoefficient or not UnitAttackPower then
		return baseDamage, true
	end

	local baseAttackPower, positiveAttackPower, negativeAttackPower = UnitAttackPower("player")
	if (baseAttackPower and issecretvalue and issecretvalue(baseAttackPower))
		or (positiveAttackPower and issecretvalue and issecretvalue(positiveAttackPower))
		or (negativeAttackPower and issecretvalue and issecretvalue(negativeAttackPower))
		or type(baseAttackPower) ~= "number" then
		return baseDamage, true
	end
	positiveAttackPower = positiveAttackPower or 0
	negativeAttackPower = negativeAttackPower or 0
	if type(positiveAttackPower) ~= "number" or type(negativeAttackPower) ~= "number" then
		return baseDamage, true
	end

	local attackPower = baseAttackPower + positiveAttackPower - negativeAttackPower
	return baseDamage + attackPower * attackPowerCoefficient * comboPoints, true
end

local function getSpellDamage(spellID)
	if not spellID or (issecretvalue and issecretvalue(spellID)) then
		return nil
	end
	local comboPointDamage, isComboPointAbility = getComboPointDamage(spellID, getSpellName(spellID))
	if isComboPointAbility then
		return comboPointDamage, false
	end
	local cached = damageCache[spellID]
	if cached then
		return cached.value, cached.healing, cached.alternateHealing, cached.duration,
			cached.isAverage, cached.alternateHealingIsAverage
	end

	local damage, healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage
	if C_Spell and C_Spell.GetSpellDescription then
		local description = C_Spell.GetSpellDescription(spellID)
		damage, healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
			parseSpellEffect(description)
	end

	if not damage and C_TooltipInfo and C_TooltipInfo.GetSpellByID then
		local tooltipData = C_TooltipInfo.GetSpellByID(spellID)
		if tooltipData and tooltipData.lines then
			for _, line in ipairs(tooltipData.lines) do
				local leftDamage, leftHealing, leftAlternateHealing, leftDuration,
					leftIsAverage, leftAlternateHealingIsAverage =
					parseSpellEffect(line.leftText)
				local rightDamage, rightHealing, rightAlternateHealing, rightDuration,
					rightIsAverage, rightAlternateHealingIsAverage =
					parseSpellEffect(line.rightText)
				damage = leftDamage or rightDamage
				if damage then
					if leftDamage then
						healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
							leftHealing, leftAlternateHealing, leftDuration,
							leftIsAverage, leftAlternateHealingIsAverage
					else
						healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
							rightHealing, rightAlternateHealing, rightDuration,
							rightIsAverage, rightAlternateHealingIsAverage
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
			local leftDamage, leftHealing, leftAlternateHealing, leftDuration,
				leftIsAverage, leftAlternateHealingIsAverage =
				parseSpellEffect(leftText)
			local rightDamage, rightHealing, rightAlternateHealing, rightDuration,
				rightIsAverage, rightAlternateHealingIsAverage =
				parseSpellEffect(rightText)
			damage = leftDamage or rightDamage
			if damage then
				if leftDamage then
					healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
						leftHealing, leftAlternateHealing, leftDuration,
						leftIsAverage, leftAlternateHealingIsAverage
				else
					healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
						rightHealing, rightAlternateHealing, rightDuration,
						rightIsAverage, rightAlternateHealingIsAverage
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
			isAverage = isAverage,
			alternateHealingIsAverage = alternateHealingIsAverage,
		}
	end
	return damage, healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage
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
addon:RegisterEvent("UNIT_POWER_UPDATE")
addon:RegisterEvent("UNIT_POWER_FREQUENT")
addon:RegisterEvent("PLAYER_TARGET_CHANGED")
addon:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
addon:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
addon:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:SetScript("OnEvent", function(_, event, unit, powerType)
	if (event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT")
		and (unit ~= "player" or (powerType ~= "COMBO_POINTS"
			and powerType ~= (Enum and Enum.PowerType and Enum.PowerType.ComboPoints))) then
		return
	end
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
