ESX.RegisterUsableItem('prescription_pad', function(source)
    TriggerClientEvent('gitcute:openPrescriptionPad', source)
end)

ESX.RegisterServerCallback('gitcute:canUsePrescriptionPad', function(src, cb)
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

RegisterNetEvent('gitcute:writeDetailedPrescription', function(targetId, ailment, medication, instructions)
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
        expires
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', src, ('Prescription for %s → %s'):format(medication, GetPlayerName(targetId)))
            TriggerClientEvent('esx:showNotification', targetId, ('You’ve been prescribed %s.'):format(medication))
        end
    end)
end)

local cleanupThread
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and cleanupThread then
        cleanupThread:cancel()  -- if you use a cancelable thread wrapper
    end
end)
