--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
function Wait(args) Citizen.Wait(args) end
function Await(args) Citizen.Await(args) end
local VORPCore = {}
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while not VORPCore do
        TriggerEvent("getCore", function(core)
            VORPCore = core
        end)
        Await(200)
    end
end)
--------------------------------------------------------------------------------
-- Register the TPM command
RegisterCommand('tpm', function()
  if AdminOnly then
    TriggerServerEvent('DevDokus:Teleport:S:CheckAdmin')
  else
    TriggerEvent('DevDokus:Teleport:C:Teleport')
  end
end)
--------------------------------------------------------------------------------
-- Collision (and therefore ground data) only streams in around the player
-- entity itself, and GetGroundZAndNormalFor_3dCoord casts DOWNWARD from the
-- height you give it. Querying from a height far above the terrain fails
-- because that collision is never loaded, and querying from below the
-- terrain finds nothing underneath. So we sweep upward in steps, physically
-- moving the (frozen, faded-out) entity to each test height, give the world
-- a moment to stream in, and ask for the ground below that height. The
-- first step that sits above the terrain with collision loaded returns the
-- real ground Z.
local function FindGround(entity, x, y)
  local testZ = 0.0
  while testZ <= TeleportMaxHeight do
    SetEntityCoordsNoOffset(entity, x, y, testZ, false, false, false)
    RequestCollisionAtCoord(x, y, testZ)
    for _ = 1, 6 do
      Wait(50)
      local found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, testZ)
      if found then
        return true, groundZ
      end
      if HasCollisionLoadedAroundEntity(entity) then
        -- Collision is loaded here and there is still no ground below us,
        -- so this height must be underneath the terrain. Go higher.
        break
      end
    end
    testZ = testZ + TeleportHeightStep
  end
  return false, nil
end
--------------------------------------------------------------------------------
RegisterNetEvent('DevDokus:Teleport:C:Teleport')
AddEventHandler('DevDokus:Teleport:C:Teleport', function()
  local ply = PlayerPedId()
  if not DoesEntityExist(ply) then return end

  local WP = GetWaypointCoords()
  if WP.x == 0 and WP.y == 0 then
    -- No waypoint set, do nothing
    return
  end

  -- Move the mount/vehicle instead of the bare ped when riding, so the
  -- player arrives together with their horse or wagon.
  local entity = ply
  if IsPedOnMount(ply) then
    entity = GetMount(ply)
  elseif IsPedInAnyVehicle(ply, false) then
    entity = GetVehiclePedIsIn(ply, false)
  end

  local originalCoords = GetEntityCoords(entity)

  DoScreenFadeOut(300)
  while not IsScreenFadedOut() do
    Wait(0)
  end
  FreezeEntityPosition(entity, true)

  local found, groundZ = FindGround(entity, WP.x, WP.y)

  if found then
    SetEntityCoordsNoOffset(entity, WP.x, WP.y, groundZ + TeleportGroundOffset, false, false, false)
    -- Let collision finish streaming at the landing spot before handing
    -- control back, otherwise the player can still drop through the map.
    RequestCollisionAtCoord(WP.x, WP.y, groundZ)
    local settle = 0
    while not HasCollisionLoadedAroundEntity(entity) and settle < 80 do
      Wait(25)
      settle = settle + 1
    end
  else
    -- No ground anywhere in the sweep (void / far off the map) - put the
    -- player back where they started instead of dropping them.
    SetEntityCoordsNoOffset(entity, originalCoords.x, originalCoords.y, originalCoords.z, false, false, false)
    TriggerEvent("vorp:TipRight", 'No ground found at the waypoint', 4000)
  end

  FreezeEntityPosition(entity, false)
  DoScreenFadeIn(300)
end)
--------------------------------------------------------------------------------
