local fallbackSpawnX, fallbackSpawnY, fallbackSpawnZ = 1959.55, -1714.46, 10
local spawnPoints
local checkPointCoords
local checkPoints = {}
local currentCheckpoint
local currentCheckpointBlip
local deliveryCar
local deliveryMan
local lastHunterSpawn = 1
local xMans = {}
local gameStarted = false

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
		
        spawnPlayer(thePlayer, 0, 0, 0) 
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
		
		spawnPlayer(thePlayer, spawnX, spawnY, spawnZ, 0, normalModel)
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
	if (deliveryMan ~= nil) then
		local checkpoint = checkPointCoords[currentCheckpoint]
		addCheckpointBlip(checkpoint)
	end
end

function newRound()
	destroyElementsByType ("marker")
	destroyElementsByType ("vehicle")
	deliveryCar = createDeliveryCar(getElementsByType ( "deliveryCar" , mapRoot )[1])
	createCheckpoints()
	createHunterJets()
	respawnAllPlayers()
	setUpDeliveryManStuff()
end

function startGame()
	local players = getElementsByType ( "player" )
	if (#players > 0) then
		deliveryMan = nil
		while (deliveryMan == nil) do
			local candidate = players[math.random(1,#players)]
			if (arrayExists(xMans, candidate) == false) then
				deliveryMan = candidate;
			end
		end
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
	local mapRoot = getResourceRootElement( startedMap ) 
    spawnPoints = getElementsByType ( "hunterSpawnpoint" , mapRoot )
	checkPointCoords = getElementsByType ( "checkpoint" , mapRoot )
	startGame()
	newRound()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function markerHit( hitElement, matchingDimension ) 
	outputDebugString("Marker hit")
	local index = 1
    for i,v in ipairs(checkPoints) do
		if (checkPoints == hitElement) then
			currentCheckpoint = index + 1
			break
		end
		index = index + 1
	end
	destroyElement(currentCheckpointBlip)
	currentCheckpointBlip = addCheckpointBlip(checkPoints[currentCheckpoint])
end
addEventHandler( "onMarkerHit", getRootElement(), markerHit )

function createCheckpoints() 
	currentCheckpoint = 1;
	checkpoints = {}
	for i,v in ipairs(checkPointCoords) do
		table.insert(checkpoints, createCheckPoint(v))
	end
end

function createHunterJets()
	local elements = getElementsByType("hunterJetSpawn")
	for i,v in ipairs(elements) do
		createHunterJet(v)
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
	-- setElementModel ( source, normalModel )
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