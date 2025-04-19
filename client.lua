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
