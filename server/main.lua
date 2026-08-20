local QBX = exports.qbx_core

-- Cache for vehicle mechanic stats
local vehicleDataCache = {}

-- Ensure database table is created on resource start
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `vehicle_mechanic_data` (
            `plate` VARCHAR(15) NOT NULL,
            `mileage` DOUBLE NOT NULL DEFAULT 0.0,
            `oil` FLOAT NOT NULL DEFAULT 100.0,
            `spark_plugs` FLOAT NOT NULL DEFAULT 100.0,
            `clutch` FLOAT NOT NULL DEFAULT 100.0,
            `suspension` FLOAT NOT NULL DEFAULT 100.0,
            `brakes` FLOAT NOT NULL DEFAULT 100.0,
            `tires` FLOAT NOT NULL DEFAULT 100.0,
            `fuel_filter` FLOAT NOT NULL DEFAULT 100.0,
            `fuel_cut` TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (`plate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `mechanic_service_logs` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `plate` VARCHAR(15) NOT NULL,
            `mechanic_name` VARCHAR(100) NOT NULL,
            `service_type` VARCHAR(100) NOT NULL,
            `cost` INT NOT NULL,
            `date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end)

--- Get vehicle mechanic data
--- @param plate string
--- @return table
local function GetVehicleMechanicData(plate)
    if not plate or plate == "" then return nil end
    plate = string.upper(string.gsub(plate, "^%s*(.-)%s*$", "%1"))

    if vehicleDataCache[plate] then
        return vehicleDataCache[plate]
    end

    local result = MySQL.single.await("SELECT * FROM vehicle_mechanic_data WHERE plate = ?", { plate })
    if not result then
        -- Default stats if new vehicle
        result = {
            plate = plate,
            mileage = 0.0,
            oil = 100.0,
            spark_plugs = 100.0,
            clutch = 100.0,
            suspension = 100.0,
            brakes = 100.0,
            tires = 100.0,
            fuel_filter = 100.0,
            fuel_cut = 0
        }
        MySQL.insert("INSERT INTO vehicle_mechanic_data (plate, mileage, oil, spark_plugs, clutch, suspension, brakes, tires, fuel_filter, fuel_cut) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
            plate, result.mileage, result.oil, result.spark_plugs, result.clutch, result.suspension, result.brakes, result.tires, result.fuel_filter, result.fuel_cut
        })
    end

    vehicleDataCache[plate] = result
    return result
end

--- Save vehicle mechanic data
--- @param plate string
--- @param data table
local function SaveVehicleMechanicData(plate, data)
    if not plate or not data then return end
    plate = string.upper(string.gsub(plate, "^%s*(.-)%s*$", "%1"))
    vehicleDataCache[plate] = data

    MySQL.query([[
        INSERT INTO vehicle_mechanic_data (plate, mileage, oil, spark_plugs, clutch, suspension, brakes, tires, fuel_filter, fuel_cut)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            mileage = VALUES(mileage),
            oil = VALUES(oil),
            spark_plugs = VALUES(spark_plugs),
            clutch = VALUES(clutch),
            suspension = VALUES(suspension),
            brakes = VALUES(brakes),
            tires = VALUES(tires),
            fuel_filter = VALUES(fuel_filter),
            fuel_cut = VALUES(fuel_cut)
    ]], {
        plate,
        math.max(0.0, tonumber(data.mileage) or 0.0),
        math.clamp(tonumber(data.oil) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.spark_plugs) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.clutch) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.suspension) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.brakes) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.tires) or 100.0, 0.0, 100.0),
        math.clamp(tonumber(data.fuel_filter) or 100.0, 0.0, 100.0),
        data.fuel_cut and 1 or 0
    })
end

-- Helper clamp function
function math.clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Callbacks & Exports
lib.callback.register('qbx_mechanic:server:getVehicleData', function(source, plate)
    return GetVehicleMechanicData(plate)
end)

RegisterNetEvent('qbx_mechanic:server:saveVehicleData', function(plate, data)
    local src = source
    if not plate or not data then return end

    -- Sanitize values on server
    local current = GetVehicleMechanicData(plate) or {}
    current.mileage = math.max(current.mileage or 0.0, tonumber(data.mileage) or 0.0)
    current.oil = math.clamp(tonumber(data.oil) or current.oil or 100.0, 0.0, 100.0)
    current.spark_plugs = math.clamp(tonumber(data.spark_plugs) or current.spark_plugs or 100.0, 0.0, 100.0)
    current.clutch = math.clamp(tonumber(data.clutch) or current.clutch or 100.0, 0.0, 100.0)
    current.suspension = math.clamp(tonumber(data.suspension) or current.suspension or 100.0, 0.0, 100.0)
    current.brakes = math.clamp(tonumber(data.brakes) or current.brakes or 100.0, 0.0, 100.0)
    current.tires = math.clamp(tonumber(data.tires) or current.tires or 100.0, 0.0, 100.0)
    current.fuel_filter = math.clamp(tonumber(data.fuel_filter) or current.fuel_filter or 100.0, 0.0, 100.0)

    SaveVehicleMechanicData(plate, current)
end)

exports('GetVehicleMechanicData', GetVehicleMechanicData)
exports('SaveVehicleMechanicData', SaveVehicleMechanicData)
