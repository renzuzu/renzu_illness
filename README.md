# renzu_illness
Fivem Player Decease and illness. including covid, hepatitis, cough, dengue and more
![image](https://user-images.githubusercontent.com/82306584/216555680-f84ce148-9ef4-4bf6-b094-2fbbf7cca854.png)

# Features
- Job Based Treating Menu
- Item Based Treatments
- Multiple Illness Preconfigured. covid,cough, heptatis,tetanus,dengue,chickenpox,diareah and dehydration.
- Illness are saved locally only
- Immune System - if immune system is low. players will get sick easily.
- Face Mask - Avoid Covid virus
- Immunesystem and immunelevel are saved in esx_status
- Viral Virus Covid. covid will spread in players if they are not in face mask or lowered immunelevel and system.

# Dependencies
- ox_lib
- ox_inventory
- ESX Framework Legacy / QBCORE (with ox_inventory)
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
- ensure the renzu_illness after ox_lib, ox_inventory, esx_status
