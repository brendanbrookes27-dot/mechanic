local inVehicle = false
local currentVehicle = nil
local currentPlate = nil
local currentVehicleData = nil
local lastPos = nil

-- Function to send NUI messages to HUD
local function UpdateOdometerHUD(visible, mileage, unit)
    SendNUIMessage({
        action = "updateOdometer",
        visible = visible,
        mileage = string.format("%.1f", mileage or 0.0),
        unit = unit or Config.DistanceUnit
    })
end

RegisterNetEvent('qbx_mechanic:client:syncVehicleData', function(plate, data)
    if currentPlate and currentPlate == plate then
        currentVehicleData = data
    end
end)

-- Thread to track vehicle distance
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local isDriver = (GetPedInVehicleSeat(veh, -1) == ped)

            if not inVehicle or currentVehicle ~= veh then
                inVehicle = true
                currentVehicle = veh
                currentPlate = GetVehicleNumberPlateText(veh)
                lastPos = GetEntityCoords(veh)

                -- Fetch vehicle data from server
                lib.callback('qbx_mechanic:server:getVehicleData', false, function(data)
                    if data then
                        currentVehicleData = data
                        UpdateOdometerHUD(true, currentVehicleData.mileage, Config.DistanceUnit)
                    end
                end, currentPlate)
            end

            if isDriver and currentVehicleData and lastPos then
                local currentPos = GetEntityCoords(veh)
                local distMeters = #(currentPos - lastPos)

                -- Only calculate distance if vehicle is actually moving and not teleporting
                if distMeters > 0.5 and distMeters < 100.0 then
                    local addedDist = distMeters * Config.MilesPerUnit
                    currentVehicleData.mileage = currentVehicleData.mileage + addedDist

                    -- Apply degradation to parts based on distance driven
                    for part, rate in pairs(Config.WearRates) do
                        if currentVehicleData[part] then
                            currentVehicleData[part] = math.max(0.0, currentVehicleData[part] - (addedDist * rate))
                        end
                    end

                    UpdateOdometerHUD(true, currentVehicleData.mileage, Config.DistanceUnit)
                end
                lastPos = currentPos
            end

            Wait(1000)
        else
            if inVehicle then
                if currentPlate and currentVehicleData then
                    TriggerServerEvent('qbx_mechanic:server:saveVehicleData', currentPlate, currentVehicleData)
                end
                inVehicle = false
                currentVehicle = nil
                currentPlate = nil
                currentVehicleData = nil
                lastPos = nil
                UpdateOdometerHUD(false)
            end
            Wait(1500)
        end
    end
end)

-- Save periodic backup when driving
CreateThread(function()
    while true do
        Wait(Config.SaveInterval * 1000)
        if inVehicle and currentPlate and currentVehicleData then
            TriggerServerEvent('qbx_mechanic:server:saveVehicleData', currentPlate, currentVehicleData)
        end
    end
end)

-- Export getCurrentVehicleData for other client modules
exports('GetCurrentVehicleData', function()
    return currentVehicleData
end)

exports('SetCurrentVehicleData', function(newData)
    currentVehicleData = newData
    if currentPlate then
        TriggerServerEvent('qbx_mechanic:server:saveVehicleData', currentPlate, currentVehicleData)
    end
end)
