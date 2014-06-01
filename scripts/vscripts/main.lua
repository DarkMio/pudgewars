print('main...')

-- Reload support apparently
if PWGameMode == nil then
    PWGameMode = {}
    PWGameMode.szEntityClassName = "PudgeWars"
    PWGameMode.szNativeClassName = "dota_base_game_mode"
    PWGameMode.__index = PWGameMode
end

function GetPWInstance()
    print("GetPWInstance...")
    return PW_Instance
end

function PWGameMode:new (o)
    print("PWGameMode:new...")
    o = o or {}
    setmetatable(o, self)
    PW_Instance = o
    return o
end

function PWGameMode:InitGameMode()
    print('\n\nPWGameMode:InitGameMode...')
    -- Load version
    self.frotaVersion = LoadKeyValues("scripts/version.txt").version

    -- Register console commands
    self:RegisterCommands()

    -- Create map of buildings
    self:CreateMapBuildingList()

    -- Setup rules
    GameRules:SetHeroRespawnEnabled( false )
    GameRules:SetUseUniversalShopMode( true )
    GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetHeroSelectionTime( 0.0 )
    GameRules:SetPreGameTime( 60.0 )
    GameRules:SetPostGameTime( 60.0 )
    GameRules:SetTreeRegrowTime( 60.0 )
    --GameRules:SetHeroMinimapIconSize( 400 )
    --GameRules:SetCreepMinimapIconScale( 0.7 )
    --GameRules:SetRuneMinimapIconScale( 0.7 )

    ListenToGameEvent('player_connect_full', Dynamic_Wrap(PWGameMode, 'AutoAssignPlayer'), self)
end

-- Auto assigns a player when they connect
function PWGameMode:AutoAssignPlayer(keys)
    -- Grab the entity index of this player
    local entIndex = keys.index+1
    local ent = EntIndexToHScript(entIndex)

    ent:SetTeam(DOTA_TEAM_GOODGUYS)
    CreateHeroForPlayer('npc_dota_hero_pudge', ent)

    -- Find the team with the least players
    -- local teamSize = {
    --     [DOTA_TEAM_GOODGUYS] = 0,
    --     [DOTA_TEAM_BADGUYS] = 0
    -- }

    -- self:LoopOverPlayers(function(ply, playerID)
    --     -- Grab the players team
    --     local team = ply:GetTeam()

    --     -- Increase the number of players on this player's team
    --     teamSize[team] = (teamSize[team] or 0) + 1
    -- end)

    -- --[[if SMJS_LOADED then
    --     local newPlayerID = -1

    --     -- SM.JS playerID override
    --     for i=0,9 do
    --         if not self.takenPlayerIDs[i] then
    --             self.takenPlayerIDs[i] = true
    --             newPlayerID = i
    --             break;
    --         end
    --     end

    --     newPlayerID = 5

    --     if newPlayerID == -1 then
    --         print('FAILED TO FIND SPARE PLAYERID!')
    --     else
    --         -- Allocate playerID
    --         smjsSetNetprop(ply, 'm_iPlayerID', newPlayerID)
    --     end

    --     --local playerManager = Entities:FindAllByClassname('dota_player_manager')[1]
    --     --smjsSetNetprop(ply, 'm_iTeamNum', 2)
    --     --smjsSetNetprop(playerManager, 'm_iPlayerTeams', 2, ply:GetPlayerID())
    -- end]]

    -- if teamSize[DOTA_TEAM_GOODGUYS] > teamSize[DOTA_TEAM_BADGUYS] then
    --     ply:SetTeam(DOTA_TEAM_BADGUYS)
    --     ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)
    -- else
    --     ply:SetTeam(DOTA_TEAM_GOODGUYS)
    --     ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_GOODGUYS)
    -- end

    -- --ply:__KeyValueFromInt('teamnumber', DOTA_TEAM_BADGUYS)

    -- --for i=0,4 do
    -- --    PlayerResource:UpdateTeamSlot(ply:GetPlayerID(), i)
    -- --end

    -- local playerID = ply:GetPlayerID()
    -- local hero = self:GetActiveHero(playerID)
    -- if IsValidEntity(hero) then
    --     hero:Remove()
    -- end

    -- -- Store into our map
    -- self.vUserIDMap[keys.userid] = ply
    -- self.nLowestUserID = self.nLowestUserID + 1

    -- self.selectedBuilds[playerID] = self:GetDefaultBuild()

    -- -- Autoassign player
    -- self:CreateTimer('assign_player_'..entIndex, {
    --     endTime = Time(),
    --     callback = function(frota, args)
    --         frota:SetActiveHero(CreateHeroForPlayer('npc_dota_hero_axe', ply))

    --         -- Check if we are in a game
    --         if self.currentState == STATE_PLAYING then
    --             -- Check if we need to assign a hero
    --             if IsValidEntity(self:GetActiveHero(playerID)) then
    --                 self:FireEvent('assignHero', ply)
    --                 self:FireEvent('onHeroSpawned', self:GetActiveHero(playerID))
    --             end
    --         end

    --         -- Fire new player event
    --         self:FireEvent('NewPlayer', ply)
    --     end,
    --     persist = true
    -- })
end

function PWGameMode:_SetInitialValues()
    -- Change random seed
    -- local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    -- math.randomseed(tonumber(timeTxt))

    -- -- Load ability List
    -- self:LoadAbilityList()

    -- -- Timers
    -- self.timers = {}

    -- -- Voting thinking
    -- self.startedInitialVote = false
    -- self.thinkState = Dynamic_Wrap( FrotaGameMode, '_thinkState_Voting' )

    -- -- Stores the current skill list for each hero
    -- self.currentSkillList = {}

    -- -- Reset Builds
    -- self:ResetBuilds()

    -- -- Options
    -- self.gamemodeOptions = {}

    -- -- Scores
    -- self.scoreDire = 0
    -- self.scoreRadiant = 0

    -- -- The state of the gane
    -- self.currentState = STATE_INIT;
    -- self:ChangeStateData({});
end

function PWGameMode:RegisterCommands()
    -- A server command to attempt to reload stuff -- doesnt work 11/02/2014
    Convars:RegisterCommand('reloadtest', function(name, skillName, slotNumber)
        -- Check if the server ran it
        if not Convars:GetCommandClient() then
            GameRules:Playtesting_UpdateCustomKeyValues()
        end
    end, 'Reload shit test', 0)
end

function PWGameMode:CreateMapBuildingList()
    -- Create new tower list
    self.MapBuildingList = {}

    for k,v in pairs(Entities:FindAllByClassname('npc_dota_*')) do
        -- Validate entity
        if IsValidEntity(v) then
            if v.IsTower then
                -- Store the building
                table.insert(self.MapBuildingList, v)
            end
        end
    end
end