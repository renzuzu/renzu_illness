stress = 0.0
drugs = 0.0
drunk = 0.0
immunesystem = 100.0
immunelevel = 0
PlayerData = {}
if GetResourceState('es_extended') == 'started' then
	ESX = exports['es_extended']:getSharedObject()
	PlayerData = ESX.GetPlayerData()

	RegisterNetEvent('esx:playerLoaded', function(xPlayer)
		PlayerData = xPlayer
	end)

	RegisterNetEvent('esx:setJob', function(job)
		PlayerData.job = job
	end)

elseif GetResourceState('qb-core') == 'started' then
	QBCore = exports['qb-core']:GetCoreObject()
	PlayerData = QBCore.Functions.GetPlayerData()
	
	RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
		PlayerData = QBCore.Functions.GetPlayerData()
	end)

	RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
		PlayerData.job = job
	end)
else -- standalone ?
	PlayerData = {job = 'ambulance'}
end
