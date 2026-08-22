-- LS Customs & Vehicle Tuning Module

local tuningCam = nil

local function CreateTuningCamera(veh)
    if tuningCam then
        DestroyCam(tuningCam, true)
    end
    local coords = GetOffsetFromEntityInWorldCoords(veh, 2.5, 3.5, 1.2)
    tuningCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 50.0, false, 0)
    PointCamAtEntity(tuningCam, veh, 0.0, 0.0, 0.0, true)
    SetCamActive(tuningCam, true)
    RenderScriptCams(true, true, 1000, true, true)
end

local function CloseTuningCamera()
    if tuningCam then
        RenderScriptCams(false, true, 1000, true, true)
        DestroyCam(tuningCam, true)
        tuningCam = nil
    end
end

-- Function to apply mod to current vehicle
local function ApplyVehicleMod(veh, modCategory, modIndex)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return end

    SetVehicleModKit(veh, 0)

    if modCategory == 'engine' then
        SetVehicleMod(veh, 11, tonumber(modIndex), false)
    elseif modCategory == 'brakes' then
        SetVehicleMod(veh, 12, tonumber(modIndex), false)
    elseif modCategory == 'transmission' then
        SetVehicleMod(veh, 13, tonumber(modIndex), false)
    elseif modCategory == 'suspension' then
        SetVehicleMod(veh, 15, tonumber(modIndex), false)
    elseif modCategory == 'turbo' then
        local enableTurbo = (modIndex == true or modIndex == 'true' or modIndex == 1 or modIndex == '1')
        ToggleVehicleMod(veh, 18, enableTurbo)
    end
end

RegisterNetEvent('qbx_mechanic:client:applyTuningMod', function(modCategory, modIndex)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if not veh or veh == 0 then
        local coords = GetEntityCoords(ped)
        veh = lib.getClosestVehicle(coords, 4.0, false)
    end

    if veh and veh ~= 0 then
        ApplyVehicleMod(veh, modCategory, modIndex)
    end
end)

-- Exports for tablet/tuning interface
exports('CreateTuningCamera', CreateTuningCamera)
exports('CloseTuningCamera', CloseTuningCamera)
