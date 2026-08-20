-- ox_inventory item definitions to register in ox_inventory/data/items.lua

return {
    ['mechanic_tablet'] = {
        label = 'Mechanic Tablet',
        weight = 500,
        stack = false,
        close = true,
        description = 'An iOS tablet used by mechanics to diagnose, tune, and service vehicles.',
        client = {
            export = 'qbx_mechanic.useTablet'
        }
    },
    ['wire_cutters'] = {
        label = 'Wire Cutters',
        weight = 200,
        stack = true,
        close = true,
        description = 'Sharp cutters capable of severing wire and vehicle fuel lines.'
    },
    ['engine_oil'] = {
        label = 'Engine Oil Drum',
        weight = 1000,
        stack = true,
        close = true,
        description = 'High quality motor oil for engine servicing.'
    },
    ['brake_pads'] = {
        label = 'Brake Pads Set',
        weight = 800,
        stack = true,
        close = true,
        description = 'Replacement ceramic brake pads.'
    },
    ['mechanic_tires'] = {
        label = 'Performance Tires Set',
        weight = 2500,
        stack = true,
        close = true,
        description = 'Set of high performance vehicle tires.'
    }
}
