-- Core
VehShop                     = {}
VehShop.ESX                 = nil

-- Callbacks
VehShop.ClientCallbacks     = {}

-- Markers
VehShop.DrawMarkers         = {}
VehShop.IsInMarker          = false
VehShop.MarkerEntered       = false
VehShop.Marker              = nil
VehShop.CurrentAction       = nil

-- Blips
VehShop.BlipsLoaded         = false

-- Vehicles
VehShop.Categories          = nil

-- Menu
VehShop.ShopMenuIsOpen      = false
VehShop.CurrentVehicle      = nil
VehShop.Camera              = nil
VehShop.SpawingVehicle      = false

-- Initialize ESX
Citizen.CreateThread(function()
    while VehShop.ESX == nil do
        TriggerEvent('esx:getSharedObject', function(object)
            VehShop.ESX = object
        end)

        Citizen.Wait(0)
    end
end)

VehShop.RegisterClientCallback = function(name, cb)
    VehShop.ClientCallbacks[name] = cb
end

RegisterNetEvent('esx_vehicleshop:triggerClientEvent')
AddEventHandler('esx_vehicleshop:triggerClientEvent', function(name, requestId, ...)
    if (VehShop.ClientCallbacks ~= nil and VehShop.ClientCallbacks[name] ~= nil) then
        VehShop.ClientCallbacks[name](function(...)
            TriggerServerEvent('esx_vehicleshop:clientCallback', requestId, ...)
        end, ...)
    else
        TriggerServerEvent('esx_vehicleshop:clientCallback', requestId, false)
    end
end)

VehShop.RegisterClientCallback('esx_vehicleshop:isModelInCdImage', function(cb, model)
    model = (type(model) == 'number' and model or GetHashKey(model))

    local isModelInCdImage = IsModelInCdimage(model)

    cb(isModelInCdImage)
end)

RegisterNetEvent('esx_vehicleshop:resetVehicleShop')
AddEventHandler('esx_vehicleshop:resetVehicleShop', function()
    if (VehShop.Camera ~= nil) then
        DestroyCam(VehShop.Camera)
        VehShop.Camera = nil
        RenderScriptCams(0, 1, 750, 1, 0)
    end

    VehShop.Marker = nil
    VehShop.ShopMenuIsOpen = false
    VehShop.IsInMarker = false
    VehShop.MarkerEntered = false
    VehShop.SpawingVehicle = false
    VehShop.Categories = nil

    if (VehShop.ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'vehicle_shop')) then
        VehShop.ESX.UI.Menu.CloseAll()
    end

    VehShop.DeleteCurrentVehicle()
end)

RegisterNetEvent('esx_vehicleshop:vehiclePurchased')
AddEventHandler('esx_vehicleshop:vehiclePurchased', function(vehicle, props)
    local position = (VehShop.Marker or {}).purchasedSpawn or {}

    VehShop.DeleteCurrentVehicle()
    VehShop.RemoveVehicles()
    VehShop.WaitForVehicleIsLoaded(vehicle)

    if (position ~= nil and position ~= {}) then
        VehShop.ESX.Game.SpawnVehicle(vehicle, position, position.h or 75.0, function(vehicle)
            VehShop.ESX.Game.SetVehicleProperties(vehicle, props)

            SetEntityAsMissionEntity(vehicle, true, true)
            SetVehicleOnGroundProperly(vehicle)
            SetEntityAsNoLongerNeeded(vehicle)
            SetVehicleNumberPlateText(vehicle, props.plate)
            SetModelAsNoLongerNeeded(vehicle)
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)

            VehShop.HasExitedMarker()
        end)
    else
        VehShop.HasExitedMarker()
    end
end)

VehShop.LoadShopData = function()
    if (VehShop.Categories == nil) then
        VehShop.ESX.TriggerServerCallback('esx_vehicleshop:getShopData', function(categories, vehicles)
            local updatedCategories = {}

            for _, category in pairs(categories or {}) do
                local name = string.lower(category.name or 'unknown')
                local label = category.label or 'Unknown'

                if (updatedCategories == nil) then
                    updatedCategories = {}
                end

                updatedCategories[name] = {
                    label = label,
                    vehicles = {}
                }
            end

            for _, vehicle in pairs(vehicles or {}) do
                local code = string.lower(vehicle.code or 'unknown')
                local category = string.lower(vehicle.category or 'unknown')
                local price = vehicle.price or 0

                if (updatedCategories ~= nil and updatedCategories[category] ~= nil) then
                    if (updatedCategories[category].vehicles == nil) then
                        updatedCategories[category].vehicles = {}
                    end

                    table.insert(updatedCategories[category].vehicles, {
                        code = code,
                        price = price,
                        hash = vehicle.hash or -1
                    })
                end
            end

            VehShop.Categories = updatedCategories
        end)
    end

    while VehShop.Categories == nil do
        Citizen.Wait(0)
    end
end