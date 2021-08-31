game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'A RedM Teleport'
author 'DevDokus Github'
version '1.0.0'

client_scripts {
    'config.lua',
    'Core/client.lua'
}

shared_script 'config.lua'

server_scripts {
    'config.lua',
    'Core/server.lua'
}
