local fallbackSpawnX, fallbackSpawnY, fallbackSpawnZ = 1959.55, -1714.46, 10
local spawnPoints
local checkPointCoords
local checkPoints = {}
local currentCheckpoint
local currentCheckpointBlip
local goalCord
local lobbyStartCoord
local lobbyStartCheckpoint
local goalCheckpoint
local deliveryCar
local deliveryMan
local hunterBackups
local lastHunterSpawn = 1
local roundActive = false
local xMans = {}
local gameStarted = false
local participants = {}

local END_ROUND_TEXT_ID = 1333
local END_GAME_TEXT_ID = 1338
local PLAYER_READY_TEXT_ID = 1334
local LEAVING_LOBBY_TEXT_ID = 1335
local PRESENTING_DELIVERY_MAN_TEXT_ID = 1335
local SCORE_KEY = "Score"

scoreboardRes = getResourceFromName( "scoreboard" )

function exitVehicle ( thePlayer, seat, jacked )
   if (thePlayer == deliveryMan) then
      cancelEvent()
   end
end
addEventHandler ( "onVehicleStartExit", getRootElement(), exitVehicle)

function getNextHunterSpawn ()
	local point = spawnPoints[lastHunterSpawn]
	lastHunterSpawn = (lastHunterSpawn % #spawnPoints) + 1
	local posX = getElementData ( point, "posX" )
	local posY = getElementData ( point, "posY" )
	local posZ = getElementData ( point, "posZ" )
	return posX, posY, posZ
end

function getDeliveryManSpawnPoint ()
	local point = deliveryManSpawnPoint
	local posX = getElementData ( point, "posX" )
	local posY = getElementData ( point, "posY" )
	local posZ = getElementData ( point, "posZ" )
	return posX, posY, posZ
end

function spawn(thePlayer)
	if (thePlayer == deliveryMan) then
		--deliveryCar = createVehicle ( 566, spawnX,spawnY,spawnZ )
		outputDebugString("Will Spawn player")

        spawnPlayer(thePlayer, 0, 0, 0, 0, 253)
        if deliveryCar  then
            outputDebugString("Will warp to car: "..getVehicleName(deliveryCar))
			setTimer(warpPedIntoVehicle, 50, 1, thePlayer, deliveryCar)
        end


		fadeCamera(thePlayer, true)
		setCameraTarget(thePlayer, thePlayer)
	else
		outputDebugString("Spawning hunter")
		local spawnX, spawnY, spawnZ
		if(spawnPoints == nil) then
			spawnX = fallbackSpawnX
			spawnY = fallbackSpawnY
			spawnZ = fallbackSpawnZ
		else
			spawnX, spawnY, spawnZ = getNextHunterSpawn()
		end

		spawnPlayer(thePlayer, spawnX, spawnY, spawnZ, 0, 287)
		giveWeapon (thePlayer, 24 , 50, true )
		fadeCamera(thePlayer, true)
		setCameraTarget(thePlayer, thePlayer)
	end
end

function respawnAllPlayers()
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		spawn ( v )
	end
end

function setUpDeliveryManStuff()
	if gameStarted then
		outputDebugString("Game started ")
	end
	if (deliveryMan ~= nil) then
		local checkpoint = checkPoints[currentCheckpoint]
		addCheckpointBlip(checkpoint)
		setElementData( deliveryMan, SCORE_KEY , 0)

		displayMessageForAll(PRESENTING_DELIVERY_MAN_TEXT_ID, getPlayerName(deliveryMan).." is now the delivery man. KILL HIM!", nil, nil, 5000, 0.5, 0.3, 255, 0, 0 )
	end
end


function cleanUpMap()
  destroyElementsByType ("marker")
	destroyElementsByType ("blip")
	destroyElementsByType ("vehicle")
end

function newRound()
	hunterBackups = {}
	cleanUpMap();
	deliveryCar = createDeliveryCar(getElementsByType ( "deliveryCar" , mapRoot )[1])
	createCheckpoints()
	goalCheckpoint = createCheckPoint(goalCoord)
	outputDebugString("New new  "..#checkPoints)
	createHunterJets()
	respawnAllPlayers()
	addPlayerBlips()
	setUpDeliveryManStuff()
	roundActive = true;
end

function startGame()
  xMans = {}
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		setElementData( v, SCORE_KEY , 0)
	end

	if (#players > 0) then
		chooseNewDeliveryMan()
	end
	gameStarted = true;
end

function arrayExists (tab, val)
    for index, value in ipairs (tab) do
        if value == val then
            return true
        end
    end

    return false
end

function destroyElementsByType(elementType)
	local elements = getElementsByType(elementType)
	for i,v in ipairs(elements) do
		destroyElement(v)
	end
end

function startGameMap( startedMap )
	outputDebugString("startGameMap")
	local mapRoot = getResourceRootElement( startedMap )
    spawnPoints = getElementsByType ( "hunterSpawnpoint" , mapRoot )
	checkPointCoords = getElementsByType ( "checkpoint" , mapRoot )
	goalCoord = getElementsByType ( "goal" , mapRoot )[1]
	lobbyStartCoord = getElementsByType ( "lobbyStart" , mapRoot )[1]
	startLobby()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function startLobby()
	lobbyStartCheckpoint = createCheckPoint(lobbyStartCoord)
	createHunterJets()
end

function leaveLobby()
	startGame()
	newRound()
end

function endRound( didFinish )
	table.insert(xMans, deliveryMan)
	roundActive = false
	if isEveryOneDone() then
		gameFinished()
	else
		local deliveryManName = getPlayerName(deliveryMan)
		local points = getElementData( deliveryMan, SCORE_KEY )
		displayMessageForAll(END_ROUND_TEXT_ID, deliveryManName.." got "..points.." points as delivery man", nil, nil, 5000)
		setTimer( prepareNewRound, 5000, 1)
	end
end

function gameFinished()
  local maxScore;
  local winner;
  for k1,v1 in ipairs(players) do
    local points = getElementData( v1, SCORE_KEY )
    if (points > maxScore) {
      winner = v1;
      maxScore = points;
    }
  end

  local winnerName = getPlayerName(winner)
  displayMessageForAll(END_GAME_TEXT_ID, winnerName.." won with "..maxScore.."! New game will start in 60 sec.", nil, nil, 60000)
  setTimer( prepareNewRound, 5000, 1)

  cleanUpMap();
  gameStarted = false;
  respawnAllPlayers();
end

function prepareNewRound()
	chooseNewDeliveryMan()
	if deliveryMan ~= nil then
		newRound()
	else
		gameFinished()
	end
end

function isEveryOneDone()
	local players = getElementsByType ( "player" )
	return #xMans == #players
end

function chooseNewDeliveryMan()
	local players = getElementsByType ( "player" )
	deliveryMan = nil
	if isEveryOneDone() then
		gameFinished()
	else
		deliveryMan = players[#xMans + 1];
	end
end

function playerReady(player)
	local players = getElementsByType ( "player" )
	if arrayExists(participants, player) == false then

		table.insert(participants, player)
		clearMessageForAll(PLAYER_READY_TEXT_ID)
		displayMessageForAll(PLAYER_READY_TEXT_ID, getPlayerName(player).." is ready", nil, nil, 5000, 0.5, 0.9)

		if #participants == #players then
			displayMessageForAll(LEAVING_LOBBY_TEXT_ID, "Game will start in 5 sec", nil, nil, 5000, 0.5, 0.5, 88, 255, 120)
			setTimer( leaveLobby, 5000, 1)
		end
	end
end

function markerHit( markerHit, matchingDimension )
	if gameStarted == false and markerHit == lobbyStartCheckpoint then
		playerReady(source)
		return
	end

	if checkPoints == nil or deliveryMan ~= source then
		return
	end

	if markerHit == goalCheckpoint then
		endRound()
		return
	end

	givePointsToDeliveryMan(1)

	local index = 1
    for i,v in ipairs(checkPoints) do
		if (v == markerHit) then
			currentCheckpoint = index + 1
			break
		end
		index = index + 1
	end

	destroyElement(markerHit)

	if currentCheckpointBlip ~= nil then
		destroyElement(currentCheckpointBlip)
		addCheckpointBlip(checkPoints[currentCheckpoint])
	end
end
addEventHandler( "onPlayerMarkerHit", getRootElement(), markerHit )

function playerDied( ammo, attacker, weapon, bodypart )
	if(source == deliveryMan) then
		endRound()
	else
		setTimer( spawn, 2000, 1, source)
	end
end
addEventHandler( "onPlayerWasted", getRootElement( ), playerDied)

function givePointsToDeliveryMan(points)
	local score = getElementData( deliveryMan, SCORE_KEY )
	if(score == false) then
		score = 0
	end
	score = score + points
	setElementData( deliveryMan, SCORE_KEY , score)
end

function createCheckpoints()
	currentCheckpoint = 1;
	checkPoints = {}
	for i,v in ipairs(checkPointCoords) do
		table.insert(checkPoints, createCheckPoint(v))
	end
end

function createHunterJets()
	local elements = getElementsByType("hunterJetSpawn")
	for i,v in ipairs(elements) do
		createHunterJet(v)
	end
end

function addPlayerBlips()
	local players = getElementsByType ( "player" )
	for k1,v1 in ipairs(players) do
		local blip = nil
		if v1 == deliveryMan then
			blip = createBlipAttachedTo ( deliveryMan, 60 )
			setElementVisibleTo ( blip, deliveryMan, false )
		else
			blip = createBlipAttachedTo ( v1, 5 )
			setElementVisibleTo ( blip, root, false )
			setElementVisibleTo ( blip, deliveryMan, true )
		end
	end
end

function addCheckpointBlip(checkpoint)
	local x, y, z = getElementPosition ( checkpoint )
	currentCheckpointBlip = createBlip ( x, y, z )
	setElementVisibleTo ( currentCheckpointBlip, root, false )
	setElementVisibleTo ( currentCheckpointBlip, deliveryMan, true )
end

function createCheckPoint(element)
	local posX, posY, posZ = coordsFromEdl ( element )
	local checkType = getElementData ( element, "type" )
	local color = getElementData ( element, "color" )
	local size = getElementData ( element, "size" )
	return createMarker(posX, posY, posZ, checkType, size)
end

function coordsFromEdl(element)
	local posX = getElementData ( element, "posX" )
	local posY = getElementData ( element, "posY" )
	local posZ = getElementData ( element, "posZ" )
	return posX, posY, posZ
end

function createDeliveryCar(element)
	local posX, posY, posZ = coordsFromEdl ( element )
	local rotX = getElementData ( element, "rotX" )
	local rotY = getElementData ( element, "rotY" )
	local rotZ = getElementData ( element, "rotZ" )
	local model = getElementData ( element, "model" )
	local plate = getElementData ( element, "plate" )
	return createVehicle(model, posX, posY, posZ, rotX, rotY, rotZ, plate)
end

function createHunterJet(element)
	local posX, posY, posZ = coordsFromEdl ( element )
	local rotX = getElementData ( element, "rotX" )
	local rotY = getElementData ( element, "rotY" )
	local rotZ = getElementData ( element, "rotZ" )
	local model = getElementData ( element, "model" )
	local plate = getElementData ( element, "plate" )
	return createVehicle(model, posX, posY, posZ, rotX, rotY, rotZ, plate)
end

function joinHandler()

	if(gameStarted and deliveryMan == nil) then
		deliveryMan = source
		setUpDeliveryManStuff()
	end
	spawn(source)
	outputChatBox("Welcome to My Server", source)
end
addEventHandler("onPlayerJoin", getRootElement(), joinHandler)

function commitSuicide ( sourcePlayer )
	-- kill the player and make him responsible for it
	killPed ( sourcePlayer, sourcePlayer )
end
addCommandHandler ( "kill", commitSuicide )

function nextRound ( sourcePlayer )
	changeGamemodeMap (getRunningGamemodeMap ())
end
addCommandHandler ( "next", nextRound )

function displayMessageForAll(textId, text, specialPlayer, specialText, displayTime, posX, posY, r, g, b, alpha, scale)
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		clearMessageForPlayer ( v, textId )
		if(v ~= specialPlayer) then
			displayMessageForPlayer ( v, textId, text, displayTime, posX, posY, r, g, b, alpha, scale )
		end
	end
	if specialPlayer ~= nil and  specialText ~= nil then
		displayMessageForPlayer ( specialPlayer, textId, specialText, displayTime, posX, posY, r, g, b, alpha, scale )
	end
end

function clearMessageForAll ( textID , exceptPlayer)
	local players = getElementsByType ( "player" )
	for k,v in ipairs(players) do
		if(v ~= exceptPlayer) then
			clearMessageForPlayer( v, textID)
		end
	end
end

function displayMessageForPlayer ( player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
	assert ( player and ID and message )
	local easyTextResource = getResourceFromName ( "easytext" )
	displayTime = displayTime or 5000
	posX = posX or 0.5
	posY = posY or 0.5
	r = r or 255
	g = g or 127
	b = b or 0
	-- display message for everyone
	outputConsole ( message, player )
	call ( easyTextResource, "displayMessageForPlayer", player, ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
end

function clearMessageForPlayer ( player, ID )
	assert ( player and ID )
	call ( getResourceFromName ( "easytext" ), "clearMessageForPlayer", player, ID )
end

addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"removeScoreboardColumn",SCORE_KEY)
end )

addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),
function()
	call(scoreboardRes,"addScoreboardColumn",SCORE_KEY)
end )
