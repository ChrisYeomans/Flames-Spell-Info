SpellInfo = SpellInfo or {}
local metricsUtils = SpellInfo.SpellMetricsUtils

local function addSpellMetrics(gameTooltip, resolvedSpellID)
	if not gameTooltip or gameTooltip == SpellInfo.DamageAnalysisTooltip
		or (not resolvedSpellID and not gameTooltip.GetSpell) or not SpellInfo.GetSpellDamage then
		return
	end

	local spellID = resolvedSpellID
	if not spellID then
		local _, tooltipSpellID = gameTooltip:GetSpell()
		spellID = tooltipSpellID
	end
	if not spellID or (issecretvalue and issecretvalue(spellID)) then
		return
	end
	local rageCost = SpellInfo.GetRageCost and SpellInfo.GetRageCost(spellID)
	local energyCost = SpellInfo.GetEnergyCost and SpellInfo.GetEnergyCost(spellID)
	if not rageCost and not energyCost and SpellInfo.PlayerUsesMana and not SpellInfo.PlayerUsesMana() then
		return
	end
	local effect, healing, alternateHealing, effectDuration, isAverage, alternateHealingIsAverage =
		SpellInfo.GetSpellDamage(spellID)
	local castTime = metricsUtils.GetCastTime(spellID)
	if not rageCost and not energyCost and not effectDuration and (not castTime or castTime <= 0.1) then
		if C_Spell and C_Spell.GetSpellDescription then
			effectDuration = metricsUtils.ParseEffectDuration(C_Spell.GetSpellDescription(spellID))
		end
		if not effectDuration and gameTooltip.GetName and gameTooltip.NumLines then
			local tooltipName = gameTooltip:GetName()
			if tooltipName then
				for index = 1, gameTooltip:NumLines() do
					local line = _G[tooltipName .. "TextLeft" .. index]
					if line then
						local parsedDuration = metricsUtils.ParseEffectDuration(line:GetText())
						if parsedDuration then
							effectDuration = parsedDuration
							break
						end
					end
				end
			end
		end
	end

	if rageCost then
		return SpellInfo.AddRageMetrics(gameTooltip, spellID, rageCost,
			effect, healing, castTime, effectDuration, isAverage, metricsUtils.FormatMetric)
	end
	if energyCost then
		return SpellInfo.AddEnergyMetrics(gameTooltip, spellID, energyCost, effect,
			healing, castTime, effectDuration, isAverage, metricsUtils.FormatMetric)
	end

	local manaCost = metricsUtils.GetManaCost(spellID)
	local showCoefficient = not SpellInfo.GetOption or SpellInfo.GetOption("showCoefficient")
	local showAverageEffect = not SpellInfo.GetOption or SpellInfo.GetOption("showAverageEffect")
	if not effect then
		if showCoefficient and SpellInfo.AddSpellCoefficientMetrics
			and SpellInfo.AddSpellCoefficientMetrics(gameTooltip, spellID, true, metricsUtils.FormatMetric) then
			return true
		end
		return
	end
	if not manaCost or not castTime then
		gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
		if showAverageEffect then
			metricsUtils.AddAverageEffectMetric(
				gameTooltip, effect, healing, isAverage, metricsUtils.FormatMetric)
			if alternateHealing then
				metricsUtils.AddAverageEffectMetric(gameTooltip, alternateHealing, true,
					alternateHealingIsAverage, metricsUtils.FormatMetric)
			end
		end
		if showCoefficient and SpellInfo.AddSpellCoefficientMetrics then
			SpellInfo.AddSpellCoefficientMetrics(gameTooltip, spellID, false, metricsUtils.FormatMetric)
		end
		return true
	end

	local castInterval = math.max(castTime, effectDuration or 0, 1.5)
	local isJudgement = SpellInfo.IsJudgementSpell and SpellInfo.IsJudgementSpell(spellID)
	local judgementCooldown = 0
	if isJudgement then
		judgementCooldown = metricsUtils.GetSpellCooldown(spellID)
	end
	local damageInterval = math.max(castInterval, judgementCooldown)
	local judgementSPPerSecond = isJudgement and SpellInfo.GetJudgementSpellPowerDPS
		and SpellInfo.GetJudgementSpellPowerDPS(spellID)
	local showEfficiency = not SpellInfo.GetOption or SpellInfo.GetOption("showEfficiency")
	local showSustained = not SpellInfo.GetOption or SpellInfo.GetOption("showSustained")
	local showTick = not SpellInfo.GetOption or SpellInfo.GetOption("showTick")
	local showBonus = not SpellInfo.GetOption or SpellInfo.GetOption("showBonus")
	local showCritical = not SpellInfo.GetOption or SpellInfo.GetOption("showCritical")
	local showOOM = not SpellInfo.GetOption or SpellInfo.GetOption("showOOM")
	local showCasts = not SpellInfo.GetOption or SpellInfo.GetOption("showCasts")

	local function addMetricLine(label, value, valueColor)
		gameTooltip:AddDoubleLine(label, value, 0.85, 0.85, 0.85, valueColor[1], valueColor[2], valueColor[3])
	end

	gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
	if showAverageEffect then
		metricsUtils.AddAverageEffectMetric(
			gameTooltip, effect, healing, isAverage, metricsUtils.FormatMetric)
		if alternateHealing then
			metricsUtils.AddAverageEffectMetric(gameTooltip, alternateHealing, true,
				alternateHealingIsAverage, metricsUtils.FormatMetric)
		end
	end
	if showBonus and SpellInfo.GetSpellBonus and SpellInfo.GetSpellBonusTotal and (healing or not healing) then
		local bonusValue = SpellInfo.GetSpellBonus(spellID, healing == true)
		local totalSpellPower = SpellInfo.GetSpellBonusTotal(spellID, healing == true)
		if bonusValue and bonusValue > 0 and totalSpellPower and totalSpellPower > 0 then
			addMetricLine("Bonus", metricsUtils.FormatMetric(bonusValue) .. " of " .. metricsUtils.FormatMetric(totalSpellPower), healing and { 0.35, 1, 0.55 } or { 1, 0.75, 0.3 })
		end
	end

	local currentMana, manaIsEstimated = metricsUtils.GetCurrentMana()
	local castsUntilOOM = currentMana and math.floor(currentMana / manaCost)
	local estimateSuffix = manaIsEstimated and " (full mana)" or ""
	local function addEffectMetrics(effectValue, isHealing)
		local effectPerMana = effectValue / manaCost
		local effectPerSecond = effectValue / (isJudgement and damageInterval or castInterval)
		local perManaLabel = isHealing and "HPM" or "DPM"
		local perSecondLabel = isHealing and "HPS" or (isJudgement and "Judgement DPS" or "DPS")
		local untilOOMLabel = isHealing and "HOOM" or "DOOM"
		local metricColor = isHealing and { 0.35, 1, 0.55 } or { 1, 0.75, 0.3 }
		if showCritical and SpellInfo.GetSpellSchool and GetSpellCritChance then
			local school = SpellInfo.GetSpellSchool(spellID, isHealing)
			local critChance = school and GetSpellCritChance(school)
			if critChance and critChance > 0 then
				local spellPowerBonus = SpellInfo.GetSpellBonus
					and SpellInfo.GetSpellBonus(spellID, isHealing) or 0
				local critEffect = (effectValue + spellPowerBonus) * 1.5
				addMetricLine("Crit Chance", metricsUtils.FormatMetric(critChance) .. "%", metricColor)
				addMetricLine(isHealing and "Crit Healing" or "Crit Damage", metricsUtils.FormatMetric(critEffect), metricColor)
			end
		end

		if showEfficiency then
			addMetricLine(perManaLabel, metricsUtils.FormatMetric(effectPerMana), metricColor)
		end
		if showSustained then
			addMetricLine(perSecondLabel, metricsUtils.FormatMetric(effectPerSecond), metricColor)
		end
		local tickValue = metricsUtils.GetTickEffect(gameTooltip, spellID)
		if showTick and tickValue then
			addMetricLine((isHealing and "Healing / Tick" or "Damage / Tick"), metricsUtils.FormatMetric(tickValue), metricColor)
		end
		if showOOM and castsUntilOOM then
			local effectUntilOOM = effectValue * castsUntilOOM
			addMetricLine(untilOOMLabel .. estimateSuffix, metricsUtils.FormatMetric(effectUntilOOM), metricColor)
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
	if showOOM then
		if castsUntilOOM then
			local cooldownInterval, cooldownRemaining = metricsUtils.GetSpellCooldown(spellID)
			local manaCastInterval = math.max(castTime, 1.5, cooldownInterval)
			local timeToOOM = cooldownRemaining + castsUntilOOM * manaCastInterval
			addMetricLine("Time to OOM" .. estimateSuffix, metricsUtils.FormatDuration(timeToOOM), { 0.9, 0.9, 0.9 })
		else
			addMetricLine("Time to OOM", "unavailable", { 0.65, 0.65, 0.65 })
		end
	end
	if showCoefficient then
		SpellInfo.AddSpellCoefficientMetrics(gameTooltip, spellID, false, metricsUtils.FormatMetric)
	end
	return true
end

local function hasSpellMetricsHeader(gameTooltip)
	if not gameTooltip.GetName or not _G then
		return false
	end

	local tooltipName = gameTooltip:GetName()
	if not tooltipName then
		return false
	end

	for index = 1, gameTooltip:NumLines() do
		local line = _G[tooltipName .. "TextLeft" .. index]
		local text = line and line:GetText()
		local isLineShown = line and (not line.IsShown or line:IsShown())
		if isLineShown and text and (not issecretvalue or not issecretvalue(text)) and text == "Spell Metrics" then
			return true
		end
	end
	return false
end

local function addMetricsForSpell(gameTooltip, spellID, allowHidden)
	if not gameTooltip or gameTooltip == SpellInfo.DamageAnalysisTooltip
		or (not allowHidden and (not gameTooltip.IsShown or not gameTooltip:IsShown()))
		or not spellID or (issecretvalue and issecretvalue(spellID)) then
		return
	end

	if gameTooltip.spellMetricsSpellID == spellID and hasSpellMetricsHeader(gameTooltip) then
		return
	end

	gameTooltip.spellMetricsSpellID = spellID
	gameTooltip.spellMetricsAdded = addSpellMetrics(gameTooltip, spellID) == true
end

local function addSpellMetricsToTooltip(gameTooltip)
	if not gameTooltip or not gameTooltip.GetSpell then
		return
	end
	local _, spellID = gameTooltip:GetSpell()
	addMetricsForSpell(gameTooltip, spellID, true)
end

SpellInfo.AddActionSpellMetrics = addMetricsForSpell

local function addActionSlotTooltipMetrics(gameTooltip, actionSlot)
	local spellID = actionSlot and SpellInfo.GetActionSpell and SpellInfo.GetActionSpell(actionSlot)
	if not spellID then
		return
	end

	local wasShown = gameTooltip and gameTooltip.IsShown and gameTooltip:IsShown()
	addMetricsForSpell(gameTooltip, spellID, true)
	if wasShown and gameTooltip.spellMetricsAdded and gameTooltip.Show then
		gameTooltip:Show()
	end
end

SpellInfo.AddActionSlotTooltipMetrics = addActionSlotTooltipMetrics

local function addSpellIDTooltipMetrics(gameTooltip, spellID)
	local wasShown = gameTooltip and gameTooltip.IsShown and gameTooltip:IsShown()
	addMetricsForSpell(gameTooltip, spellID, true)
	if wasShown and gameTooltip.spellMetricsAdded and gameTooltip.Show then
		gameTooltip:Show()
	end
end

if GameTooltip then
	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall
		and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Spell then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, addSpellMetricsToTooltip)
	elseif GameTooltip.HookScript then
		GameTooltip:HookScript("OnTooltipSetSpell", addSpellMetricsToTooltip)
	end
	if GameTooltip.HookScript then
		GameTooltip:HookScript("OnHide", function(gameTooltip)
			gameTooltip.spellMetricsSpellID = nil
			gameTooltip.spellMetricsAdded = nil
		end)
	end
	if hooksecurefunc and GameTooltip.SetAction then
		hooksecurefunc(GameTooltip, "SetAction", addActionSlotTooltipMetrics)
	end
	if hooksecurefunc and GameTooltip.SetSpellByID then
		hooksecurefunc(GameTooltip, "SetSpellByID", addSpellIDTooltipMetrics)
	end
end
