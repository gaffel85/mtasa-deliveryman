function setThrustersEventHandler ()
     local theVehicle = getPedOccupiedVehicle ( getLocalPlayer() )
     if (theVehicle and getElementModel(theVehicle) == 520) then
       setVehicleAdjustableProperty ( theVehicle, 255 )
     end
end
addEvent( "onHunterRespawn", true )
addEventHandler( "onHunterRespawn", localPlayer, setThrustersEventHandler )
