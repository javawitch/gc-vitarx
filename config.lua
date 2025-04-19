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
