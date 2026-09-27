SpellInfo = SpellInfo or {}

local coefficients = {
	-- ==========================================
	-- PALADIN
	-- ==========================================
	["Seal of Fury"]            = { coefficient = 0.100, school = 2 },
	["Holy Strike"]             = { coefficient = 0.100, school = 2 },
	["Holy Shock"]              = { coefficient = 0.429, school = 2, healing = true },
	["Holy Light"]              = { coefficient = 0.714, school = 2, healing = true, healingOnly = true },
	["Flash of Light"]          = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },
	["Consecration"]            = { coefficient = 0.330, school = 2 }, 
	["Seal of Righteousness"]   = { coefficient = 0.100, school = 2 }, 
	["Seal of Command"]         = { coefficient = 0.200, school = 2 }, 
	["Exorcism"]                = { coefficient = 0.429, school = 2 },
	["Holy Wrath"]              = { coefficient = 0.190, school = 2 },

	-- ==========================================
	-- SHAMAN
	-- ==========================================
	["Lava Burst"]          = { coefficient = 0.571, school = 3 }, 
	["Lightning Bolt"]      = { coefficient = 0.714, school = 4 }, 
	["Chain Lightning"]     = { coefficient = 0.571, school = 4 }, 
	["Earth Shock"]         = { coefficient = 0.429, school = 4 }, 
	["Flame Shock"]         = { coefficient = 0.429, school = 3 }, 
	["Frost Shock"]         = { coefficient = 0.429, school = 5 },
	["Healing Wave"]        = { coefficient = 0.857, school = 4, healing = true, healingOnly = true },
	["Lesser Healing Wave"] = { coefficient = 0.429, school = 4, healing = true, healingOnly = true },
	["Chain Heal"]          = { coefficient = 0.714, school = 4, healing = true, healingOnly = true },

	-- ==========================================
	-- MAGE
	-- ==========================================
	["Frostbolt"]           = { coefficient = 0.814, school = 5 }, 
	["Fireball"]            = { coefficient = 1.000, school = 3 }, 
	["Arcane Missiles"]     = { coefficient = 1.000, school = 7 }, 
	["Scorch"]              = { coefficient = 0.429, school = 3 },
	["Fire Blast"]          = { coefficient = 0.429, school = 3 },
	["Arcane Explosion"]    = { coefficient = 0.143, school = 7 }, 
	["Cone of Cold"]        = { coefficient = 0.135, school = 5 },
	["Blizzard"]            = { coefficient = 0.330, school = 5 }, 
	["Ice Barrier"]         = { coefficient = 0.100, school = 5 }, -- Absorb effect

	-- ==========================================
	-- WARLOCK
	-- ==========================================
	["Shadow Bolt"]         = { coefficient = 0.857, school = 6 }, 
	["Corruption"]          = { coefficient = 1.000, school = 6 }, 
	["Immolate"]            = { coefficient = 0.650, school = 3 }, 
	["Curse of Agony"]      = { coefficient = 1.000, school = 6 },
	["Siphon Life"]         = { coefficient = 1.000, school = 6 },
	["Death Coil"]          = { coefficient = 0.214, school = 6 },
	["Searing Pain"]        = { coefficient = 0.429, school = 3 },
	["Rain of Fire"]        = { coefficient = 0.330, school = 3 },
	["Hellfire"]            = { coefficient = 0.330, school = 3 },

	-- ==========================================
	-- PRIEST
	-- ==========================================
	["Smite"]               = { coefficient = 0.714, school = 2 },
	["Holy Fire"]           = { coefficient = 1.000, school = 2 }, 
	["Mind Blast"]          = { coefficient = 0.429, school = 6 },
	["Mind Flay"]           = { coefficient = 0.450, school = 6 }, 
	["Shadow Word: Pain"]   = { coefficient = 1.000, school = 6 },
	["Flash Heal"]          = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },
	["Greater Healing"]     = { coefficient = 0.857, school = 2, healing = true, healingOnly = true },
	["Renew"]               = { coefficient = 1.000, school = 2, healing = true, healingOnly = true },
	["Prayer of Healing"]   = { coefficient = 0.429, school = 2, healing = true, healingOnly = true },

	-- ==========================================
	-- DRUID
	-- ==========================================
	["Starfire"]            = { coefficient = 1.000, school = 7 }, 
	["Wrath"]               = { coefficient = 0.571, school = 4 }, 
	["Moonfire"]            = { coefficient = 0.520, school = 7 }, 
	["Insect Swarm"]        = { coefficient = 1.000, school = 4 },
	["Healing Touch"]       = { coefficient = 0.857, school = 4, healing = true, healingOnly = true },
	["Regrowth"]            = { coefficient = 1.000, school = 4, healing = true, healingOnly = true }, -- Has an instant heal + HoT component
	["Rejuvenation"]        = { coefficient = 0.800, school = 4, healing = true, healingOnly = true },
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

local function getRankCastTime(spellID)
	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellID)
		if spellInfo and spellInfo.castTime and (not issecretvalue or not issecretvalue(spellInfo.castTime)) then
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

local function getCoefficientData(spellID, isHealing)
	if not spellID then
		return nil
	end

	local coefficientData = coefficients[getSpellName(spellID)]
	if not coefficientData or (isHealing and not coefficientData.healing)
		or (not isHealing and (not coefficientData.school or coefficientData.healingOnly)) then
		return nil
	end
	return coefficientData
end

local function getEffectiveCoefficient(spellID, coefficientData)
	local coefficient = coefficientData.coefficient
	if coefficientData.referenceCastTime then
		local castTime = getRankCastTime(spellID)
		if castTime then
			coefficient = coefficient * math.min(math.max(castTime, 1.5) / coefficientData.referenceCastTime, 1)
		end
	end

	return coefficient
end

function SpellInfo.GetSpellCoefficient(spellID, isHealing)
	local coefficientData = getCoefficientData(spellID, isHealing)
	if not coefficientData then
		return nil
	end
	return coefficientData.coefficient, getEffectiveCoefficient(spellID, coefficientData)
end

