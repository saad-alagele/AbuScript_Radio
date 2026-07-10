fx_version 'cerulean'
game 'gta5'

name        'AbuScript_Radio'
description 'FiveM ESX Radio script with caller list and controllable radio model'
author      'AbuScript'
version     '1.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'locales/en.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

lua54 'yes'
