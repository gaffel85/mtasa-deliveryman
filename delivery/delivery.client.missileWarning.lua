local missilesInfo = {}
local maxWarningDist = 200

addEventHandler("onClientRender", root, renderAllMissiles)

function renderAllMissiles()
  --if nbrOfMissiles > 0 then
    local projectiles = getElementsByType ("projectile")
    for k,v in ipairs(projectiles) do
      local projType = getProjectileType (v)
      if projType == 19 or projType == 20 then
        renderMissileLine(v)
      end
    end
  --end
end

function renderMissileLine(missile)
  local info = missilesInfo[missile]
  if not info then
    local x2, y2, z2 = getEndCoordsForMissile(missile)
    info = {x2 = x2, y2 = y2, z2 = z2}
    missilesInfo[missile] = info
  end

  local x1, y1, z1 = getElementPosition(missile)
  local playerX, playerY, playerZ = getElementPosition(getLocalPlayer())
  local distanceAway = getDistanceBetweenPoints3D(x1, y1, z1, playerX, playerY, playerZ)
  outputDebugString("Dist: "..distanceAway .. " Accepted: "..maxWarningDist)
  if distanceAway < maxWarningDist then
    dxDrawLine3D ( x1, y1, z1, info.x2, info.y2, info.z2, tocolor ( 180, 0, 0, 200 ), 4) -- Create 3D Line between test vehicle and local player.
  end
end

function getEndCoordsForMissile(missile)
  local x1, y1, z1 = getElementPosition(missile)
  local velX, velY, velZ = getElementVelocity(missile)

  local tx = timeToMaxCoord(velX, x1)
  local ty = timeToMaxCoord(velY, y1)
  local tz = timeToMaxCoord(velZ, z1)

  local time = math.min(tx, ty, tz)
  local x2 = time * velX + x1
  local y2 = time * velY + y1
  local z2 = time * velZ + z1

  return x2, y2, z2
end

local worldMaxSize = 3000
function timeToMaxCoord(velocity, start)
  local signKoeff = velocity/math.abs(velocity)
  return (signKoeff * worldMaxSize - start)/velocity
end

function onMissile(missile)
  addEventHandler("onClientElementDestroy", missile, function ()
    missilesInfo[missile] = nil
  end)
end

function onProjectile ( )
  local projType = getProjectileType( source )
  if projType == 19 or projType == 20 then
	   onMissile(source)
	end
end
addEventHandler( "onClientProjectileCreation", getRootElement(), onProjectile )

function warningDeliveryManChanged()
  if source == getLocalPlayer() then
    addEventHandler("onClientRender", root, renderAllMissiles)
  else
    removeEventHandler("onClientRender", root, renderAllMissiles)
  end
end
addEventHandler("onDeliveryManChanged", getRootElement(), warningDeliveryManChanged)


function missileWarningDistChangedRequest(newMaxDist, newReloadTime)
  maxWarningDist = tonumber(newMaxDist);
  outputChatBox("New Max dist: "..newMaxDist)
end
addEvent("onMissileWarningDistChangedRequest", true)
addEventHandler("onMissileWarningDistChangedRequest", getLocalPlayer(), missileWarningDistChangedRequest)
