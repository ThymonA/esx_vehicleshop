MySQL.ready(function()
    local tasks = {}

    table.insert(tasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories`', {}, function(results)
            for _, category in pairs(results or {}) do
                local name = string.lower(category.name or 'unknown')

                if (VehShop.Categories == nil) then
                    VehShop.Categories = {}
                end

                if (VehShop.Categories[name] == nil) then
                    VehShop.Categories[name] = category
                end
            end

            cb()
        end)
    end)

    table.insert(tasks, function(cb)
        MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_vehicles` AS `vv` LEFT JOIN `vehicleshop_categories` AS `vc` ON `vv`.`category` = `vc`.`name`', {}, function(results)
            for _, vehicle in pairs(results or {}) do
                local code = string.lower(vehicle.code or 'unknown')

                if (VehShop.Vehicles == nil) then
                    VehShop.Vehicles = {}
                end

                if (VehShop.Vehicles[code] == nil) then
                    VehShop.Vehicles[code] = vehicle
                end
            end

            cb()
        end)
    end)

    Async.parallel(tasks, function()
        VehShop.VehiclesLoaded = true
    end)
end)

VehShop.ESX.RegisterServerCallback('esx_vehicleshop:getShopData', function(playerId, cb)
    if (VehShop.HasOpenRequest(playerId)) then
        cb(false)
    end

    VehShop.StartRequest(playerId)

    while not VehShop.VehiclesLoaded do
        Citizen.Wait(0)
    end

    cb(VehShop.Categories, VehShop.Vehicles)

    VehShop.StopRequest(playerId)
end)

VehShop.ESX.RegisterServerCallback('esx_vehicleshop:requestSellVehicle', function(playerId, cb, plate)
    if (VehShop.HasOpenRequest(playerId)) then
        cb(false)
    end

    VehShop.StartRequest(playerId)

    while not VehShop.VehiclesLoaded do
        Citizen.Wait(0)
    end

    local xPlayer = VehShop.ESX.GetPlayerFromId(playerId)

    if (xPlayer == nil) then
        return
    end

    MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `plate` = @plate AND `owner` = @owner', {
        ['@plate'] = plate,
        ['@owner'] = xPlayer.identifier,
    }, function(results)
        if (results == nil or #results <= 0) then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_not_your_vehicle'))
            cb(false)
        else
            local props = json.decode((results[1] or {}).vehicle or '{}')
            local model = props.model or -1

            for code, vehicle in pairs(VehShop.Vehicles) do
                if (model == vehicle.hash or GetHashKey(code) == model) then
                    VehShop.StopRequest(playerId)
                    cb(true)
                    return
                end
            end

            VehShop.StopRequest(playerId)
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_hash_mismatch'))
            cb(false)
        end
    end)
end)

VehShop.ESX.RegisterServerCallback('esx_vehicleshop:sellVehicle', function(playerId, cb, plate)
    if (VehShop.HasOpenRequest(playerId)) then
        cb(false)
    end

    VehShop.StartRequest(playerId)

    while not VehShop.VehiclesLoaded do
        Citizen.Wait(0)
    end

    local xPlayer = VehShop.ESX.GetPlayerFromId(playerId)

    if (xPlayer == nil) then
        return
    end

    MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `plate` = @plate AND `owner` = @owner', {
        ['@plate'] = plate,
        ['@owner'] = xPlayer.identifier,
    }, function(results)
        if (results == nil or #results <= 0) then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_not_your_vehicle'))
            cb(false)
        else
            local props = json.decode((results[1] or {}).vehicle or '{}')
            local model = props.model or -1

            for code, vehicle in pairs(VehShop.Vehicles) do
                if (model == vehicle.hash or GetHashKey(code) == model) then
                    MySQL.Async.execute('DELETE FROM `owned_vehicles` WHERE `plate` = @plate', {
                        ['@plate'] = plate
                    }, function(rowChanged)
                        local price = VehShop.Formats.Round(((vehicle.price or 0) / 100) * Config.ResellPercentage, 0)

                        xPlayer.addAccountMoney('bank', price)

                        VehShop.StopRequest(playerId)
                        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('vehicle_sold', VehShop.Formats.NumberToCurrancy(price)))
                        cb(true)

                        return
                    end)

                    return
                end
            end

            VehShop.StopRequest(playerId)
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_hash_mismatch'))
            cb(false)
        end
    end)
end)

RegisterServerEvent('esx_vehicleshop:buyVehicle')
AddEventHandler('esx_vehicleshop:buyVehicle', function(vehicleCode)
    vehicleCode = string.lower(vehicleCode or 'unknown')

    local playerId = source

    if (playerId == nil or playerId == 0) then
        return
    end

    local xPlayer = VehShop.ESX.GetPlayerFromId(playerId)

    if (xPlayer == nil) then
        return
    end

    local vehicle = (VehShop.Vehicles or {})[vehicleCode] or nil

    vehicle.code = string.lower(vehicle.code or 'unknown')

    if (vehicle == nil or vehicle.code == 'unknown') then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_invalid_vehicle'))
        return
    end

    local hash = vehicle.hash or -1

    if (hash == -1) then
        hash = GetHashKey(vehicle.code)
    end

    local price = vehicle.price or 0

    if (price <= 0) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_invalid_price'))
        return
    end

    local playerBankMoney = (xPlayer.getAccount('bank') or {}).money or 0

    if (price > playerBankMoney) then
        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('error_no_money'))
        return
    end

    VehShop.GeneratePlateNotExists(function(plate)
        local props = Config.DefaultVehicleProps or {}

        props.model = hash
        props.plate = plate

        if (props.extras == true) then
            props.extras = {}

            for i = 0, 20 do
                props.extras[i] = true
            end
        else
            props.extras = {}
        end

        MySQL.Async.execute('INSERT INTO `owned_vehicles` (`owner`, `plate`, `vehicle`, `type`, `stored`) VALUES (@owner, @plate, @vehicle, @type, @stored)', {
            ['@owner'] = xPlayer.identifier,
            ['@plate'] = plate,
            ['@vehicle'] = json.encode(props),
            ['@type'] = 'car',
            ['@stored'] = 0
        }, function(rowChanged)
            xPlayer.removeAccountMoney('bank', price)
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U('vehicle_purched', plate))
            TriggerClientEvent('esx_vehicleshop:vehiclePurchased', xPlayer.source, vehicle.code, props)
        end)
    end)
end)

VehShop.GeneratePlateNotExists = function(cb)
    local plate = string.upper(VehShop.GeneratePlate())

    MySQL.Async.fetchAll('SELECT * FROM `owned_vehicles` WHERE `plate` = @plate', {
        ['@plate'] = plate
    }, function(results)
        if (results == nil or #results <= 0) then
            if (cb ~= nil) then
                cb(plate)
            else
                return plate
            end
        else
            if (cb ~= nil) then
                VehShop.GeneratePlateNotExists(cb)
            else
                return VehShop.GeneratePlateNotExists()
            end
        end
    end)
end