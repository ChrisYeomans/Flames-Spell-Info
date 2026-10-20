SpellInfo = SpellInfo or {}

local function getEnergyCost(spellID)
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

	local energyType = Enum and Enum.PowerType and Enum.PowerType.Energy or 3
	for _, powerCost in ipairs(powerCosts) do
		if powerCost.type == energyType and powerCost.cost and powerCost.cost > 0 then
			return powerCost.cost
		end
	end

	return nil
end

local function playerUsesEnergy()
	if not UnitPowerMax then
		return false
	end

	local energyType = Enum and Enum.PowerType and Enum.PowerType.Energy or 3
	local maximumEnergy = UnitPowerMax("player", energyType)
	if issecretvalue and issecretvalue(maximumEnergy) then
		return false
	end

	return maximumEnergy and maximumEnergy > 0
end

function SpellInfo.GetEnergyCost(spellID)
	return getEnergyCost(spellID)
end

function SpellInfo.PlayerUsesEnergy()
	return playerUsesEnergy()
end

function SpellInfo.AddEnergyMetrics(gameTooltip, spellID, energyCost, effect, healing, castTime,
	effectDuration, isAverage, formatMetric)
	if not energyCost or not effect or healing or not castTime then
		return false
	end

	local showEfficiency = not SpellInfo.GetOption or SpellInfo.GetOption("showEfficiency")
	local showSustained = not SpellInfo.GetOption or SpellInfo.GetOption("showSustained")

	local castInterval = math.max(castTime, effectDuration or 0, 1.5)
	gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
	if SpellInfo.SpellMetricsUtils
		and (not SpellInfo.GetOption or SpellInfo.GetOption("showAverageEffect")) then
		SpellInfo.SpellMetricsUtils.AddAverageEffectMetric(
			gameTooltip, effect, false, isAverage, SpellInfo.SpellMetricsUtils.FormatMetric)
	end
	if showSustained then
		gameTooltip:AddDoubleLine("DPS", formatMetric(effect / castInterval),
			0.85, 0.85, 0.85, 1, 0.75, 0.3)
	end
	if showEfficiency then
		gameTooltip:AddDoubleLine("DPE", formatMetric(effect / energyCost),
			0.85, 0.85, 0.85, 1, 0.85, 0.2)
	end
	return true
end
