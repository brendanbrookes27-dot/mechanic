-- Part degradation effects, oil leaks, and handling modifiers

local defaultHandling = {}

local function LoadPtfxAsset(asset)
    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(10)
    end
end

-- Fast loop to enforce fuel cut / engine stall
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local isDriver = (GetPedInVehicleSeat(veh, -1) == ped)

            if isDriver then
                local data = exports.qbx_mechanic:GetCurrentVehicleData()
                if data and (data.fuel_cut == 1 or data.fuel_cut == true) then
                    SetVehicleFuelLevel(veh, 0.0)
                    SetVehicleEngineOn(veh, false, true, true)
                    SetVehicleUndriveable(veh, true)
                    Wait(100)
                else
                    Wait(1000)
                end
            else
                Wait(1000)
            end
        else
            Wait(2000)
        end
    end
end)

-- Monitoring loop for degradation, oil leaks, and handling modifiers
CreateThread(function()
    local ptfxAsset = "core"
    LoadPtfxAsset(ptfxAsset)

    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local isDriver = (GetPedInVehicleSeat(veh, -1) == ped)

            if isDriver then
                -- Store initial handling parameters
                if not defaultHandling[veh] then
                    defaultHandling[veh] = {
                        brakeForce = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce'),
                        traction = GetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin')
                    }
                end

                local data = exports.qbx_mechanic:GetCurrentVehicleData()
                if data then
                    -- Check Low Oil -> Smoke & Oil Leak PTFX attached to vehicle
                    if data.oil <= Config.WearThresholds.oil_leak then
                        UseParticleFxAssetNextCall(ptfxAsset)
                        local oilEffect = StartParticleFxLoopedOnEntity("ent_ray_pro1_oil_drip", veh, 0.0, 1.2, -0.5, 0.0, 0.0, 0.0, 0.8, false, false, false)
                        Wait(500)
                        if DoesParticleFxLoopedExist(oilEffect) then
                            StopParticleFxLooped(oilEffect, false)
                            RemoveParticleFx(oilEffect, false)
                        end

                        -- Engine damage if severely empty
                        if data.oil <= Config.WearThresholds.oil_engine_damage then
                            local engineHealth = GetVehicleEngineHealth(veh)
                            if engineHealth > 100.0 then
                                SetVehicleEngineHealth(veh, engineHealth - 2.0)
                            end
                        end
                    end

                    -- Check Spark Plugs / Fuel Filter -> Engine misfires
                    if data.spark_plugs <= Config.WearThresholds.spark_misfire or data.fuel_filter <= 20.0 then
                        if math.random(1, 100) <= 15 then
                            SetVehicleEngineOn(veh, false, true, true)
                            Wait(800)
                            SetVehicleEngineOn(veh, true, true, true)
                        end
                    end

                    -- Check Brakes & Restore when repaired
                    if data.brakes <= Config.WearThresholds.brake_failure then
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', 0.2)
                    elseif defaultHandling[veh] then
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', defaultHandling[veh].brakeForce)
                    end

                    -- Check Tires & Restore when repaired
                    if data.tires <= Config.WearThresholds.tire_slip then
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', 1.0)
                    elseif defaultHandling[veh] then
                        SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMin', defaultHandling[veh].traction)
                    end
                end
            end
            Wait(2000)
        else
            Wait(3000)
        end
    end
end)
