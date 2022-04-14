if Config.useBuySystem then
    -- usefull function (na, it's useless, you could do this in 1 line lol) --
    local function GetVehicle(locationInd, vehicleInd)
        return Config.locations[locationInd].cars[vehicleInd]
    end
    -- you can place your event here :) --

    if Config.useESX then
        -- esx example --
        ESX = nil
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    
        ESX.RegisterServerCallback('showcase:Buyvehicle', function(src, cb, name, locationIndex, vehicleIndex)
            local xPlayer = ESX.GetPlayerFromId(src)
            local vehicle = GetVehicle(locationIndex, vehicleIndex)
    
            -- ESX 1.1 --
            -- if vehicle.desc.buyable then
            --     if xPlayer.getMoney() >= vehicle.desc.price then 
            --         xPlayer.removeMoney(vehicle.desc.price)
    
            --         cb(true)
            --     else
            --         cb(false)
            --     end
            -- else
            --     cb(false)
            -- end
    
            -- ESX LEGACY --
            -- if vehicle.desc.buyable then
            --     if xPlayer.getAccount('money').money >= vehicle.desc.price then 
            --         xPlayer.removeAccountMoney('money',vehicle.desc.price)
    
            --         cb(true)
            --     else
            --         cb(false)
            --     end
            -- else
            --     cb(false)
            -- end
        end)
    else
        RegisterServerEvent('showcase:BuyVehicle')
        AddEventHandler('showcase:BuyVehicle', function(locationIndex, vehicleIndex)
            local vehicle = GetVehicle(locationIndex, vehicleIndex) -- this function returns the vehicle table in the cars table of the curren location
            local price = vehicle.desc.price

            print(price)
        end)
    end
end