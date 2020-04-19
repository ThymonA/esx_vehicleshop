# FiveM Vehicle Shop By TIGO
![esx_vehicleshop](https://i.imgur.com/vGma6BR.png)
[![Thymon](https://i.imgur.com/3EquTNl.jpg)](https://www.tigodev.com)

[![Developer](https://img.shields.io/badge/Developer-TigoDevelopment-darkgreen)](https://github.com/TigoDevelopment)
[![Discord](https://img.shields.io/badge/Discord-Tigo%239999-purple)](https://discordapp.com/users/636509961375055882)
[![Version](https://img.shields.io/badge/Version-1.0.0-darkgreen)](https://github.com/TigoDevelopment/esx_customJobs/blob/master/version)
[![Version](https://img.shields.io/badge/License-MIT-darkgreen)](https://github.com/TigoDevelopment/esx_customJobs/blob/master/LICENSE)

### About Custom ESX Jobs

ESX Vehicle Shop adds an vehicle shop to the game, any player can buy vehicles and sell vehicles with a menu based interaction.

### Requirement
- **es_extended** | [GitHub](https://github.com/ESX-Org/es_extended)
- **async** | [GitHub](https://github.com/ESX-Org/async)
- **mysql-async** | [GitHub](https://github.com/brouznouf/fivem-mysql-async)

### Get Started
1) Copy **esx_vehicleshop** to your FXServer resource folder
2) Run the **esx_vehicleshop.sql** file in your FXServer database
3) Add **start esx_vehicleshop** to your **sever.cfg** file
4) Start your server or resource

⚠️ **esx_vehicleshop.sql** adds table `vehicleshop_categories`, `vehicleshop_vehicles` and `owned_vehicles` if not exists

### Commands
esx_vehicleshop also has integrated commands. This makes it possible to modify the vehicle without restarting the script. It also checks if the specified vehicle actually exists before adding or editing it.

Command | Option | Example Command
:--------|:-------|:----------------
`/shopcategory` | `add` | `/shopcategory add sports Sports`
`/shopcategory` | `update` | `/shopcategory update sports Super-Sports`
`/shopcategory` | `remove` | `/shopcategory remove sports`
`/shopvehicle` | `add` | `/shopvehicle add adder 750000 sports`
`/shopvehicle` | `update` | `/shopvehicle update adder 850000 sports`
`/shopvehicle` | `remove` | `/shopvehicle remove adder`

### Example (Video)
[![esx_vehicleshop](https://i.imgur.com/3BeSufe.jpg)](https://streamable.com/eeu18s)

### License
MIT License

Copyright (c) 2020 Thymon Arens (TigoDevelopment)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


### Disclamer
---
This resource was created by me with all the knowledge at the time of writing. The request for new functionality is allowed but it does not mean that it will be released. Further development of this resource is permitted.