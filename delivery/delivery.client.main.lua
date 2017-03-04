var rocketsFired = {}
var magSize = 4;
var reloadTimeInHundreds = 300;

function setThrustersEventHandler ()
     local theVehicle = getPedOccupiedVehicle ( thePlayer )
     if (theVehicle and getElementModel(theVehicle) == 520) then
       setVehicleAdjustableProperty ( theVehicle, 255 )
     end
end
addEvent( "onHunterRespawn", true )
addEventHandler( "onHunterRespawn", localPlayer, setThrustersEventHandler )


function disableFireForHydra ( disable )
  if disable then
    toggleControl ( "vehicle_secondary_fire", false ) -- disable their fire key
  else
    toggleControl ( "vehicle_secondary_fire", true ) -- enable their fire key
  end
end

function missileFierd ()
  var now = os.clock();
  outputChatBox("Missile fired " + now);

  -- Remove old rockets from history
  if #rocketsFired >= magSize then
    local done = false
    while done ~= true do
      var timeElapsed = now - v;
      if timeElapsed > reloadTimeInHundreds then
        table.remove(rocketsFired, 0)
      else
        done = true;
      end
    end
  end

  if #rocketsFired < magSize then
    table.insert(rocketsFired, time);
  end

  if #rocketsFired >= magSize then
    disableFireForHydra(true);
    var reloadTime = os.clock() - rocketsFired[0];
    setTimer(function() 
      table.remove(rocketsFired, 0)
      disableFireForHydra(false);
    end, reloadTime * 10, 1)
  end
end

armedVehicles = {[425]=true, [520]=true, [476]=true, [447]=true, [430]=true, [432]=true, [464]=true, [407]=true, [601]=true}
function vehicleWeaponFire(key, keyState, vehicleFireType)
	local vehModel = getElementModel(getPedOccupiedVehicle(localPlayer))
	if (armedVehicles[vehModel]) then
		function missileFierd ()
	end
end
bindKey("vehicle_fire", "down", vehicleWeaponFire, "primary")
bindKey("vehicle_secondary_fire", "down", vehicleWeaponFire, "secondary")
