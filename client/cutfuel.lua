-- /cutfuel command implementation

local function GetClosestVehicleToPlayer(radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh = lib.getClosestVehicle(coords, radius or 3.0, false)
    return veh
end

RegisterCommand('cutfuel', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        lib.notify({ title = 'Fuel Line', description = 'You cannot cut fuel lines while inside a vehicle!', type = 'error' })
        return
    end

    local vehicle = GetClosestVehicleToPlayer(3.0)
    if not vehicle or not DoesEntityExist(vehicle) then
        lib.notify({ title = 'Fuel Line', description = 'No vehicle nearby to cut fuel line!', type = 'error' })
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate then return end

    -- Check if player has shears or wire cutters in inventory via server
    lib.callback('qbx_mechanic:server:canCutFuelLine', false, function(hasTool)
        if not hasTool then
            lib.notify({ title = 'Fuel Line', description = 'You need wire cutters or a cutting tool!', type = 'error' })
            return
        end

        -- Animation and Progress Bar
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_VEHICLE_MECHANIC', 0, true)

        if lib.progressBar({
            duration = 7000,
            label = 'Cutting vehicle fuel line...',
            useReplay = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            }
        }) then
            ClearPedTasks(ped)
            TriggerServerEvent('qbx_mechanic:server:setFuelCut', plate, true)
            lib.notify({ title = 'Fuel Line Cut', description = 'You successfully cut the vehicle\'s fuel line!', type = 'success' })
        else
            ClearPedTasks(ped)
            lib.notify({ title = 'Cancelled', description = 'Cancelled fuel line cutting!', type = 'error' })
        end
    end)
end, false)

TriggerEvent('chat:addSuggestion', '/cutfuel', 'Sabotage/cut the fuel line of the nearest vehicle.')
