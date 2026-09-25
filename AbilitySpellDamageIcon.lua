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

local function getNumbers(text)
	local numbers = {}
	for number in string.gmatch(text, "%d[%d,]*") do
		local cleanedNumber = string.gsub(number, ",", "")
		numbers[#numbers + 1] = tonumber(cleanedNumber)
	end
	return numbers
end

local function isReadableText(text)
	return text and (not issecretvalue or not issecretvalue(text))
end

local function findDamage(text, requireDamageWord)
	if not isReadableText(text) then
		return nil
	end

	local lowerText = text and string.lower(text)
	local isDefensiveEffect = lowerText and (
		string.find(lowerText, "damage taken")
		or string.find(lowerText, "damage received")
		or string.find(lowerText, "damage reduction")
		or string.find(lowerText, "healing received")
		or string.find(lowerText, "healing taken")
	)
	local hasHealingAction = lowerText and (
		string.find(lowerText, "heals ")
		or string.find(lowerText, "heal%s")
		or string.find(lowerText, "heal the")
		or string.find(lowerText, "restores ")
		or string.find(lowerText, "restores?%s")
		or string.find(lowerText, "absorbs?%s+%d")
		or string.find(lowerText, "absorbing%s+%d")
	)
	local hasEffectWord = lowerText
		and (string.find(lowerText, "damage") or hasHealingAction)
	local hasDamageAction = lowerText and (
		string.find(lowerText, "deals?%s+%d")
		or string.find(lowerText, "inflicts?%s+%d")
		or string.find(lowerText, "causes?%s+%d")
		or string.find(lowerText, "causing%s+%d")
		or string.find(lowerText, "dealing%s+%d")
		or string.find(lowerText, "take%s+%d[^%d%.%%]*damage")
		or string.find(lowerText, "struck%s+for%s+%d")
		or string.find(lowerText, "for%s+%d[^%d%.]*damage")
		or string.find(lowerText, "for%s+%d[%d,]*%s+to%s+%d")
		or string.find(lowerText, "for%s+%d[%d,]*%s*%-%s*%d")
	)
	if not text or isDefensiveEffect or (requireDamageWord and not hasEffectWord) then
		return nil
	end

	if hasDamageAction then
		for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			local average = (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2
			return average
		end

		for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s*%-%s*(%d[%d,]*)[^%d%.%%]*damage") do
			local average = (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2
			return average
		end

		for number in string.gmatch(lowerText, "deals?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "inflicts?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "causes?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "causing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "dealing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "take%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "struck%s+for%s+(%d[%d,]*)") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "for%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end
	end

	if hasHealingAction then
		for low, high in string.gmatch(lowerText, "absorbs?%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			local average = (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2
			return average
		end

		for low, high in string.gmatch(lowerText, "absorbing%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			local average = (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2
			return average
		end

		for number in string.gmatch(lowerText, "absorbs?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "absorbing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		local numbers = getNumbers(text)
		if #numbers >= 2 then
			return (numbers[1] + numbers[2]) / 2
		elseif #numbers == 1 then
			return numbers[1]
		end
	end

	return nil
end

local function isHealingText(text)
	if not isReadableText(text) then
		return false
	end

	local lowerText = text and string.lower(text)
	return lowerText and (
		string.find(lowerText, "heals ")
		or string.find(lowerText, "heal%s")
		or string.find(lowerText, "heal the")
		or string.find(lowerText, "restores ")
		or string.find(lowerText, "restores?%s")
		or string.find(lowerText, "absorbs?%s+%d")
		or string.find(lowerText, "absorbing%s+%d")
	) ~= nil
end

local function getSpellDamage(spellID)
	if not spellID or (issecretvalue and issecretvalue(spellID)) then
		return nil
	end
	local cached = damageCache[spellID]
	if cached then
		return cached.value, cached.healing
	end

	local damage, healing
	if C_Spell and C_Spell.GetSpellDescription then
		local description = C_Spell.GetSpellDescription(spellID)
		damage = findDamage(description, true)
		healing = damage and isHealingText(description) or false
	end

	if not damage and C_TooltipInfo and C_TooltipInfo.GetSpellByID then
		local tooltipData = C_TooltipInfo.GetSpellByID(spellID)
		if tooltipData and tooltipData.lines then
			for _, line in ipairs(tooltipData.lines) do
				local leftDamage = findDamage(line.leftText, true)
				local rightDamage = findDamage(line.rightText, true)
				damage = leftDamage or rightDamage
				if damage then
					healing = isHealingText(line.leftText) or isHealingText(line.rightText)
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
			damage = findDamage(leftText, true) or findDamage(rightText, true)
			if damage then
				healing = isHealingText(leftText) or isHealingText(rightText)
				break
			end
		end
		tooltip:Hide()
	end

	if damage then
		damageCache[spellID] = { value = damage, healing = healing }
	end
	return damage, healing
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

local refreshTimer = 0
addon:SetScript("OnUpdate", function(_, elapsed)
	refreshTimer = refreshTimer + elapsed
	if refreshTimer >= 0.5 then
		refreshTimer = 0
		hookKnownActionButtons()
		updateActionButtons()
	end
end)
