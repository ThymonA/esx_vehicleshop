-- Core
VehShop                     = {}
VehShop.ESX                 = nil

-- Callbacks
VehShop.ClientCallbacks     = {}
VehShop.CurrentRequestId    = 0

-- Vehicles
VehShop.Categories          = {}
VehShop.Vehicles            = {}
VehShop.VehiclesLoaded      = false

-- Requests
VehShop.OpenRequest         = {}

-- Initialize ESX
TriggerEvent('esx:getSharedObject', function(object)
    VehShop.ESX = object
end)

VehShop.TriggerClientCallback = function(source, name, args, showError, cb, ...)
    VehShop.ClientCallbacks[VehShop.CurrentRequestId] = {
        args = args,
        showError = showError,
        func = cb
    }

    TriggerClientEvent('esx_vehicleshop:triggerClientEvent', source, name, VehShop.CurrentRequestId, ...)

    if (VehShop.CurrentRequestId < 65535) then
        VehShop.CurrentRequestId = VehShop.CurrentRequestId + 1
    else
        VehShop.CurrentRequestId = 0
    end
end

RegisterServerEvent('esx_vehicleshop:clientCallback')
AddEventHandler('esx_vehicleshop:clientCallback', function(requestId, ...)
    if (VehShop.ClientCallbacks ~= nil and VehShop.ClientCallbacks[requestId] ~= nil) then
        local args = VehShop.ClientCallbacks[requestId].args or {}
        local showError = VehShop.ClientCallbacks[requestId].showError or function() end
        local xPlayer = VehShop.ESX.GetPlayerFromId(source)

        VehShop.ClientCallbacks[requestId].func(xPlayer, args, showError, ...)
        VehShop.ClientCallbacks[requestId] = nil
    end
end)

VehShop.StartRequest = function(playerId)
    if (VehShop.OpenRequest == nil) then
        VehShop.OpenRequest = {}
    end

    VehShop.OpenRequest[playerId] = true
end

VehShop.StopRequest = function(playerId)
    if (VehShop.OpenRequest ~= nil and VehShop.OpenRequest[playerId] ~= nil) then
        VehShop.OpenRequest[playerId] = nil
    end
end

VehShop.HasOpenRequest = function(playerId)
    return (VehShop.OpenRequest ~= nil and VehShop.OpenRequest[playerId] ~= nil)
end

VehShop.GeneratePlate = function()
    local plateletters = Config.PlateLetters or 3
    local plateNumbers = Config.PlateNumbers or 3
    local useSpace = Config.PlateUseSpace or false

    if (useSpace and (plateletters + plateNumbers) >= 8) then
        plateletters = 4
        plateNumbers = 3
    elseif(not useSpace and (plateletters + plateNumbers) >= 8) then
        plateletters = 4
        plateNumbers = 4
    elseif ((plateletters + plateNumbers) <= 0) then
        plateletters = 3
        plateNumbers = 3
    end

    local plate = ''

    plate = plate .. VehShop.GenerateRandomString(plateletters, 'string')

    if (useSpace and plateNumbers > 0) then
        plate = plate .. ' '
    end

    plate = plate .. VehShop.GenerateRandomString(plateNumbers, 'number')

    return plate
end

VehShop.GenerateRandomString = function(length, textType)
    local result = ''

    for i = 1, length do
        if (string.lower(textType or 'string') == 'string') then
            if (math.random(0, 100) % 2 == 0) then
                result = result .. string.char(math.random(65, 90))
            else
                result = result .. string.char(math.random(97, 122))
            end
        else
            result = result .. string.char(math.random(48, 57))
        end
    end

    return result
end