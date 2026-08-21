-- Tablet client side logic and NUI callbacks

local tabletOpen = false

local function OpenTablet()
    if tabletOpen then return end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local plate = nil
    local modelName = "Vehicle"

    if veh and veh ~= 0 then
        plate = GetVehicleNumberPlateText(veh)
        local hash = GetEntityModel(veh)
        modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
        if modelName == "NULL" then
            modelName = GetDisplayNameFromVehicleModel(hash)
        end
    else
        -- Get closest vehicle if outside vehicle
        local coords = GetEntityCoords(ped)
        local closeVeh = lib.getClosestVehicle(coords, 5.0, false)
        if closeVeh and closeVeh ~= 0 then
            plate = GetVehicleNumberPlateText(closeVeh)
            local hash = GetEntityModel(closeVeh)
            modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
            if modelName == "NULL" then
                modelName = GetDisplayNameFromVehicleModel(hash)
            end
        end
    end

    if plate then
        lib.callback('qbx_mechanic:server:getVehicleData', false, function(data)
            tabletOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openTablet",
                vehicleData = data,
                vehicleModel = modelName
            })
        end, plate)
    else
        tabletOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openTablet",
            vehicleData = nil,
            vehicleModel = "No Vehicle"
        })
    end
end

RegisterCommand('tablet', function()
    -- Check mechanic job
    lib.callback('qbx_mechanic:server:isMechanic', false, function(isMech)
        if isMech then
            OpenTablet()
        else
            lib.notify({ title = 'Tablet', description = 'Only mechanics have access to the mechanic tablet!', type = 'error' })
        end
    end)
end, false)

-- Export for item usage
exports('useTablet', function()
    OpenTablet()
end)

-- Receive Invoice Prompt
RegisterNetEvent('qbx_mechanic:client:receiveInvoicePrompt', function(senderId, amount, reason)
    local alert = lib.alertDialog({
        header = 'Mechanic Invoice Received',
        content = string.format('Mechanic (ID %d) has sent you an invoice for **$%d**.\n\nReason: %s\n\nWould you like to pay?', senderId, amount, reason),
        centered = true,
        cancel = true
    })

    if alert == 'confirm' then
        TriggerServerEvent('qbx_mechanic:server:payInvoice', senderId, amount, reason)
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeTablet', function(_, cb)
    tabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeTablet" })
    cb('ok')
end)

RegisterNUICallback('connectOBD', function(_, cb)
    SetNuiFocus(false, false)
    local ped = PlayerPedId()

    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)

    if lib.progressBar({
        duration = 2500,
        label = 'Connecting OBD-II Diagnostic Tool...',
        useReplay = false,
        canCancel = true
    }) then
        ClearPedTasks(ped)
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "obdConnected" })
        lib.notify({ title = 'OBD Diagnostic', description = 'Connected to vehicle ECU via OBD-II port!', type = 'success' })
    else
        ClearPedTasks(ped)
        SetNuiFocus(true, true)
        lib.notify({ title = 'OBD Diagnostic', description = 'Connection cancelled.', type = 'error' })
    end
    cb('ok')
end)

RegisterNUICallback('repairPart', function(data, cb)
    if data and data.plate and data.part then
        TriggerServerEvent('qbx_mechanic:server:repairPart', data.plate, data.part, 100.0)
    end
    cb('ok')
end)

RegisterNUICallback('buyTuningMod', function(data, cb)
    if data and data.category then
        lib.callback('qbx_mechanic:server:purchaseMod', false, function(success)
            if success then
                lib.notify({ title = 'LS Customs', description = 'Modification installed!', type = 'success' })
            end
        end, data.category, data.mod, data.cost)
    end
    cb('ok')
end)

RegisterNUICallback('buyShopItem', function(data, cb)
    if data and data.item and data.cost then
        TriggerServerEvent('qbx_mechanic:server:buyShopItem', data.item, data.cost)
    end
    cb('ok')
end)

RegisterNUICallback('sendInvoice', function(data, cb)
    if data and data.target and data.amount then
        TriggerServerEvent('qbx_mechanic:server:sendInvoice', data.target, data.amount, data.reason)
    end
    cb('ok')
end)
