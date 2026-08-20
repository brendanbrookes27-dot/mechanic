-- Server side degradation & servicing handlers

local PartRequiredItems = {
    oil = 'engine_oil',
    spark_plugs = 'mechanic_tools',
    clutch = 'mechanic_tools',
    suspension = 'mechanic_tools',
    brakes = 'brake_pads',
    tires = 'mechanic_tires',
    fuel_filter = 'mechanic_tools'
}

RegisterNetEvent('qbx_mechanic:server:repairPart', function(plate, partName, newValue)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    -- Verify mechanic job
    local jobName = player.PlayerData.job.name
    if not Config.MechanicJobs[jobName] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Servicing', description = 'Only mechanics can service vehicles!', type = 'error' })
        return
    end

    -- Check required item in ox_inventory
    local requiredItem = PartRequiredItems[partName] or 'mechanic_tools'
    local itemCount = exports.ox_inventory:GetItemCount(src, requiredItem)

    if itemCount and itemCount <= 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Servicing', description = string.format('You need a %s to service %s!', requiredItem, partName), type = 'error' })
        return
    end

    -- Remove item if consumable part
    if partName == 'oil' or partName == 'brakes' or partName == 'tires' then
        exports.ox_inventory:RemoveItem(src, requiredItem, 1)
    end

    local data = exports.qbx_mechanic:GetVehicleMechanicData(plate)
    if data and data[partName] ~= nil then
        data[partName] = math.min(100.0, newValue or 100.0)
        exports.qbx_mechanic:SaveVehicleMechanicData(plate, data)

        -- Broadcast state update to all clients
        TriggerClientEvent('qbx_mechanic:client:syncVehicleData', -1, plate, data)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Vehicle Serviced', description = string.format('Successfully serviced %s!', partName), type = 'success' })
    end
end)
