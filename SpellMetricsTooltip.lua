SpellInfo = SpellInfo or {}

local function getManaCost(spellID)
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

local function getCastTime(spellID)
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

local function getCurrentMana()
	return SpellInfo.CurrentMana, SpellInfo.ManaIsEstimated
end

local manaTracker = CreateFrame("Frame")
manaTracker:SetScript("OnUpdate", function(_, elapsed)
	manaTracker.elapsed = (manaTracker.elapsed or 0) + elapsed
	if manaTracker.elapsed < 0.2 then
		return
	end
	manaTracker.elapsed = 0

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
end)

local function addSpellMetrics(gameTooltip)
	if not gameTooltip or gameTooltip == SpellInfo.DamageAnalysisTooltip
		or not gameTooltip.GetSpell or not SpellInfo.GetSpellDamage
		or (SpellInfo.PlayerUsesMana and not SpellInfo.PlayerUsesMana()) then
		return
	end

	local _, spellID = gameTooltip:GetSpell()
	if not spellID or (issecretvalue and issecretvalue(spellID)) then
		return
	end
	local effect, healing, alternateHealing, effectDuration = SpellInfo.GetSpellDamage(spellID)
	local manaCost = getManaCost(spellID)
	local castTime = getCastTime(spellID)
	if not effect or not manaCost or not castTime then
		return
	end

	local castInterval = math.max(castTime, effectDuration or 0, 1.5)
	local showEfficiency = not SpellInfo.GetOption or SpellInfo.GetOption("showEfficiency")
	local showSustained = not SpellInfo.GetOption or SpellInfo.GetOption("showSustained")
	local showOOM = not SpellInfo.GetOption or SpellInfo.GetOption("showOOM")
	local showCasts = not SpellInfo.GetOption or SpellInfo.GetOption("showCasts")
	if not showEfficiency and not showSustained and not showOOM and not showCasts then
		return
	end

	local function addMetricLine(label, value, valueColor)
		gameTooltip:AddDoubleLine(label, value, 0.85, 0.85, 0.85, valueColor[1], valueColor[2], valueColor[3])
	end

	gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
	local currentMana, manaIsEstimated = getCurrentMana()
	local castsUntilOOM = currentMana and math.floor(currentMana / manaCost)
	local estimateSuffix = manaIsEstimated and " (full mana)" or ""
	local function addEffectMetrics(effectValue, isHealing)
		local effectPerMana = effectValue / manaCost
		local effectPerSecond = effectValue / castInterval
		local perManaLabel = isHealing and "HPM" or "DPM"
		local perSecondLabel = isHealing and "HPS" or "DPS"
		local untilOOMLabel = isHealing and "HOOM" or "DOOM"
		local metricColor = isHealing and { 0.35, 1, 0.55 } or { 1, 0.75, 0.3 }

		if showEfficiency then
			addMetricLine(perManaLabel, formatMetric(effectPerMana), metricColor)
		end
		if showSustained then
			addMetricLine(perSecondLabel, formatMetric(effectPerSecond), metricColor)
		end
		if showOOM and castsUntilOOM then
			local effectUntilOOM = effectValue * castsUntilOOM
			addMetricLine(untilOOMLabel .. estimateSuffix, formatMetric(effectUntilOOM), metricColor)
		elseif showOOM then
			addMetricLine(untilOOMLabel, "unavailable", { 0.65, 0.65, 0.65 })
		end
	end
	addEffectMetrics(effect, healing)
	if alternateHealing then
		addEffectMetrics(alternateHealing, true)
	end

	if showCasts and currentMana then
		addMetricLine("Casts to OOM" .. estimateSuffix, tostring(castsUntilOOM), { 0.9, 0.9, 0.9 })
	elseif showCasts then
		addMetricLine("Casts to OOM", "unavailable", { 0.65, 0.65, 0.65 })
	end
	gameTooltip:Show()
	return true
end

if GameTooltip and GameTooltip.HookScript then
	GameTooltip:HookScript("OnUpdate", function(gameTooltip)
		if not gameTooltip:IsShown() or gameTooltip == SpellInfo.DamageAnalysisTooltip
			or not gameTooltip.GetSpell then
			return
		end

		local _, spellID = gameTooltip:GetSpell()
		if not spellID or (issecretvalue and issecretvalue(spellID)) then
			return
		end

		local lineCount = gameTooltip:NumLines()
		if gameTooltip.spellMetricsSpellID == spellID
			and gameTooltip.spellMetricsBaseLines
			and lineCount > gameTooltip.spellMetricsBaseLines then
			return
		end

		gameTooltip.spellMetricsSpellID = spellID
		gameTooltip.spellMetricsBaseLines = lineCount
		addSpellMetrics(gameTooltip)
	end)
	GameTooltip:HookScript("OnHide", function(gameTooltip)
		gameTooltip.spellMetricsSpellID = nil
		gameTooltip.spellMetricsBaseLines = nil
	end)
end
