local descriptions = {
	[1] = "Your attacks deal an additional 6 Holy damage.",
	[2] = "Deals 120 Fire damage.",
	[3] = "Deals 10 to 20 Nature damage.",
	[4] = "Heals the target for 15 to 20.",
	[5] = "Reduces damage taken by 10%.",
	[6] = "Transforms the enemy into a sheep, forcing it to wander around for up to 50 sec. While wandering, the sheep cannot attack or cast spells but will regenerate very quickly.",
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
	[32] = "A word of darkness that causes 30 Shadow damage over 18 sec.",
	[33] = "Judges the target, revealing its weaknesses. This effect does no damage.",
	[34] = "Judges the target, revealing its weaknesses. This effect does no damage.",
	[37] = "Judges the target, causing 100 Holy damage.",
	[35] = "Fills the Paladin with the spirit of righteousness for 30 sec, granting each melee attack additional Holy damage.",
	[36] = "Gives the Paladin a chance to deal additional Holy damage on each melee attack.",
	[38] = "Blasts nearby enemies, doing 10 damage to them.",
	[39] = "A strong attack that increases melee damage by 21 and causes a high amount of threat.",
	[40] = "Increases the druid's next attack by 18 damage.",
	[41] = "Hamstrings the enemy, reducing movement speed by 40% for 15 sec. Causes 5 damage.",
	[42] = "Deals 100 damage.",
	[52] = "Deals 100 Frost damage.",
	[53] = "Deals 80 Frost damage.",
	[43] = "Finishing move that causes damage per combo point, increased by Attack Power:\n1 point : 6-10 damage\n2 points: 11-15 damage\n3 points: 16-20 damage\n4 points: 21-25 damage\n5 points: 26-30 damage",
	[44] = "Finishing move causing damage based on combo points:\n1 combo point: 8 damage\n2 combo points: 16 damage\n3 combo points: 24 damage\n4 combo points: 32 damage\n5 combo points: 40 damage\nAdds 2% of Attack Power per combo point.",
}
local spellNames = {
	[2] = "Fireball",
	[8] = "Holy Shock",
	[9] = "Immolate",
	[11] = "Moonfire",
	[13] = "Flame Shock",
	[32] = "Shadow Word: Pain",
	[16] = "Regrowth",
	[19] = "Healing Touch",
	[20] = "Holy Light",
	[31] = "Holy Strike",
	[33] = "Judgement of Righteousness",
	[34] = "Judgement of Command",
	[37] = "Judgement of Righteousness",
	[35] = "Seal of Righteousness",
	[36] = "Seal of Command",
	[39] = "Heroic Strike",
	[40] = "Maul",
	[21] = "Flash of Light",
	[22] = "Healing Wave",
	[23] = "Lesser Healing Wave",
	[24] = "Chain Heal",
	[25] = "Flash Heal",
	[26] = "Greater Heal",
	[27] = "Renew",
	[28] = "Prayer of Healing",
	[29] = "Regrowth",
	[30] = "Rejuvenation",
	[41] = "Hamstring",
	[42] = "Sinister Strike",
	[43] = "Eviscerate",
	[44] = "Test Finisher",
	[45] = "Flame Shock",
	[46] = "Light's Vigil",
	[47] = "Seal of Fury",
	[48] = "Judgement of Fury",
	[51] = "Lightning Shield",
	[52] = "Frostbolt",
	[53] = "Frostbolt",
	[9000001] = "Arcane Missiles",
	[50] = "Lightning Bolt",
	[133] = "Fireball",
	[143] = "Fireball",
	[145] = "Fireball",
	[172] = "Corruption",
	[6222] = "Corruption",
	[6223] = "Corruption",
	[635] = "Holy Light",
	[8052] = "Flame Shock",
	[8921] = "Moonfire",
	[8924] = "Moonfire",
}
local createdFrames = {}
local spellCastTimes = {
	[19] = 1500,
}
local function createFrame()
	local frame = {
		SetOwner = function() end,
		Hide = function() end,
		RegisterEvent = function(self, event)
			self.registeredEvents = self.registeredEvents or {}
			self.registeredEvents[event] = true
		end,
		SetScript = function(self, script, callback)
			self.scripts = self.scripts or {}
			self.scripts[script] = callback
		end,
	}
	createdFrames[#createdFrames + 1] = frame
	return frame
end

CreateFrame = createFrame
UIParent = {}
C_Spell = {
	GetSpellDescription = function(spellID)
		return descriptions[spellID]
	end,
	GetSpellInfo = function(spellID)
		if spellID == "Fireball" then
			return { name = "Fireball", spellID = 2 }
		elseif spellID == "Frostbolt" then
			return { name = "Frostbolt", spellID = 53 }
		end
		return { name = spellNames[spellID], spellID = spellID, castTime = spellCastTimes[spellID] or 0 }
	end,
}
GetSpellBonusDamage = function()
	return 0
end
GetSpellBonusHealing = function()
	return 0
end
GetSpellCritChance = function(school)
	return (school == 3 or school == 6 or school == 7) and 25 or 0
end
local mainHandSwingSpeed = 2.5
local currentComboPoints = 1
GetComboPoints = function()
	return currentComboPoints
end
UnitAttackPower = function()
	return 1000, 0, 0
end
UnitAttackSpeed = function()
	return mainHandSwingSpeed, 0
end
GetSpellBaseCooldown = function(spellID)
	return spellID == 2 and 4000 or 0, 1500
end

dofile("SpellDamageTextParser.lua")
dofile("SpellPowerCoefficients.generated.lua")
dofile("SpellPowerCoefficients.lua")
dofile("ActionBarSpellUtils.lua")
dofile("AbilitySpellDamageIcon.lua")
dofile("SpellInfoOptions.lua")
local damageAddonFrame
for _, frame in ipairs(createdFrames) do
	if frame.registeredEvents and frame.registeredEvents.UNIT_POWER_UPDATE then
		damageAddonFrame = frame
	end
end
assert(damageAddonFrame, "damage overlay addon should register its power-update frame")
assert(SpellInfo.GetOption("showTick") == true, "per-tick display should default on")
assert(SpellInfo.GetOption("showBonus") == true, "bonus display should default on")
assert(SpellInfo.GetOption("showCritical") == true, "critical display should default on")
assert(SpellInfo.GetOption("showAverageEffect") == true, "average damage/healing display should default on")
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
	{ spellID = 32, spellName = "Shadow Word: Pain", expectedDamage = 30, expectedHealing = false, expectedDuration = 18 },
	{ spellID = 38, spellName = "Thunder Clap", expectedDamage = 10, expectedHealing = false },
	{ spellID = 39, spellName = "Heroic Strike", expectedDamage = 21, expectedHealing = false },
	{ spellID = 40, spellName = "Maul", expectedDamage = 18, expectedHealing = false },
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
	local rageCosts = { [39] = 15, [40] = 10, [41] = 15 }
	local energyCosts = { [42] = 40 }
	if rageCosts[spellID] then
		return { { type = 1, cost = rageCosts[spellID] } }
	end
	if energyCosts[spellID] then
		return { { type = 3, cost = energyCosts[spellID] } }
	end
	return { { type = 0, cost = manaCosts[spellID] or 160 } }
end
C_Spell.GetSpellInfo = function(spellID)
	if spellID == "Fireball" then
		return { name = "Fireball", spellID = 2 }
	elseif spellID == "Frostbolt" then
		return { name = "Frostbolt", spellID = 53 }
	end
	return {
		name = spellNames[spellID],
		spellID = spellID,
		castTime = spellCastTimes[spellID]
			or (spellID == 9 or spellID == 14 or spellID == 16) and 2000
			or 0,
	}
end

local function assertCoefficientBreakdown(spellID, isHealing, expectedDirect, expectedPeriodic, expectedLabel)
	local direct, periodic, periodicLabel =
		SpellInfo.GetSpellCoefficientBreakdown(spellID, isHealing)
	assert(direct == expectedDirect, string.format("spell %d: expected direct coefficient %s, got %s",
		spellID, tostring(expectedDirect), tostring(direct)))
	assert(periodic == expectedPeriodic, string.format("spell %d: expected periodic coefficient %s, got %s",
		spellID, tostring(expectedPeriodic), tostring(periodic)))
	assert(periodicLabel == expectedLabel, string.format("spell %d: expected periodic label %s, got %s",
		spellID, tostring(expectedLabel), tostring(periodicLabel)))
end

assert(SpellInfo.GetSealJudgementCoefficient(35) == 0.429,
	"Seal of Righteousness should expose its Judgement coefficient")
assert(SpellInfo.GetSealJudgementCoefficient(36) == 0.429,
	"Seal of Command should expose its Judgement coefficient")
assert(SpellInfo.GetSealJudgementCoefficient(2) == nil,
	"non-seal spells should not expose a seal Judgement coefficient")
GetSpellBonusDamage = function(school)
	return school == 2 and 100 or 0
end
assert(SpellInfo.GetJudgementSpellPowerDPS(35) == 4.29,
	"Seal of Righteousness should calculate Judgement spell-power DPS")
assert(SpellInfo.GetJudgementSpellPowerDPS(36) == 4.29,
	"Seal of Command should calculate Judgement spell-power DPS")
assert(SpellInfo.IsJudgementSpell(33), "Judgement of Righteousness should be identified as a Judgement")
assert(not SpellInfo.IsJudgementSpell(35), "Seal of Righteousness should not be identified as a Judgement spell")

assertCoefficientBreakdown(9, false, 0.200, 0.650, "DoT")
assertCoefficientBreakdown(11, false, 0.150, 0.520, "DoT")
assertCoefficientBreakdown(13, false, 0.214, 0.400, "DoT")
assertCoefficientBreakdown(16, true, 0.286, 0.497, "HoT")
assert(SpellInfo.GetSpellCoefficientBreakdown(2, false) == nil,
	"spells without separate direct and periodic coefficients should not return a breakdown")
assert(SpellInfo.GetSpellCoefficientBreakdown(16, false) == nil,
	"healing-only spells should not return a damage coefficient breakdown")
assert(SpellInfo.GetSpellCoefficientBreakdown(9, true) == nil,
	"damage spells should not return a healing coefficient breakdown")
assert(SpellInfo.GetSpellCoefficientBreakdown(999, false) == nil,
	"unknown spells should not return a coefficient breakdown")
print("Passed direct and periodic coefficient breakdown tests.")

local tooltipScripts = {}
local metricValues = {}
local tooltipShowCalls = 0
local originalTooltipShowCalls = 0
local tooltipLineCount = 0
local tooltipName = "SpellInfoMetricsTestTooltip"
local tooltipTextLines = {}
local hiddenTooltipLines = {}
local currentSpellID = 8
local lastTooltipSpellID

local function clearTooltipLines()
	for index = 1, tooltipLineCount do
		_G[tooltipName .. "TextLeft" .. index] = nil
	end
	tooltipLineCount = 0
	tooltipTextLines = {}
	hiddenTooltipLines = {}
end

local function addTooltipLine(label)
	tooltipLineCount = tooltipLineCount + 1
	local lineIndex = tooltipLineCount
	tooltipTextLines[lineIndex] = label
	_G[tooltipName .. "TextLeft" .. lineIndex] = {
		GetText = function()
			return tooltipTextLines[lineIndex]
		end,
		IsShown = function()
			return not hiddenTooltipLines[lineIndex]
		end,
	}
end

GameTooltip = {
	HookScript = function(_, script, callback)
		tooltipScripts[script] = callback
		if script == "OnTooltipSetSpell" then
			tooltipScripts.OnUpdate = callback
		end
	end,
	IsShown = function()
		return true
	end,
	GetSpell = function()
		if lastTooltipSpellID ~= currentSpellID then
			clearTooltipLines()
			lastTooltipSpellID = currentSpellID
		end
		return nil, currentSpellID
	end,
	SetAction = function() end,
	SetSpellByID = function() end,
	NumLines = function()
		return tooltipLineCount
	end,
	GetName = function()
		return tooltipName
	end,
	AddLine = function(_, label)
		addTooltipLine(label)
	end,
	AddDoubleLine = function(_, label, value)
		metricValues[label] = value
		addTooltipLine(label)
	end,
	Show = function()
		tooltipShowCalls = tooltipShowCalls + 1
	end,
}
SpellInfo.CurrentMana = 960
SpellInfo.ManaIsEstimated = false

dofile("SpellMetricsUtils.lua")
dofile("RageSpellMetrics.lua")
dofile("EnergySpellMetrics.lua")
dofile("SpellCoefficientTooltip.lua")
local gameTooltipSetActionHook
local gameTooltipSetSpellByIDHook
hooksecurefunc = function(target, method, callback)
	if target == GameTooltip then
		if method == "SetAction" then
			gameTooltipSetActionHook = callback
		elseif method == "SetSpellByID" then
			gameTooltipSetSpellByIDHook = callback
		end
	end
end
dofile("SpellMetricsTooltip.lua")
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(tooltipShowCalls == 0, "adding spell metrics should not force a tooltip redraw")

for _, label in ipairs({ "DPM", "DPS", "DOOM", "HPM", "HPS", "HOOM" }) do
	assert(metricValues[label], "Holy Shock tooltip is missing " .. label)
end
assert(metricValues["Time to OOM"] == "9 sec", "Holy Shock time to OOM should use available casts and the global cooldown")

assert(metricValues.DPM == "0.86", "Holy Shock DPM should use its damage amount")
assert(metricValues.HPM == "0.73", "Holy Shock HPM should use its healing amount")
assert(metricValues["Average Damage"] == "138" and metricValues["Average Healing"] == "118",
	"Holy Shock should show base average damage and healing matching the action-bar values, got "
		.. tostring(metricValues["Average Damage"]) .. " and " .. tostring(metricValues["Average Healing"]))
assert(tooltipTextLines[2] == "Average Damage" and tooltipTextLines[3] == "Average Healing",
	"average damage and healing should be the first metrics after the header")
assert(metricValues["Damage SP Coeff"] == "42.9%", "Holy Shock tooltip should show its damage coefficient")
assert(metricValues["Healing SP Coeff"] == "42.9%", "Holy Shock tooltip should show its healing coefficient")

SpellInfoDB.showAverageEffect = false
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues["Average Damage"] == nil and metricValues["Average Healing"] == nil,
	"average damage/healing setting should hide those tooltip lines")
assert(metricValues.DPM == "0.86", "hiding average damage/healing should not hide other tooltip metrics")
SpellInfoDB.showAverageEffect = true

clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.86", "Holy Shock metrics should be restored if WoW clears them")
local tooltipLinesWithMetrics = tooltipLineCount
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(tooltipLineCount == tooltipLinesWithMetrics, "metrics already present should not be duplicated")
assert(tooltipShowCalls == 0, "restoring metrics should not force a tooltip redraw")

hiddenTooltipLines[1] = true
tooltipLineCount = 1
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.86", "metrics should be restored if the old header line is hidden")
clearTooltipLines()
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.86", "metrics should be restored after another tooltip rebuild")
assert(tooltipShowCalls == 0, "restoring metrics after a tooltip update should not force a redraw")
print("Passed Holy Shock tooltip metric test.")

currentSpellID = 9
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "1", "Immolate DPM should include its direct and periodic damage")
assert(metricValues.DPS == "12.5", "Immolate DPS should use its total parsed damage")
assert(metricValues["SP Coeff"] == "20.0% direct + 65.0% DoT",
	"Immolate should show separate direct and DoT coefficients, got " .. tostring(metricValues["SP Coeff"]))
print("Passed Immolate tooltip metric test.")

currentSpellID = 10
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.HPM == "1.28", "Rejuvenation HPM should exclude its duration")
print("Passed Rejuvenation tooltip metric test.")

currentSpellID = 11
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.90", "Moonfire DPM should include its direct and periodic damage")
assert(metricValues["Average Damage"] == "22.5", "Moonfire should show average full-cast damage")
assert(metricValues["SP Coeff"] == "15.0% direct + 52.0% DoT", "Moonfire should show separate direct and DoT coefficients")
assert(metricValues["Crit Chance"] == "25%", "Moonfire should show its Arcane critical chance")
assert(metricValues["Crit Damage"] == "33.8",
	"Moonfire critical damage should include both its direct hit and DoT")
print("Passed Moonfire tooltip metric test.")

currentSpellID = 12
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.HPM == "1.50", "Renew HPM should exclude its duration")
assert(metricValues.HPS == "3", "Renew HPS should use its 15-second duration")
print("Passed Renew tooltip metric test.")

currentSpellID = 32
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPS == "1.67", "Shadow Word: Pain DPS should use its 18-second DoT duration")
assert(metricValues["Damage / Tick"] == "5", "Shadow Word: Pain tooltip should infer its 3-second tick value from the 18-second duration")
assert(metricValues["Crit Chance"] == "25%" and metricValues["Crit Damage"] == "45",
	"periodic-only Shadow Word: Pain should show its critical chance and DoT critical damage")
print("Passed Shadow Word: Pain tooltip metric test.")

currentSpellID = 13
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.95", "Flame Shock DPM should include its direct and periodic damage")
assert(metricValues["SP Coeff"] == "21.4% direct + 40.0% DoT", "Flame Shock should show separate direct and DoT coefficients")
print("Passed Flame Shock tooltip metric test.")

currentSpellID = 14
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.97", "Fireball DPM should include its direct and periodic damage")
assert(metricValues["Average Damage"] == "43.5",
	"Fireball damage ranges should keep the average label")
print("Passed Fireball tooltip metric test.")

GetSpellBonusDamage = function(school)
	return school == 3 and 100 or 0
end
currentSpellID = 2
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.Bonus == "100 of 100", "Fireball tooltip should show the coefficient-adjusted spell-power usage and the total spell power")
assert(metricValues.Damage == "120" and metricValues["Average Damage"] == nil,
	"fixed Fireball damage should use a non-average label and match its action-bar value")
assert(metricValues["Crit Chance"] == "25%", "Fireball tooltip should use the Fire spell critical chance")
assert(metricValues["Crit Damage"] == "330", "Fireball critical damage should include its spell-power bonus")
assert(metricValues["Time to OOM"] == "24 sec", "Fireball time to OOM should include its four-second cooldown")
SpellInfoDB.showCritical = false
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues["Crit Chance"] == nil and metricValues["Crit Damage"] == nil, "critical setting should hide critical metrics")
SpellInfoDB.showCritical = true
print("Passed Fireball bonus tooltip metric test.")

currentSpellID = 15
SpellInfo.CurrentMana = 425
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.88", "Arcane Missiles DPM should include all three ticks")
assert(metricValues.DPS == "25", "Arcane Missiles DPS should use its channel duration")
assert(metricValues.DOOM == "375", "Arcane Missiles DOOM should include all three ticks")
print("Passed Arcane Missiles tooltip metric test.")

currentSpellID = 16
SpellInfo.CurrentMana = 960
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.HPM == "2.54", "Regrowth HPM should include its direct and periodic healing")
assert(metricValues["SP Coeff"] == "28.6% direct + 49.7% HoT",
	"Regrowth should show separate direct and HoT coefficients, got " .. tostring(metricValues["SP Coeff"])
		.. " (healing: " .. tostring(metricValues["Healing SP Coeff"]) .. ")")
print("Passed Regrowth tooltip metric test.")

GetSpellBonusDamage = function(school)
	return school == 2 and 100 or 0
end
for _, judgementTest in ipairs({
	{ spellID = 33, expectedCoefficient = "42.9%" },
	{ spellID = 34, expectedCoefficient = "42.9%" },
}) do
	currentSpellID = judgementTest.spellID
	metricValues = {}
	tooltipScripts.OnUpdate(GameTooltip, 0.2)
	assert(metricValues["Judgement SP Coeff"] == judgementTest.expectedCoefficient,
		"Judgement tooltip should show its coefficient even without parsed damage")
	assert(metricValues["Judgement SP DPS"] ~= nil,
		"Judgement tooltip should show spell-power contribution DPS when fixed damage is unavailable")
end
print("Passed Judgement of the Seals coefficient tooltip tests.")

GetSpellBaseCooldown = function(spellID)
	if spellID == 37 then
		return 10000, 1500
	end
	return spellID == 2 and 4000 or 0, 1500
end
currentSpellID = 37
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues["Judgement DPS"] == "10",
	"Judgement DPS should use parsed damage and the Judgement cooldown")
assert(metricValues["Judgement SP DPS"] == "4.29",
	"Judgement SP DPS should show the spell-power contribution per cooldown")
assert(metricValues.DPS == nil, "Judgement should use its Judgement DPS label")
assert(metricValues["Judgement SP Coeff"] == "42.9%", "Judgement coefficient should appear at the end of its metrics")
assert(tooltipTextLines[#tooltipTextLines] == "Judgement SP DPS",
	"Judgement spell-power DPS should be the last metric line")
print("Passed Judgement DPS and bottom coefficient tests.")

currentSpellID = 33
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
currentSpellID = 34
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues["Judgement SP Coeff"] == "42.9%", "refresh should follow the tooltip's latest spell")
assert(tooltipShowCalls == 0, "changing spells should not force tooltip redraws")
print("Passed tooltip spell-change test.")

for _, sealTest in ipairs({
	{ spellID = 35, expectedSealCoefficient = "42.9%", expectedJudgementCoefficient = "42.9%", expectedJudgementSPDPS = "4.29" },
	{ spellID = 36, expectedSealCoefficient = "42.9%", expectedJudgementCoefficient = "42.9%", expectedJudgementSPDPS = "4.29" },
}) do
	currentSpellID = sealTest.spellID
	metricValues = {}
	tooltipScripts.OnUpdate(GameTooltip, 0.2)
	assert(metricValues["SP Coeff"] == sealTest.expectedSealCoefficient,
		"Seal tooltip should retain its own coefficient")
	assert(metricValues["Judgement SP Coeff"] == sealTest.expectedJudgementCoefficient,
		"Seal tooltip should show the related Judgement coefficient")
	assert(metricValues["Judgement SP DPS"] == sealTest.expectedJudgementSPDPS,
		"Seal tooltip should show the related Judgement spell-power DPS, got "
			.. tostring(metricValues["Judgement SP DPS"]))
	local headerCount = 0
	for _, text in ipairs(tooltipTextLines) do
		if text == "Spell Metrics" then
			headerCount = headerCount + 1
		end
	end
	assert(headerCount == 1, "Seal tooltip should only show the Spell Metrics header once")
	assert(tooltipTextLines[#tooltipTextLines] == "Judgement SP DPS",
		"Seal's related Judgement spell-power DPS should appear at the bottom")
	assert(metricValues["Judgement DPS"] == nil,
		"Seal tooltip should not claim total Judgement DPS without the Judgement's base damage")
end
print("Passed seal tooltip coefficients and single-header tests.")

currentSpellID = 17
SpellInfo.CurrentMana = 880
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPM == "0.77", "Hurricane DPM should include all ten ticks")
assert(metricValues.DPS == "68", "Hurricane DPS should use its 10-second duration")
assert(metricValues.DOOM == "680", "Hurricane DOOM should include all ten ticks")
assert(metricValues["Damage / Tick"] == "68", "Hurricane tooltip should include per-tick damage")
print("Passed Hurricane tooltip metric test.")

currentSpellID = 18
SpellInfo.CurrentMana = 925
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.HPM == "1.54", "Tranquility HPM should include all five healing ticks")
assert(metricValues.HPS == "142", "Tranquility HPS should use its 10-second duration")
assert(metricValues.HOOM == "1425", "Tranquility HOOM should include all five healing ticks")
assert(metricValues["Healing / Tick"] == "285", "Tranquility tooltip should include per-tick healing")
print("Passed Tranquility tooltip metric test.")

GetSpellBonusDamage = function(school)
	return school == 3 and 100 or 0
end
local fireballAtLowLevel = SpellInfo.GetSpellDamage(2)
assert(fireballAtLowLevel == 120, "Fireball amount should come from its tooltip, without added spell power")
local fireballCoefficient = SpellInfo.GetSpellCoefficient(2, false)
assert(fireballCoefficient == 1, "Fireball should return its listed coefficient")

local flameShockCoefficient = SpellInfo.GetSpellCoefficient(45, false)
local flameShockDirect, flameShockDot, flameShockPeriodicLabel =
	SpellInfo.GetSpellCoefficientBreakdown(45, false)
assert(flameShockCoefficient == 0.614, "Flame Shock should include the full four-tick DoT coefficient")
assert(flameShockDirect == 0.214 and flameShockDot == 0.400 and flameShockPeriodicLabel == "DoT",
	"Flame Shock should expose its updated direct and periodic coefficients")

assert(SpellInfo.GetSpellCoefficient(133, false) == 0.429,
	"rank 1 Fireball should use its generated rank-specific coefficient")
assert(SpellInfo.GetSpellCoefficient(143, false) == 0.571,
	"rank 2 Fireball should use its generated rank-specific coefficient")
assert(SpellInfo.GetSpellCoefficient(145, false) == 0.714,
	"rank 3 Fireball should use its generated rank-specific coefficient")
assert(SpellInfo.GetSpellCoefficient(172, false) == 0.8,
	"rank 1 Corruption should total its coefficient across its four ticks")
assert(SpellInfo.GetSpellCoefficient(6222, false) == 1,
	"rank 2 Corruption should total its coefficient across its five ticks")
assert(math.abs(SpellInfo.GetSpellCoefficient(6223, false) - 1.2) < 0.000001,
	"rank 3 Corruption should total its coefficient across its six ticks")
assert(math.abs(SpellInfo.GetSpellCoefficient(8921, false) - 0.54) < 0.000001
		and math.abs(SpellInfo.GetSpellCoefficient(8924, false) - 0.67) < 0.000001,
	"Moonfire should use each rank's duration to total its periodic coefficient")
assert(SpellInfo.GetSpellSchool(133, false) == 3,
	"generated DB2 school masks should map to the spell bonus school index")
assert(SpellInfo.GetSpellCoefficient(635, true) == 0.714,
	"rank-specific generated healing coefficients should be used")

local lightVigilDamageCoefficient = SpellInfo.GetSpellCoefficient(46, false)
local lightVigilHealingCoefficient = SpellInfo.GetSpellCoefficient(46, true)
assert(lightVigilDamageCoefficient == 0.429 and lightVigilHealingCoefficient == 0.143,
	"Light's Vigil should use distinct damage and healing coefficients")
assert(SpellInfo.GetSealJudgementCoefficient(47) == 0.429,
	"Seal of Fury should expose its Judgement of Fury coefficient")
assert(SpellInfo.IsJudgementSpell(48), "Judgement of Fury should be recognized as a judgement")

local arcaneMissilesCoefficient = SpellInfo.GetSpellCoefficient(9000001, false)
assert(arcaneMissilesCoefficient == 1.430, "Arcane Missiles should include all five ticks")
local lowRankLightningCoefficient = SpellInfo.GetSpellCoefficient(50, false)
assert(lowRankLightningCoefficient == 0.714,
	"Lightning Bolt should use the listed coefficient without rank-based scaling")
assert(SpellInfo.GetSpellCoefficient(51, false) == 0.267
		and SpellInfo.GetSpellSchool(51, false) == 4,
	"Lightning Shield should use its name-based Nature coefficient when its rank ID is missing")
local getSpellBonusDamage = GetSpellBonusDamage
GetSpellBonusDamage = function(school)
	return school == 4 and 100 or 0
end
assert(math.abs(SpellInfo.GetSpellBonus(50, false) - 71.4) < 0.000001,
	"Spell-power bonus calculations should use the listed coefficient at every rank")
GetSpellBonusDamage = getSpellBonusDamage

GetSpellBonusDamage = function(school)
	return school == 2 and 100 or 0
end
GetSpellBonusHealing = function()
	return 200
end
assert(math.abs(SpellInfo.GetSpellBonus(46, false) - 42.9) < 0.000001,
	"Light's Vigil should use its damage coefficient for damage spell power")
assert(math.abs(SpellInfo.GetSpellBonus(46, true) - 28.6) < 0.000001,
	"Light's Vigil should use its healing coefficient for healing spell power")
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
local holyLightCoefficient = SpellInfo.GetSpellCoefficient(20, true)
assert(rankThreeHolyLight == 100, "Holy Light amount should come from its tooltip, without added spell power")
assert(holyLightCoefficient == 0.714,
	"Rank 3 Holy Light should retain its observed 71.4% coefficient at level 17")
assert(SpellInfo.GetSpellCoefficient(20, false) == nil, "Holy Light should not expose a damage coefficient")

currentSpellID = 20
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.Healing == "100" and metricValues["Average Healing"] == nil,
	"Holy Light healing should match its fixed action-bar amount without added spell power")
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

SpellInfo.PlayerUsesMana = function()
	return false
end
for _, rageTest in ipairs({
	{ spellID = 39, expectedDPS = "8.40", expectedDPR = "1.40" },
	{ spellID = 40, expectedDPS = "7.20", expectedDPR = "1.80" },
	{ spellID = 41, expectedDPS = "3.33", expectedDPR = "0.33" },
}) do
	currentSpellID = rageTest.spellID
	metricValues = {}
	tooltipScripts.OnUpdate(GameTooltip, 0.2)
	assert(metricValues.DPS == rageTest.expectedDPS,
		"rage ability should show DPS, got " .. tostring(metricValues.DPS))
	assert(metricValues.DPR == rageTest.expectedDPR,
		"rage ability should show damage per rage, got " .. tostring(metricValues.DPR))
	assert(metricValues.Damage and metricValues["Average Damage"] == nil,
		"fixed rage ability damage should not be labeled average")
	assert(metricValues.DPM == nil and metricValues.DOOM == nil and metricValues["Time to OOM"] == nil,
		"rage ability should not show mana-related metrics")
end
print("Passed rage ability tooltip metric tests.")

SpellInfoDB.showAverageEffect = false
currentSpellID = 39
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.Damage == nil and metricValues.DPR == "1.40",
	"average amount setting should hide rage damage without hiding rage efficiency")
SpellInfoDB.showAverageEffect = true
clearTooltipLines()

mainHandSwingSpeed = nil
currentSpellID = 39
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPS == nil, "Heroic Strike should omit DPS when main-hand swing speed is unavailable")
assert(metricValues.DPR == "1.40", "Heroic Strike should still show DPR without weapon speed")
mainHandSwingSpeed = 3
currentSpellID = 40
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPS == "6", "Maul DPS should divide bonus damage by main-hand swing speed")
assert(metricValues.DPR == "1.80", "Maul should keep damage per rage based on its rage cost")

mainHandSwingSpeed = nil
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPS == nil, "Maul should omit DPS when main-hand swing speed is unavailable")
assert(metricValues.DPR == "1.80", "Maul should still show DPR without weapon speed")
mainHandSwingSpeed = 2.5
print("Passed Heroic Strike and Maul weapon-speed DPS tests.")

for _, eviscerateTest in ipairs({
	{ comboPoints = 1, expectedDamage = 38 },
	{ comboPoints = 3, expectedDamage = 108 },
	{ comboPoints = 5, expectedDamage = 178 },
}) do
	currentComboPoints = eviscerateTest.comboPoints
	local damage = SpellInfo.GetSpellDamage(43)
	assert(damage == eviscerateTest.expectedDamage,
		"Eviscerate icon damage should update for current combo points and attack power: "
			.. tostring(damage))
end
currentComboPoints = 0
assert(SpellInfo.GetSpellDamage(43) == nil,
	"Eviscerate icon damage should be hidden when there are no combo points")
currentComboPoints = 5
local originalUnitAttackPower = UnitAttackPower
local secretAttackPower = {}
local originalIsSecretValueForAttackPower = issecretvalue
issecretvalue = function(value)
	return value == secretAttackPower
end
UnitAttackPower = function()
	return secretAttackPower, 0, 0
end
assert(SpellInfo.GetSpellDamage(43) == 28,
	"Eviscerate should still show its combo-point base damage when attack power is unreadable")
UnitAttackPower = originalUnitAttackPower
issecretvalue = originalIsSecretValueForAttackPower
print("Passed Eviscerate combo-point damage tests.")
for _, comboPointTest in ipairs({
	{ comboPoints = 1, expectedDamage = 28 },
	{ comboPoints = 3, expectedDamage = 84 },
	{ comboPoints = 5, expectedDamage = 140 },
}) do
	currentComboPoints = comboPointTest.comboPoints
	assert(SpellInfo.GetSpellDamage(44) == comboPointTest.expectedDamage,
		"combo-point damage should be derived from any spell's tooltip rows and explicit AP coefficient")
end
currentComboPoints = 0
assert(SpellInfo.GetSpellDamage(44) == nil,
	"generic combo-point damage should be hidden when there are no combo points")
currentComboPoints = 5
print("Passed generic combo-point damage tests.")
local originalGetSpellDescription = C_Spell.GetSpellDescription
local originalCTooltipInfo = C_TooltipInfo
C_Spell.GetSpellDescription = function(spellID)
	if spellID == 45 then
		return nil
	end
	return originalGetSpellDescription(spellID)
end
C_TooltipInfo = {
	GetSpellByID = function(spellID)
		assert(spellID == 45)
		return {
			lines = {
				{ leftText = "1 point: 8 damage" },
				{ leftText = "2 points: 16 damage" },
				{ leftText = "3 points: 24 damage" },
				{ leftText = "Adds 2% of Attack Power per combo point." },
			},
		}
	end,
}
currentComboPoints = 2
assert(SpellInfo.GetSpellDamage(45) == 56,
	"combo-point rows and attack-power coefficients may be supplied on separate tooltip lines")
C_Spell.GetSpellDescription = originalGetSpellDescription
C_TooltipInfo = originalCTooltipInfo
currentComboPoints = 5

local damageOverlay
local eviscerateButton = {
	action = 1,
	GetAttribute = function()
		return 1
	end,
	CreateFontString = function()
		damageOverlay = {
			SetPoint = function() end,
			SetFont = function() end,
			SetJustifyH = function() end,
			SetJustifyV = function() end,
			SetShadowOffset = function() end,
			SetTextColor = function() end,
			SetText = function(_, text)
				damageOverlay.text = text
			end,
			SetShown = function(_, shown)
				damageOverlay.shown = shown
			end,
		}
		return damageOverlay
	end,
	HookScript = function() end,
}
_G.ActionButton1 = eviscerateButton
GetActionInfo = function()
	return "spell", 43
end
local originalPlayerUsesMana = SpellInfo.PlayerUsesMana
local originalPlayerUsesRage = SpellInfo.PlayerUsesRage
local originalPlayerUsesEnergy = SpellInfo.PlayerUsesEnergy
local originalIsSecretValue = issecretvalue
local originalGetComboPoints = GetComboPoints
local originalUnitPower = UnitPower
SpellInfo.PlayerUsesMana = function() return false end
SpellInfo.PlayerUsesRage = function() return false end
SpellInfo.PlayerUsesEnergy = function() return false end
currentComboPoints = 2
damageAddonFrame.scripts.OnEvent(damageAddonFrame, "PLAYER_LOGIN")
assert(damageOverlay and damageOverlay.shown and damageOverlay.text == "73",
	"Eviscerate icon should show damage even if resource-detection APIs report no supported power")
currentComboPoints = 5
damageAddonFrame.scripts.OnEvent(damageAddonFrame, "UNIT_POWER_UPDATE", "player", "COMBO_POINTS")
assert(damageOverlay.shown and damageOverlay.text == "178",
	"Eviscerate icon should refresh its damage when combo points change")

local secretComboPoints = {}
issecretvalue = function(value)
	return value == secretComboPoints
end
GetComboPoints = function()
	return secretComboPoints
end
UnitPower = function(_, powerType)
	return powerType == (Enum and Enum.PowerType and Enum.PowerType.ComboPoints or 4) and 3 or 0
end
damageAddonFrame.scripts.OnEvent(damageAddonFrame, "UNIT_POWER_UPDATE", "player", "COMBO_POINTS")
assert(damageOverlay.shown and damageOverlay.text == "108",
	"Eviscerate icon should use readable UnitPower combo points when GetComboPoints is protected")
issecretvalue = originalIsSecretValue
GetComboPoints = originalGetComboPoints
UnitPower = originalUnitPower
SpellInfo.PlayerUsesMana = originalPlayerUsesMana
SpellInfo.PlayerUsesRage = originalPlayerUsesRage
SpellInfo.PlayerUsesEnergy = originalPlayerUsesEnergy

GetActionInfo = function()
	return "macro", 7
end
GetMacroInfo = function(macroID)
	assert(macroID == 7)
	return "Frostbolt Macro", "icon",
		"#showtooltip\n/cast [@mouseover,harm,nodead] Frostbolt; Frostbolt"
end
GetMacroSpell = function(macroID)
	assert(macroID == 7)
	return "Frostbolt", 52
end
damageAddonFrame.scripts.OnEvent(damageAddonFrame, "ACTIONBAR_SLOT_CHANGED")
assert(damageOverlay.shown and damageOverlay.text == "100",
	"spell damage overlay should resolve a Frostbolt macro action to its spell")
GetMacroSpell = function(macroID)
	assert(macroID == 7 or macroID == "Frostbolt Macro")
	return nil
end
assert(SpellInfo.GetActionSpell(1) == 53,
	"conditional cast macros should resolve the spell from their macro body")
damageAddonFrame.scripts.OnEvent(damageAddonFrame, "ACTIONBAR_SLOT_CHANGED")
assert(damageOverlay.shown and damageOverlay.text == "80",
	"Frostbolt macro should display its spell damage")
GetMacroSpell = function(macroID)
	assert(macroID == 7)
	return "Frostbolt", 52
end
C_ActionBar = {
	GetActionInfo = function()
		return { actionType = "macro", actionID = 7 }
	end,
}
assert(SpellInfo.GetActionSpell(1) == 52,
	"macro actions should resolve the actionID returned by C_ActionBar")
C_ActionBar.GetActionInfo = function()
	return { actionType = "macro" }
end
assert(SpellInfo.GetActionSpell(1) == 52,
	"macro actions should fall back to GetActionInfo when C_ActionBar omits the identifier")
C_ActionBar = nil
GetMacroInfo = nil
GetMacroSpell = nil
GetActionInfo = function()
	return "macro", 205
end
GetActionText = function(actionSlot)
	assert(actionSlot == 1)
	return "Frostbolt Macro"
end
GetMacroInfo = function(identifier)
	if identifier == "Frostbolt Macro" then
		return "Frostbolt Macro", "icon",
			"#showtooltip\n/cast [@mouseover,harm,nodead] Frostbolt; Frostbolt"
	end
end
GetMacroSpell = function()
	return nil
end
assert(SpellInfo.GetActionSpell(1) == 53,
	"macro actions should resolve by action text when the action ID is not a macro index")
local originalTooltipManaCheck = SpellInfo.PlayerUsesMana
SpellInfo.PlayerUsesMana = function()
	return true
end
local originalTooltipGetSpell = GameTooltip.GetSpell
local originalTooltipIsShown = GameTooltip.IsShown
GameTooltip.GetSpell = function()
	return nil, nil
end
GameTooltip.IsShown = function()
	return true
end
clearTooltipLines()
metricValues = {}
GameTooltip.spellMetricsSpellID = nil
assert(gameTooltipSetActionHook, "action tooltip should be hooked after GameTooltip:SetAction")
gameTooltipSetActionHook(GameTooltip, 1)
assert(metricValues.Damage or metricValues["Average Damage"],
	"GameTooltip:SetAction should add resolved macro metrics before the tooltip is shown")
assert(tooltipShowCalls == originalTooltipShowCalls + 1,
	"action tooltip should be resized after metrics are appended")
assert(gameTooltipSetSpellByIDHook, "spell tooltips should be hooked after GameTooltip:SetSpellByID")
clearTooltipLines()
metricValues = {}
GameTooltip.spellMetricsSpellID = nil
tooltipShowCalls = originalTooltipShowCalls
gameTooltipSetSpellByIDHook(GameTooltip, 53)
assert(metricValues.Damage or metricValues["Average Damage"],
	"GameTooltip:SetSpellByID should add metrics for #showtooltip macro spells")
assert(tooltipShowCalls == originalTooltipShowCalls + 1,
	"spell tooltip should be resized after metrics are appended")
GameTooltip.GetSpell = originalTooltipGetSpell
GameTooltip.IsShown = originalTooltipIsShown
SpellInfo.PlayerUsesMana = originalTooltipManaCheck
GetActionText = nil
GetMacroInfo = nil
GetMacroSpell = nil
GetActionInfo = function()
	return "spell", 43
end
print("Passed Eviscerate action-bar refresh tests.")

UnitPowerMax = function(_, powerType)
	return powerType == 3 and 100 or 0
end
assert(SpellInfo.PlayerUsesEnergy(), "energy users should be detected from their maximum energy")
assert(SpellInfo.GetEnergyCost(42) == 40, "energy spell cost should be read from its power-cost data")

local energyOverlay
local energyButton = {
	action = 1,
	GetAttribute = function()
		return 1
	end,
	CreateFontString = function()
		energyOverlay = {
			SetPoint = function() end,
			SetFont = function() end,
			SetJustifyH = function() end,
			SetJustifyV = function() end,
			SetTextColor = function(_, red, green, blue)
				energyOverlay.color = { red, green, blue }
			end,
			SetShadowOffset = function() end,
			SetText = function(_, text)
				energyOverlay.text = text
			end,
			SetShown = function(_, shown)
				energyOverlay.shown = shown
			end,
		}
		return energyOverlay
	end,
	HookScript = function() end,
}
_G.ActionButton1 = energyButton
ActionButton_GetPagedID = function()
	return 1
end
GetActionInfo = function()
	return "spell", 42
end
ActionButton_Update = function() end
local updateEnergyButton
hooksecurefunc = function(_, callback)
	updateEnergyButton = callback
end
dofile("AbilityEnergyCostIcon.lua")
updateEnergyButton(energyButton)
assert(energyOverlay.text == "40" and energyOverlay.shown,
	"energy cost should appear on the action button")
assert(energyOverlay.color[1] == 1 and energyOverlay.color[2] == 0.85 and energyOverlay.color[3] == 0.1,
	"energy action-button cost should be yellow")

currentSpellID = 42
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.DPS == "66.7", "energy ability DPS should use its GCD")
assert(metricValues.DPE == "2.50", "energy ability should show damage per energy")
assert(metricValues.Damage and metricValues["Average Damage"] == nil,
	"fixed energy ability damage should not be labeled average")
assert(metricValues.DPR == nil and metricValues.DPM == nil and metricValues.DOOM == nil,
	"energy tooltip should not show rage or mana efficiency metrics")
SpellInfoDB.showAverageEffect = false
clearTooltipLines()
metricValues = {}
tooltipScripts.OnUpdate(GameTooltip, 0.2)
assert(metricValues.Damage == nil and metricValues.DPE == "2.50",
	"average amount setting should hide energy damage without hiding energy efficiency")
SpellInfoDB.showAverageEffect = true
assert(SpellInfo.PlayerUsesMana() == false, "energy-only users should not be detected as mana users")
print("Passed energy ability tooltip metric tests.")
