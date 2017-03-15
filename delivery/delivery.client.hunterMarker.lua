local deliveryMan = nil

function deliveryManChanged(newDeliveryMan)
  deliveryMan = newDeliveryMan
end
addEvent("onDeliveryManChanged", true)
addEventHandler("onDeliveryManChanged", localPlayer, deliveryManChanged)

function createMarker ( )
  if deliveryMan then
    local car = getPedOccupiedVehicle(deliveryMan)
    if car then
      x1, y1, z1 = getElementPosition ( car )
      dxDrawLine3D ( x1, y1, z1, x1, y1, z1+2, tocolor ( 255, 0, 0, 230 ), 50, true) -- Create 3D Line between test vehicle and local player.
    end
  end
end
addCommandHandler("test", makeLineAppear)


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
