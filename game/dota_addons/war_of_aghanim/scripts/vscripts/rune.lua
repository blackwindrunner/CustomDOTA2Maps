-- Spawns runes on the map
function SpawnRunes()

	-- Locate the rune spots on the map
	local bounty_rune_locations = Entities:FindAllByName("dota_item_rune_spawner_bounty")
	local powerup_rune_locations = Entities:FindAllByName("dota_item_rune_spawner_powerup")
	--DeepPrintTable(bounty_rune_locations)
	--DeepPrintTable(powerup_rune_locations)
	-- Spawn bounty runes
	local game_time = GameRules:GetDOTATime(false, false)
	--print("[GetDOTATime] "..game_time)
	for _, bounty_loc in pairs(bounty_rune_locations) do
		local bounty_rune = CreateItem("item_rune_bounty", nil, nil)
		 CreateItemOnPositionForLaunch(bounty_loc:GetAbsOrigin(), bounty_rune)

		-- If these are the 00:00 runes, double their worth
		if game_time < 1 then
			bounty_rune.is_initial_bounty_rune = true
		end
	end

	-- List of powerup rune types
	local powerup_rune_types = {
		"item_rune_double_damage",
		"item_rune_haste",
		"item_rune_regeneration"
	}

	-- Spawn a random powerup rune in a random powerup location
	if game_time > 1 then
		CreateItemOnPositionForLaunch(powerup_rune_locations[RandomInt(1, #powerup_rune_locations)]:GetAbsOrigin(), CreateItem(powerup_rune_types[RandomInt(1, #powerup_rune_types)], nil, nil))
	end
end


-- Picks up a bounty rune
function PickupBountyRune(item, unit)
	print("PickupBountyRune")
	-- Bounty rune parameters
	local base_bounty = 200
	local bounty_per_minute = 5
	local game_time = GameRules:GetDOTATime(false, false)
	local current_bounty = base_bounty + bounty_per_minute * game_time / 60

	-- If this is the first bounty rune spawn, double the base bounty
	if item.is_initial_bounty_rune then
		current_bounty = base_bounty * 1
	end

	-- Adjust value for lobby options
	--current_bounty = current_bounty * (1 + CUSTOM_GOLD_BONUS * 0.01)

	-- Grant the unit experience
	--unit:AddExperience(current_bounty, DOTA_ModifyXP_CreepKill, false, true)
	unit:AddExperience(current_bounty, DOTA_ModifyXP_CreepKill, false, true)
	-- If this is alchemist, increase the gold amount
	if unit:FindAbilityByName("alchemist_goblins_greed") and unit:FindAbilityByName("alchemist_goblins_greed"):GetLevel() > 0 then
		current_bounty = current_bounty * 2
	end

	-- Grant the unit gold
	unit:ModifyGold(current_bounty, false, DOTA_ModifyGold_CreepKill)

	-- Show the gold gained message to everyone
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, unit, current_bounty, nil)

	-- Play the gold gained sound
	unit:EmitSound("General.Coins")

	-- Play the bounty rune activation sound to the unit's team
	EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Bounty", unit)
end


-- Picks up a haste rune
function PickupHasteRune(item, unit)

	-- Apply the aura modifier to the owner
	--item:ApplyDataDrivenModifier(unit, unit, "modifier_rune_haste", {})

	-- Apply the movement speed increase modifier to the owner
	local duration = item:GetSpecialValueFor("duration")
	unit:AddNewModifier(unit, item, "modifier_rune_haste", {duration = duration})

	-- Play the haste rune activation sound to the unit's team
	EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Haste", unit)
end

-- Picks up a double damage rune
function PickupDoubleDamageRune(item, unit)

	-- Apply the aura modifier to the owner
	--item:ApplyDataDrivenModifier(unit, unit, "modifier_rune_doubledamage", {})
	local duration = item:GetSpecialValueFor("duration")
	unit:AddNewModifier(unit, item, "modifier_rune_doubledamage", {duration = duration})
	-- Play the double damage rune activation sound to the unit's team
	EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.DD", unit)
end

-- Picks up a regeneration rune
function PickupRegenerationRune(item, unit)

	-- Apply the aura modifier to the owner
	--item:ApplyDataDrivenModifier(unit, unit, "modifier_rune_regen", {})
	local duration = item:GetSpecialValueFor("duration")
	unit:AddNewModifier(unit, item, "modifier_rune_regen", {duration = duration})
	-- Play the double damage rune activation sound to the unit's team
	EmitSoundOnLocationForAllies(unit:GetAbsOrigin(), "Rune.Regen", unit)
end