SpellInfo = SpellInfo or {}
SpellInfoDB = SpellInfoDB or {}

local defaults = {
	showManaCost = true,
	showSpellEffect = true,
	showAverageEffect = true,
	showEfficiency = true,
	showSustained = true,
	showTick = true,
	showBonus = true,
	showCritical = true,
	showOOM = true,
	showCasts = true,
	showCoefficient = false,
}

function SpellInfo.GetOption(name)
	local value = SpellInfoDB[name]
	if value == nil then
		return defaults[name]
	end
	return value
end

local function registerSettings()
	if not Settings or not Settings.RegisterCanvasLayoutCategory then
		return
	end

	local panel = CreateFrame("Frame")
	panel.name = "Spell Info"
	panel:SetSize(640, 530)

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 24, -24)
	title:SetText("Spell Info")

	local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetText("Choose which action-bar overlays and tooltip metrics appear.")

	local options = {
		{
			name = "showManaCost",
			label = "Action-bar power costs",
			description = "Display mana, rage, or energy costs on action-bar icons.",
		},
		{
			name = "showSpellEffect",
			label = "Action-bar damage / healing",
			description = "Display spell damage or healing amounts on action-bar icons.",
		},
		{
			name = "showAverageEffect",
			label = "Tooltip damage / healing",
			description = "Display the spell's base damage or healing amount near the top of its tooltip.",
		},
		{
			name = "showEfficiency",
			label = "DPM / HPM / DPR",
			description = "Show damage per mana, healing per mana, or damage per rage.",
		},
		{
			name = "showSustained",
			label = "DPS / HPS",
			description = "Show constant-cast damage or healing per second.",
		},
		{
			name = "showTick",
			label = "Damage / healing per tick",
			description = "Display damage or healing done each tick for periodic effects.",
		},
		{
			name = "showBonus",
			label = "Spell-power bonus",
			description = "Display the coefficient-based spell-power bonus for the spell.",
		},
		{
			name = "showCritical",
			label = "Critical chance / damage",
			description = "Show the spell's critical chance and estimated critical effect.",
		},
		{
			name = "showOOM",
			label = "DOOM / HOOM",
			description = "Show damage or healing until out of mana.",
		},
		{
			name = "showCasts",
			label = "Casts until OOM",
			description = "Show how many casts can be made before running out of mana.",
		},
		{
			name = "showCoefficient",
			label = "Spell-power coefficients",
			description = "Display spell-power scaling for supported spells.",
		},
	}

	for index, option in ipairs(options) do
		local column = math.floor((index - 1) / 6)
		local row = (index - 1) % 6
		local left = 24 + column * 300
		local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", left, -92 - (row * 68))
		checkbox:SetChecked(SpellInfo.GetOption(option.name))
		checkbox:SetScript("OnClick", function(self)
			SpellInfoDB[option.name] = self:GetChecked() and true or false
		end)

		local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		label:SetPoint("TOPLEFT", checkbox, "TOPRIGHT", 8, -4)
		label:SetWidth(250)
		label:SetText(option.label)
		local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		description:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
		description:SetWidth(260)
		description:SetWordWrap(true)
		description:SetText(option.description)
	end

	local category = Settings.RegisterCanvasLayoutCategory(panel, "Spell Info")
	Settings.RegisterAddOnCategory(category)
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", registerSettings)
