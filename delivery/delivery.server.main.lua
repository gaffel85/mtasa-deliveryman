local fallbackSpawnX, fallbackSpawnY, fallbackSpawnZ = 1959.55, -1714.46, 10
local spawnPoints
local deliveryCar
local deliveryMan
players = getElementsByType ( "player" )

function getRandomSpawnPoint ()
	local point = spawnPoints[math.random(1,#spawnPoints)]
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
		local deliveryManPed = createPed ( 252, 0, 0, 3 )
		spawnX, spawnY, spawnZ = getRandomSpawnPoint()
		deliveryCar = createVehicle ( 566, spawnX,spawnY,spawnZ )
		
        spawnPlayer(thePlayer, spawnX + 5, spawnY, spawnZ) 
        if deliveryCar  then 
            setTimer(warpPedIntoVehicle, 50, 1, thePlayer, deliveryCar) 
        end 
		

--		fadeCamera(thePlayer, true)
--		setCameraTarget(thePlayer, thePlayer)
	else
		local spawnX, spawnY, spawnZ
		if(spawnPoints == nil) then
			spawnX = fallbackSpawnX
			spawnY = fallbackSpawnY
			spawnZ = fallbackSpawnZ
		else
			spawnX, spawnY, spawnZ = getRandomSpawnPoint()
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

function startGameMap( startedMap )
	local mapRoot = getResourceRootElement( startedMap ) 
    spawnPoints = getElementsByType ( "hunterSpawnpoint" , mapRoot )
	deliveryCar = getElementsByType ( "deliveryCar" , mapRoot )[0]
	-- respawnAllPlayers()
end
addEventHandler("onGamemodeMapStart", getRootElement(), startGameMap)

function joinHandler()
	if(deliveryMan == nil) then
		deliveryMan = source
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