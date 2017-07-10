local deliveryCar = nil
local carMaxHP = 1000

function deliveryCarHealtBar()
	deliveryCar = findDeliveryCar()

	if deliveryCar then
		dxDrawProgressBar( 500, 20, 200, 30, healtProgress(deliveryCar), tocolor( 250, 50, 50, 255), tocolor( 255, 255, 255, 255) )
	end
end

function healtProgress(car)
	return 100 * getElementHealth (car) / carMaxHP
end

function findDeliveryCar()
	if deliveryCar then
		return deliveryCar
	end

	local cars = getElementsByType("vehicle")

	for i,car in ipairs(cars) do
		if car and getElementModel(car) ~= 520 then
			carMaxHP = getElementHealth(car)
			return car
		end
	end
	return nil
end

addEventHandler ( "onClientVehicleDamage", root, function ( attacker, weapon, loss )
	if source == deliveryCar and loss > 100 then        

		outputDebugString("Hit")
		fixVehicle (source)
	end
end )

function hitDeliveryManChanged()
	deliveryCar = nil;
  if source == getLocalPlayer() then
    --addEventHandler("onClientRender", root, renderAllMissiles)
  else
	--removeEventHandler("onClientRender", root, renderAllMissiles)
  end
  addEventHandler("onClientRender", root, deliveryCarHealtBar)
end
addEventHandler("onDeliveryManChanged", getRootElement(), hitDeliveryManChanged)



function joinHandler()
	addEventHandler("onClientRender", root, deliveryCarHealtBar)
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), joinHandler)

local unlerp = function(from,to,lerp) return (lerp-from)/(to-from) end
 
function dxDrawProgressBar( startX, startY, width, height, progress, color, backColor )
        local progress = math.max( 0, (math.min( 100, progress) ) )
        local wBar = width*.18
        for i = 0, 4 do
                --back
                local startPos = (wBar*i + (width*.025)*i) + startX
                dxDrawRectangle( startPos, startY, wBar, height, backColor )
                --progress
                local eInterval = (i*20)
                local localProgress = math.min( 1, unlerp( eInterval, eInterval + 20, progress ) )
                        if localProgress > 0 then
                                dxDrawRectangle( startPos, startY, wBar*localProgress, height, color )
                        end
        end
end