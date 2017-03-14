function setThrustersEventHandler (thrusterValue)
	if thrusterValue then
		local theVehicle = getPedOccupiedVehicle ( getLocalPlayer() )
		if (theVehicle and getElementModel(theVehicle) == 520) then
			setVehicleAdjustableProperty ( theVehicle, thrusterValue )
		end
	else
		local val = getVehicleAdjustableProperty(getPedOccupiedVehicle(getLocalPlayer()))
	end


end
addEvent( "onHunterRespawn", true )
addEventHandler( "onHunterRespawn", localPlayer, setThrustersEventHandler )
