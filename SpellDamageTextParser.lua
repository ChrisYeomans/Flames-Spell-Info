SpellInfo = SpellInfo or {}

local function isReadableText(text)
	return text and (not issecretvalue or not issecretvalue(text))
end

local function findDamage(text, requireDamageWord)
	if not isReadableText(text) then
		return nil
	end

	local lowerText = string.lower(text)
	local isDefensiveEffect = string.find(lowerText, "damage taken")
		or string.find(lowerText, "damage received")
		or string.find(lowerText, "damage reduction")
		or string.find(lowerText, "healing received")
		or string.find(lowerText, "healing taken")
	local hasHealingAction = string.find(lowerText, "heals ")
		or string.find(lowerText, "heal%s")
		or string.find(lowerText, "heal the")
		or string.find(lowerText, "restores ")
		or string.find(lowerText, "restores?%s")
		or string.find(lowerText, "regenerates?%s")
		or string.find(lowerText, "absorbs?%s+%d")
		or string.find(lowerText, "absorbing%s+%d")
	local hasEffectWord = string.find(lowerText, "damage") or hasHealingAction
	local hasDamageAction = string.find(lowerText, "deals?%s+%d")
		or string.find(lowerText, "deals?%s+an additional%s+%d")
		or string.find(lowerText, "inflicts?%s+%d")
		or string.find(lowerText, "causes?%s+%d")
		or string.find(lowerText, "causing%s+%d")
		or string.find(lowerText, "dealing%s+%d")
		or string.find(lowerText, "doing%s+%d")
		or string.find(lowerText, "does%s+%d")
		or string.find(lowerText, "do%s+%d")
		or string.find(lowerText, "increases?%s+.-damage%s+by%s+%d")
		or string.find(lowerText, "next%s+attack%s+by%s+%d[%d,]*[^%d%.%%]*damage")
		or string.find(lowerText, "take%s+%d[^%d%.%%]*damage")
		or string.find(lowerText, "struck%s+for%s+%d")
		or string.find(lowerText, "for%s+%d[%d,]*[^%d%.%%]*damage")
		or string.find(lowerText, "for%s+%d[%d,]*%s+to%s+%d")
		or string.find(lowerText, "for%s+%d[%d,]*%s*%-%s*%d")
	if isDefensiveEffect or (requireDamageWord and not hasEffectWord) then
		return nil
	end

	if hasDamageAction then
		local damagePerSecond, channelDuration = string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*damage%s+each second%s+for%s+(%d[%d,]*)%s+sec")
		if damagePerSecond and channelDuration then
			local duration = tonumber((string.gsub(channelDuration, ",", "")))
			local totalDamage = tonumber((string.gsub(damagePerSecond, ",", ""))) * duration
			return totalDamage, duration
		end

		local damagePerTick, tickInterval = string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*damage.-every%s+(%d[%d,]*)%s+sec")
		local totalDuration = string.match(lowerText, "lasts%s+(%d[%d,]*)%s+sec")
		if damagePerTick and tickInterval and totalDuration then
			local duration = tonumber((string.gsub(totalDuration, ",", "")))
			local tickCount = math.floor(duration / tonumber((string.gsub(tickInterval, ",", ""))))
			local totalDamage = tonumber((string.gsub(damagePerTick, ",", ""))) * tickCount
			if tickCount > 0 then
				return totalDamage, duration
			end
		end

		local immediateDamage = string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*damage%s+immediately")
		local followingDamage = string.match(lowerText, "and%s+(%d[%d,]*)[^%d%.%%]*damage%s+over%s+%d")
		if immediateDamage and followingDamage then
			return tonumber((string.gsub(immediateDamage, ",", "")))
				+ tonumber((string.gsub(followingDamage, ",", "")))
		end

		local initialLow, initialHigh = string.match(lowerText, "for%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage")
		if not initialLow then
			initialLow, initialHigh = string.match(lowerText, "(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage%s+and%s+an additional%s+%d")
		end
		local initialDamage
		local hasAverageDamage = initialLow ~= nil
		if initialLow and initialHigh then
			initialDamage = (tonumber((string.gsub(initialLow, ",", ""))) + tonumber((string.gsub(initialHigh, ",", "")))) / 2
		else
			local initialNumber = string.match(lowerText, "for%s+(%d[%d,]*)[^%d%.%%]*damage")
				or string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*damage%s+and%s+an additional%s+%d")
			initialDamage = initialNumber and tonumber((string.gsub(initialNumber, ",", "")))
		end
		local damageOverTime = string.match(lowerText, "additional%s+(%d[%d,]*)[^%d%.%%]*damage%s+over%s+%d")
		if initialDamage and damageOverTime then
			return initialDamage + tonumber((string.gsub(damageOverTime, ",", ""))),
				nil, hasAverageDamage
		end

		local totalDamageOverTime, damageDuration = string.match(lowerText, "(%d[%d,]*)%s*[%a%s%-]*damage%s+over%s+(%d[%d,]*)%s*sec")
		if totalDamageOverTime and damageDuration then
			return tonumber((string.gsub(totalDamageOverTime, ",", ""))), tonumber((string.gsub(damageDuration, ",", "")))
		end

		for number in string.gmatch(lowerText, "deals?%s+an additional%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s*%-%s*(%d[%d,]*)[^%d%.%%]*damage") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for number in string.gmatch(lowerText, "deals?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "inflicts?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "causes?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "causing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "dealing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "doing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "does%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "do%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		local increasedDamage = string.match(lowerText, "increases?%s+.-damage%s+by%s+(%d[%d,]*)")
		if increasedDamage then
			return tonumber((string.gsub(increasedDamage, ",", "")))
		end

		local nextAttackDamage = string.match(lowerText, "next%s+attack%s+by%s+(%d[%d,]*)[^%d%.%%]*damage")
		if nextAttackDamage then
			return tonumber((string.gsub(nextAttackDamage, ",", "")))
		end

		for number in string.gmatch(lowerText, "take%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "struck%s+for%s+(%d[%d,]*)") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "for%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end
	end

	if hasHealingAction then
		local healingPerTick, healingTickInterval = string.match(lowerText, "(%d[%d,]*)[^%d%.%%]*every%s+(%d[%d,]*)%s+sec")
		local healingDuration = string.match(lowerText, "for%s+(%d[%d,]*)%s+sec")
		if healingPerTick and healingTickInterval and healingDuration then
			local interval = tonumber((string.gsub(healingTickInterval, ",", "")))
			local duration = tonumber((string.gsub(healingDuration, ",", "")))
			if interval > 0 then
				local tickCount = math.floor(duration / interval)
				if tickCount > 0 then
					return tonumber((string.gsub(healingPerTick, ",", ""))) * tickCount, duration
				end
			end
		end

		local directHealLow, directHealHigh = string.match(lowerText, "heals?%s+.-for%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)")
		local healOverTime = string.match(lowerText, "and%s+another%s+(%d[%d,]*)[^%d%.%%]*over%s+%d")
		if directHealLow and directHealHigh and healOverTime then
			local directHeal = (tonumber((string.gsub(directHealLow, ",", ""))) + tonumber((string.gsub(directHealHigh, ",", "")))) / 2
			return directHeal + tonumber((string.gsub(healOverTime, ",", ""))), nil, true
		end

		if not string.find(lowerText, "and%s+another%s+%d") then
			local totalHealingOverTime = string.match(lowerText, "(%d[%d,]*)%s*[%a%s%-]*over%s+(%d[%d,]*)%s*sec")
			if totalHealingOverTime then
				return tonumber((string.gsub(totalHealingOverTime, ",", "")))
			end
		end

		for low, high in string.gmatch(lowerText, "heals?%s+.-of%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for number in string.gmatch(lowerText, "heals?%s+.-of%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for low, high in string.gmatch(lowerText, "heals?%s+.-for%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for low, high in string.gmatch(lowerText, "heals?%s+.-for%s+(%d[%d,]*)%s*%-%s*(%d[%d,]*)") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for number in string.gmatch(lowerText, "heals?%s+.-for%s+(%d[%d,]*)") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for low, high in string.gmatch(lowerText, "absorbs?%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for low, high in string.gmatch(lowerText, "absorbing%s+(%d[%d,]*)%s+to%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
				nil, true
		end

		for number in string.gmatch(lowerText, "absorbs?%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

		for number in string.gmatch(lowerText, "absorbing%s+(%d[%d,]*)[^%d%.%%]*damage") do
			return tonumber((string.gsub(number, ",", "")))
		end

	end

	return nil
end

local function isHealingText(text)
	if not isReadableText(text) then
		return false
	end

	local lowerText = string.lower(text)
	return (string.find(lowerText, "heals ")
		or string.find(lowerText, "heal%s")
		or string.find(lowerText, "heal the")
		or string.find(lowerText, "restores ")
		or string.find(lowerText, "restores?%s")
		or string.find(lowerText, "regenerates?%s")
		or string.find(lowerText, "absorbs?%s+%d")
		or string.find(lowerText, "absorbing%s+%d")) ~= nil
end

local function findHealingAmount(text)
	if not isReadableText(text) then
		return nil
	end

	local lowerText = string.lower(text)
	for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s+to%s+(%d[%d,]*)%s+healing") do
		return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
			true
	end

	for low, high in string.gmatch(lowerText, "(%d[%d,]*)%s*%-%s*(%d[%d,]*)%s+healing") do
		return (tonumber((string.gsub(low, ",", ""))) + tonumber((string.gsub(high, ",", "")))) / 2,
			true
	end

	for number in string.gmatch(lowerText, "(%d[%d,]*)%s+healing") do
		return tonumber((string.gsub(number, ",", "")))
	end

	return nil
end

local function parseSpellEffect(text)
	local effect, effectDuration, effectIsAverage = findDamage(text, true)
	local healingAmount, healingIsAverage = findHealingAmount(text)
	if effect then
		local healing = isHealingText(text)
		return effect, healing, not healing and healingAmount or nil, effectDuration,
			healing and healingIsAverage or effectIsAverage, not healing and healingIsAverage or nil
	elseif healingAmount then
		return healingAmount, true, nil, nil, healingIsAverage
	end
	return nil, false, nil
end

SpellInfo.ParseSpellEffectText = parseSpellEffect