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

            if (shopLocation ~= nil and spawnLocation ~= nil and cameraLocation ~= nil and purchasedSpawnLocation ~= nil) then
                local distance = #(shopLocation - playerCoords)

                if (distance < Config.DrawDistance) then
                    table.insert(VehShop.DrawMarkers, {
                        shop = shopLocation,
                        spawn = spawnLocation,
                        camera = cameraLocation,
                        purchasedSpawn = purchasedSpawnLocation
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
        for _, marker in pairs(VehShop.DrawMarkers or {}) do
            marker = marker or nil

            if (marker ~= nil) then
                local x, y, z = table.unpack(marker.shop or {})

                DrawMarker((Config.Marker or {}).Type or 1, x, y, z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, (Config.Marker or {}).SizeX or 1.5, (Config.Marker or {}).SizeY or 1.5, (Config.Marker or {}).SizeZ or 1.5, (Config.Marker or {}).ColorRed or 255, (Config.Marker or {}).ColorGreen or 255, (Config.Marker or {}).ColorBlue or 255, 100, false, true, 2, false, false, false, false)
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
                local distance = #(marker.shop - playerCoords)

                if (distance < ((Config.Marker or {}).SizeX or 1.5)) then
                    VehShop.IsInMarker = true
                    VehShop.Marker = marker or {}
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
        VehShop.ESX.ShowHelpNotification(_U('open_vehicle_shop'))
    end
end

-- Triggers when player left the marker
VehShop.HasExitedMarker = function()
    VehShop.ESX.UI.Menu.CloseAll()
    VehShop.Marker = nil
    VehShop.ShopMenuIsOpen = false
    VehShop.IsInMarker = false
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
    if (IsControlJustPressed(0, 38)) then
        VehShop.MarkerEntered = true
        VehShop.OpenShopMenu()
    end
end