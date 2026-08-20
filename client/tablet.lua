-- Tablet client side logic and NUI callbacks

local tabletOpen = false

local function OpenTablet()
    if tabletOpen then return end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local plate = nil

    if veh and veh ~= 0 then
        plate = GetVehicleNumberPlateText(veh)
    else
        -- Get closest vehicle if outside vehicle
        local coords = GetEntityCoords(ped)
        local closeVeh = lib.getClosestVehicle(coords, 5.0, false)
        if closeVeh and closeVeh ~= 0 then
            plate = GetVehicleNumberPlateText(closeVeh)
        end
    end

    if plate then
        lib.callback('qbx_mechanic:server:getVehicleData', false, function(data)
            tabletOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openTablet",
                vehicleData = data
            })
        end, plate)
    else
        tabletOpen = true
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openTablet",
            vehicleData = nil
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
