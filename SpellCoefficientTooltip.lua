SpellInfo = SpellInfo or {}

local function formatCoefficient(coefficient)
	return string.format("%.1f%%", coefficient * 100)
end

local function formatSpellCoefficient(spellID, isHealing, coefficient)
	local getBreakdown = SpellInfo.GetSpellCoefficientBreakdown
	if getBreakdown then
		local directCoefficient, periodicCoefficient, periodicLabel =
			getBreakdown(spellID, isHealing)
		if directCoefficient then
			return formatCoefficient(directCoefficient) .. " direct + "
				.. formatCoefficient(periodicCoefficient) .. " " .. periodicLabel
		end
	end
	return formatCoefficient(coefficient)
end

function SpellInfo.AddSpellCoefficientMetrics(gameTooltip, spellID, addHeader, formatMetric)
	if not SpellInfo.GetSpellCoefficient then
		return false
	end

	local damageCoefficient = SpellInfo.GetSpellCoefficient(spellID, false)
	local healingCoefficient = SpellInfo.GetSpellCoefficient(spellID, true)
	local judgementCoefficient = SpellInfo.GetSealJudgementCoefficient
		and SpellInfo.GetSealJudgementCoefficient(spellID)
	if not damageCoefficient and not healingCoefficient and not judgementCoefficient then
		return false
	end

	local function addMetricLine(label, value, valueColor)
		gameTooltip:AddDoubleLine(label, value, 0.85, 0.85, 0.85, valueColor[1], valueColor[2], valueColor[3])
	end

	if addHeader then
		gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
	end
	local isJudgement = SpellInfo.IsJudgementSpell and SpellInfo.IsJudgementSpell(spellID)
	if damageCoefficient and healingCoefficient then
		addMetricLine("Damage SP Coeff", formatSpellCoefficient(spellID, false, damageCoefficient), { 1, 0.75, 0.3 })
		addMetricLine("Healing SP Coeff", formatSpellCoefficient(spellID, true, healingCoefficient), { 0.35, 1, 0.55 })
	elseif healingCoefficient then
		addMetricLine("SP Coeff", formatSpellCoefficient(spellID, true, healingCoefficient), { 0.35, 1, 0.55 })
	elseif damageCoefficient then
		local label = isJudgement and "Judgement SP Coeff" or "SP Coeff"
		addMetricLine(label, formatSpellCoefficient(spellID, false, damageCoefficient), { 1, 0.75, 0.3 })
	end
	if judgementCoefficient then
		addMetricLine("Judgement SP Coeff", formatCoefficient(judgementCoefficient), { 1, 0.75, 0.3 })
	end
	local showSustained = not SpellInfo.GetOption or SpellInfo.GetOption("showSustained")
	local judgementSPPerSecond = showSustained and SpellInfo.GetJudgementSpellPowerDPS
		and SpellInfo.GetJudgementSpellPowerDPS(spellID)
	if judgementSPPerSecond then
		addMetricLine("Judgement SP DPS", formatMetric(judgementSPPerSecond), { 1, 0.75, 0.3 })
	end
	return true
end
