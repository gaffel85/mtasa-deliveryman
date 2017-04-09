local rocketsFired = {}
local magSize = 8;
local reloadTimeInMillis = 2000;
local MAX_ROCKET_SPEED = 100;
local ROCKET_SPEED = 0.1;

function disableFireForHydra ( disable )
  if disable then
    displayMessageForPlayer(92992, "Reloading", reloadTimeInMillis, 0.5, 0.9, 255, 0, 0 )
    --toggleControl ( "vehicle_secondary_fire", false ) -- disable their fire key
    --toggleControl ( "vehicle_fire", true ) -- enable their fire key
  else
    clearMessageForPlayer(92992)
  --  toggleControl ( "vehicle_secondary_fire", true ) -- enable their fire key
    --toggleControl ( "vehicle_fire", true ) -- enable their fire key
  end
end

function missileFired ()
  local now = getTickCount()
  local wasFired = false
  -- Remove old rockets from history
  if #rocketsFired >= magSize then
    local done = false
    while not done do
      local timeElapsed = now - rocketsFired[1];
      if timeElapsed > reloadTimeInMillis then
        table.remove(rocketsFired, 1)
        if #rocketsFired <= 0 then
          done = true
        end
      else
        done = true;
      end
    end
  end

  if #rocketsFired < magSize then
    table.insert(rocketsFired, now);
    wasFired = true

    if #rocketsFired >= magSize then
      disableFireForHydra(true);
      local reloadTime = reloadTimeInMillis - (getTickCount() - rocketsFired[1]);
      setTimer(function()
        table.remove(rocketsFired, 1)
        disableFireForHydra(false);
      end, reloadTime, 1)
    end
  end

  return wasFired
end

function projectileFired ( )
  local projType = getProjectileType( source )
  if projType == 19 or projType == 20 then
    velX, velY, velZ = getElementVelocity(source)
	   setElementVelocity(source, velX*ROCKET_SPEED*MAX_ROCKET_SPEED, velY*ROCKET_SPEED*MAX_ROCKET_SPEED, velZ*ROCKET_SPEED*MAX_ROCKET_SPEED)
	end
end
addEventHandler( "onClientProjectileCreation", getRootElement(), projectileFired )

function playerPressedKey(button, press)
  if press and button == "lctrl" then
      local hasMissileLeft = missileFired()
      if not hasMissileLeft then
        cancelEvent ()
      end
  end
end
addEventHandler("onClientKey", root, playerPressedKey)

function reloadTimeChangedRequest(newMagSize, newReloadTime)
  magSize = tonumber(newMagSize);
  reloadTimeInMillis = tonumber(newReloadTime);
  outputChatBox("Missiles: "..magSize.." Time: "..reloadTimeInMillis.." ms")
end
addEvent("onReloadTimeChangedRequest", true)
addEventHandler("onReloadTimeChangedRequest", getLocalPlayer(), reloadTimeChangedRequest)

function missileSpeedChangeRequest(speed)
  MAX_ROCKET_SPEED = tonumber(speed)
  outputChatBox("Missile MAX speed: "..MAX_ROCKET_SPEED.."x")
end
addEvent("onMissileSpeedChangeRequest", true)
addEventHandler("onMissileSpeedChangeRequest", getLocalPlayer(), missileSpeedChangeRequest)

function missileSpeedStepRequest(speed)
  ROCKET_SPEED = tonumber(speed)
  outputChatBox("Missile speed step: "..ROCKET_SPEED.."x")
end
addEvent("onMissileSpeedStepRequest", true)
addEventHandler("onMissileSpeedStepRequest", getLocalPlayer(), missileSpeedStepRequest)

function displayMessageForPlayer ( ID, message, displayTime, posX, posY, r, g, b, alpha, scale )
	triggerServerEvent("onDisplayClientText", resourceRoot, getLocalPlayer(), ID, message, displayTime, posX, posY, r, g, b, scale)
end

function clearMessageForPlayer ( ID )
	triggerServerEvent("onClearClientText", resourceRoot, getLocalPlayer(), ID)
end
