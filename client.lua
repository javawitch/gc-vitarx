RegisterNetEvent('gitcute:openPrescriptionPad', function()
    ESX.TriggerServerCallback('gitcute:canUsePrescriptionPad', function(canUse)
        if not canUse then
            lib.notify({ title = 'Access Denied', description = 'Only certified doctors can use this pad.', type = 'error' })
            return
        end

        -- (the rest of your inputDialog logic stays the same)
        local playerOptions = {}
        for _, id in ipairs(GetActivePlayers()) do
            local serverId = GetPlayerServerId(id)
            local name = GetPlayerName(id)
            table.insert(playerOptions, { value = tostring(serverId), label = name .. " [" .. serverId .. "]" })
        end

        local input = lib.inputDialog('Write Prescription', {
            { type = 'select', label = 'Select Patient (Online Only)', options = playerOptions, required = true },
            { type = 'select', label = 'Ailment', options = Config.Ailments, required = true },
            { type = 'select', label = 'Medication', options = Config.PrescriptionItems, required = true },
            { type = 'textarea', label = 'Instructions (Dosage, Frequency, etc.)', required = true }
        })

        if not input then return end

        local patientServerId = tonumber(input[1])
        local ailment          = input[2]
        local medication       = input[3]
        local instructions     = input[4]

        TriggerServerEvent('gitcute:writeDetailedPrescription', patientServerId, ailment, medication, instructions)
    end)
end)

ESX = nil
CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Wait(0)
  end
end)

local pharmacyPed = nil

-- every 30s, spawn/remove ped based on pharmacist count
CreateThread(function()
  while true do
    Wait(30000)
    ESX.TriggerServerCallback('gitcute:getPharmacistCount', function(count)
      if count == 0 and not pharmacyPed then
        -- spawn ped
        local m = GetHashKey(Config.Pharmacy.pedModel)
        RequestModel(m); while not HasModelLoaded(m) do Wait(1) end
        pharmacyPed = CreatePed(4, m,
          Config.Pharmacy.coords.x,
          Config.Pharmacy.coords.y,
          Config.Pharmacy.coords.z - 1,
          Config.Pharmacy.heading,
          false, true
        )
        SetEntityInvincible(pharmacyPed, true)
        FreezeEntityPosition(pharmacyPed, true)
        TaskStartScenarioInPlace(pharmacyPed, Config.Pharmacy.pedScenario, 0, true)

        -- interaction zone (using ox_target as example)
        exports.ox_target:addBoxZone({
          coords   = Config.Pharmacy.coords,
          size     = vec3(1.0,1.0,2.0),
          rotation = Config.Pharmacy.heading,
          options  = {
            {
              event = 'gitcute:openPharmacyMenu',
              icon  = 'fas fa-pills',
              label = 'Talk to Pharmacist'
            }
          }
        })
      elseif count > 0 and pharmacyPed then
        DeleteEntity(pharmacyPed)
        pharmacyPed = nil
      end
    end)
  end
end)

-- build the drop‑off / pick‑up menu
RegisterNetEvent('gitcute:openPharmacyMenu', function()
  local menu = {
    { title = 'Drop Off Prescription',   action = 'drop'   },
    { title = 'Pick Up Prescription',    action = 'pickup' }
  }
  lib.registerContext({ id = 'pharmacy_main', title = 'Pharmacy', options = menu })
  lib.showContext('pharmacy_main')

  lib.onContext('pharmacy_main', function(item)
    if item.action == 'drop' then
      ESX.TriggerServerCallback('gitcute:getPatientPrescriptions', function(results)
        local opts = {}
        for _, rx in ipairs(results) do
          if rx.status == 'written' then
            table.insert(opts, {
              title = ('%s for %s'):format(rx.medication, rx.ailment),
              prescriptionId = rx.id
            })
          end
        end
        if #opts == 0 then
          return lib.notify({ title='No Prescriptions', description='Nothing to drop off.', type='error' })
        end

        lib.registerContext({ id='drop_menu', title='Drop Off', options=opts })
        lib.showContext('drop_menu')
        lib.onContext('drop_menu', function(sel)
          TriggerServerEvent('gitcute:dropOffPrescription', sel.prescriptionId)
        end)
      end)

    elseif item.action == 'pickup' then
      ESX.TriggerServerCallback('gitcute:getPatientPrescriptions', function(results)
        local opts = {}
        for _, rx in ipairs(results) do
          if rx.status == 'filled' then
            table.insert(opts, {
              title = ('%s for %s'):format(rx.medication, rx.ailment),
              prescriptionId = rx.id
            })
          end
        end
        if #opts == 0 then
          return lib.notify({ title='No Ready Prescriptions', description='Come back later.', type='error' })
        end

        lib.registerContext({ id='pickup_menu', title='Pick Up', options=opts })
        lib.showContext('pickup_menu')
        lib.onContext('pickup_menu', function(sel)
          TriggerServerEvent('gitcute:pickUpPrescription', sel.prescriptionId)
        end)
      end)
    end
  end)
end)

