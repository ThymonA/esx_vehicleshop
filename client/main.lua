-- Load Shop Blips
Citizen.CreateThread(function()
    while not VehShop.BlipsLoaded do
        for _, shop in pairs(Config.Shops or {}) do
            local blip = shop.Blip or nil

            if (blip ~= nil) then
                local x, y, z = table.unpack(blip)
                local data = AddBlipForCoord(x, y, z)

                SetBlipSprite(data, (Config.Blip or {}).Sprite or 1)
                SetBlipDisplay(data, (Config.Blip or {}).Display or 4)
                SetBlipScale(data, (Config.Blip or {}).Scale or 1.0)
                SetBlipColour(data, (Config.Blip or {}).Colour or 1)
                SetBlipAsShortRange(data, (Config.Blip or {}).AsShortRange or false)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString((Config.Blip or {}).Title or _U('vehicle_shop'))
                EndTextCommandSetBlipName(data)
            end
        end

        VehShop.BlipsLoaded = true

        Citizen.Wait(0)
    end
end)

-- Load Visible Markers
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        VehShop.DrawMarkers = {}

        for _, shop in pairs(Config.Shops or {}) do
            local shopLocation = shop.Shop or nil
            local spawnLocation = shop.Spawn or nil
            local cameraLocation = shop.Camera or nil
            local purchasedSpawnLocation = shop.PurchasedSpawn or nil
            local sellLocation = shop.Sell or nil

            if (shopLocation ~= nil and spawnLocation ~= nil and cameraLocation ~= nil and purchasedSpawnLocation ~= nil and sellLocation ~= nil) then
                local distance = #(shopLocation - playerCoords)
                local sellDistance = #(sellLocation - playerCoords)

                if (distance < Config.DrawDistance or sellDistance < Config.DrawDistance) then
                    table.insert(VehShop.DrawMarkers, {
                        shop = shopLocation,
                        spawn = spawnLocation,
                        camera = cameraLocation,
                        purchasedSpawn = purchasedSpawnLocation,
                        sell = sellLocation
                    })
                end
            end
        end

        Citizen.Wait(1500)
    end
end)

-- Draw Markers
Citizen.CreateThread(function()
    while true do
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        for _, marker in pairs(VehShop.DrawMarkers or {}) do
            marker = marker or nil

            if (marker ~= nil) then
                local shopDistance = #(marker.shop - playerCoords)
                local x, y, z = table.unpack(marker.shop or {})

                if (shopDistance < Config.DrawDistance) then
                    DrawMarker(((Config.Marker or {})['shop'] or {}).Type or 1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, ((Config.Marker or {})['shop'] or {}).SizeX or 1.5, ((Config.Marker or {})['shop'] or {}).SizeY or 1.5, ((Config.Marker or {})['shop'] or {}).SizeZ or 1.5, ((Config.Marker or {})['shop'] or {}).ColorRed or 255, ((Config.Marker or {})['shop'] or {}).ColorGreen or 255, ((Config.Marker or {})['shop'] or {}).ColorBlue or 255, 100, false, true, 2, false, false, false, false)
                end

                local sellDistance = #(marker.sell - playerCoords)
                x, y, z = table.unpack(marker.sell or {})

                if (sellDistance < Config.DrawDistance) then
                    DrawMarker(((Config.Marker or {})['sell'] or {}).Type or 1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, ((Config.Marker or {})['sell'] or {}).SizeX or 1.5, ((Config.Marker or {})['sell'] or {}).SizeY or 1.5, ((Config.Marker or {})['sell'] or {}).SizeZ or 1.5, ((Config.Marker or {})['sell'] or {}).ColorRed or 255, ((Config.Marker or {})['sell'] or {}).ColorGreen or 255, ((Config.Marker or {})['sell'] or {}).ColorBlue or 255, 100, false, true, 2, false, false, false, false)
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Enter Markers
Citizen.CreateThread(function()
    while true do
        VehShop.IsInMarker = false

        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        for _, marker in pairs(VehShop.DrawMarkers or {}) do
            marker = marker or nil

            if (marker ~= nil) then
                local shopDistance = #(marker.shop - playerCoords)

                if (shopDistance < (((Config.Marker or {})['shop'] or {}).SizeX or 1.5)) then
                    VehShop.IsInMarker = true
                    VehShop.Marker = marker or {}
                    VehShop.CurrentAction = 'shop'
                end

                local sellDistance = #(marker.sell - playerCoords)

                if (sellDistance < (((Config.Marker or {})['sell'] or {}).SizeX or 1.5)) then
                    VehShop.IsInMarker = true
                    VehShop.Marker = marker or {}
                    VehShop.CurrentAction = 'sell'
                end
            end
        end

        Citizen.Wait(0)
    end
end)

-- Trigger Marker Events
Citizen.CreateThread(function()
    while true do
        if (VehShop.IsInMarker) then
            VehShop.IsInMarkerEvent()
            VehShop.OpenMenuWhenKeyPressed()
        elseif (not VehShop.IsInMarker and VehShop.Marker ~= nil) then
            VehShop.HasExitedMarker()
        end

        Citizen.Wait(0)
    end
end)

-- Triggers when player is in marker
VehShop.IsInMarkerEvent = function()
    if (not VehShop.MarkerEntered) then
        if (string.lower(VehShop.CurrentAction) == 'shop') then
            VehShop.ESX.ShowHelpNotification(_U('open_vehicle_shop'), true)
        elseif (string.lower(VehShop.CurrentAction) == 'sell') then
            local sellPrice = VehShop.GetCurrentSellPrice()

            VehShop.ESX.ShowHelpNotification(_U('open_vehicle_sell', VehShop.Formats.NumberToCurrancy(sellPrice)), true)
        end
    end
end

VehShop.GetCurrentSellPrice = function()
    VehShop.LoadShopData()

    while VehShop.Categories == nil do
        Citizen.Wait(0)
    end

    local playerPed = GetPlayerPed(-1)

    if (not IsPedInAnyVehicle(playerPed, false)) then
        return 0
    end

    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local entityModel = GetEntityModel(vehicle)

    for _, categoryValue in pairs(VehShop.Categories or {}) do
        local vehicles = categoryValue.vehicles or {}

        for _, vehicleInfo in pairs(vehicles) do
            if (GetHashKey(vehicleInfo.code or 'unknown') == entityModel) then
                return VehShop.Formats.Round(((vehicleInfo.price or 0) / 100) * (Config.ResellPercentage or 75), 0)
            end
        end
    end

    return 0
end

-- Triggers when player left the marker
VehShop.HasExitedMarker = function()
    VehShop.ShopMenuIsOpen = false
    VehShop.IsInMarker = false
    VehShop.ESX.UI.Menu.CloseAll()
    VehShop.Marker = nil
    VehShop.MarkerEntered = false
    VehShop.SpawingVehicle = false

    VehShop.DeleteCurrentVehicle()

    if (VehShop.Camera ~= nil) then
        DestroyCam(VehShop.Camera)
        VehShop.Camera = nil
        RenderScriptCams(0, 1, 750, 1, 0)
    end
end

-- Open shop menu when player press required key
VehShop.OpenMenuWhenKeyPressed = function()
    if (IsControlJustPressed(0, 38) and VehShop.CurrentAction == 'shop') then
        VehShop.MarkerEntered = true
        VehShop.OpenShopMenu()
    elseif (IsControlJustPressed(0, 38) and VehShop.CurrentAction == 'sell') then
        VehShop.MarkerEntered = true
        VehShop.OpenSellMenu()
    end
end