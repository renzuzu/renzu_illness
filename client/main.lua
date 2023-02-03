ESX = exports['es_extended']:getSharedObject()
local stress = 0.0
local drugs = 0.0
local drunk = 0.0
local immunesystem = 100.0
local immunelevel = 0
local PlayerData = {}
Citizen.CreateThread(function()
	Wait(1000)
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    PlayerData = playerData
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

function GetClosestVehicle(c,dist)
	local closest = 0
	for k,v in pairs(GetGamePool('CVehicle')) do
		local dis = #(GetEntityCoords(v) - c)
		if dis < dist 
		    or dist == -1 then
			closest = v
			dist = dis
		end
	end
	return closest, dist
end

isNearMuffler = function(entity,coords)
	local boneId = GetEntityBoneIndexByName(entity, 'boot')
	local indist = #(coords - GetWorldPositionOfEntityBone(entity, boneId)) < 11.0 and GetIsVehicleEngineRunning(entity)
	return indist
end

local debug = false

isNightandNotInterior = function()
	local hour = GetClockHours()
	local in_interior = GetInteriorFromEntity(cache.ped) ~= 0
	if debug then
		print(hour,'current time')
	end
	return not in_interior and hour > 18 or not in_interior and hour > 1 and hour < 7
end

local usingitem = false
exports('useItem', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
		usingitem = true
		TreatPatient(data.name)
		Wait(5000)
		usingitem = false
	end)
end)

TreatPatient = function(item)
	if item == 'multivitamins' then
		TriggerEvent('esx_status:add','immunesystem',500000)
	end
	if item == 'ambroxol' then
		RemoveIllnes('cough')
	end
	if item == 'metronidazole' then
		RemoveIllnes('tetanus')
	end
	if item == 'baraclude' then
		RemoveIllnes('hepatitis')
	end
	if item == 'molnupiravir' then
		RemoveIllnes('covid')
	end
	if item == 'diatabs' then
		RemoveIllnes('diarrhea')
	end
	if item == 'antihistamine' then
		RemoveIllnes('chickenpox')
	end
	if item == 'acetaminophe' then
		RemoveIllnes('dengue')
	end
	if item == 'offlotion' then
		LocalPlayer.state:set('offlotion',true,true)
	end
end

exports('TreatPatient',TreatPatient)
RegisterNetEvent('renzu_illness:RemoveIllness',TreatPatient)

RunIllness = function()
	while PlayerData.job == nil do Wait(111) end	-- make sure player fully loaded before starting loop
	while true do
		local coord = GetEntityCoords(cache.ped)
		local vehicle = GetClosestVehicle(coord, 10.0)
		if isNearMuffler(vehicle,coord) then
			immunesystem -= 0.5
			if immunesystem <= 0 or immunesystem <= 40 and math.random(1,100) < 40 then
				SetIllnes('cough')
			end
		end
		if isNightandNotInterior() then
			immunesystem -= 1.5
			if immunesystem <= 0 or immunesystem <= 40 and math.random(1,100) < 40 then
				SetIllnes('cough')
			end
		end
		if stress > 50 then
			immunesystem -= 2.5
			if immunesystem <= 0 or immunesystem <= 50 and math.random(1,100) < 50 then
				SetIllnes('chickenpox')
			end
			if immunesystem <= 0 or immunesystem <= 40 and math.random(1,100) < 50 then
				SetIllnes('hepatitis')
			end
			if immunesystem <= 0 or immunesystem <= 30 and math.random(1,100) < 15 then
				SetIllnes('diarrhea')
			end
		end
		if drugs > 40 then
			immunesystem -= 1.5
			if immunesystem <= 0 or immunesystem <= 50 and math.random(1,100) < 50 then
				SetIllnes('hepatitis')
			end
			if immunesystem <= 0 or immunesystem <= 80 and math.random(1,100) < 50 then
				SetIllnes('chickenpox')
			end
			if immunesystem <= 0 or immunesystem <= 50 and math.random(1,100) < 50 then
				SetIllnes('diarrhea')
			end
		end
		if drunk > 50 then
			immunesystem -= 1.5
			if immunesystem <= 0 or immunesystem <= 50 and math.random(1,100) < 50 then
				SetIllnes('hepatitis')
				TriggerEvent('esx_status:add','stress',10000)
			end
		end
		for k,v in pairs(config.illnes) do
			local ply = LocalPlayer.state
			if ply[k] and not usingitem then
				SetIllnes(k)
			end
		end
		LocalPlayer.state:set('immunesystem',immunesystem, true)
		LocalPlayer.state:set('immunelevel',immunelevel, true)
		if math.random(1,100) < 5 and isNightandNotInterior() and not LocalPlayer.state.offlotion then
			Mosquitos()
		end
		Wait(10000)
	end
end

Citizen.CreateThread(RunIllness)

RegisterNetEvent("devcore_smoke:c_eff_cigarette", function(cigaratte)
	local ped = NetToPed(cigaratte)
	if DoesEntityExist(ped) and ped ~= PlayerPedId() and #(GetEntityCoords(cache.ped) - GetEntityCoords(ped)) < 5 and immunesystem < 50 and not LocalPlayer.state.facemask then
		SetIllnes('cough')
	end
end)

Mosquitos = function(ent)
	local ent = cache.ped
    local mycoords = GetEntityCoords(cache.ped)
	local loopAmount = 25
	createdParticle = {}
	local asset = "core"
	local particleName = 'ent_amb_insect_swarm'
	RequestNamedPtfxAsset(asset)
	print('lamok attack')
	while not HasNamedPtfxAssetLoaded(asset) do
		Wait(100)
	end
    local particleEffects = {}
	for x=0,loopAmount do
		UseParticleFxAssetNextCall(asset)
		local particle = StartNetworkedParticleFxLoopedOnEntity(particleName, ent, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, false, false, false)
		table.insert(particleEffects, 1, particle)
		Citizen.Wait(0)
	end
	SetEntityHealth(cache.ped,GetEntityHealth(cache.ped)-2)
	config.Notify('you have been bited by mosquito')
	if math.random(1,100) < 7 and immunesystem < 40 then
		SetIllnes('dengue')
	end
	Citizen.Wait(8000)
	for _,particle in pairs(particleEffects) do
		StopParticleFxLooped(particle, true)
		RemoveParticleFx(particle, 0)
	end
	RemoveParticleFxFromEntity(ent)
	RemoveParticleFxInRange(mycoords.x,mycoords.y,mycoords.z)
end

RegisterNetEvent('ptfxevent', function(data)
	print('ptfx event', data)
	if #(GetEntityCoords(cache.ped) - vec3(data.posX,data.posY,data.posZ)) < 20 and immunesystem < 40 then
		SetIllnes('cough')
	end
end)

RegisterCommand('poopa', function()
	SetIllnes('cough')
	local hash = `prop_big_shit_02`
	local coords = GetEntityCoords(cache.ped)
	shit = CreateObject(hash,coords.x,coords.y,coords.z,true,true)
	Wait(5000)
	ClearPedTasks(cache.ped)
end)

AddEventHandler('gameEventTriggered', function (name, args)
	if name == 'CEventNetworkEntityDamage' then
		local victim = args[1]
		if victim == cache.ped then
			if HasEntityBeenDamagedByWeapon(cache.ped, 0 , 1) and immunesystem < 40 then
				SetIllnes('tetanus')
			end
		end
	end
end)

function GetPlayers(onlyOtherPlayers, returnKeyValue, returnPeds)
    local players, myPlayer = {}, PlayerId()

    for k, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)

        if DoesEntityExist(ped) and player ~= myPlayer then
			players[player] = GetPlayerServerId(player)
        end
    end

    return players
end

RegisterCommand('covid', function(src,args)
	SetIllnes('covid')
end)


RegisterCommand('dengue', function(src,args)
	SetIllnes('dengue')
end)

SetIllnes = function(type)
	Citizen.CreateThreadNow(function()
		if not LocalPlayer.state[type] then
			LocalPlayer.state:set(type, 100, true)
		end
		config.illnes[type]()
		if type == 'covid' then
			local players = GetPlayers()
			for k,v in pairs(players) do
				local ped = GetPlayerPed(k)
				--print(#(GetEntityCoords(cache.ped) - GetEntityCoords(ped)),Player(v).state.immunesystem)
				if DoesEntityExist(ped) and #(GetEntityCoords(cache.ped) - GetEntityCoords(ped)) < 5 and not Player(v).state.facemask then
					TriggerServerEvent('addcovid', v)
					--print('adding')
				end
			end
		end
	end)
end

RemoveIllnes = function(type)
	return config.removeillness[type]()
end


Status = function(id)
	local src = id
	local ply = Player(src).state
	lib.registerMenu({
		id = 'Status',
		title = 'Patient #'..src..' Status',
		position = 'top-right',
		onSideScroll = function(selected, scrollIndex, args)
			print("Scroll: ", selected, scrollIndex, args)
		end,
		onSelected = function(selected, secondary, args)
			if not secondary then
				print("Normal button")
			else
				if args.isCheck then
					print("Check button")
				end
	
				if args.isScroll then
					print("Scroll button")
				end
			end
			print(selected, secondary, json.encode(args, {indent=true}))
		end,
		onCheck = function(selected, checked, args)
			print("Check: ", selected, checked, args)
			ClearPedTasks(cache.ped)
		end,
		onClose = function(keyPressed)
			print('Menu closed')
			if keyPressed then
				print(('Pressed %s to close the menu'):format(keyPressed))
			end
			ClearPedTasks(cache.ped)
		end,
		options = {
			{label = 'Immune System', description = ' Immune System', progress = ply.immunesystem or 0.0, colorScheme = 'green', args = 'multivitamins'},
			{label = 'Diarrhea', description = ' Stomach Health', progress = ply.diarrhea or 0.0, colorScheme = 'orange', args = 'diatabs'},
			{label = 'Chicken Pox', description = ' Chicken Pox Status', progress = ply.chickenpox or 0.0, colorScheme = 'blue', args = 'antihistamine'},
			{label = 'Cough', description = ' Cough Status', progress = ply.cough or 0.0, args = 'ambroxol'},
			{label = 'Hepatitis', description = ' Hepatitis Status', progress = ply.hepatitis or 0.0, args = 'baraclude'},
			{label = 'Covid', description = ' Covid Status', progress = ply.covid or 0.0, colorScheme = 'red', args = 'molnupiravir'},
			{label = 'Tetanus', description = ' Tetanus Status', progress = ply.tetanus or 0.0, args = 'metronidazole'},
			{label = 'Dehydrated', description = ' Hydro Status', progress = ply.dehydrated or 0.0, args = 'water'},
			{label = 'Dengue', description = ' Dengue Status', progress = ply.dengue or 0.0, args = 'acetaminophe'},
		}
	}, function(selected, scrollIndex, item)
		print(selected, scrollIndex, item)
		if config.job == PlayerData?.job?.name then
			local hasitem = lib.callback.await('renzu_illness:hasItem',false,item,src)
			if hasitem then
				lib.progressBar({
					duration = 2000,
					label = 'Treating Patient',
					useWhileDead = false,
					canCancel = false,
					disable = {
						car = true,
					},
					anim = {
						dict = 'mini@repair',
						clip = 'fixing_a_player'
					}
				})
				ClearPedTasks(cache.ped)
			else
				config.Notify('you dont have the required medicine item')
			end
		end
	end)
	lib.showMenu('Status')
end

RegisterCommand('status', function(src,args)
	--if PlayerData.job == 'ambulance' then return end
    Status(GetPlayerServerId(PlayerId()))
end)

faceMask = function(data,slot)
	exports.ox_inventory:useItem(data, function(data)
		local ped = cache.ped
		local male = GetEntityModel(ped) == GetHashKey('mp_m_freemode_01')
		if male then
			SetPedComponentVariation(ped,tonumber(7),162,0,0)
		else
			SetPedComponentVariation(ped,tonumber(7),6,0,0)
		end
		LocalPlayer.state:set('facemask',true,true)
	end)
end

exports('Status',Status)
exports('RemoveIllnes',RemoveIllnes)
exports('SetIllnes',SetIllnes)
exports('Config',config)
exports('faceMask',faceMask)

RegisterNetEvent("esx_status:onTick", function(data)
    for _,v in pairs(data) do
        if v.name == 'stress' then
			stress = v.percent
		end
		if v.name == 'drugs' then
			drugs = v.percent
		end
		if v.name == 'drunk' then
			drunk = v.percent
		end
		if v.name == 'thirst' and v.percent < 30 then
			SetIllnes('dehydrated')
		elseif v.name == 'thirst' and v.percent > 40 and LocalPlayer.state.dehydrated then
			RemoveIllnes('dehydrated')
		end
		if v.name == 'immunesystem' then
			immunesystem = v.percent
		end
		--print(v.name,v.percent)
		if v.name == 'hunger' and v.percent > 91 then
			if math.random(1,100) < 3 and immunesystem < 40 then
				SetIllnes('diarrhea')
			end
		end
		if v.name == 'immunelevel' then
			immunelevel = v.percent
			print(immunelevel,'immunelevel')
		end
    end
end)

RegisterNetEvent('esx_status:loaded', function(status) -- register immunesystem and immunelevel as status
	print('register status events')

	TriggerEvent('esx_status:registerStatus', 'immunesystem', 1000000, '#0C98F1', function(status)
		return false
	end, function(status)
		local immunelevel = LocalPlayer?.state?.immunelevel or 1
		local remove = 110
		status.remove(remove - immunelevel)
	end)

	TriggerEvent('esx_status:registerStatus', 'immunelevel', 0, '#0C98F1', function(status) -- you can add value to this when player takes a gym for example. my gym resource is not public atm.
		return false
	end, function(status)
	end)
end)