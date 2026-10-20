SpellInfo = SpellInfo or {}

local coefficients = {
	-- ==========================================
	-- PALADIN
	-- ==========================================
	["Seal of Fury"]            	 = { coefficient = 0.100, judgementSpell = "Judgement of Fury", school = 2 },
	["Holy Strike"]             	 = { coefficient = 0.350, school = 2 },
	["Holy Shock"]             	  	 = { coefficient = 0.429, school = 2, healing = true },
	["Holy Light"]              	 = { coefficient = 0.714, school = 2, healing = true, healingOnly = true },
	["Flash of Light"]          	 = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },
	["Consecration"]            	 = { coefficient = 0.336, school = 2 },
	["Seal of Righteousness"]        = { coefficient = 0.429, judgementSpell = "Judgement of Righteousness", school = 2 },
	["Judgement of Righteousness"]   = { coefficient = 0.429, judgementCooldown = 10, school = 2, judgement = true },
	["Seal of Command"]         	 = { coefficient = 0.429, judgementSpell = "Judgement of Command", school = 2 },
	["Judgement of Command"]         = { coefficient = 0.429, judgementCooldown = 10, school = 2, judgement = true },
	["Exorcism"]                	 = { coefficient = 0.429, school = 2 },
	["Holy Wrath"]              	 = { coefficient = 0.190, school = 2 },
	["Holy Shield"]              	 = { coefficient = 0.080, school = 2 },
	["Hammer of Wrath"]         	 = { coefficient = 0.429, school = 2 },
	["Light's Vigil"]           	 = { coefficient = 0.429, healingCoefficient = 0.143, school = 2, healing = true },
	["Judgement of Fury"]            = { coefficient = 0.429, judgementCooldown = 10, school = 2, judgement = true },

	-- ==========================================
	-- SHAMAN
	-- ==========================================
	["Lava Burst"]          = { coefficient = 0.714, school = 3 },
	["Lightning Bolt"]      = { coefficient = 0.714, school = 4 },
	["Chain Lightning"]     = { coefficient = 0.571, school = 4 },
	["Earth Shock"]         = { coefficient = 0.386, school = 4 },
	["Flame Shock"]         = { coefficient = 0.614, directCoefficient = 0.214, dotCoefficient = 0.400, school = 3 },
	["Frost Shock"]         = { coefficient = 0.386, school = 5 },
	["Lightning Shield"]    = { coefficient = 0.267, school = 4 },
	["Healing Wave"]        = { coefficient = 0.857, school = 4, healing = true, healingOnly = true },
	["Lesser Healing Wave"] = { coefficient = 0.429, school = 4, healing = true, healingOnly = true },
	["Chain Heal"]          = { coefficient = 0.714, school = 4, healing = true, healingOnly = true },

	-- ==========================================
	-- MAGE
	-- ==========================================
	["Frostbolt"]           = { coefficient = 0.814, school = 5 },
	["Fireball"]            = { coefficient = 1.000, school = 3 },
	["Arcane Missiles"]     = { coefficient = 1.430, school = 7 },
	["Scorch"]              = { coefficient = 0.429, school = 3 },
	["Fire Blast"]          = { coefficient = 0.429, school = 3 },
	["Arcane Explosion"]    = { coefficient = 0.143, school = 7 }, 
	["Cone of Cold"]        = { coefficient = 0.129, school = 5 },
	["Blizzard"]            = { coefficient = 0.336, school = 5 },
	["Ice Barrier"]         = { coefficient = 0.100, school = 5 }, -- Absorb effect
	["Arcane Blast"]        = { coefficient = 0.429, school = 7 },

	-- ==========================================
	-- WARLOCK
	-- ==========================================
	["Shadow Bolt"]         = { coefficient = 0.857, school = 6 },
	["Corruption"]          = { coefficient = 1.200, school = 6 },
	["Immolate"]            = { coefficient = 0.850, directCoefficient = 0.200, dotCoefficient = 0.650, school = 3 },
	["Curse of Doom"]       = { coefficient = 2.000, school = 6 },
	["Curse of Agony"]      = { coefficient = 1.000, school = 6 },
	["Siphon Life"]         = { coefficient = 0.500, school = 6 },
	["Death Coil"]          = { coefficient = 0.214, school = 6 },
	["Searing Pain"]        = { coefficient = 0.429, school = 3 },
	["Rain of Fire"]        = { coefficient = 0.332, school = 3 },
	["Hellfire"]            = { coefficient = 0.330, school = 3 },
	["Drain Life"]          = { coefficient = 0.500, school = 6 },
	["Drain Soul"]          = { coefficient = 0.500, school = 6 },

	-- ==========================================
	-- PRIEST
	-- ==========================================
	["Smite"]               = { coefficient = 0.714, school = 2 },
	["Holy Fire"]           = { coefficient = 1.000, directCoefficient = 0.750, dotCoefficient = 0.250, school = 2 },
	["Mind Blast"]          = { coefficient = 0.429, school = 6 },
	["Mind Flay"]           = { coefficient = 0.501, school = 6 },
	["Shadow Word: Pain"]   = { coefficient = 1.200, school = 6 },
	["Flash Heal"]          = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },
	["Greater Heal"]        = { coefficient = 0.857, school = 2, healing = true, healingOnly = true },
	["Renew"]               = { coefficient = 1.000, school = 2, healing = true, healingOnly = true },
	["Prayer of Healing"]   = { coefficient = 0.286, school = 2, healing = true, healingOnly = true },
	["Holy Nova"]           = { coefficient = 0.107, school = 2, healing = true },
	["Lesser Heal"]         = { coefficient = 0.714, school = 2, healing = true, healingOnly = true },
	["Heal"]         		= { coefficient = 0.857, school = 2, healing = true, healingOnly = true },
	["Binding Heal"]        = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },
	["Penance"]        		= { coefficient = 0.643, school = 2, healing = true },

	-- ==========================================
	-- DRUID
	-- ==========================================
	["Starfire"]            = { coefficient = 1.000, school = 7 }, 
	["Wrath"]               = { coefficient = 0.571, school = 4 },
	["Moonfire"]            = { coefficient = 0.670, directCoefficient = 0.150, dotCoefficient = 0.520, school = 7 },
	["Insect Swarm"]        = { coefficient = 0.948, school = 4 },
	["Healing Touch"]       = { coefficient = 1.000, school = 4, healing = true, healingOnly = true },
	["Regrowth"]            = { coefficient = 0.783, directCoefficient = 0.286, hotCoefficient = 0.497, school = 4, healing = true, healingOnly = true },
	["Rejuvenation"]        = { coefficient = 0.800, school = 4, healing = true, healingOnly = true },
	["Thorns"]       		= { coefficient = 0.060, school = 4 },
}

local schoolByMask = {
	[1] = 1,
	[2] = 2,
	[4] = 3,
	[8] = 4,
	[16] = 5,
	[32] = 6,
	[64] = 7,
}

local function getSpellName(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo and spellInfo.name then
			return spellInfo.name
		end
	end

	if GetSpellInfo then
		return GetSpellInfo(spellID)
	end

	return nil
end

local function getGeneratedCoefficientData(spellID, fallbackData)
	local generatedData = SpellInfo.GeneratedSpellCoefficients
	local generatedSpell = generatedData and generatedData.spells and generatedData.spells[spellID]
	if not generatedSpell then
		return nil
	end

	local selectedDifficulty
	for _, effect in ipairs(generatedSpell.effects) do
		if selectedDifficulty == nil or effect.difficulty < selectedDifficulty then
			selectedDifficulty = effect.difficulty
		end
	end

	local damageDirect, damagePeriodic = 0, 0
	local healingDirect, healingPeriodic = 0, 0
	for _, effect in ipairs(generatedSpell.effects) do
		if effect.difficulty == selectedDifficulty then
			if effect.effect == 2 then
				damageDirect = damageDirect + effect.coefficient
			elseif effect.effect == 10 or effect.aura == 69 then
				healingDirect = healingDirect + effect.coefficient
			elseif effect.aura == 3 or effect.aura == 8 then
				local tickCount = 1
				if effect.periodMs > 0 and generatedSpell.durationMs > 0 then
					tickCount = math.max(math.floor(generatedSpell.durationMs / effect.periodMs), 1)
				end
				if effect.aura == 3 then
					damagePeriodic = damagePeriodic + effect.coefficient * tickCount
				else
					healingPeriodic = healingPeriodic + effect.coefficient * tickCount
				end
			end
		end
	end

	local hasDamage = damageDirect > 0 or damagePeriodic > 0
	local hasHealing = healingDirect > 0 or healingPeriodic > 0
	if not hasDamage and not hasHealing then
		return nil
	end

	local coefficientData = {
		school = schoolByMask[generatedSpell.school] or (fallbackData and fallbackData.school),
		healing = hasHealing,
		healingOnly = not hasDamage,
		judgementSpell = fallbackData and fallbackData.judgementSpell,
		judgementCooldown = fallbackData and fallbackData.judgementCooldown,
		judgement = fallbackData and fallbackData.judgement,
	}

	if hasDamage then
		coefficientData.coefficient = damageDirect + damagePeriodic
		if damagePeriodic > 0 then
			coefficientData.damageDirectCoefficient = damageDirect
			coefficientData.dotCoefficient = damagePeriodic
		end
	end
	if hasHealing then
		coefficientData.healingCoefficient = healingDirect + healingPeriodic
		if not hasDamage then
			coefficientData.coefficient = coefficientData.healingCoefficient
		end
		if healingPeriodic > 0 then
			coefficientData.healingDirectCoefficient = healingDirect
			coefficientData.hotCoefficient = healingPeriodic
		end
	end

	return coefficientData
end

local function getCoefficientData(spellID, isHealing)
	if not spellID then
		return nil
	end

	local fallbackData = coefficients[getSpellName(spellID)]
	local coefficientData = getGeneratedCoefficientData(spellID, fallbackData) or fallbackData
	if not coefficientData or (isHealing and not coefficientData.healing)
		or (not isHealing and (not coefficientData.school or coefficientData.healingOnly)) then
		return nil
	end
	return coefficientData
end

local function getBaseCoefficient(coefficientData, isHealing)
	if isHealing and coefficientData.healingCoefficient then
		return coefficientData.healingCoefficient
	end
	return coefficientData.coefficient
end

function SpellInfo.GetSpellCoefficientBreakdown(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	if not coefficientData then
		return nil
	end

	local directCoefficient = isHealing
		and (coefficientData.healingDirectCoefficient or coefficientData.directCoefficient)
		or (coefficientData.damageDirectCoefficient or coefficientData.directCoefficient)
	local periodicCoefficient = isHealing
		and (coefficientData.hotCoefficient or coefficientData.dotCoefficient)
		or (coefficientData.dotCoefficient or coefficientData.hotCoefficient)
	if directCoefficient == nil or not periodicCoefficient then
		return nil
	end

	local periodicLabel = isHealing and coefficientData.hotCoefficient and "HoT" or "DoT"
	return directCoefficient,
		periodicCoefficient,
		periodicLabel
end

function SpellInfo.GetSpellCoefficient(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	if not coefficientData then
		return nil
	end
	local coefficient = getBaseCoefficient(coefficientData, isHealing)
	return coefficient
end

local function getJudgementData(coefficientData)
	if not coefficientData then
		return nil
	end
	if coefficientData.judgementSpell then
		return coefficients[coefficientData.judgementSpell]
	end
	if coefficientData.judgement then
		return coefficientData
	end
	return nil
end

function SpellInfo.GetSealJudgementCoefficient(spellID)
	local coefficientData = getCoefficientData(spellID, false)
	local judgementData = coefficientData and coefficientData.judgementSpell
		and getJudgementData(coefficientData)
	return judgementData and judgementData.coefficient or nil
end

function SpellInfo.IsJudgementSpell(spellID)
	local coefficientData = getCoefficientData(spellID, false)
	return coefficientData and coefficientData.judgement == true or false
end

function SpellInfo.GetJudgementSpellPowerDPS(spellID)
	local coefficientData = getCoefficientData(spellID, false)
	local judgementData = getJudgementData(coefficientData)
	if not judgementData or not judgementData.coefficient or not judgementData.judgementCooldown then
		return nil
	end

	local spellPower = SpellInfo.GetSpellBonusTotal(spellID, false)
	if not spellPower or spellPower <= 0 then
		return nil
	end

	return spellPower * judgementData.coefficient / judgementData.judgementCooldown
end

function SpellInfo.GetSpellSchool(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	return coefficientData and coefficientData.school or nil
end

function SpellInfo.GetSpellBonus(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	if not coefficientData then
		return nil
	end

	local totalSpellPower = SpellInfo.GetSpellBonusTotal(spellID, isHealing)
	if not totalSpellPower or totalSpellPower <= 0 then
		return nil
	end

	return totalSpellPower * getBaseCoefficient(coefficientData, isHealing)
end

function SpellInfo.GetSpellBonusTotal(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	if not coefficientData then
		return nil
	end

	if isHealing then
		return GetSpellBonusHealing and GetSpellBonusHealing() or nil
	end
	return coefficientData.school and GetSpellBonusDamage and GetSpellBonusDamage(coefficientData.school) or nil
end
