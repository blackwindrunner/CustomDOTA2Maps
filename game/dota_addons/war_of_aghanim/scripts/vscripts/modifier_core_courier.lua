modifier_core_courier = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,

	DeclareFunctions = function()
		return {
			MODIFIER_PROPERTY_MOVESPEED_MAX,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
			MODIFIER_PROPERTY_FIXED_DAY_VISION,
			MODIFIER_PROPERTY_FIXED_NIGHT_VISION,
		}
	end,
	GetFixedDayVision = function() return 150 end,
	GetFixedNightVision = function() return 150 end,

	CheckState = function()
		return {
			--[MODIFIER_STATE_NO_HEALTH_BAR] = true,
			--[MODIFIER_STATE_INVULNERABLE] = true,
		}
	end,
}

function modifier_core_courier:GetModifierMoveSpeed_Max()
	if self:GetCaster():HasFlyMovementCapability() then
		return 1600
	else
		return 800
	end
end

function modifier_core_courier:GetModifierMoveSpeed_Limit()
	if self:GetCaster():HasFlyMovementCapability() then
		return 1600
	else
		return 800
	end
end

function modifier_core_courier:GetModifierMoveSpeed_Absolute()
	if self:GetCaster():HasFlyMovementCapability() then
		return 1600
	else
		return 800
	end
end