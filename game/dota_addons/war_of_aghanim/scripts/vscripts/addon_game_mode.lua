require('timers')
require('settings')
require('rune')
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
	GameRules:SetGoldPerTick(10) --没分钟金钱增长
	--GameRules:SetStartingGold(3000) -- 初始化金币
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CAddonAdvExGameMode,"OnGameRulesStateChange"), self)
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

	
	--GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	--GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	--GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
end


function CAddonAdvExGameMode:OnGameRulesStateChange( keys )
        print("OnGameRulesStateChange")
        --DeepPrintTable(keys)    --详细打印传递进来的表

       
       

        
        --获取游戏进度
        local newState = GameRules:State_Get()
    
        if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
                print("Player begin select hero")  --玩家处于选择英雄界面
 
        elseif newState == DOTA_GAMERULES_STATE_PRE_GAME then
                print("Player ready game begin")  --玩家处于游戏准备状态
 
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
         	--SpawnRunes()
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
 		SpawnRunes()
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

