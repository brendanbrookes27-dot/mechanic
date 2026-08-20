# qbx_mechanic

An advanced mechanic, LS Customs tuning, servicing, and vehicle wear system built for FiveM using QBox (`qbx_core`), `ox_lib`, `ox_inventory`, and `oxmysql`.

## Key Features

- 📱 **iOS Mechanic Tablet (`/tablet`)**: Glassmorphism UI featuring Vehicle Diagnostics, LS Customs Modder, Invoicing System, Parts Order Shop, Employee Roster, and Service Logs.
- 🎨 **LS Customs & Tuning System**: Tune engine, brakes, transmission, suspension, turbo, resprays, and cosmetics with live preview.
- ⛽ **Fuel Line Sabotage (`/cutfuel`)**: Cut the fuel line of nearby vehicles using wire cutters, stalling the vehicle completely.
- 🛢️ **Vehicle Wear & Oil Leak System**: Parts (Oil, Spark Plugs, Clutch, Suspension, Brakes, Tires, Fuel Filter) degrade over time/miles. Low oil causes smoking and visible oil leaks under the engine bay.
- ⏱️ **Automatic Mileage Tracking & Odometer HUD**: Sleek HUD automatically displays when entering any vehicle and persists driven distance directly to MySQL.

## Commands

- `/tablet`: Opens the Mechanic Tablet (Restricted to mechanics or item usage).
- `/cutfuel`: Cuts the fuel line of the closest vehicle (Requires `wire_cutters` or `mechanic_tools`).

## Installation

1. Place `qbx_mechanic` in your resources folder.
2. Import `sql/schema.sql` into your database.
3. Add the items in `items.lua` to `ox_inventory/data/items.lua`.
4. Ensure the resource in your `server.cfg`:
   ```cfg
   ensure qbx_mechanic
   ```
