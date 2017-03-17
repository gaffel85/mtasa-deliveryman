local deliveryMan = nil

function deliveryManChanged()
  deliveryMan = source
end
addEvent("onDeliveryManChanged", true)
addEventHandler("onDeliveryManChanged", getRootElement(), deliveryManChanged)

function createMarker ( )
  if deliveryMan then
    local car = getPedOccupiedVehicle(deliveryMan)
    local car = deliveryMan
    if car then
      x1, y1, z1 = getElementPosition ( car )
      local playerX, playerY, playerZ = getElementPosition(getLocalPlayer())
      local distanceAway = getDistanceBetweenPoints3D(x1, y1, z1, playerX, playerY, playerZ)
      local alpha = math.min(distanceAway/2, 255)
      local height = math.min(distanceAway/100, 5)
      dxDrawLine3D ( x1, y1, z1, x1, y1, z1+height, tocolor ( 255, 0, 0, alpha ), 500, true) -- Create 3D Line between test vehicle and local player.
    end
  end
end

function exitVehicle ( thePlayer, seat, jacked )
  removeEventHandler("onClientRender", root, createMarker)
end
addEventHandler("onClientPlayerVehicleExit", localPlayer, exitVehicle)

function enterVehicle(theVehicle)
	if getElementModel(theVehicle) == 520 then
    addEventHandler("onClientRender", root, createMarker)
  end
end
addEventHandler("onClientPlayerVehicleEnter",localPlayer,enterVehicle)
