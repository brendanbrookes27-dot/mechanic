fx_version 'cerulean'
game 'gta5'
lua_54 'yes'

name 'qbx_mechanic'
author 'Jules'
description 'Advanced Mechanic System with LS Customs, iOS Tablet, Servicing, Mileage HUD, Oil Leaks, and Fuel Cut System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/mileage.lua',
    'client/degradation.lua',
    'client/tuning.lua',
    'client/tablet.lua',
    'client/cutfuel.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/mileage.lua',
    'server/degradation.lua',
    'server/tuning.lua',
    'server/tablet.lua',
    'server/cutfuel.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

dependencies {
    'ox_lib',
    'qbx_core',
    'ox_inventory',
    'oxmysql'
}
