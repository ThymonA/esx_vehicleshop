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