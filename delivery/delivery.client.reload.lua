var rocketsFired = {}
var magSize = 4;
var reloadTimeInHundreds = 500;

function disableFireForHydra ( disable )
  if disable then
    toggleControl ( "vehicle_secondary_fire", false ) -- disable their fire key
    toggleControl ( "vehicle_fire", true ) -- enable their fire key
  else
    toggleControl ( "vehicle_secondary_fire", true ) -- enable their fire key
    toggleControl ( "vehicle_fire", true ) -- enable their fire key
  end
end

function missileFired ()
  local now = os.clock();
  outputChatBox("Missile fired ".. now);

  -- Remove old rockets from history
  if #rocketsFired >= magSize then
    local done = false
    while not done do
      local timeElapsed = now - rocketsFired[0];
      if timeElapsed > reloadTimeInHundreds then
        table.remove(rocketsFired, 0)
        if #rocketsFired <= 0 then
          done = true
        end
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

function projectileFired ( )
  local projType = getProjectileType( source )
  if projType == 19 or projType == 20 then
	   missileFired()
	end
end

addEventHandler( "onClientProjectileCreation", getRootElement(), projectileFired )
