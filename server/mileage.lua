-- Server side mileage event handler if needed
RegisterNetEvent('qbx_mechanic:server:updateMileage', function(plate, addedMileage)
    local src = source
    local data = exports.qbx_mechanic:GetVehicleMechanicData(plate)
    if data then
        data.mileage = data.mileage + addedMileage
        exports.qbx_mechanic:SaveVehicleMechanicData(plate, data)
    end
end)
