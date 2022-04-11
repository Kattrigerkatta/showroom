Config = {
    language = 'en',
    locations = {
        {
            entry = vector3(-32.85, -1102.21, 26.42),
            renderDistance = 30.0, -- vehicle spawn
            rotDist = 20.0, -- rotation distance (must be smaller than render distance)
            rotationspeed = 200, -- rotation speed for the toggled vehicles -- not added yet
            fadetime = 400,
            blip = {
                sprite = 227,
                color = 37,
                scale = 0.7,
                display = 6, -- https://docs.fivem.net/natives/?_0x9029B2F3DA924928
                text = "Car-Showroom"
            },
            marker = {
                sort = 21,
                color = {r = 225, g = 6, b = 0},
                alpha = 160,
                jump = false,
                rotate = true,
                faceCam = false,
                scale = {x = 1.0, y = 1.0, z = 1.0},
                rotation = {x = 0.0, y = 0.0, z = 0.0} -- if faceCam and rotate = false
            },
            cars = {
                {
                    spawnname = 'adder',
                    coords = vector4(-47.16, -1096.26, 26.42, 118.62), -- x, y, z, heading
                    rotating = false, -- not added yet
                    shop = "https://tebex.io", -- shop link (remove it if you don't need it)
                    color = {
                        primary = {255, 4, 125},
                        secondary = {255, 255, 255},
                    },
                    desc = { -- description
                        enabled = true,
                        sort = 'up', -- up / down
                        label = 'Adder',
                        text = 'A nice car', -- Shouldn't be too long
                        maxSp = 300, -- maxspeed
                        price = 500, -- price !!! YOU CAN'T BUY THE CAR IN THIS SCRIPT !!!!!!
                    }, 
                    cam = {
                        enabled = true,
                        zoomspeed = 100.0,
                        fov_min = 55.0,
                        fov_max = 25.0,
                        radius = 5.5,
                        minz = 49.0,
                        maxz = 0.0, 
                    }
                },
                {
                    spawnname = 'sanchez',
                    coords = vector4(-48.48, -1102.33, 26.42, 301.65), -- x, y, z, heading
                    rotating = true,
                    --shop = "https://tebex.io", -- shop link (remove it if you don't need it)
                    color = {
                        primary = {255, 255, 255},
                        secondary = {255, 255, 255},
                    },
                    desc = { -- description
                        enabled = true,
                        sort = 'down', -- up / down
                        label = 'Adder',
                        text = 'A nice car', -- Shouldn't be too long
                        maxSp = 300, -- maxspeed
                        price = 500, -- price !!! YOU CAN'T BUY THE CAR IN THIS SCRIPT !!!!!!
                    }, 
                    cam = {
                        enabled = true,
                        zoomspeed = 100.0,
                        fov_min = 55.0,
                        fov_max = 25.0,
                        radius = 2.5,
                        minz = 49.0,
                        maxz = 0.0, 
                    }
                },
                {
                    spawnname = 'dominator7',
                    coords = vector4(-40.22, -1099.38, 26.42, 66.84), -- x, y, z, heading
                    rotating = false,
                    --shop = "https://tebex.io", -- shop link (remove it if you don't need it)
                    color = {
                        primary = {255, 255, 255},
                        secondary = {255, 255, 255},
                    },
                    desc = { -- description
                        enabled = true,
                        sort = 'up', -- up / down
                        label = 'Dominator 7',
                        text = 'A nice car', -- Shouldn't be too long
                        maxSp = 300, -- maxspeed
                        price = 500, -- price !!! YOU CAN'T BUY THE CAR IN THIS SCRIPT !!!!!!
                    }, 
                    cam = {
                        enabled = true,
                        zoomspeed = 100.0,
                        fov_min = 55.0,
                        fov_max = 25.0,
                        radius = 5.5,
                        minz = 49.0,
                        maxz = 0.0, 
                    }
                },
            }
        }
    },
}