Config                          = {}
Config.Locale                   = 'nl'
Config.DrawDistance             = 10
Config.CurrancySymbol           = '€'
Config.MenuLocation             = 'top-right'
Config.PlateLetters             = 3
Config.PlateNumbers             = 3
Config.PlateUseSpace            = true
Config.ResellPercentage         = 75

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
        },
        PurchasedSpawn = { x = -30.75, y = -1089.97, z = 25.43, h = 333.5 },
        Sell = vector3(-44.46, -1082.08, 25.8)
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
    ['shop'] = {
        Type        = 27,
        SizeX       = 1.5,
        SizeY       = 1.5,
        SizeZ       = 1.5,
        ColorRed    = 255,
        ColorGreen  = 255,
        ColorBlue   = 0
    },
    ['sell'] = {
        Type        = 27,
        SizeX       = 3.5,
        SizeY       = 3.5,
        SizeZ       = 1.5,
        ColorRed    = 255,
        ColorGreen  = 0,
        ColorBlue   = 0
    }
}

Config.DefaultVehicleProps = {
    modTank = -1,
    modEngine = -1,
    modStruts = -1,
    modFrontBumper = -1,
    engineHealth = 1000.0,
    bodyHealth = 1000.0,
    modRoof = -1,
    modDial = -1,
    modXenon = false,
    modAPlate = 5,
    modLivery = -1,
    modPlateHolder = -1,
    wheels = 0,
    modGrille = -1,
    color2 = 0,
    modEngineBlock = -1,
    modSpoilers = -1,
    modTransmission = -1,
    pearlescentColor = 0,
    neonColor = { 255, 0, 255 },
    modSmokeEnabled = false,
    modFrontWheels = -1,
    modArchCover = -1,
    modVanityPlate = -1,
    modHydrolic = -1,
    plateIndex = 4,
    modHorns = -1,
    modFender = -1,
    xenonColor = 255,
    modDoorSpeaker = -1,
    fuelLevel = 100.0,
    wheelColor = 0,
    neonEnabled = { false,false,false,false },
    modSideSkirt = -1,
    modBrakes = -1,
    modAirFilter = -1,
    modShifterLeavers = -1,
    modRightFender = -1,
    modAerials = -1,
    modArmor = -1,
    modSeats = -1,
    modBackWheels = -1,
    windowTint = -1,
    modSteeringWheel = -1,
    modTrunk = -1,
    extras = true,
    dirtLevel = 1.0,
    modSuspension = -1,
    modFrame = -1,
    tyreSmokeColor = { 255,255,255} ,
    modSpeakers = -1,
    modTrimB = -1,
    modDashboard = -1,
    modHood = -1,
    modTurbo = false,
    color1 = 134,
    modOrnaments = -1,
    modExhaust = -1,
    modTrimA = -1,
    modRearBumper = -1,
    modWindows = -1
}