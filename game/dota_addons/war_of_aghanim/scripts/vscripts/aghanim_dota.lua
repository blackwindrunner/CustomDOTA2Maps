if AddonAdventure == nil then
    print ( '[DOTA2IMBA] creating DOTA2IMBA game mode' )
    AddonAdventure = class({})
end


function AddonAdventure:OnHeroInGame(hero)
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
  hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  --local item = CreateItem("item_multiteam_action", hero, hero)
  --hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability
  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end