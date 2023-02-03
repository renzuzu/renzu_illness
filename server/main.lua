local ptfxsource = {}
AddEventHandler('ptFxEvent', function(source, data)
	if not ptfxsource[source] then
		ptfxsource[source] = true
		TriggerClientEvent('ptfxevent',-1, data)
		Wait(10000)
		ptfxsource[source] = false
	end
end)

RegisterNetEvent('addcovid', function(id)
	local ply = Player(source).state
	if ply.covid then
		local other = Player(id).state
		if other.immunesystem and other.immunesystem < 50 or other.immunesystem and other.immunesystem < 80 and not other.facemask then
			other:set('covid',100.0, true)
			print('adding covid', id)
		end
	end
end)

lib.callback.register('renzu_illness:hasItem', function(src,item,patient)
	local hasitems = false
	local items = exports.ox_inventory:Search(src, 'count', item)
	if items >= 1 then
		exports.ox_inventory:RemoveItem(src, item, 1)
		TriggerClientEvent('renzu_illness:RemoveIllness',patient,item)
		hasitems = true
	end
	return hasitems
end)