ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('prescription_pad', function(source)
    TriggerClientEvent('gc-vitarx:openPrescriptionPad', source)
end)

ESX.RegisterServerCallback('gc-vitarx:canUsePrescriptionPad', function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    cb(Config.DoctorJobs[xPlayer.job.name] == true)
end)

local function isValidOption(option, list)
    for _, entry in ipairs(list) do
        if entry.value == option then return true end
    end
    return false
end

RegisterCommand('prescriptions', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local citizenId = xPlayer.getIdentifier()

    MySQL.query('SELECT * FROM user_prescriptions WHERE citizenid = ?', { citizenId }, function(results)
        local active = {}
        local now = os.time()

        for _, rx in pairs(results) do
            if tonumber(rx.expires_at) > now then
                local minutesLeft = math.floor((rx.expires_at - now) / 60)
                table.insert(active, {
                    doctor = rx.doctor,
                    ailment = rx.ailment,
                    medication = rx.medication,
                    instructions = rx.instructions,
                    expires = minutesLeft
                })
            else
                -- Cleanup expired prescriptions
                MySQL.update('DELETE FROM user_prescriptions WHERE id = ?', { rx.id })
            end
        end

        if #active == 0 then
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 0, 0},
                args = {'[Prescriptions]', 'You have no active prescriptions.'}
            })
        else
            local timeStr = os.date('%Y-%m-%d %H:%M', rx.expires_at)
            TriggerClientEvent('chat:addMessage', source, {
                color = {0,255,100},
                args = {
                ('[%s]'):format(timeStr),
                ('Dr. %s | %s → %s | %s'):format(rx.doctor, rx.ailment, rx.medication, rx.instructions)
    }
})
            end
    end)
end)

RegisterNetEvent('gc-vitarx:writeDetailedPrescription', function(targetId, ailment, medication, instructions)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not Config.DoctorJobs[xPlayer.job.name] then return DropPlayer(src, 'Unauthorized') end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    if not targetPlayer then return end

    if not isValidOption(ailment, Config.Ailments)
        or not isValidOption(medication, Config.PrescriptionItems) then
    return TriggerClientEvent('esx:showNotification', src, 'Invalid prescription data.')
    end

    local expires = os.time() + Config.PrescriptionExpiry
    MySQL.Async.execute([[
        INSERT INTO user_prescriptions
          (citizenid, doctor, ailment, medication, instructions, expires_at)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        targetPlayer.getIdentifier(),
        xPlayer.getName(),
        ailment,
        medication,
        instructions,
        expires,
        'written'
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', src, ('Prescription for %s → %s'):format(medication, GetPlayerName(targetId)))
            TriggerClientEvent('esx:showNotification', targetId, ('You’ve been prescribed %s.'):format(medication))
        end
    end)
end)

-- count on‑duty pharmacists
ESX.RegisterServerCallback('gc-vitarx:getPharmacistCount', function(src, cb)
    local count = 0
    for _, pid in ipairs(ESX.GetPlayers()) do
      local xP = ESX.GetPlayerFromId(pid)
      if Config.PharmacistJobs[xP.job.name] then count = count + 1 end
    end
    cb(count)
  end)
  
  -- fetch *all* patient prescriptions (we’ll filter by status client‑side)
  ESX.RegisterServerCallback('gc-vitarx:getPatientPrescriptions', function(src, cb)
    local xP = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll('SELECT * FROM user_prescriptions WHERE citizenid = ?', {
      xP.getIdentifier()
    }, cb)
  end)
  
  -- drop‑off (written → pending)
  RegisterNetEvent('gc-vitarx:dropOffPrescription', function(prescriptionId)
    local src = source
    local cid = ESX.GetPlayerFromId(src).getIdentifier()
    MySQL.Async.execute([[
      UPDATE user_prescriptions
      SET status = 'pending'
      WHERE id = ? AND citizenid = ?
    ]], { prescriptionId, cid })
    TriggerClientEvent('esx:showNotification', src, 'Prescription dropped off.')
  end)
  
  -- pick‑up (filled → collected + give item)
  RegisterNetEvent('gc-vitarx:pickUpPrescription', function(prescriptionId)
    local src = source
    local xP  = ESX.GetPlayerFromId(src)
    MySQL.Async.fetchAll([[
      SELECT * FROM user_prescriptions
      WHERE id = ? AND citizenid = ? AND status = 'filled'
    ]], { prescriptionId, xP.getIdentifier() }, function(results)
      if #results == 0 then
        return TriggerClientEvent('esx:showNotification', src, 'No filled prescription found.')
      end
  
      local rx = results[1]
      -- give the medicine
      exports.ox_inventory:AddItem(src, rx.medication, 1, { instructions = rx.instructions })
      -- mark collected
      MySQL.Async.execute('UPDATE user_prescriptions SET status = \'collected\' WHERE id = ?', { prescriptionId })
      TriggerClientEvent('esx:showNotification', src, 'You picked up ' .. rx.medication)
    end)
  end)
  

local cleanupThread
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and cleanupThread then
        cleanupThread:cancel()  -- if you use a cancelable thread wrapper
    end
end)
