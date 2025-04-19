CREATE TABLE IF NOT EXISTS `user_prescriptions` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `citizenid` VARCHAR(100) NOT NULL,
    `doctor` VARCHAR(100) NOT NULL,
    `ailment` VARCHAR(100) NOT NULL,
    `medication` VARCHAR(100) NOT NULL,
    `instructions` TEXT NOT NULL,
    `expires_at` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `status` VARCHAR(20) NOT NULL DEFAULT 'written',
    `filled_by` VARCHAR(100) NULL,
    `filled_at` INT NULL,
    PRIMARY KEY (`id`)
);
