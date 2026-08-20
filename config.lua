Config = {}

-- Mechanic Job Names
Config.MechanicJobs = {
    ['mechanic'] = 0, -- Min grade
    ['bennys'] = 0,
    ['lscustoms'] = 0
}

-- Unit: 'mi' or 'km'
Config.DistanceUnit = 'mi'
Config.MilesPerUnit = 0.000621371 -- Meters to Miles conversion factor

-- Save interval for mileage (in seconds)
Config.SaveInterval = 30

-- Part wear rates (per mile driven)
Config.WearRates = {
    oil = 0.05,          -- Oil degrades ~5% per 100 miles
    spark_plugs = 0.02,  -- Spark plugs degrade ~2% per 100 miles
    clutch = 0.03,       -- Clutch degrades ~3% per 100 miles
    suspension = 0.025,  -- Suspension degrades ~2.5% per 100 miles
    brakes = 0.04,       -- Brakes degrade ~4% per 100 miles
    tires = 0.045,       -- Tires degrade ~4.5% per 100 miles
    fuel_filter = 0.02   -- Fuel filter degrades ~2% per 100 miles
}

-- Thresholds for performance impact (0 - 100%)
Config.WearThresholds = {
    oil_leak = 20.0,     -- Oil level below 20% causes visible oil leaks & smoke
    oil_engine_damage = 10.0, -- Below 10% damages engine over time
    brake_failure = 25.0,     -- Brakes below 25% reduce stopping power
    tire_slip = 25.0,         -- Tires below 25% lose traction
    spark_misfire = 20.0,     -- Spark plugs below 20% cause stuttering
    clutch_slip = 20.0        -- Clutch below 20% reduces acceleration
}

-- Customization categories & costs
Config.TuningCategories = {
    engine = { label = 'Engine Upgrades', mods = { -1, 0, 1, 2, 3 }, basePrice = 1500 },
    brakes = { label = 'Brakes', mods = { -1, 0, 1, 2 }, basePrice = 1000 },
    transmission = { label = 'Transmission', mods = { -1, 0, 1, 2, 3 }, basePrice = 1200 },
    suspension = { label = 'Suspension', mods = { -1, 0, 1, 2, 3 }, basePrice = 1000 },
    turbo = { label = 'Turbo Tuning', mods = { false, true }, basePrice = 3000 },
    respray = { label = 'Respray & Paint', basePrice = 500 },
    wheels = { label = 'Custom Wheels', basePrice = 800 },
    cosmetics = { label = 'Cosmetics & Body Kits', basePrice = 600 }
}

-- Shop Locations for LS Customs / Mechanic Tablet
Config.MechanicShops = {
    { name = "LS Customs Downtown", coords = vec3(-337.0, -136.0, 39.0), radius = 30.0 },
    { name = "Benny's Original Motorworks", coords = vec3(-211.0, -1324.0, 31.0), radius = 30.0 },
    { name = "Paleto Bay Mechanic", coords = vec3(110.0, 6626.0, 32.0), radius = 30.0 },
    { name = "Sandy Shores Mechanic", coords = vec3(1177.0, 2640.0, 38.0), radius = 30.0 }
}
