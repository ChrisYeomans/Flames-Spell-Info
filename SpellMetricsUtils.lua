SpellInfo = SpellInfo or {}
SpellInfo.SpellMetricsUtils = SpellInfo.SpellMetricsUtils or {}

local utils = SpellInfo.SpellMetricsUtils

function utils.GetManaCost(spellID)
	if not spellID then
		return nil
	end

	local getPowerCost = GetSpellPowerCost
	if not getPowerCost and C_Spell then
		getPowerCost = C_Spell.GetSpellPowerCost
	end
	if not getPowerCost then
		return nil
	end

	local powerCosts = getPowerCost(spellID)
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

function utils.GetCastTime(spellID)
	if not spellID then
		return nil
	end

	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo and spellInfo.castTime then
			return spellInfo.castTime / 1000
		end
	end

	if GetSpellInfo then
		local _, _, _, castTime = GetSpellInfo(spellID)
		if castTime then
			return castTime / 1000
		end
	end

	return nil
end

function utils.GetSpellCooldown(spellID)
	local cooldownInterval = 0
	local cooldownRemaining = 0
	if GetSpellBaseCooldown then
		local baseCooldown, baseGCD = GetSpellBaseCooldown(spellID)
		if baseCooldown and (not issecretvalue or not issecretvalue(baseCooldown)) then
			cooldownInterval = math.max(cooldownInterval, baseCooldown / 1000)
		end
		if baseGCD and (not issecretvalue or not issecretvalue(baseGCD)) then
			cooldownInterval = math.max(cooldownInterval, baseGCD / 1000)
		end
	end

	local startTime, duration, isEnabled
	if C_Spell and C_Spell.GetSpellCooldown then
		local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
		if cooldownInfo then
			startTime = cooldownInfo.startTime
			duration = cooldownInfo.duration
			isEnabled = cooldownInfo.isEnabled
		end
	elseif GetSpellCooldown then
		startTime, duration, isEnabled = GetSpellCooldown(spellID)
	end

	if duration and (not issecretvalue or not issecretvalue(duration)) and duration > 0
		and isEnabled ~= false then
		cooldownInterval = math.max(cooldownInterval, duration)
		local currentTime = GetTime and GetTime()
		if startTime and currentTime and (not issecretvalue or not issecretvalue(startTime))
			and (not issecretvalue or not issecretvalue(currentTime)) then
			cooldownRemaining = math.max(0, startTime + duration - currentTime)
		end
	end

	return cooldownInterval, cooldownRemaining
end

local function parseTickValue(text)
	if not text then
		return nil
	end

	local lowerText = string.lower(text)
	local explicitTickValue, explicitInterval = string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*every%s+(%d[%d,]*)%s+sec")
	if explicitTickValue and explicitInterval then
		return tonumber((string.gsub(explicitTickValue, ",", "")))
	end

	local totalValue, duration = string.match(lowerText, "(%d[%d,]*)%s*[%a%s%-]*damage%s+over%s+(%d[%d,]*)%s*sec")
	if not totalValue or not duration then
		totalValue, duration = string.match(lowerText, "(%d[%d,]*)%s*[%a%s%-]*over%s+(%d[%d,]*)%s*sec")
	end
	if totalValue and duration then
		local total = tonumber((string.gsub(totalValue, ",", "")))
		local tickDuration = tonumber((string.gsub(duration, ",", "")))
		if tickDuration and tickDuration > 0 then
			local defaultInterval = 3
			local tickCount = math.max(1, math.floor(tickDuration / defaultInterval))
			return total / tickCount
		end
	end
	return nil
end

function utils.ParseEffectDuration(text)
	if not text then
		return nil
	end

	local lowerText = string.lower(text)
	local duration = string.match(lowerText, "over%s+(%d[%d,]*)%s*sec") or string.match(lowerText, "for%s+(%d[%d,]*)%s*sec")
	if not duration then
		return nil
	end

	return tonumber((string.gsub(duration, ",", "")))
end

function utils.GetTickEffect(gameTooltip, spellID)
	if not spellID then
		return nil
	end

	if gameTooltip and gameTooltip.GetName and gameTooltip.NumLines then
		local tooltipName = gameTooltip:GetName()
		if tooltipName then
			for index = 1, gameTooltip:NumLines() do
				local line = _G[tooltipName .. "TextLeft" .. index]
				local text = line and line:GetText()
				if text then
					local tickValue = parseTickValue(text)
					if tickValue then
						return tickValue
					end
				end
			end
		end
	end

	local getDescription = C_Spell and C_Spell.GetSpellDescription
	local description = getDescription and getDescription(spellID)
	if description then
		return parseTickValue(description)
	end

	return nil
end

function utils.FormatMetric(value)
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

function utils.AddAverageEffectMetric(gameTooltip, effect, isHealing, isAverage, formatMetric)
	if not effect then
		return
	end

	local metricColor = isHealing and { 0.35, 1, 0.55 } or { 1, 0.75, 0.3 }
	local label = isAverage and (isHealing and "Average Healing" or "Average Damage")
		or (isHealing and "Healing" or "Damage")
	gameTooltip:AddDoubleLine(label,
		formatMetric(effect), 0.85, 0.85, 0.85,
		metricColor[1], metricColor[2], metricColor[3])
end

function utils.FormatDuration(seconds)
	local totalSeconds = math.max(0, math.ceil(seconds))
	local minutes = math.floor(totalSeconds / 60)
	local remainingSeconds = totalSeconds % 60
	if minutes > 0 then
		return string.format("%d min %d sec", minutes, remainingSeconds)
	end
	return string.format("%d sec", totalSeconds)
end

function utils.GetCurrentMana()
	return SpellInfo.CurrentMana, SpellInfo.ManaIsEstimated
end

local manaTracker = CreateFrame("Frame")
local function updateManaEstimate()
	if not UnitPower then
		return
	end

	local manaType = Enum and Enum.PowerType and Enum.PowerType.Mana or 0
	local mana = UnitPower("player", manaType)
	if not issecretvalue or not issecretvalue(mana) then
		SpellInfo.CurrentMana = mana
		SpellInfo.ManaIsEstimated = false
		return
	end

	if UnitPowerMax then
		local maximumMana = UnitPowerMax("player", manaType)
		if not issecretvalue or not issecretvalue(maximumMana) then
			SpellInfo.CurrentMana = maximumMana
			SpellInfo.ManaIsEstimated = true
		end
	end
end

if C_Timer and C_Timer.NewTicker then
	C_Timer.NewTicker(1, updateManaEstimate)
else
	manaTracker:SetScript("OnUpdate", function(_, elapsed)
		manaTracker.elapsed = (manaTracker.elapsed or 0) + elapsed
		if manaTracker.elapsed < 1 then
			return
		end
		manaTracker.elapsed = 0
		updateManaEstimate()
	end)
end
