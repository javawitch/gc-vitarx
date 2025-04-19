Config = {}

Config.DoctorJobs = { ['doctor'] = true }

Config.PrescriptionItems = {
    { value = 'steroids', label = 'Steroids' },
    { value = 'painkillers', label = 'Painkillers' },
    { value = 'antibiotics', label = 'Antibiotics' },
    { value = 'protein_powder', label = 'Protein Powder' }
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
