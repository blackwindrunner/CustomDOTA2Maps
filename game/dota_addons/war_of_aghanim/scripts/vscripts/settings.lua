--Game base setting
CUSTOM_TEAM_PLAYER_COUNT = {} --team player count
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5

if GetMapName() == "dota" then 
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 10 --it is temporary
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 10
elseif GetMapName() == "dota_10v10" then
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 10
	CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 10
end

HERO_SELECTION_TIME = 50               -- How long should we let people select their hero?
RUNE_SPAWN_TIME = 120					-- How long in seconds should we wait between rune spawns?


--custom variable
MEEPO_FLAG=0; -- 0. Meepo did't have aghanim 1.Meepo had aghanim