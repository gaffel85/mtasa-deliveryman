local rocketsFired = {}
local magSize =2;
local reloadTimeInMillis = 5000;

function disableFireForHydra ( disable )
  if disable then
    outputChatBox("Reloading")
    toggleControl ( "vehicle_secondary_fire", false ) -- disable their fire key
    toggleControl ( "vehicle_fire", true ) -- enable their fire key
  else
    outputChatBox("Reloading done")
    toggleControl ( "vehicle_secondary_fire", true ) -- enable their fire key
    toggleControl ( "vehicle_fire", true ) -- enable their fire key
  end
end

function missileFired ()
  local now = getTickCount()

  -- Remove old rockets from history
  if #rocketsFired >= magSize then
    local done = false
    while not done do
      local timeElapsed = now - rocketsFired[1];
      outputDebugString("Duration: "..timeElapsed)
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
  end

  outputDebugString("fired: "..#rocketsFired .. " magSize: "  ..magSize)
  if #rocketsFired >= magSize then
    disableFireForHydra(true);
    local reloadTime = reloadTimeInMillis - (getTickCount() - rocketsFired[1]);
    outputDebugString("reloadTime: "..reloadTime)
    setTimer(function()
      table.remove(rocketsFired, 1)
      disableFireForHydra(false);
    end, reloadTime, 1)
  end
end

function projectileFired ( )
  outputDebugString("A")
  local projType = getProjectileType( source )
  if projType == 19 or projType == 20 then
	   missileFired()
	end
end
addEventHandler( "onClientProjectileCreation", getRootElement(), projectileFired )

function reloadTimeChangedRequest(newMagSize, newReloadTime)
  magSize = tonumber(newMagSize);
  reloadTimeInMillis = tonumber(newReloadTime);
end
addEvent("onReloadTimeChangedRequest", true)
addEventHandler("onReloadTimeChangedRequest", getLocalPlayer(), reloadTimeChangedRequest)
