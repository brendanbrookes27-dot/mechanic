-- LS Customs & Vehicle Tuning Server Logic

lib.callback.register('qbx_mechanic:server:purchaseMod', function(source, modType, modIndex, price)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return false end

    -- Check money
    local bank = player.PlayerData.money['bank'] or 0
    local cash = player.PlayerData.money['cash'] or 0

    local paid = false
    if cash >= price then
        player.Functions.RemoveMoney('cash', price, 'mechanic-mod-purchase')
        paid = true
    elseif bank >= price then
        player.Functions.RemoveMoney('bank', price, 'mechanic-mod-purchase')
        paid = true
    else
        TriggerClientEvent('ox_lib:notify', src, { title = 'LS Customs', description = 'Insufficient funds!', type = 'error' })
        return false
    end

    if paid then
        TriggerClientEvent('qbx_mechanic:client:applyTuningMod', src, modType, modIndex)
        return true
    end

    return false
end)
