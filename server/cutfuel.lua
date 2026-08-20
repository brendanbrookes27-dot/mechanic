-- Server side cutfuel logic

lib.callback.register('qbx_mechanic:server:canCutFuelLine', function(source)
    -- Check if player has wire_cutters or mechanic tool in ox_inventory
    local count = exports.ox_inventory:GetItemCount(source, 'wire_cutters')
    if count and count > 0 then
        return true
    end
    -- Allow if player is mechanic or has generic toolkit
    local toolCount = exports.ox_inventory:GetItemCount(source, 'mechanic_tools')
    return (toolCount and toolCount > 0)
end)

RegisterNetEvent('qbx_mechanic:server:setFuelCut', function(plate, status)
    local src = source
    local data = exports.qbx_mechanic:GetVehicleMechanicData(plate)
    if data then
        data.fuel_cut = status and 1 or 0
        exports.qbx_mechanic:SaveVehicleMechanicData(plate, data)
    end
end)
