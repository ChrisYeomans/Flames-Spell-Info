SpellInfo = SpellInfo or {}
SpellInfoDB = SpellInfoDB or {}

local defaults = {
	showEfficiency = true,
	showSustained = true,
	showOOM = true,
	showCasts = true,
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
	panel.name = "SpellInfo"
	panel:SetSize(640, 420)

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 24, -24)
	title:SetText("SpellInfo")

	local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetText("Choose which spell metrics appear in tooltips.")

	local options = {
		{
			name = "showEfficiency",
			label = "Show DPM / HPM",
			description = "Show damage per mana or healing per mana.",
		},
		{
			name = "showSustained",
			label = "Show DPS / HPS",
			description = "Show constant-cast damage or healing per second.",
		},
		{
			name = "showOOM",
			label = "Show DOOM / HOOM",
			description = "Show damage or healing until out of mana.",
		},
		{
			name = "showCasts",
			label = "Show casts until OOM",
			description = "Show how many casts can be made before running out of mana.",
		},
	}

	for index, option in ipairs(options) do
		local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
		checkbox:SetPoint("TOPLEFT", 24, -92 - ((index - 1) * 44))
		checkbox:SetChecked(SpellInfo.GetOption(option.name))
		checkbox:SetScript("OnClick", function(self)
			SpellInfoDB[option.name] = self:GetChecked() and true or false
		end)

		local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		label:SetPoint("LEFT", checkbox, "RIGHT", 8, 4)
		label:SetText(option.label)

		local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		description:SetPoint("LEFT", label, "RIGHT", 16, 0)
		description:SetText(option.description)
	end

	local category = Settings.RegisterCanvasLayoutCategory(panel, "SpellInfo")
	Settings.RegisterAddOnCategory(category)
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", registerSettings)
