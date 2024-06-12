ESX = nil
local bacLevels = {}

ESX = exports["es_extended"]:getSharedObject()

-- Sicherstellen, dass bacLevels initialisiert ist
local function EnsureBacLevelsInitialized()
    if bacLevels == nil then
        bacLevels = {}
    end
end

-- Simuliert den Konsum von Alkohol und erhöht den BAC
RegisterNetEvent('bac:add')
AddEventHandler('bac:add', function(amount)
    EnsureBacLevelsInitialized()
    local playerId = GetPlayerServerId(PlayerId())
    if bacLevels[playerId] == nil then
        bacLevels[playerId] = 0.0
    end

    bacLevels[playerId] = bacLevels[playerId] + amount
    if bacLevels[playerId] > 4.0 then
        bacLevels[playerId] = 4.0 -- Maximale BAC von 4.0 ‰
    end
end)

-- Verringert den BAC über Zeit (Simulation des Alkoholabbaus)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Jede Minute
        EnsureBacLevelsInitialized()
        for playerId, bacLevel in pairs(bacLevels) do
            if bacLevel > 0 then
                bacLevels[playerId] = bacLevel - 0.01 -- Abbau um 0.01 ‰ pro Minute
                if bacLevels[playerId] < 0 then
                    bacLevels[playerId] = 0
                end
            end
        end
    end
end)

-- Event zum Benutzen des Alkoholmessgeräts
RegisterNetEvent('bac:use')
AddEventHandler('bac:use', function(targetId)
    EnsureBacLevelsInitialized()
    local targetBacLevel = bacLevels[targetId] or 0.0
    ESX.ShowNotification('Der Blutalkoholspiegel der Zielperson ist ' .. string.format("%.2f", targetBacLevel) .. ' ‰.')
end)

-- Hilfsfunktion zum Finden des nächsten Spielers
function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for i = 1, #players, 1 do
        local targetPed = GetPlayerPed(players[i])
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

RegisterNetEvent('bac:check')
AddEventHandler('bac:check', function()
    local closestPlayer, closestDistance = GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('bac:measure', targetId)
    else
        ESX.ShowNotification('Keine Person in der Nähe gefunden.')
    end
end)
