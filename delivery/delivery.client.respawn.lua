function setGetThrusters (vehicle, thrusterValue)
	if thrusterValue and vehicle then
		local theVehicle = vehicle --getPedOccupiedVehicle ( getLocalPlayer() )
		if (theVehicle and getElementModel(theVehicle) == 520) then
			setVehicleAdjustableProperty ( theVehicle, thrusterValue )
		end
	else
		local val = getVehicleAdjustableProperty(getPedOccupiedVehicle(getLocalPlayer()))
		triggerServerEvent("clientSaveThrusterStatesRequest", getLocalPlayer(), val)
	end


end
addEvent( "onSetGetThrusters", true )
addEventHandler( "onSetGetThrusters", localPlayer, setGetThrusters )
