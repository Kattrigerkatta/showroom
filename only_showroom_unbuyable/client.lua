local inShowRoom = false
local cam = nil

local current = {
	ind = 0,
	carInd = 0,
	vehlist = {}
}
-- spawn-vehicles --
local toggled = false
local spawnedVehicles = {}
-- Rotation --
local angleY = 0.0
local angleZ = 0.0

-- Zoom --
local fov_max = 25.0
local fov_min = 55.0
local zoomspeed = 100.0
local fov = (fov_max+fov_min)*0.5
local rona = 50.0

function zoom(scrollType)
    if scrollType == "ScrollDown" then
        fov = math.max(fov - zoomspeed, fov_min)
    end
    
    if scrollType == "Scrollup" then
        fov = math.min(fov + zoomspeed, fov_max)
    end

    local current_fov = GetCamFov(cam)
    if math.abs(fov-current_fov) < 0.1 then
        fov = current_fov
    end
    SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
    ron = current_fov + (fov - current_fov)*0.05
end

-- translation function --
function _(name, ...)
	return string.format(Locales[Config.language][name], ...)
end

-- notify top left (Press ...) --
local function ShowInfobar(msg)
	SetTextComponentFormat('STRING')
	AddTextComponentString(msg)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- notify above the minimap --
local function ShowNotification(text)
	SetNotificationTextEntry('STRING')
    AddTextComponentString(text)
	DrawNotification(false, true)
end

local function GetEntFromIndex()
	for k,v in ipairs(spawnedVehicles) do
		if k == current.carInd then
			return v.ent
		end
	end
end

---------------------------------------------------------------------------------------------------

-- [[ CAM FUNCTIONS BY KIMINAZE  ]]--
-- [[ https://forum.cfx.re/t/release-deathcam-rotate-the-camera-while-you-are-dead/959761 ]]

local function StartCam()
    ClearFocus()

    local playerPed = PlayerPedId()
    
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

-- destroy camera
function EndCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    
    cam = nil
end

-- process camera controls
local function ProcessCamControls()
    local coords = Config.locations[current.ind].cars[current.carInd].coords

    -- disable 1st person as the 1st person camera can cause some glitches
    DisableFirstPersonCamThisFrame()
    
    -- calculate new position
    local newPos = ProcessNewPosition()

    -- focus cam area
    SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
    
    -- set coords of cam
    SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
    
    -- set rotation
    PointCamAtCoord(cam, coords.x, coords.y, coords.z)

	--DrawMarker(21, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
end

function ProcessNewPosition()
    local mouseX = 0.0
    local mouseY = 0.0
    
	fov_max = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.fov_max
	fov_min = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.fov_min
	zoomspeed = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.zoomspeed

    -- keyboard
    if (IsInputDisabled(0)) then
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 8.0
        mouseY = GetDisabledControlNormal(1, 2) * 8.0
        
    -- controller
    else
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 1.5
        mouseY = GetDisabledControlNormal(1, 2) * 1.5
    end

    angleZ = angleZ - mouseX -- around Z axis (left / right)
    angleY = angleY + mouseY -- up / down
    -- limit up / down angle to 90°
    if (angleY > Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.minz) then angleY = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.minz elseif (angleY < Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.maxz) then angleY = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.maxz end
    
    local pCoords = Config.locations[current.ind].cars[current.vehlist[current.carInd]].coords
    
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.radius + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.radius + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.radius + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    local maxRadius = Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.radius
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < Config.locations[current.ind].cars[current.vehlist[current.carInd]].cam.radius + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end
    
    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }
    
    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }
        
    return pos
end

---------------------------------------------------------------------------------------------------

--[[ Scaleform instruction buttons by sadboilogan ]]--
--[[ FiveM-Topic: https://forum.cfx.re/t/instructional-buttons/53283 ]]

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    -- draw it once to set up layout
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

	if Config.locations[current.ind].cars[current.vehlist[current.carInd]].shop ~= nil then
		PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
		PushScaleformMovieFunctionParameterInt(0)
		Button(GetControlInstructionalButton(2, 139, true))
		ButtonMessage(_("shop"))
		PopScaleformMovieFunctionVoid()
	end

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 23, true))
    ButtonMessage(_("leave"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage(_("next_veh"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 174, true)) -- The button to display
    ButtonMessage(_("last_veh")) -- the message to display next to it
    PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, 182, true)) -- The button to display
    ButtonMessage(_("toggle_lights")) -- the message to display next to it
    PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(2, 101, true)) -- The button to display
    ButtonMessage(_("toggle_doors")) -- the message to display next to it
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if inShowRoom then
			if form == nil then
				form = setupScaleform("instructional_buttons")
			end
        	DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
		else
			Citizen.Wait(1000)
		end
    end
end)

---------------------------------------------------------------------------------------------------

local function CloseShowroom()
	DoScreenFadeOut(800)

	while IsScreenFadingOut() do
		Citizen.Wait(50)
	end

	local c = Config.locations[current.ind].entry
	SetEntityCoords(PlayerPedId(), c.x, c.y, c.z)

	EndCam()
	DisplayRadar(true)

	FreezeEntityPosition(PlayerPedId(), false)
	NetworkFadeInEntity(PlayerPedId(), true)
	DoScreenFadeIn(500)

	while NetworkIsEntityFading(PlayerPedId()) or IsScreenFadingIn() do
		Citizen.Wait(50)
	end

	current = {
		ind = 0,
		carInd = 0,
		vehlist = {}
	}

	inShowRoom = false
end

local function OpenShowroom(ind)
	current.ind = ind
	for k,v in ipairs(Config.locations[ind].cars) do
		if v.cam.enabled then
			if #current.vehlist == 0 then
				current.carInd = 1
			end
			current.vehlist[#current.vehlist + 1] = k
		end
	end

	DoScreenFadeOut(800)

	while IsScreenFadingOut() do
		Citizen.Wait(50)
	end

	DisplayRadar(false)
	StartCam()

	inShowRoom = true

	local vehicles = GetGamePool('CVehicle')
	for k, v in ipairs(vehicles) do
		local dist = #(GetEntityCoords(v) - Config.locations[ind].entry)
		if dist <= 20.0 then
			if GetVehicleDoorLockStatus(v) == 7 then
				if DoesEntityExist(v) then
					NetworkRegisterEntityAsNetworked(v)
					NetworkRequestControlOfEntity(v)
					SetEntityAsMissionEntity(v, true, true)
					DeleteEntity(v)
				end
			end
		end
	end

	NetworkFadeOutEntity(PlayerPedId(), true, false)

	while NetworkIsEntityFading(PlayerPedId()) do
		Citizen.Wait(50)
	end

	local co = Config.locations[ind].entry
	SetEntityCoords(PlayerPedId(), co.x, co.y, co.z - 2.5, 0.0, 0.0, 0.0, false)
	FreezeEntityPosition(PlayerPedId(), true)
	NetworkSetEntityInvisibleToNetwork(PlayerPedId(), true)
	SetEntityInvincible(PlayerPedId(), true)

	DoScreenFadeIn(500)

	while IsScreenFadingIn() do 
		Citizen.Wait(50)
	end
end

Citizen.CreateThread(function()
    for k, v in ipairs(Config.locations) do
        local blip = AddBlipForCoord(v.entry.x, v.entry.y, v.entry.z)
		SetBlipSprite(blip, v.blip.sprite)
		SetBlipScale(blip, v.blip.scale)
		SetBlipDisplay(blip, v.blip.display)
		SetBlipColour(blip, v.blip.color)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v.blip.text)
		EndTextCommandSetBlipName(blip)
    end
end)

-- Car spawn / rotate thread -- 

Citizen.CreateThread(function()
	while true do
		local inAny = false
		for k, v in ipairs(Config.locations) do
			local c = GetEntityCoords(PlayerPedId())
			local dist = #(vector3(v.entry.x, v.entry.y, v.entry.z) - c)

			if dist <= v.renderDistance then
				inAny = true
				if not toggled then
					toggled = true

					if dist <= v.rotDist then
						-- Disable random car spawn --
						SetVehicleDensityMultiplierThisFrame(0.0)
						SetRandomVehicleDensityMultiplierThisFrame(0.0)
						SetParkedVehicleDensityMultiplierThisFrame(0.0)
					end

					for l,m in ipairs(v.cars) do
						local model = m.spawnname
						RequestModel(model)
					
						while not HasModelLoaded(model) do
							Citizen.Wait(50)
						end

						local car = CreateVehicle(GetHashKey(model), m.coords[1], m.coords[2], m.coords[3], m.coords[4])

						SetModelAsNoLongerNeeded(model)

						spawnedVehicles[l] = {
							ent = car,
							rot = m.rotating,
						}

						SetVehicleDoorsLocked(car, 2)
						SetVehicleCustomPrimaryColour(car, m.color.primary[1], m.color.primary[2], m.color.primary[3])
						SetVehicleCustomSecondaryColour(car, m.color.secondary[1], m.color.secondary[2], m.color.secondary[3])
						SetVehicleHasUnbreakableLights(car, true)
						SetEntityInvincible(car, true)
						FreezeEntityPosition(car, true)
						SetVehicleDirtLevel(car, 0.0)
					end
				end
			end
		end

		if not inAny then
			toggled = false 
			for k,v in ipairs(spawnedVehicles) do
				DeleteEntity(v.ent)
			end
			spawnedVehicles = {}
			Citizen.Wait(1000)
		end
		Citizen.Wait(0)
	end
end)

-- marker / enter thread --

Citizen.CreateThread(function()
	while true do
		if not inShowRoom then
			local nearAny = true
			for k, v in ipairs(Config.locations) do
				local c = GetEntityCoords(PlayerPedId())
				local dist = #(vector3(v.entry.x, v.entry.y, v.entry.z) - c)

				if dist <= 10.0 then
					nearAny = false
					local m = v.marker
					local rot = m.rotation
					DrawMarker(m.sort, v.entry.x, v.entry.y, v.entry.z, 0.0, 0.0, 0.0, rot.x, rot.y, rot.z, m.scale.x, m.scale.y, m.scale.z, m.color.r, m.color.g, m.color.b, m.alpha, m.jump, m.faceCamera, 2, m.rotate, nil, nil, false)

					if dist <= 1.5 then
						ShowInfobar(_('enter'))
						if IsControlJustReleased(0, 38) then
							OpenShowroom(k)
						end
					end
				end
			end

			if nearAny then
				Citizen.Wait(1000)
			end
		else -- Control check for the cams --
			if IsDisabledControlJustReleased(0, 23) then -- ESCAPE
				CloseShowroom()

				SetPauseMenuActive(false)
			elseif IsDisabledControlJustReleased(0, 174) then -- Left Arrow
				DoScreenFadeOut(Config.locations[current.ind].fadetime)

				while IsScreenFadingOut() do
					Citizen.Wait(50)
				end

				if current.carInd > 1 then
					current.carInd  = current.carInd - 1
				else
					current.carInd = #current.vehlist
				end

				form = setupScaleform("instructional_buttons")

				DoScreenFadeIn(Config.locations[current.ind].fadetime) 

				while IsScreenFadingIn() do
					Citizen.Wait(50)
				end
			elseif IsDisabledControlJustReleased(0, 175) then -- Right Arrow
				DoScreenFadeOut(Config.locations[current.ind].fadetime)

				while IsScreenFadingOut() do
					Citizen.Wait(50)
				end

				if current.carInd < #current.vehlist then
					current.carInd = current.carInd + 1
				else
					current.carInd = 1
				end

				form = setupScaleform("instructional_buttons")

				DoScreenFadeIn(Config.locations[current.ind].fadetime) 

				while IsScreenFadingIn() do
					Citizen.Wait(50)
				end
			elseif IsDisabledControlPressed(0, 14) then -- Scrollup
				zoom('ScrollDown')
			elseif IsDisabledControlPressed(0, 15) then
				zoom('Scrollup')
			elseif IsDisabledControlJustReleased(0, 182) then -- L / toggle lights
				local veh = GetEntFromIndex()

				for k, v in ipairs(spawnedVehicles) do
					if k == current.carInd then
						if v.lights then
							v.lights = false
							SetVehicleLights(veh, 1)
						else
							SetVehicleLights(veh, 2)
							v.lights = true
						end
					end
				end
			elseif IsDisabledControlJustReleased(0, 101) then -- H / open / close all doors
				local veh = GetEntFromIndex()
				local opened = false

				FreezeEntityPosition(veh, false)
				if (GetVehicleDoorAngleRatio(veh, 1) < 0.1) then
					opened = true
					SetVehicleDoorsLocked(veh, 1)

					for i = 0, 8, 1 do
						SetVehicleDoorOpen(veh, i, false, false)
					end
				else
					SetVehicleDoorsShut(veh, false);
					Citizen.Wait(500)
				end
				Citizen.Wait(500)
				FreezeEntityPosition(veh, true)

				if not opened then
					SetVehicleDoorsLocked(car, 2)
				end
			elseif IsDisabledControlJustReleased(0, 33) then
				if Config.locations[current.ind].cars[current.vehlist[current.carInd]].shop ~= nil then
					SendNUIMessage({
						link = Config.locations[current.ind].cars[current.vehlist[current.carInd]].shop,
					})
				end
			end
		end
		Citizen.Wait(0)
	end
end)

-- Cam-control thread --
Citizen.CreateThread(function()
	while true do
		if (cam and inShowRoom) then
            ProcessCamControls()

			local desc = Config.locations[current.ind].cars[current.vehlist[current.carInd]].desc
			-- Show Description --
			if desc.enabled then
				if desc.sort == 'up' then
					ShowInfobar(_("veh_desc", desc.label, desc.text, desc.maxSp, desc.price))
				elseif desc.sort == 'down' then
					ShowNotification(_("veh_desc", desc.label, desc.text, desc.maxSp, desc.price))
				end
			end

			-- Hide hud stuff --
			HideHudComponentThisFrame(19) -- weapon wheel
			HideHudComponentThisFrame(20) -- weapon wheel stats

			-- Disable random car spawn --
			SetVehicleDensityMultiplierThisFrame(0.0)
			SetRandomVehicleDensityMultiplierThisFrame(0.0)
			SetParkedVehicleDensityMultiplierThisFrame(0.0)

			-- Disable controls --
			DisableAllControlActions(0)

			if IsPauseMenuActive() then
				SetPauseMenuActive(false)
			end
		else
			Citizen.Wait(500)
        end

		Citizen.Wait(0)
	end	
end)