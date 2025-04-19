Config = {}

Config.DoctorJobs = { ['doctor'] = true }

Config.PrescriptionItems = {
    { value = 'steroids', label = 'Steroids' },
    { value = 'painkillers', label = 'Painkillers' },
    { value = 'antibiotics', label = 'Antibiotics' },
    { value = 'protein_powder', label = 'Protein Powder' }
}

Config.PharmacistJobs = { ['pharmacist'] = true }

-- Medicines pharmacists can dispense without a doctor’s pad
Config.PharmacyMedicines = {
    { value = 'aspirin',         label = 'Aspirin'         },
    { value = 'ibuprofen',       label = 'Ibuprofen'       },
    { value = 'cough_syrup',     label = 'Cough Syrup'     },
    { value = 'antihistamine',   label = 'Antihistamine'   },
    { value = 'antacid',         label = 'Antacid'         },
    { value = 'laxative',        label = 'Laxative'        }
}

Config.Ailments = {
    { value = 'muscle_strain', label = 'Muscle Strain' },
    { value = 'chronic_pain', label = 'Chronic Pain' },
    { value = 'infection', label = 'Infection' },
    { value = 'fatigue', label = 'Fatigue' }
}

Config.PrescriptionExpiry = 86400 -- 24 hours in seconds

-- pharmacy ped & job settings
Config.PharmacistJobs = { ['pharmacist'] = true }

Config.Pharmacy = {
  coords     = vector3(355.8, -594.8, 28.8),   -- set your pharmacy location
  heading    = 160.0,
  pedModel   = 's_m_m_doctor_01',
  pedScenario= 'WORLD_HUMAN_CLIPBOARD'
}
