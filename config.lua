Config                          = {}
Config.Locale                   = 'nl'
Config.DrawDistance             = 7.5
Config.CurrancySymbol           = '€'
Config.MenuLocation             = 'top-right'

-- Vehicle Shops
Config.Shops = {
    {
        Blip = vector3(-45.45, -1097.69, 25.43),
        Shop = vector3(-33.26, -1103.51, 25.44),
        Spawn = { x = -45.45, y = -1097.69, z = 25.43, h = 250.5 },
        Camera = {
            x = -42.88,
            y = -1101.12,
            z = 27.19,
            rotationX = -20.0,
            rotationY = 0.0,
            rotationZ = 40.0
        }
    }
}

-- Vehicle Shop Blips
Config.Blip = {
    Sprite          = 523,
    Display         = 4,
    Colour          = 46,
    Scale           = 0.8,
    AsShortRange    = true,
    Title           = _U('vehicle_shop')
}

-- Vehicle Shop Markers
Config.Marker = {
    Type        = 27,
    SizeX       = 1.5,
    SizeY       = 1.5,
    SizeZ       = 1.5,
    ColorRed    = 255,
    ColorGreen  = 255,
    ColorBlue   = 0
}