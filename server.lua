
ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterUsableItem('alcoholmeter', function(source)
    TriggerClientEvent('bac:check', source)
end)

RegisterServerEvent('bac:measure')
AddEventHandler('bac:measure', function(targetId)
    local source = source
    TriggerClientEvent('bac:use', source, targetId)
end)
