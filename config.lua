config = {
	job = 'ambulance', -- required job to use the menu function for treating patients
	tick = 10000, -- in milliseconds, affects when the illness runs in client. affects checking and setting illness
	immuneremove = 110, -- min 1 , max 1000000. how much immune system is removed to player for every esx_status tick?
	Notify = function(msg)
		lib.notify({
			title = 'Illness',
			description = msg,
			type = 'inform'
		})
	end,
	trigger = {
		dehydrated = { status = 'thirst', percent = 30 },
		diarrhea = { status = 'hunger', percent = 91, immunesystem = 40, chance = 3},
		cough = { immunesystem = 40, chance = 40},
		chickenpox = { status = 'stress', percent = 50, immunesystem = 50, chance = 50},
		hepatitis = { status = 'stress', percent = 50, immunesystem = 20, chance = 50},
		mosquito = {chance = 5}, -- chance of spawning mosquito attack
		dengue = { chance = 7, immunesystem = 40}, -- chances when mosquito bites you
		tetanus = {chance = 40 }, -- triggered by bulllets
		covid = {distance = 5, totalcough = 30}, -- @distance total distance before spreading the virus to other player, totalcough = total amount of cough before having covid
	},
	Emotes = function(anim,dict)
		lib.requestAnimDict(dict)
		TaskPlayAnim(cache.ped, dict, anim, 1.0, 1.0, -1, 50, 0, false, false, false)
	end,
	Walk = function(anim)
		lib.requestAnimSet(anim)
		SetPedMovementClipset(cache.ped, anim, true)
		RemoveAnimSet(anim)	
	end,
	illnes = {
		cough = function()
			config.Emotes('idle_cough','timetable@gardener@smoking_joint')
			LocalPlayer.state:set('coughcount',LocalPlayer.state.coughcount and LocalPlayer.state.coughcount + 1 or 1, true)
			if LocalPlayer.state.coughcount and LocalPlayer.state.coughcount >= config.trigger.covid.totalcough then
				SetPlayerMaxStamina(PlayerId(),0)
				LocalPlayer.state:set('covid',100.0,true)
			end
		end,
		covid = function()
			config.Emotes('idle_cough','timetable@gardener@smoking_joint')
			if math.random(1,100) < 10 then
				SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) - 1)
				print('health reduce')
				TriggerEvent('esx_status:add', 'stress',10000)
				TriggerEvent('esx_status:remove', 'thirst',20000)
				config.Notify('Health is getting degenerated')
				Citizen.CreateThreadNow(function()
					Wait(5000)
					config.Walk('move_m@depressed@a')
					Wait(2000)
					lib.requestAnimDict('random@drunk_driver_1')
					TaskPlayAnim(cache.ped, 'random@drunk_driver_1', "vomit_low", 2.0, 2.0, -1, 50, 0, false, false, false)
				end)
				config.Notify('You have Major Cough and mucus and hardtime breathing')
			end
		end,
		chickenpox = function()
			local ped = cache.ped
			if not LocalPlayer.state.oldchickenpox then
				local data = {
					[11] = GetPedHeadOverlayValue(cache.ped,11),
					[12] = GetPedHeadOverlayValue(cache.ped,12),
					[0] = GetPedHeadOverlayValue(cache.ped,0),
				}
				LocalPlayer.state:set('oldchickenpox', data, true)
			end
			config.Notify('my skin is very itchy')
			SetPedHeadOverlay(ped,12,1,1.0)
			SetPedHeadOverlay(ped,11,5,1.0)
			SetPedHeadOverlay(ped,0,18,1.0)
		end,
		diarrhea = function()
			--config.Emotes('kylie_clip','sitkylie@queensisters')
			if not config.countToPoop then
				config.countToPoop = 0
			end
			config.countToPoop += 1
			if config.countToPoop > 20 then
				local hash = `prop_big_shit_02`
				local coords = GetEntityCoords(cache.ped)
				shit = CreateObject(hash,coords.x,coords.y,coords.z,true,true)
				Wait(5000)
				ClearPedTasks(cache.ped)
				LocalPlayer.state:set('diarrhea', false, true)
				config.countToPoop = 0
			else
				config.Notify('you are having stomach issue. please ask a doctor')
			end
		end,
		hepatitis = function()
			local ped = cache.ped
			function GetHeadBlendData()
				return Citizen.InvokeNative(0x2746BD9D88C5C5D0, PlayerPedId(), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueIntInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0), Citizen.PointerValueFloatInitialized(0))
			end
		
			local data = {GetHeadBlendData()}
			if not LocalPlayer.state.oldhepatitis then
				LocalPlayer.state:set('oldhepatitis', data, true)
			end
			if not LocalPlayer.state.eyecolor then
				LocalPlayer.state:set('eyecolor', GetPedEyeColor(cache.ped), true)
			end
			local shapeFirst, shapeSecond, shapeThird, skinFirst, skinSecond, skinThird, shapeMix, skinMix, thirdMix  = GetHeadBlendData(ped)
		
			SetPedHeadBlendData(cache.ped, shapeFirst, shapeSecond, shapeThird, 39, 39, skinThird, shapeMix, skinMix, thirdMix, false)
			SetPedEyeColor(cache.ped,25)
			config.Notify('my skin is yellowish')
		end,
		tetanus = function()
			lib.requestAnimDict('random@drunk_driver_1')
			TaskPlayAnim(cache.ped, 'random@drunk_driver_1', "vomit_low", 2.0, 2.0, -1, 50, 0, false, false, false)
			Wait(10000)
			config.Walk('move_m@depressed@a')
			config.Notify('Your wound has been infected')
		end,
		dehydrated = function()
			local ped = cache.ped
			if not LocalPlayer.state.olddehydrated then
				LocalPlayer.state:set('olddehydrated', GetPedHeadOverlayValue(cache.ped,3), true)
			end
			LocalPlayer.state:set('dehydrated',100.0,true)
			SetPedHeadOverlay(ped,3,14,1.0)
			config.Walk('move_characters@jimmy@slow@')

			config.Notify('im thirsy')
		end,
		dengue = function()
			local ped = cache.ped
			lib.requestAnimDict('missfam5_blackout')
			TaskPlayAnim(cache.ped, 'missfam5_blackout', "vomit_facial", 2.0, 2.0, -1, 50, 0, false, false, false)
			LocalPlayer.state:set('dengue',100.0,true)
			config.Walk('anim_group_move_ballistic')

			config.Notify('i feel i have a high fever')
			SetEntityMaxHealth(cache.ped,110)
		end,
	},
	removeillness = {
		dengue = function()
			LocalPlayer.state:set('dengue',false,true)
			ResetPedMovementClipset(cache.ped)
			config.Notify('i feel relieved')
			SetEntityMaxHealth(cache.ped,200)
		end,
		dehydrated = function()
			local ped = cache.ped
			print('removing',LocalPlayer.state.olddehydrated)
			SetPedHeadOverlay(ped,3,LocalPlayer.state.olddehydrated or 0.0,0.0)
			ResetPedMovementClipset(cache.ped)
			LocalPlayer.state:set('dehydrated',false,true)
			config.Notify('im Fully Hydrated')
		end,
		tetanus = function()
			ClearPedTasks(cache.ped)
			ResetPedMovementClipset(cache.ped)
			LocalPlayer.state:set('tetanus',false,true)
			config.Notify('You feel the Anti biotic works')
		end,
		hepatitis = function()
			local ped = cache.ped
			local data = LocalPlayer.state.oldhepatitis
			if not data then return end
			SetPedHeadBlendData(cache.ped, data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], false)
			SetPedEyeColor(cache.ped,LocalPlayer.state.eyecolor or 0)
			LocalPlayer.state:set('oldhepatitis',nil,true)
			LocalPlayer.state:set('hepatitis',false,true)
			config.Notify('Your skin is starting to get normal')
		end,
		diarrhea = function()
			LocalPlayer.state:set('diarrhea',false,true)
			config.Notify('My stomach is now in good condition')
		end,
		chickenpox = function()
			local ped = cache.ped
			if LocalPlayer.state.oldchickenpox then
				SetPedHeadOverlay(ped,12,LocalPlayer.state.oldchickenpox[12],0.0)
				SetPedHeadOverlay(ped,11,LocalPlayer.state.oldchickenpox[11],0.0)
				SetPedHeadOverlay(ped,0,LocalPlayer.state.oldchickenpox[0],0.0)
			else
				SetPedHeadOverlay(ped,12,0,0.0)
				SetPedHeadOverlay(ped,11,0,0.0)
				SetPedHeadOverlay(ped,0,0,0.0)
			end
			LocalPlayer.state:set('oldchickenpox',false,true)
			LocalPlayer.state:set('chickenpox',false,true)
			config.Notify('Your skin itching problem has been cured')
		end,
		covid = function()
			LocalPlayer.state:set('covid',false,true)
			LocalPlayer.state:set('coughcount',false, true)
			ResetPedMovementClipset(cache.ped)
			config.Notify('Covid has been cured.')
			SetPlayerMaxStamina(PlayerId(),1.0)
			RestorePlayerStamina(PlayerId(), 1.0)
			ResetPlayerStamina(PlayerId(),1.0)
		end,
		cough = function()
			LocalPlayer.state:set('cough',false,true)
			LocalPlayer.state:set('coughcount',false, true)
			config.Notify('My cough has been gone')
			config.Notify('i can breath easily now')
		end,
	}
}
