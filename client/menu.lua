VehShop.OpenShopMenu = function()
    VehShop.ShopMenuIsOpen = true

    VehShop.DisableExitVehicle()
    VehShop.LoadShopData()

    local elements = {}
    local firstModel = nil

    table.sort(VehShop.Categories)

    for name, category in pairs(VehShop.Categories or {}) do
        local options = {}

        category.vehicles = category.vehicles or {}

        table.sort(category.vehicles, function(vehicle1, vehicle2)
            local vehicle1Price = vehicle1.price or 0
            local vehicle2Price = vehicle2.price or 0

            return vehicle1Price < vehicle2Price
        end)

        for _, vehicle in pairs(category.vehicles) do
            vehicle.code = string.lower(vehicle.code or 'unknown')

            local vehicleName = VehShop.ModelToLabel(vehicle.code)

            if (firstModel == nil) then
                firstModel = vehicle.code
            end

            table.insert(options, _U('shop_menu_item', vehicleName, VehShop.Formats.NumberToCurrancy(vehicle.price)))
        end

        if (#options > 0) then
            table.insert(elements, {
                name = string.lower(name or 'unknown'),
                label = category.label or 'Unknown',
                value = 0,
                type = 'slider',
                max = #category.vehicles - 1,
                options = options
            })
        end
    end

    if (firstModel ~= nil) then
        VehShop.RenderVehicleSpot(firstModel)
    end

    VehShop.RenderCamera(true)

    VehShop.ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
        title = _U('vehicle_shop'),
        align = Config.MenuLocation or 'top-left',
        elements = elements
    },
    function(data, menu)
        local selectedIndex = ((data.current).value or 0) + 1
        local categoryName = string.lower((data.current or {}).name or 'unknown')
        local category = (VehShop.Categories or {})[categoryName] or nil
        local vehicle = (category.vehicles or {})[selectedIndex] or nil

        vehicle.code = string.lower(vehicle.code or 'unknown')
        vehicle.price = vehicle.price or 0

        local vehicleName = VehShop.ModelToLabel(vehicle.code)

        if (category ~= nil and vehicle ~= nil) then
            VehShop.ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop_confirm', {
                title = _U('confirm_title', vehicleName, VehShop.Formats.NumberToCurrancy(vehicle.price)),
                align = Config.MenuLocation or 'top-left',
                elements = {
                    { label = _U('no'), value = 'no' },
                    { label = _U('yes'), value = 'yes' },
                }
            }, function(data2, menu2)
                TriggerServerEvent('esx_vehicleshop:buyVehicle', vehicle.code)
                menu2.close()
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end,
    function(data, menu)
        menu.close()

        VehShop.DeleteCurrentVehicle()
        VehShop.RenderCamera(false)

        VehShop.ShopMenuIsOpen = false
        VehShop.SpawingVehicle = false
    end,
    function(data, menu)
        local selectedIndex = ((data.current).value or 0) + 1
        local categoryName = string.lower((data.current or {}).name or 'unknown')
        local category = (VehShop.Categories or {})[categoryName] or nil
        local vehicle = (category.vehicles or {})[selectedIndex] or nil

        if (category ~= nil and vehicle ~= nil) then
            local vehicleSpawnCode = string.lower(vehicle.code or 'unknown')

            VehShop.RenderVehicleSpot(vehicleSpawnCode)
        end
    end)
end

VehShop.OpenSellMenu = function()
    local playerPed = GetPlayerPed(-1)

    if (not IsPedInAnyVehicle(playerPed, false)) then
        return
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local plate = VehShop.ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

    if (plate == nil or plate == '') then
        return
    end

    if (GetPedInVehicleSeat(vehicle, -1) ~= playerPed) then
        ESX.ShowNotification(_U('must_driver'))
        return
    end

    VehShop.ESX.TriggerServerCallback('esx_vehicleshop:requestSellVehicle', function(openMenu)
        if (openMenu) then
            local price = VehShop.GetCurrentSellPrice()

            VehShop.ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_shop', {
                title = _U('confirm_vehicle_sell', VehShop.Formats.NumberToCurrancy(price)),
                align = Config.MenuLocation or 'top-left',
                elements = {
                    { label = _U('no'), value = 'no' },
                    { label = _U('yes'), value = 'yes' },
                }
            }, function(data, menu)
                if (data.current.value == 'no') then
                    menu.close()
                elseif (data.current.value == 'yes') then
                    VehShop.ESX.TriggerServerCallback('esx_vehicleshop:sellVehicle', function(sold)
                        if (sold) then
                            VehShop.ESX.Game.DeleteVehicle(vehicle)
                        end

                        menu.close()
                    end, plate)
                end
            end,
            function(data, menu)
                menu.close()
            end)
        end
    end, plate)
end

VehShop.RenderVehicleSpot = function(model)
    local marker = VehShop.Marker or nil

    if (marker == nil) then
        return
    end

    while VehShop.SpawingVehicle do
        Citizen.Wait(0)
    end

    VehShop.SpawingVehicle = true

    local position = marker.spawn

    if (model ~= nil and model ~= '' and string.lower(model) ~= 'unknown' and string.lower(model) ~= 'none') then
        local vehicleHash = (type(model) == 'number' and model or GetHashKey(model))

        if (IsModelInCdimage(vehicleHash)) then
            if (DoesEntityExist(VehShop.CurrentVehicle)) then
                local currentVehicleModel = GetEntityModel(VehShop.CurrentVehicle)

                if (currentVehicleModel ~= vehicleHash) then
                    VehShop.SpawnVehicle(position, vehicleHash, function()
                        VehShop.SpawingVehicle = false
                    end)
                end
            else
                VehShop.SpawnVehicle(position, vehicleHash, function()
                    VehShop.SpawingVehicle = false
                end)
            end
        else
            VehShop.RemoveVehicles(function()
                VehShop.SpawingVehicle = false
            end)
        end
    else
        VehShop.RemoveVehicles(function()
            VehShop.SpawingVehicle = false
        end)
    end
end

VehShop.WaitForVehicleIsLoaded = function(model)
    if (model ~= nil and model ~= '' and string.lower(model) ~= 'unknown' and string.lower(model) ~= 'none') then
        local vehicleHash = (type(model) == 'number' and model or GetHashKey(model))

        if (not HasModelLoaded(vehicleHash)) then
            RequestModel(vehicleHash)

            BeginTextCommandBusyspinnerOn('STRING')
            AddTextComponentSubstringPlayerName(_U('wait_vehicle'))
            EndTextCommandBusyspinnerOn(4)

            while not HasModelLoaded(vehicleHash) do
                DisableAllControlActions(0)

                Citizen.Wait(0)
            end

            BusyspinnerOff()
        end
    end
end

VehShop.RemoveVehicles = function(cb)
    local marker = VehShop.Marker or nil

    if (marker == nil) then
        if (cb ~= nil) then
            cb()
        end
        return
    end

    local vehiclesInArea = VehShop.ESX.Game.GetVehiclesInArea(marker.spawn, 7.50)

    for _, vehicle in ipairs(vehiclesInArea or {}) do
        local attempt = 0

        while not NetworkHasControlOfEntity(vehicle) and attempt < 100 and DoesEntityExist(vehicle) do
            NetworkRequestControlOfEntity(vehicle)
            Citizen.Wait(100)
            attempt = attempt + 1
        end

        if (NetworkHasControlOfEntity(vehicle) and DoesEntityExist(vehicle)) then
            VehShop.ESX.Game.DeleteVehicle(vehicle)
        end
    end

    if (cb ~= nil) then
        cb()
    end
end

VehShop.DisableExitVehicle = function()
    Citizen.CreateThread(function()
        while VehShop.ShopMenuIsOpen do
            DisableControlAction( 0, 75,  true)
            DisableControlAction(27, 75,  true)

            Citizen.Wait(0)
        end
    end)
end

VehShop.SpawnVehicle = function(position, vehicleHash, cb)
    VehShop.RemoveVehicles()
    VehShop.WaitForVehicleIsLoaded(vehicleHash)

    VehShop.ESX.Game.SpawnLocalVehicle(vehicleHash, position, position.h or 75.0, function(vehicle)
        VehShop.SetVehicleProperties(vehicle)

        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)
        FreezeEntityPosition(vehicle, true)
        SetEntityInvincible(vehicle, true)
        SetVehicleDoorsLocked(vehicle, 2)

        VehShop.CurrentVehicle = vehicle

        if (cb ~= nil) then
            cb(vehicle)
        end
    end)
end

VehShop.SetVehicleProperties = function(vehicle)
    local defaultProps = Config.DefaultVehicleProps or {}

    if (defaultProps == nil or defaultProps == {}) then
        return
    end

    if (defaultProps.extras == true) then
        defaultProps.extras = {}

        for i = 0, 20 do
            if (DoesExtraExist(vehicle, i)) then
                defaultProps.extras[i] = true
            end
        end
    else
        defaultProps.extras = {}
    end

    VehShop.ESX.Game.SetVehicleProperties(vehicle, defaultProps)
end

VehShop.DeleteCurrentVehicle = function()
    if (VehShop.CurrentVehicle ~= nil and DoesEntityExist(VehShop.CurrentVehicle)) then
        VehShop.ESX.Game.DeleteVehicle(VehShop.CurrentVehicle)
        VehShop.CurrentVehicle = nil
    end
end

VehShop.RenderCamera = function(toggle)
    local marker = VehShop.Marker or nil

    if (marker == nil) then
        return
    end

    local camera = marker.camera or nil

    if (camera == nil) then
        return
    end

    if (not toggle) then
        if (VehShop.Camera ~= nil) then
            DestroyCam(VehShop.Camera)
            VehShop.Camera = nil
        end

        VehShop.RemoveVehicles()

        RenderScriptCams(0, 1, 750, 1, 0)

        return
    end

    if (VehShop.Camera ~= nil) then
        DestroyCam(VehShop.Camera)
        VehShop.Camera = nil
    end

    VehShop.Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

    SetCamCoord(VehShop.Camera, camera.x, camera.y, camera.z)
    SetCamRot(VehShop.Camera, camera.rotationX, camera.rotationY, camera.rotationZ)
    SetCamActive(VehShop.Camera, true)

    RenderScriptCams(1, 1, 750, 1, 1)

    Citizen.Wait(500)
end

VehShop.ModelToLabel = function(model)
    model = (type(model) == 'number' and model or GetHashKey(model))

    local displayName = GetDisplayNameFromVehicleModel(model)
    local vehicleName = GetLabelText(displayName)

    if (vehicleName == nil or string.lower(vehicleName) == 'null' or string.lower(vehicleName) == 'carnotfound') then
        vehicleName = displayName
    end

    if (vehicleName == nil or string.lower(vehicleName) == 'null' or string.lower(vehicleName) == 'carnotfound') then
        vehicleName = model
    end

    return vehicleName
end