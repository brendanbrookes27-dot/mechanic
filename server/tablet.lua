-- Server tablet & job permissions logic

lib.callback.register('qbx_mechanic:server:isMechanic', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local jobName = player.PlayerData.job.name
    return (Config.MechanicJobs[jobName] ~= nil)
end)

RegisterNetEvent('qbx_mechanic:server:buyShopItem', function(itemName, cost)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not itemName or not cost or cost <= 0 then return end

    -- Verify mechanic job
    local jobName = player.PlayerData.job.name
    if not Config.MechanicJobs[jobName] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Parts Shop', description = 'Only mechanics can order shop items!', type = 'error' })
        return
    end

    local bank = player.PlayerData.money['bank'] or 0
    local cash = player.PlayerData.money['cash'] or 0

    local paid = false
    if cash >= cost then
        player.Functions.RemoveMoney('cash', cost, 'mechanic-shop-item')
        paid = true
    elseif bank >= cost then
        player.Functions.RemoveMoney('bank', cost, 'mechanic-shop-item')
        paid = true
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Parts Shop', description = 'Insufficient funds to buy item!', type = 'error' })
        return
    end

    if paid then
        exports.ox_inventory:AddItem(src, itemName, 1)
        TriggerClientEvent('ox_lib:notify', src, { title = 'Parts Shop', description = string.format('Ordered 1x %s', itemName), type = 'success' })
    end
end)

RegisterNetEvent('qbx_mechanic:server:sendInvoice', function(targetId, amount, reason)
    local src = source
    targetId = tonumber(targetId)
    amount = tonumber(amount)

    if not targetId or not amount or amount <= 0 then return end

    -- Verify sender is mechanic
    local senderPlayer = exports.qbx_core:GetPlayer(src)
    if not senderPlayer then return end

    local jobName = senderPlayer.PlayerData.job.name
    if not Config.MechanicJobs[jobName] then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Invoice', description = 'Only mechanics can send invoices!', type = 'error' })
        return
    end

    local targetPlayer = exports.qbx_core:GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Invoice', description = 'Player not found online!', type = 'error' })
        return
    end

    -- Proximity Check
    local senderCoords = GetEntityCoords(GetPlayerPed(src))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
    if #(senderCoords - targetCoords) > 10.0 then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Invoice', description = 'Target player is too far away!', type = 'error' })
        return
    end

    -- Request confirmation from target player before charging
    TriggerClientEvent('qbx_mechanic:client:receiveInvoicePrompt', targetId, src, amount, reason or 'Mechanic Service')
end)

RegisterNetEvent('qbx_mechanic:server:payInvoice', function(senderId, amount, reason)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not amount or amount <= 0 then return end

    local bank = player.PlayerData.money['bank'] or 0
    if bank >= amount then
        player.Functions.RemoveMoney('bank', amount, 'mechanic-invoice')

        local senderPlayer = exports.qbx_core:GetPlayer(senderId)
        if senderPlayer then
            senderPlayer.Functions.AddMoney('bank', amount, 'mechanic-invoice-payment')
            TriggerClientEvent('ox_lib:notify', senderId, { title = 'Invoice Paid', description = string.format('Received $%d from ID %d', amount, src), type = 'success' })
        end

        TriggerClientEvent('ox_lib:notify', src, { title = 'Invoice Paid', description = string.format('Paid $%d for %s', amount, reason), type = 'inform' })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'Invoice Payment', description = 'Insufficient bank balance!', type = 'error' })
        TriggerClientEvent('ox_lib:notify', senderId, { title = 'Invoice Failed', description = 'Target player could not afford the invoice!', type = 'error' })
    end
end)
