fx_version 'adamant'

game 'gta5'

description 'Vehicle Shop by Tigo'
name 'ESX Vehicle Shop'
author 'TigoDevelopment'
contact 'me@tigodev.com'
version '1.0.0'

server_scripts {
    '@async/async.lua',
    '@es_extended/locale.lua',
    '@mysql-async/lib/MySQL.lua',

    'config.lua',

    'locales/nl.lua',
    'locales/en.lua',

    'server/common.lua',

    'shared/shared.lua',

    'server/commands.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',

    'config.lua',

    'locales/nl.lua',
    'locales/en.lua',

    'client/common.lua',

    'shared/shared.lua',

    'client/menu.lua',
    'client/main.lua'
}

dependencies {
    'async',
    'es_extended',
    'mysql-async'
}