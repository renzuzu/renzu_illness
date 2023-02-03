# renzu_illness
Fivem Player Decease and illness. including covid, hepatitis, cough, dengue and more

# Dependencies
- ox_lib
- ox_inventory
- ESX Framework Legacy
- esx_status

# exports and commands
- /status -- check status of illnesses
 ```
 -- Checking and Treating Patient
 exports.renzu_illness:Status(PLAYERID) -- Player ID of patient
 
  -- Setting Illness Manually
 exports.renzu_illness:SetIllnes('covid')

 -- Removing Illness Manually
 exports.renzu_illness:RemoveIllnes('covid')
 ``` 

# Installation
- goto /renzu_illness/ox_inventory/items.lua
- Install the Items to ox_inventory
- ensure the renzu_illness before ox_lib, ox_inventory, esx_status
