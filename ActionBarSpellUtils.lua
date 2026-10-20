SpellInfo = SpellInfo or {}

local function getSpellIDByName(spellName)
	if not spellName or (issecretvalue and issecretvalue(spellName)) then
		return nil
	end

	if C_Spell and C_Spell.GetSpellInfo then
		local spellInfo = C_Spell.GetSpellInfo(spellName)
		if spellInfo and spellInfo.spellID then
			return spellInfo.spellID
		end
	end
	if GetSpellInfo then
		local _, _, _, _, _, _, spellID = GetSpellInfo(spellName)
		return spellID
	end
	return nil
end

local function getSpellIDFromMacroBody(macroBody)
	if type(macroBody) ~= "string" then
		return nil
	end

	for line in string.gmatch(macroBody, "[^\r\n]+") do
		local command, arguments = string.match(line, "^%s*/([%a]+)%s*(.-)%s*$")
		if command and (string.lower(command) == "cast" or string.lower(command) == "use") then
			arguments = string.gsub(arguments, "%b[]", " ")
			for spellClause in string.gmatch(arguments .. ";", "(.-);") do
				local spellName = string.gsub(spellClause, "^%s*(.-)%s*$", "%1")
				spellName = string.gsub(spellName, "^!", "")
				local spellID = getSpellIDByName(spellName)
				if spellID then
					return spellID
				end
			end
		end
	end
	return nil
end

function SpellInfo.GetActionSpell(actionSlot)
	if not actionSlot then
		return nil
	end

	local actionType, actionID
	if C_ActionBar and C_ActionBar.GetActionInfo then
		local actionInfo = C_ActionBar.GetActionInfo(actionSlot)
		if type(actionInfo) == "table" then
			actionType = actionInfo.actionType or actionInfo.type
			actionID = actionInfo.macroID or actionInfo.spellID or actionInfo.actionID
				or actionInfo.actionId or actionInfo.id
		end
	end
	if (not actionType or not actionID) and GetActionInfo then
		local legacyActionType, legacyActionID = GetActionInfo(actionSlot)
		actionType = legacyActionType or actionType
		actionID = legacyActionID or actionID
	end

	if actionType == "spell" then
		return actionID
	end
	if actionType ~= "macro" then
		return nil
	end

	local macroName
	local actionText = GetActionText and GetActionText(actionSlot)
	if not actionText and C_ActionBar and C_ActionBar.GetActionText then
		actionText = C_ActionBar.GetActionText(actionSlot)
	end

	local macroInfo, macroBody
	local function getMacroInfo(identifier)
		if not identifier then
			return
		end
		if GetMacroInfo then
			macroInfo, _, macroBody = GetMacroInfo(identifier)
		end
		if not macroInfo and C_Macro and C_Macro.GetMacroInfo then
			macroInfo, _, macroBody = C_Macro.GetMacroInfo(identifier)
		end
		if type(macroInfo) == "table" then
			macroBody = macroInfo.body or macroInfo.macrotext or macroBody
			macroName = macroInfo.name or macroName
		elseif macroInfo then
			macroName = macroInfo
		end
	end

	getMacroInfo(actionID)
	if not macroInfo and actionText then
		getMacroInfo(actionText)
	end

	local macroIndex = macroName and GetMacroIndexByName and GetMacroIndexByName(macroName)
	local function getMacroSpell(identifier)
		if not identifier then
			return nil
		end
		local spellID, spellIDAlternate
		if GetMacroSpell then
			spellID, spellIDAlternate = GetMacroSpell(identifier)
		end
		if not spellID and C_Macro and C_Macro.GetMacroSpell then
			spellID, spellIDAlternate = C_Macro.GetMacroSpell(identifier)
		end
		if type(spellID) == "number" then
			return spellID
		end
		if type(spellIDAlternate) == "number" then
			return spellIDAlternate
		end
		return getSpellIDByName(spellID)
	end

	for _, identifier in ipairs({ actionID, macroName, macroIndex }) do
		local spellID = getMacroSpell(identifier)
		if spellID then
			return spellID
		end
	end

	if macroBody then
		local spellID = getSpellIDFromMacroBody(macroBody)
		if spellID then
			return spellID
		end
	end

	return nil
end

if SlashCmdList then
	SLASH_SPELLINFODEBUG1 = "/spellinfodebug"
	SlashCmdList.SPELLINFODEBUG = function(message)
		local actionSlot = tonumber(message) or 1
		local actionType, actionID
		if GetActionInfo then
			actionType, actionID = GetActionInfo(actionSlot)
		end

		local spellID = SpellInfo.GetActionSpell(actionSlot)
		local spellName
		if spellID and C_Spell and C_Spell.GetSpellInfo then
			local spellInfo = C_Spell.GetSpellInfo(spellID)
			spellName = spellInfo and spellInfo.name
		end
		if not spellName and spellID and GetSpellInfo then
			spellName = GetSpellInfo(spellID)
		end

		local damage = spellID and SpellInfo.GetSpellDamage and SpellInfo.GetSpellDamage(spellID)
		local macroDetails = ""
		if actionType == "macro" and GetMacroInfo then
			local macroName, _, macroBody = GetMacroInfo(actionID)
			local actionText = GetActionText and GetActionText(actionSlot)
			if not macroName and actionText then
				macroName, _, macroBody = GetMacroInfo(actionText)
			end
			local macroSpellID = GetMacroSpell and GetMacroSpell(actionID)
			if not macroSpellID and actionText and GetMacroSpell then
				macroSpellID = GetMacroSpell(actionText)
			end
			macroBody = macroBody and string.gsub(macroBody, "%s+", " ") or ""
			macroDetails = string.format("; macro=%s actionText=%s macroSpell=%s body=%s",
				tostring(macroName), tostring(actionText), tostring(macroSpellID), macroBody)
		end

		local messageText = string.format("SpellInfo slot=%s action=%s id=%s resolvedSpell=%s name=%s damage=%s%s",
			tostring(actionSlot), tostring(actionType), tostring(actionID), tostring(spellID),
			tostring(spellName), tostring(damage), macroDetails)
		if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
			DEFAULT_CHAT_FRAME:AddMessage(messageText)
		elseif print then
			print(messageText)
		end
	end
end
