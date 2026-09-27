local descriptions = {
	[1] = "Your attacks deal an additional 6 Holy damage.",
	[2] = "Deals 120 Fire damage.",
	[3] = "Deals 10 to 20 Nature damage.",
	[4] = "Heals the target for 15 to 20.",
	[5] = "Reduces damage taken by 10%.",
	[6] = "Transforms the enemy into a sheep. Any damage will cancel the effect.",
	[7] = "Your next 3 damaging or healing abilities have their Mana cost reduced by 10% and deal 10% more damage or healing.",
	[8] = "Blasts the target with Holy energy, causing 132 to 143 Holy damage to an enemy, or 113 to 122 healing to an ally.",
	[9] = "Burns the enemy for 10 Fire damage and then an additional 15 Fire damage over 15 sec.",
	[10] = "Heals the target for 32 over 12 sec.",
	[11] = "Burns the enemy for 9 to 12 Arcane damage and then an additional 12 Arcane damage over 9 sec.",
	[12] = "Heals the target of 45 damage over 15 sec.",
	[13] = "Instantly sears the target with fire, causing 22 Fire damage immediately and 30 Fire damage over 12 sec.",
	[14] = "Hurls a fiery ball that causes 33 to 48 Fire damage and an additional 3 Fire damage over 6 sec.",
	[15] = "Launches Arcane Missiles at the enemy, causing 25 Arcane damage each second for 3 sec.",
	[16] = "Heals a friendly target for 80 to 94 and another 91 over 21 sec.",
	[17] = "Creates a violent storm in the target area causing 68 Nature damage to enemies every 1 sec, and increasing the time between attacks of enemies by 20%. Lasts 10 sec. Druid must channel to maintain the spell.",
	[18] = "Regenerates all nearby party members within 20 yards for 285 every 2 sec for 10 sec. Druid must channel to maintain the spell.",
	[19] = "Heals the target for 100.",
	[20] = "Heals the target for 100.",
	[31] = "An instant strike that causes 29 weapon damage plus an additional 5 to 7 Holy damage.",
}
local spellNames = {
	[2] = "Fireball",
	[8] = "Holy Shock",
	[19] = "Healing Touch",
	[20] = "Holy Light",
	[31] = "Holy Strike",
	[21] = "Flash of Light",
	[22] = "Healing Wave",
	[23] = "Lesser Healing Wave",
	[24] = "Chain Heal",
	[25] = "Flash Heal",
	[26] = "Greater Healing",
	[27] = "Renew",
	[28] = "Prayer of Healing",
	[29] = "Regrowth",
	[30] = "Rejuvenation",
}
local function createFrame()
	return {
		SetOwner = function() end,
		Hide = function() end,
		RegisterEvent = function() end,
		SetScript = function() end,
	}
end

CreateFrame = createFrame
UIParent = {}
C_Spell = {
	GetSpellDescription = function(spellID)
		return descriptions[spellID]
	end,
	GetSpellInfo = function(spellID)
		return { name = spellNames[spellID], castTime = spellID == 19 and 1500 or 0 }
	end,
}
GetSpellBonusDamage = function()
	return 0
end
GetSpellBonusHealing = function()
	return 0
end

dofile("SpellDamageTextParser.lua")
dofile("SpellPowerCoefficients.lua")
dofile("AbilitySpellDamageIcon.lua")
dofile("SpellInfoOptions.lua")
assert(SpellInfo.GetOption("showCoefficient") == false, "spell power coefficient display should default off")
SpellInfoDB.showCoefficient = true

for _, spellID in ipairs({ 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 }) do
	assert(SpellInfo.GetSpellCoefficient(spellID, true), "healing spell should have a healing coefficient")
	assert(not SpellInfo.GetSpellCoefficient(spellID, false), "healing-only spell should not have a damage coefficient")
end

local tests = {
	{ spellID = 1, expectedDamage = 6, expectedHealing = false },
	{ spellID = 2, expectedDamage = 120, expectedHealing = false },
	{ spellID = 3, expectedDamage = 15, expectedHealing = false },
	{ spellID = 4, expectedDamage = 17.5, expectedHealing = true },
	{ spellID = 5, expectedDamage = nil, expectedHealing = false },
	{ spellID = 6, spellName = "Polymorph", expectedDamage = nil, expectedHealing = false },
	{ spellID = 7, spellName = "Eureka!", expectedDamage = nil, expectedHealing = false },
	{ spellID = 8, spellName = "Holy Shock", expectedDamage = 137.5, expectedHealing = false, expectedAlternateHealing = 117.5 },
	{ spellID = 9, spellName = "Immolate", expectedDamage = 25, expectedHealing = false },
	{ spellID = 10, spellName = "Rejuvenation", expectedDamage = 32, expectedHealing = true },
	{ spellID = 11, spellName = "Moonfire", expectedDamage = 22.5, expectedHealing = false },
	{ spellID = 12, spellName = "Renew", expectedDamage = 45, expectedHealing = true },
	{ spellID = 13, spellName = "Flame Shock", expectedDamage = 52, expectedHealing = false },
	{ spellID = 14, spellName = "Fireball", expectedDamage = 43.5, expectedHealing = false },
	{ spellID = 15, spellName = "Arcane Missiles", expectedDamage = 75, expectedHealing = false, expectedDuration = 3 },
	{ spellID = 16, spellName = "Regrowth", expectedDamage = 178, expectedHealing = true },
	{ spellID = 17, spellName = "Hurricane", expectedDamage = 680, expectedHealing = false, expectedDuration = 10 },
	{ spellID = 18, spellName = "Tranquility", expectedDamage = 1425, expectedHealing = true, expectedDuration = 10 },
	{ spellID = 19, spellName = "Healing Touch", expectedDamage = 100, expectedHealing = true },
	{ spellID = 20, spellName = "Holy Light", expectedDamage = 100, expectedHealing = true },
	{ spellID = 31, spellName = "Holy Strike", expectedDamage = 6, expectedHealing = false },
}

for _, test in ipairs(tests) do
	local damage, healing, alternateHealing, duration = SpellInfo.GetSpellDamage(test.spellID)
	local spellName = test.spellName or tostring(test.spellID)
	assert(damage == test.expectedDamage, string.format(
		"spell %s: expected damage %s, got %s",
		spellName,
		tostring(test.expectedDamage),
		tostring(damage)
	))
	assert(healing == test.expectedHealing, string.format(
		"spell %s: expected healing flag %s, got %s",
		spellName,
		tostring(test.expectedHealing),
		tostring(healing)
	))
	assert(alternateHealing == test.expectedAlternateHealing, string.format(
		"spell %s: expected alternate healing %s, got %s",
		spellName,
		tostring(test.expectedAlternateHealing),
		tostring(alternateHealing)
	))
	assert(duration == test.expectedDuration, string.format(
		"spell %s: expected effect duration %s, got %s",
		spellName,
		tostring(test.expectedDuration),
		tostring(duration)
	))
end

print(string.format("Passed %d spell-description parsing tests.", #tests))

C_Spell.GetSpellPowerCost = function(spellID)
	local manaCosts = { [9] = 25, [10] = 25, [11] = 25, [12] = 30, [13] = 55, [14] = 45, [15] = 85, [16] = 70, [17] = 880, [18] = 925 }
	return { { type = 0, cost = manaCosts[spellID] or 160 } }
end
C_Spell.GetSpellInfo = function(spellID)
	return {
		name = spellNames[spellID],
		castTime = spellID == 19 and 1500 or (spellID == 9 or spellID == 14 or spellID == 16) and 2000 or 0,
	}
end

local tooltipScripts = {}
local metricValues = {}
local currentSpellID = 8
GameTooltip = {
	HookScript = function(_, script, callback)
		tooltipScripts[script] = function(gameTooltip)
			callback(gameTooltip, 0.2)
		end
	end,
	IsShown = function()
		return true
	end,
	GetSpell = function()
		return nil, currentSpellID
	end,
	NumLines = function()
		return 0
	end,
	AddLine = function() end,
	AddDoubleLine = function(_, label, value)
		metricValues[label] = value
	end,
	Show = function() end,
}
SpellInfo.CurrentMana = 960
SpellInfo.ManaIsEstimated = false

dofile("SpellMetricsTooltip.lua")
tooltipScripts.OnUpdate(GameTooltip)

for _, label in ipairs({ "DPM", "DPS", "DOOM", "HPM", "HPS", "HOOM" }) do
	assert(metricValues[label], "Holy Shock tooltip is missing " .. label)
end

assert(metricValues.DPM == "0.86", "Holy Shock DPM should use its damage amount")
assert(metricValues.HPM == "0.73", "Holy Shock HPM should use its healing amount")
assert(metricValues["Damage SP Coeff"] == "42.9%", "Holy Shock tooltip should show its damage coefficient")
assert(metricValues["Healing SP Coeff"] == "42.9%", "Holy Shock tooltip should show its healing coefficient")
print("Passed Holy Shock tooltip metric test.")

currentSpellID = 9
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "1", "Immolate DPM should include its direct and periodic damage")
assert(metricValues.DPS == "12.5", "Immolate DPS should use its total parsed damage")
print("Passed Immolate tooltip metric test.")

currentSpellID = 10
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.HPM == "1.28", "Rejuvenation HPM should exclude its duration")
print("Passed Rejuvenation tooltip metric test.")

currentSpellID = 11
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "0.90", "Moonfire DPM should include its direct and periodic damage")
print("Passed Moonfire tooltip metric test.")

currentSpellID = 12
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.HPM == "1.50", "Renew HPM should exclude its duration")
print("Passed Renew tooltip metric test.")

currentSpellID = 13
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "0.95", "Flame Shock DPM should include its direct and periodic damage")
print("Passed Flame Shock tooltip metric test.")

currentSpellID = 14
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "0.97", "Fireball DPM should include its direct and periodic damage")
print("Passed Fireball tooltip metric test.")

currentSpellID = 15
SpellInfo.CurrentMana = 425
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "0.88", "Arcane Missiles DPM should include all three ticks")
assert(metricValues.DPS == "25", "Arcane Missiles DPS should use its channel duration")
assert(metricValues.DOOM == "375", "Arcane Missiles DOOM should include all three ticks")
print("Passed Arcane Missiles tooltip metric test.")

currentSpellID = 16
SpellInfo.CurrentMana = 960
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.HPM == "2.54", "Regrowth HPM should include its direct and periodic healing")
print("Passed Regrowth tooltip metric test.")

currentSpellID = 17
SpellInfo.CurrentMana = 880
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.DPM == "0.77", "Hurricane DPM should include all ten ticks")
assert(metricValues.DPS == "68", "Hurricane DPS should use its 10-second duration")
assert(metricValues.DOOM == "680", "Hurricane DOOM should include all ten ticks")
print("Passed Hurricane tooltip metric test.")

currentSpellID = 18
SpellInfo.CurrentMana = 925
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues.HPM == "1.54", "Tranquility HPM should include all five healing ticks")
assert(metricValues.HPS == "142", "Tranquility HPS should use its 10-second duration")
assert(metricValues.HOOM == "1425", "Tranquility HOOM should include all five healing ticks")
print("Passed Tranquility tooltip metric test.")

GetSpellBonusDamage = function(school)
	return school == 3 and 100 or 0
end
local fireballAtLowLevel = SpellInfo.GetSpellDamage(2)
assert(fireballAtLowLevel == 120, "Fireball amount should come from its tooltip, without added spell power")
local fireballBaseCoefficient, fireballEffectiveCoefficient = SpellInfo.GetSpellCoefficient(2, false)
assert(fireballBaseCoefficient == 1 and fireballEffectiveCoefficient == 1,
	"Fireball should not receive a learned-level coefficient penalty")

GetSpellBonusDamage = function(school)
	return school == 2 and 100 or 0
end
GetSpellBonusHealing = function()
	return 200
end
local holyShockDamage, _, holyShockHealing = SpellInfo.GetSpellDamage(8)
assert(holyShockDamage == 137.5, "Holy Shock damage should not have spell power added to its tooltip amount")
assert(holyShockHealing == 117.5, "Holy Shock healing should not have healing power added to its tooltip amount")

GetSpellBonusDamage = function(school)
	return school == 2 and 4 or 0
end
GetSpellBonusHealing = function()
	return 4
end
local rankThreeHolyLight = SpellInfo.GetSpellDamage(20)
local holyLightBaseCoefficient, holyLightEffectiveCoefficient = SpellInfo.GetSpellCoefficient(20, true)
assert(rankThreeHolyLight == 100, "Holy Light amount should come from its tooltip, without added spell power")
assert(holyLightBaseCoefficient == 0.714 and holyLightEffectiveCoefficient == 0.714,
	"Rank 3 Holy Light should retain its observed 71.4% coefficient at level 17")
assert(SpellInfo.GetSpellCoefficient(20, false) == nil, "Holy Light should not expose a damage coefficient")

currentSpellID = 20
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip)
assert(metricValues["SP Coeff"] == "71.4%", "Holy Light tooltip should show its healing coefficient")
assert(metricValues["Damage SP Coeff"] == nil, "Holy Light tooltip should not show a damage coefficient")

GetSpellBonusHealing = function()
	return 200
end
local healingTouchWithPower = SpellInfo.GetSpellDamage(19)
assert(healingTouchWithPower == 100, "Healing Touch amount should not have healing power added to its tooltip amount")

GetSpellBonusDamage = function(school)
	return school == 2 and 9 or 0
end
local holyStrikeWithPower = SpellInfo.GetSpellDamage(31)
assert(holyStrikeWithPower == 6, "Holy Strike should use only its 5-to-7 Holy damage midpoint")
print("Passed coefficient tests.")
