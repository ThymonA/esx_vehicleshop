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