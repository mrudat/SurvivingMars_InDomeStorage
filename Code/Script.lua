local orig_print = print
if Mods.mrudat_TestingMods then
  print = orig_print
else
  print = empty_func
end

local CurrentModId = rawget(_G, 'CurrentModId') or rawget(_G, 'CurrentModId_X')
local CurrentModDef = rawget(_G, 'CurrentModDef') or rawget(_G, 'CurrentModDef_X')
if not CurrentModId then

  -- copied shamelessly from Expanded Cheat Menu
  local Mods, rawset = Mods, rawset
  for id, mod in pairs(Mods) do
    rawset(mod.env, "CurrentModId_X", id)
    rawset(mod.env, "CurrentModDef_X", mod)
  end

  CurrentModId = CurrentModId_X
  CurrentModDef = CurrentModDef_X
end

orig_print("loading", CurrentModId, "-", CurrentModDef.title)

local T = ChoGGi.ComFuncs.Translate

local lookup_other_building_id = {}

local orig_City_AddPrefabs = City.AddPrefabs
function City:AddPrefabs(building_id, amount, refresh)
  local other_building_id = lookup_other_building_id[building_id]
  if other_building_id then
    orig_City_AddPrefabs(self, other_building_id, amount)
  end
  orig_City_AddPrefabs(self, building_id, amount, refresh)
end

function OnMsg.ClassesPostprocess()
  local buildings = BuildingTemplates

  local buildings_to_make_internal = {}

  for id, building in pairs(buildings) do
    if building.dome_forbidden then
      if building.pin_progress_max and building.pin_progress_max == 'storage_capacity' then
        -- OxygenTank/WaterTank/Battery
        buildings_to_make_internal[id] = building
      elseif building.template_class then
        if building.template_class == 'UniversalStorageDepot' then
          buildings_to_make_internal[id] = building
        elseif building.template_class == 'MysteryDepot' then
          buildings_to_make_internal[id] = building
        else
          local template_class = g_Classes[building.template_class]
          if template_class then
            if template_class:IsKindOf("MechanizedDepot") then
              buildings_to_make_internal[id] = building
            elseif template_class:IsKindOf("StorageDepot") then
              if template_class:IsKindOf("DumpSiteWithAttachedVisualPilesBase") then
                buildings_to_make_internal[id] = building
              end
            end
          end
        end
      end
    end
  end

  local function starts_with(str, start)
    return str:sub(1, #start) == start
  end

  local requirements = BuildingTechRequirements

  for id, building in pairs(buildings_to_make_internal) do
    local new_id = 'Inside_' .. id
    lookup_other_building_id[id] = new_id
    lookup_other_building_id[new_id] = id
    if buildings[new_id] then goto next_building end
    print("Defining new building:", new_id)
    local data = {}
    local labels = {}
    for k,v in pairs(building) do
      if v == "" then goto next_v end
      if k == 'id' then
        data[#data + 1] = 'Id'
        data[#data + 1] = new_id
      elseif k == 'dome_forbidden' then
        -- Skip
      elseif k == 'dome_required' then
        data[#data + 1] = k
        data[#data + 1] = true
      elseif k == 'display_name' then
        data[#data + 1] = k
        data[#data + 1] = T(498709591203, --[[ModItemBuildingTemplate  display_name]] "Inside ") .. T(v)
      elseif starts_with(k, 'label') then
        labels[v] = true
      else
        data[#data + 1] = k
        data[#data + 1] = v
      end
      ::next_v::
    end

    labels['InsideBuildings'] = true
    labels['OutsideBuildings'] = nil
    labels['OutsideBuildingsTargets'] = nil

    local label_index = 1

    for label in pairs(labels) do
      data[#data + 1] = 'label' .. label_index
      data[#data + 1] = label
      label_index = label_index + 1
    end

    print("data: ", data)
    PlaceObj("BuildingTemplate", data)
    -- FIXME MysteryDepot and SeedsDepot are unlocked via code, not directly via research.
    requirements[new_id] = requirements[id]
    ::next_building::
  end
end

function OnMsg.LoadGame()
  local prefabs = UICity.available_prefabs
  for building_id, other_building_id in pairs(lookup_other_building_id) do
    local prefab_count = prefabs[building_id]
    local other_prefab_count = prefabs[other_building_id]
    if other_prefab_count then
      if not prefab_count or other_prefab_count > prefab_count then
        prefabs[building_id] = other_prefab_count
      end
    end
  end
end

orig_print("loaded", CurrentModId, "-", CurrentModDef.title)
