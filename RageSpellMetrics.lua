SpellInfo = SpellInfo or {}

local function getRageCost(spellID)
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

	local rageType = Enum and Enum.PowerType and Enum.PowerType.Rage or 1
	for _, powerCost in ipairs(powerCosts) do
		if powerCost.type == rageType and powerCost.cost and powerCost.cost > 0 then
			return powerCost.cost
		end
	end

	return nil
end

local function isSwingDamageAbility(spellID)
	local spellName
	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		spellName = spellInfo and spellInfo.name
	end
	if not spellName and GetSpellInfo then
		spellName = GetSpellInfo(spellID)
	end
	if spellName and issecretvalue and issecretvalue(spellName) then
		return false
	end
	return spellName == "Heroic Strike" or spellName == "Maul"
end

local function getMainHandSwingSpeed()
	if not UnitAttackSpeed then
		return nil
	end

	local speed = UnitAttackSpeed("player")
	if (speed and issecretvalue and issecretvalue(speed)) or type(speed) ~= "number" or speed <= 0 then
		return nil
	end
	return speed
end

function SpellInfo.GetRageCost(spellID)
	return getRageCost(spellID)
end

function SpellInfo.AddRageMetrics(gameTooltip, spellID, rageCost, effect, healing, castTime,
	effectDuration, isAverage, formatMetric)
	if not rageCost or not effect or healing then
		return false
	end

	local swingDamageAbility = isSwingDamageAbility(spellID)
	if not castTime and not swingDamageAbility then
		return false
	end

	local showEfficiency = not SpellInfo.GetOption or SpellInfo.GetOption("showEfficiency")
	local showSustained = not SpellInfo.GetOption or SpellInfo.GetOption("showSustained")

	local swingSpeed = swingDamageAbility and getMainHandSwingSpeed()
	local castInterval = math.max(castTime or 0, effectDuration or 0, 1.5)
	gameTooltip:AddLine("Spell Metrics", 1, 0.82, 0.25)
	if SpellInfo.SpellMetricsUtils
		and (not SpellInfo.GetOption or SpellInfo.GetOption("showAverageEffect")) then
		SpellInfo.SpellMetricsUtils.AddAverageEffectMetric(
			gameTooltip, effect, false, isAverage, SpellInfo.SpellMetricsUtils.FormatMetric)
	end
	if showSustained and (not swingDamageAbility or swingSpeed) then
		local damagePerSecond = effect / (swingSpeed or castInterval)
		gameTooltip:AddDoubleLine("DPS", formatMetric(damagePerSecond),
			0.85, 0.85, 0.85, 1, 0.75, 0.3)
	end
	if showEfficiency then
		gameTooltip:AddDoubleLine("DPR", formatMetric(effect / rageCost),
			0.85, 0.85, 0.85, 1, 0.75, 0.3)
	end
	return true
end
