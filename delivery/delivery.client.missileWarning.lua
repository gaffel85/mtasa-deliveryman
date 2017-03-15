local nbrOfMissiles = 0

addEventHandler("onClientRender", root, function()
  if nbrOfMissiles > 0 then
    local projectiles = getElementsByType ("projectile")
    for k,v in ipairs(projectiles) do
      local projType = getProjectileType (v)
      if projType == 19 or projType == 20 then
        renderMissileLine(v)
      end
    end
  end
end)

function renderMissileLine(missile)
  local x1, y1, z1 = getElementPosition(missile)
  local velX, velY, velZ = getElementVelocity(missile)

  local

  velX*t + x1 = x2
end

function missileFired(missile)
  nbrOfMissiles = nbrOfMissiles + 1
  addEventHandler("onClientElementDestroy", missile, function ()
    nbrOfMissiles = nbrOfMissiles - 1
  end)
end

function projectileFired ( )
  local projType = getProjectileType( source )
  if projType == 19 or projType == 20 then
	   missileFired(source)
	end
end
addEventHandler( "onClientProjectileCreation", getRootElement(), projectileFired )
