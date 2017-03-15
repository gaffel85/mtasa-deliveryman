local deliveryMan = nil

function deliveryManChanged()
  deliveryMan = source
  setVehicleAdjustableProperty ( getPedOccupiedVehicle(getLocalPlayer()), 2500 )
end
addEvent("onDeliveryManChanged", true)
addEventHandler("onDeliveryManChanged", getRootElement(), deliveryManChanged)

function createMarker ( )
  deliveryMan = getLocalPlayer()
  if deliveryMan then
    local car = getPedOccupiedVehicle(deliveryMan)
    local car = deliveryMan
    if car then
      x1, y1, z1 = getElementPosition ( car )
      dxDrawLine3D ( x1, y1, z1, x1, y1, z1+2, tocolor ( 255, 0, 0, 230 ), 500, true) -- Create 3D Line between test vehicle and local player.
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
