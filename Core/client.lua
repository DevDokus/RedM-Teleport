--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
function Wait(args)
    Citizen.Wait(args)
end
function Await(args)
    Citizen.Await(args)
end
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
RegisterNetEvent('DevDokus:Teleport:C:Teleport')
AddEventHandler('DevDokus:Teleport:C:Teleport', function()
    local ply = PlayerPedId()
    if DoesEntityExist(ply) then
        local WP = GetWaypointCoords()
        if (WP.x == 0 and WP.y == 0) then
            --Enter Notification of no waypoint here or do nothing
        else
            local height = 1
            for height = 1, 1000 do
                SetEntityCoords(ply, WP.x, WP.y, height + 0.0)
                local foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(WP.x, WP.y, height + 0.0)
                if foundground then
                    SetEntityCoords(ply, WP.x, WP.y, height + 0.0)
                    break
                end
                Wait(25)
            end
        end
    end
end)
--------------------------------------------------------------------------------
