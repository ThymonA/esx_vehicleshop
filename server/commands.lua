VehShop.ESX.RegisterCommand('shopvehicle', 'admin', function(xPlayer, args, showError)
    local action = string.lower(args.action or 'unknown')

    if (action == 'unknown') then
        showError(_U('invalid_action'))
    elseif (action == 'add') then
        VehShop.AddVehicle(xPlayer, args, showError)
    elseif (action == 'remove') then
        VehShop.RemoveVehicle(xPlayer, args, showError)
    elseif (action == 'update') then
        VehShop.UpdateVehicle(xPlayer, args, showError)
    else
        showError(_U('invalid_action'))
    end
end, false, { help = _U('command_shopvehicle'), validate = false, arguments = {
    { name = 'action', help = _U('command_shopvehicle_action'), type = 'string' },
    { name = 'vehicle', help = _U('command_shopvehicle_vehicle'), type = 'string' },
    { name = 'price', help = _U('command_shopvehicle_price'), type = 'number' },
    { name = 'category', help = _U('command_shopvehicle_category'), type = 'string' },
}})

VehShop.ESX.RegisterCommand('shopcategory', 'admin', function(xPlayer, args, showError)
    local action = string.lower(args.action or 'unknown')

    if (action == 'unknown') then
        showError(_U('invalid_action'))
    elseif (action == 'add') then
        VehShop.AddCategory(xPlayer, args, showError)
    elseif (action == 'remove') then
        VehShop.RemoveCategory(xPlayer, args, showError)
    elseif (action == 'update') then
        VehShop.UpdateCategory(xPlayer, args, showError)
    else
        showError(_U('invalid_action'))
    end
end, false, { help = _U('command_shopcategory'), validate = false, arguments = {
    { name = 'action', help = _U('command_shopvehicle_action'), type = 'string' },
    { name = 'name', help = _U('command_shopvehicle_name'), type = 'string' },
    { name = 'label', help = _U('command_shopvehicle_label'), type = 'string' }
}})

VehShop.AddVehicle = function(xPlayer, args, showError)
    if (args.vehicle == nil) then
        showError(_U('empty_parameter', 'vehicle'))
        return
    end

    if (args.price == nil) then
        showError(_U('empty_parameter', 'price'))
        return
    end

    if (type(args.price) ~= 'number') then
        showError(_U('empty_number', 'price'))
        return
    end

    if (args.category == nil) then
        showError(_U('empty_parameter', 'category'))
        return
    end

    local vehicle = args.vehicle or 'unknown'
    local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

    VehShop.TriggerClientCallback(xPlayer.source, 'esx_vehicleshop:isModelInCdImage', args, showError, function(xPlayer, args, showError, isModelInCdImage)
        if (isModelInCdImage == 1 or isModelInCdImage == true) then
            local vehicleCode = string.lower(args.vehicle or 'unknown')
            local vehicleHash = (type(vehicleCode) == 'number' and vehicleCode or GetHashKey(vehicleCode))
            local vehiclePrice = args.price or 0
            local vehicleCategory = string.lower(args.category or 'unknown')

            if (vehiclePrice <= 0) then
                showError(_U('invalid_vehicle_price'))
                return
            end

            MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories` WHERE LOWER(`name`) = @name', {
                ['@name'] = vehicleCategory
            }, function(results)
                if (results == nil or #results <= 0) then
                    showError(_U('invalid_category'))
                    return
                else
                    local cateogryLabel = results[1].label or 'Unknown'

                    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_vehicles` WHERE LOWER(`code`) = @code', {
                        ['@code'] = vehicleCode
                    }, function(results)
                        if (results ~= nil and #results > 0) then
                            showError(_U('vehicle_already_exists', vehicleCode))
                            return
                        else
                            MySQL.Async.execute('INSERT INTO `vehicleshop_vehicles` (`code`, `hash`, `price`, `category`) VALUES (@code, @hash, @price, @category)', {
                                ['@code'] = vehicleCode,
                                ['@hash'] = vehicleHash,
                                ['@price'] = vehiclePrice,
                                ['category'] = vehicleCategory
                            }, function(rowChanged)
                                VehShop.AddOrUpdateVehicle({
                                    code = vehicleCode,
                                    price = vehiclePrice,
                                    category = vehicleCategory,
                                    label = cateogryLabel
                                })

                                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                                xPlayer.triggerEvent('chat:addMessage', {args = {'^2SYSTEM', _U('vehicle_added', vehicleCode, VehShop.Formats.NumberToCurrancy(vehiclePrice) )}})
                            end)
                        end
                    end)
                end
            end)
        else
            showError(_U('invalid_vehicle_model'))
        end
    end, model)
end

VehShop.RemoveVehicle = function(xPlayer, args, showError)
    if (args.vehicle == nil) then
        showError(_U('empty_parameter', 'vehicle'))
        return
    end

    local vehicle = args.vehicle or 'unknown'

    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_vehicles` WHERE LOWER(`code`) = @code', {
        ['@code'] = vehicle
    }, function(results)
        if (results == nil or #results <= 0) then
            showError(_U('vehicle_doesnt_exists', vehicle))
            return
        else
            MySQL.Async.execute('DELETE FROM `vehicleshop_vehicles` WHERE LOWER(`code`) = @code', {
                ['@code'] = vehicle
            }, function(rowChanged)
                VehShop.RemoveVehicleFromCache(vehicle)
                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                xPlayer.triggerEvent('chat:addMessage', {args = { '^2SYSTEM', _U('vehicle_removed', vehicle) }})
            end)
        end
    end)
end

VehShop.UpdateVehicle = function(xPlayer, args, showError)
    if (args.vehicle == nil) then
        showError(_U('empty_parameter', 'vehicle'))
        return
    end

    if (args.price == nil) then
        showError(_U('empty_parameter', 'price'))
        return
    end

    if (type(args.price) ~= 'number') then
        showError(_U('empty_number', 'price'))
        return
    end

    if (args.category == nil) then
        showError(_U('empty_parameter', 'category'))
        return
    end

    local vehicle = args.vehicle or 'unknown'
    local model = (type(vehicle) == 'number' and vehicle or GetHashKey(vehicle))

    VehShop.TriggerClientCallback(xPlayer.source, 'esx_vehicleshop:isModelInCdImage', args, showError, function(xPlayer, args, showError, isModelInCdImage)
        if (isModelInCdImage == 1 or isModelInCdImage == true) then
            local vehicleCode = string.lower(args.vehicle or 'unknown')
            local vehiclePrice = args.price or 0
            local vehicleCategory = string.lower(args.category or 'unknown')

            if (vehiclePrice <= 0) then
                showError(_U('invalid_vehicle_price'))
                return
            end

            MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories` WHERE LOWER(`name`) = @name', {
                ['@name'] = vehicleCategory
            }, function(results)
                if (results == nil or #results <= 0) then
                    showError(_U('invalid_category'))
                    return
                else
                    local cateogryLabel = results[1].label or 'Unknown'

                    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_vehicles` WHERE LOWER(`code`) = @code', {
                        ['@code'] = vehicleCode
                    }, function(results)
                        if (results == nil or #results <= 0) then
                            showError(_U('vehicle_doesnt_exists', vehicleCode))
                            return
                        else
                            MySQL.Async.execute('UPDATE `vehicleshop_vehicles` SET `price` = @price, `category` = @category WHERE `code` = @code', {
                                ['@code'] = vehicleCode,
                                ['@price'] = vehiclePrice,
                                ['category'] = vehicleCategory
                            }, function(rowChanged)
                                VehShop.AddOrUpdateVehicle({
                                    code = vehicleCode,
                                    price = vehiclePrice,
                                    category = vehicleCategory,
                                    label = cateogryLabel
                                })
                                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                                xPlayer.triggerEvent('chat:addMessage', {args = {'^2SYSTEM', _U('vehicle_updated', vehicleCode, VehShop.Formats.NumberToCurrancy(vehiclePrice) )}})
                            end)
                        end
                    end)
                end
            end)
        else
            showError(_U('invalid_vehicle_model'))
        end
    end, model)
end

VehShop.AddCategory = function(xPlayer, args, showError)
    if (args.name == nil) then
        showError(_U('empty_parameter', 'name'))
        return
    end

    if (args.label == nil) then
        showError(_U('empty_parameter', 'label'))
        return
    end

    local name = string.lower(args.name or 'unknown')
    local label = args.label or 'Unknown'

    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories` WHERE LOWER(`name`) = @name', {
        ['@name'] = name
    }, function(results)
        if (results ~= nil and #results > 0) then
            showError(_U('category_already_exists', name))
            return
        else
            MySQL.Async.execute('INSERT INTO `vehicleshop_categories` (`name`, `label`) VALUES (@name, @label)', {
                ['@name'] = name,
                ['@label'] = label
            }, function(rowChanged)
                VehShop.AddOrUpdateCategory({
                    name = name,
                    label = label
                })
                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                xPlayer.triggerEvent('chat:addMessage', {args = { '^2SYSTEM', _U('category_added', name) }})
            end)
        end
    end)
end

VehShop.RemoveCategory = function(xPlayer, args, showError)
    if (args.name == nil) then
        showError(_U('empty_parameter', 'name'))
        return
    end

    local name = string.lower(args.name or 'unknown')

    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories` WHERE LOWER(`name`) = @name', {
        ['@name'] = name
    }, function(results)
        if (results == nil or #results <= 0) then
            showError(_U('category_doesnt_exists', name))
            return
        else
            MySQL.Async.execute([==[
                DELETE FROM `vehicleshop_vehicles` WHERE `category` = @name;
                DELETE FROM `vehicleshop_categories` WHERE `name` = @name
                ]==], { ['@name'] = name }, function(rowChanged)
                VehShop.RemoveCategoryFromCache(name)
                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                xPlayer.triggerEvent('chat:addMessage', {args = { '^2SYSTEM', _U('category_removed', name) }})
            end)
        end
    end)
end

VehShop.UpdateCategory = function(xPlayer, args, showError)
    if (args.name == nil) then
        showError(_U('empty_parameter', 'name'))
        return
    end

    if (args.label == nil) then
        showError(_U('empty_parameter', 'label'))
        return
    end

    local name = string.lower(args.name or 'unknown')
    local label = args.label or 'Unknown'

    MySQL.Async.fetchAll('SELECT * FROM `vehicleshop_categories` WHERE LOWER(`name`) = @name', {
        ['@name'] = name
    }, function(results)
        if (results == nil or #results <= 0) then
            showError(_U('category_doesnt_exists', name))
            return
        else
            MySQL.Async.execute('UPDATE `vehicleshop_categories` SET `label` = @label WHERE `name` = @name', {
                ['@label'] = label,
                ['@name'] = name
            }, function(rowChanged)
                VehShop.AddOrUpdateCategory({
                    name = name,
                    label = label
                })
                TriggerClientEvent('esx_vehicleshop:resetVehicleShop', -1)
                xPlayer.triggerEvent('chat:addMessage', {args = { '^2SYSTEM', _U('category_updated', name) }})
            end)
        end
    end)
end

VehShop.AddOrUpdateVehicle = function(vehicle)
    if (VehShop.Vehicles == nil) then
        VehShop.Vehicles = {}
    end

    local vehicleCode = string.lower(vehicle.code or 'unknown')

    VehShop.Vehicles[vehicleCode] = {
        code = vehicleCode,
        hash = GetHashKey(vehicleCode) or -1,
        price = vehicle.price or 0,
        category = string.lower(vehicle.category or 'unknown'),
        name = string.lower(vehicle.category or 'unknown'),
        label = vehicle.label or 'Unknown'
    }
end

VehShop.RemoveVehicleFromCache = function(vehicleCode)
    if (VehShop.Vehicles == nil) then
        VehShop.Vehicles = {}
    end

    if (VehShop.Vehicles[vehicleCode] ~= nil) then
        VehShop.Vehicles[vehicleCode] = nil
    end
end

VehShop.AddOrUpdateCategory = function(category)
    local name = string.lower(category.name or 'unknown')
    local label = category.label or 'Unknown'

    if (VehShop.Categories == nil) then
        VehShop.Categories = {}
    end

    VehShop.Categories[name] = {
        name = name,
        label = label
    }
end

VehShop.RemoveCategoryFromCache = function(categoryName)
    categoryName = string.lower(categoryName or 'unknown')

    if (VehShop.Categories == nil) then
        VehShop.Categories = {}
    end

    if (VehShop.Categories[categoryName] ~= nil) then
        VehShop.Categories[categoryName] = nil
    end

    for vehicleCode, vehicle in pairs(VehShop.Vehicles or {}) do
        local category = string.lower(vehicle.category or 'unknown')

        if (category == categoryName) then
            VehShop.Vehicles[vehicleCode] = nil
        end
    end
end