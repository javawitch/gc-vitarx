fx_version 'cerulean'
game 'gta5'

author 'Git Cute'
description 'Prescription System'
version '1.0.0'

dependency 'es_extended'

shared_script 'config.lua'
shared_script 'shared/items.lua'

server_script '@oxmysql/lib/MySQL.lua'  -- if you’re using oxmysql
server_script 'server.lua'
client_script 'client.lua'
