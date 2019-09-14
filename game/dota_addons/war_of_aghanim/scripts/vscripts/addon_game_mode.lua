require('timers')
require('settings')

LinkLuaModifier("modifier_core_courier", LUA_MODIFIER_MOTION_NONE)
HERO_SELECTION_TIME = 50               -- How long should we let people select their hero?
MEEPO_FLAG=0;
RUNE_SPAWN_TIME = 120					-- How long in seconds should we wait between rune spawns?
-- Create the class for the game mode, unused in this example as the functions for the quest are global
if CAddonAdvExGameMode == nil then
	CAddonAdvExGameMode = class({})
end


-- If something was being created via script such as a new npc, it would need to be precached here
function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end


-- Create the game mode class when we activate
function Activate()
	GameRules.AddonAdventure = CAddonAdvExGameMode()
	GameRules.AddonAdventure:InitGameMode()
end

-- Begins processing script for the custom game mode.  This "template_example" contains a main OnThink function.
function CAddonAdvExGameMode:InitGameMode()
	print( "Adventure Example loaded." )
	GameRules:SetCustomGameSetupAutoLaunchDelay(15)--队伍分配时间
	GameRules:SetGoldPerTick(10) --每分钟金钱增长
	--GameRules:SetStartingGold(3000) -- 初始化金币
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonAdvExGameMode,"OnGameRulesStateChange"), self)
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CAddonAdvExGameMode, "OnNPCSpawned" ), self )

	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap(CAddonAdvExGameMode, "ItemAddedFilter"), self )
	--ListenToGameEvent("player_spawn", Dynamic_Wrap(CAddonAdvExGameMode, "OnPlayerSpawn"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(CAddonAdvExGameMode, "OnNPCSpawn"), self)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS] )
	--GameRules:SetTimeOfDay( 0.75 )
	--GameRules:SetHeroRespawnEnabled( false )
	--GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 60.0 )
	--GameRules:SetPreGameTime( 60.0 )
	GameRules:SetPostGameTime( 60.0 )
	--GameRules:SetTreeRegrowTime( 60.0 )
	
	--GameRules:SetCreepMinimapIconScale( 0.7 )
	--GameRules:SetRuneMinimapIconScale( 0.7 )
	--GameRules:SetGoldTickTime( 60.0 )
	GameRules:SetGoldPerTick( 1.7 )
	--决策时间0
	GameRules:SetStrategyTime( 0.0 )
	--开始动画时间0
	GameRules:SetShowcaseTime( 0.0 )
	
	--GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	--GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	--GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	self.couriers = {}
end

function CAddonAdvExGameMode:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )

	if spawnedUnit:IsRealHero() then
		--设置信使可以被玩家控制
		if self.couriers[spawnedUnit:GetTeamNumber()] then
			self.couriers[spawnedUnit:GetTeamNumber()]:SetControllableByPlayer(spawnedUnit:GetPlayerID(), true)
		end

		
	end
end

function CAddonAdvExGameMode:OnGameRulesStateChange( keys )
        print("OnGameRulesStateChange")
        --DeepPrintTable(keys)    --详细打印传递进来的表

       
       

        
        --获取游戏进度
        local newState = GameRules:State_Get()
    
        if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
                print("Player begin select hero")  --玩家处于选择英雄界面
 		elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then --策略页面
	 			local ggp = 0
				local bgp = 0
				local ggcolor = {
					{70,70,255},
					{0,255,255},
					{255,0,255},
					{255,255,0},
					{255,165,0},
					{0,255,0},
					{255,0,0},
					{75,0,130},
					{109,49,19},
					{255,20,147},
					{128,128,0},
					{255,255,255}
				}
				local bgcolor = {
					{255,135,195},
					{160,180,70},
					{100,220,250},
					{0,128,0},
					{165,105,0},
					{153,50,204},
					{0,128,128},
					{0,0,165},
					{128,0,0},
					{180,255,180},
					{255,127,80},
					{0,0,0}
				}
				for i=0, PlayerResource:GetPlayerCount()-1 do
					if PlayerResource:GetTeam(i) == DOTA_TEAM_GOODGUYS then
						ggp = ggp + 1
						PlayerResource:SetCustomPlayerColor(i,ggcolor[ggp][1],ggcolor[ggp][2],ggcolor[ggp][3])
					end
					if PlayerResource:GetTeam(i) == DOTA_TEAM_BADGUYS then
						bgp = bgp + 1
						PlayerResource:SetCustomPlayerColor(i,bgcolor[bgp][1],bgcolor[bgp][2],bgcolor[bgp][3])
					end
				end
 				for i=0, DOTA_MAX_TEAM_PLAYERS do
		            if PlayerResource:IsValidPlayer(i) then
		                if PlayerResource:HasSelectedHero(i) == false then

		                    local player = PlayerResource:GetPlayer(i)
		                    player:MakeRandomHeroSelection()

		                    local hero_name = PlayerResource:GetSelectedHeroName(i)
		                end
		            end
		        end
        elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
                print("Player ready game begin")  --玩家处于游戏准备状态
 				local courier_spawn = {}
				courier_spawn[2] = Entities:FindByClassname(nil, "info_courier_spawn_radiant")
				courier_spawn[3] = Entities:FindByClassname(nil, "info_courier_spawn_dire")
				print(courier_spawn[0]);
				print(courier_spawn[1]);
				print(courier_spawn[2]);
				print(courier_spawn[3]);
				for team = 2, 3 do
					self.couriers[team] = CreateUnitByName("npc_dota_courier", courier_spawn[team]:GetAbsOrigin(), true, nil, nil, team)
					self.couriers[team]:AddNewModifier(self.couriers[team], nil, "modifier_core_courier", {})
				end
        elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
                print("Player game begin")  --玩家开始游戏
 
        end
        if newState == DOTA_GAMERULES_STATE_PRE_GAME then --游戏开始前准备
            GameRules:SendCustomMessage("<font color='yellow'>游戏即将开始</font>",-1,1 )
             GameRules:SendCustomMessage("<font color='green'>神杖效果已注入英雄体内</font>",-1,1 )
            print("game start")

            -- AddNewModifier(1,nil,"modifier_item_ultimate_scepter",nil)
             --print(self)
         end

        --游戏开始
         if newState==DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
         	print("game start")
         	--SpawnImbaRunes()
         	OnGameInProgress()

        --ShuaGuai()
        end
        if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        	--CAddonAdvExGameMode:OnAllPlayersLoaded()
        	print("HERO_SELECTION_TIME="..HERO_SELECTION_TIME)
        	
			Timers:CreateTimer(HERO_SELECTION_TIME - 10.1, function()
				
				print(PlayerResource:GetTeamPlayerCount())
				for player_id = 0,PlayerResource:GetTeamPlayerCount()-1 do
						-- If this player still hasn't picked a hero, random one
						if not PlayerResource:HasSelectedHero(player_id) then
							PlayerResource:GetPlayer(player_id):MakeRandomHeroSelection()
							PlayerResource:SetCanRepick(player_id, false)
							PlayerResource:SetHasRandomed(player_id)
							print("tried to random a hero for "..player_id)
						end
				end
			end)
			
		end
        
end

function OnGameInProgress()

	
	-------------------------------------------------------------------------------------------------
	--  Rune timers setup
	-------------------------------------------------------------------------------------------------
	Timers:CreateTimer(0, function()
 		SpawnImbaRunes()
 		return RUNE_SPAWN_TIME
  	end)
	
end
function CAddonAdvExGameMode:OnAllPlayersLoaded()
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter( Dynamic_Wrap(CAddonAdvExGameMode, "ItemAddedFilter"), self )

end
-- Item added to inventory filter
function CAddonAdvExGameMode:ItemAddedFilter( keys )
	print("ItemAddedFilter")
	local unit = EntIndexToHScript(keys.inventory_parent_entindex_const)
	local item = EntIndexToHScript(keys.item_entindex_const)
	local item_name = 0
	print(item)
	if item:GetName() then
		item_name = item:GetName()
		print(item_name)
	end
	-------------------------------------------------------------------------------------------------
	-- Rune pickup logic
	-------------------------------------------------------------------------------------------------

	if item_name == "item_rune_bounty" or item_name == "item_rune_double_damage" or item_name == "item_rune_haste" or item_name == "item_rune_regeneration" then

		-- Only real heroes can pick up runes
		--if unit:IsRealHero() then
			if item_name == "item_rune_bounty" then
				PickupBountyRune(item, unit)
				return false
			end

			if item_name == "item_rune_double_damage" then
				PickupDoubleDamageRune(item, unit)
				return false
			end

			if item_name == "item_rune_haste" then
				PickupHasteRune(item, unit)
				return false
			end

			if item_name == "item_rune_regeneration" then
				PickupRegenerationRune(item, unit)
				return false
			end

		-- If this is not a real hero, drop another rune in place of the picked up one
		-- else
		-- 	local new_rune = CreateItem(item_name, nil, nil)
		-- 	CreateItemOnPositionForLaunch(item:GetAbsOrigin(), new_rune)
		-- 	return false
		-- end
	end
	return true
end
-- Spawns runes on the map
function SpawnImbaRunes()

	-- Locate the rune spots on the map
	local bounty_rune_locations = Entities:FindAllByName("dota_item_rune_spawner_bounty")
	--local powerup_rune_locations = Entities:FindAllByName("dota_item_rune_spawner_powerup")
	DeepPrintTable(bounty_rune_locations)
	DeepPrintTable(powerup_rune_locations)
	-- Spawn bounty runes
	local game_time = GameRules:GetDOTATime(false, false)
	for _, bounty_loc in pairs(bounty_rune_locations) do
		local bounty_rune = CreateItem("item_rune_bounty", nil, nil)
		 CreateItemOnPositionForLaunch(bounty_loc:GetAbsOrigin(), bounty_rune)

		-- If these are the 00:00 runes, double their worth
		if game_time < 1 then
			bounty_rune.is_initial_bounty_rune = true
		end
	end
--[[
	-- List of powerup rune types
	local powerup_rune_types = {
		"item_rune_double_damage",
		"item_rune_haste",
		"item_rune_regeneration"
	}

	-- Spawn a random powerup rune in a random powerup location
	if game_time > 1 then
		CreateItemOnPositionForLaunch(powerup_rune_locations[RandomInt(1, #powerup_rune_locations)]:GetAbsOrigin(), CreateItem(powerup_rune_types[RandomInt(1, #powerup_rune_types)], nil, nil))
	end]]
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


function CAddonAdvExGameMode:OnPlayerSpawn(keys)
	--print(keys)
	DeepPrintTable(keys)
	--print(keys.userid)
	local attacker = EntIndexToHScript(keys.userid)
	attacker:MakeRandomHeroSelection()
end

function CAddonAdvExGameMode:OnNPCSpawn(keys)
	--print("[DOTA2IMBA] NPC Spawned")

  	--PrintTable(keys)
  	local entity = EntIndexToHScript(keys.entindex)
  	--print(entity:GetUnitName())
  	--print("NAME == ".. entity:GetUnitName())
 	
	entity:SetDeathXP(entity:GetDeathXP()*2)
	
	
	if(entity:IsRealHero() and not entity:HasModifier("modifier_item_ultimate_scepter_consumed")) then
    	
    	--print(entity:GetUnitName())
    	print(MEEPO_FLAG)
    	--if(entity:GetUnitName()~="npc_dota_hero_meepo" or print(MEEPO_FLAG)==0) then 
    		local item_scepter=entity:AddItemByName("item_ultimate_scepter")
    		entity:TakeItem(item_scepter)
	    	entity:AddNewModifier(entity,nil,"modifier_item_ultimate_scepter_consumed", {--[[duration = 10 ]]} )
	    	CAddonAdvExGameMode:OnHeroInGame(entity)
	    	entity:SetBaseAgility(entity:GetBaseAgility()+10)
	    	entity:SetBaseIntellect(entity:GetBaseIntellect()+10)
	    	entity:SetBaseStrength(entity:GetBaseStrength()+10)
	    	--entity:SetBaseMaxHealth(2000)
	    	--entity:SetHealth(2000)
	    	--print("GetBaseMaxHealth"..entity:GetBaseMaxHealth())
	    	--print("GetMana"..entity:GetMaxMana())
	    	--entity:SetMana(2000)
	    	--entity:SetMaxMana(entity:GetMaxMana()+175)
	    	--if(MEEPO_FLAG==0)then
	    	--	MEEPO_FLAG=1
	    	--end
    	  		
    	--end

    	
  	end
	--print("qian="..entity:GetGoldBounty())
	--attacker:AddNewModifier(keys,nil,"modifier_item_ultimate_scepter",nil)
	
	--DeepPrintTable(keys)
	
		
	
	--attacker:AddItemByName("item_ultimate_scepter")
end

function CAddonAdvExGameMode:OnHeroInGame(hero)
  print("[DOTA2IMBA] Hero spawned in game for first time -- " .. hero:GetUnitName())

  --[[ Multiteam configuration, currently unfinished
  local team = "team1"
  local playerID = hero:GetPlayerID()
  if playerID > 3 then
    team = "team2"
  end
  print("setting " .. playerID .. " to team: " .. team)
  MultiTeam:SetPlayerTeam(playerID, team)]]

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(1200, false)
	local level = hero:GetLevel()
      while level < 6 do
        hero:AddExperience (10,0,false,false)
        level = hero:GetLevel()
      end

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  --local item = CreateItem("item_multiteam_action", hero, hero)
  --hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability
  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

