#-- Virtual Domains Table
CREATE TABLE `virtual_domains` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domain` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

#-- Virtual User Table
CREATE TABLE `virtual_users` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domainIdx` INT NOT NULL,
    `usrEmail` VARCHAR(255) NOT NULL,
    `passwd` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`),
    UNIQUE KEY `uni_user_email` (`usrEmail`),
    FOREIGN KEY (`domainIdx`) REFERENCES virtual_domains(`idx`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

#-- Virtual Aliases Table
CREATE TABLE `virtual_aliases` (
    `idx` INT NOT NULL AUTO_INCREMENT,
    `domainIdx` INT NOT NULL,
    `usrIdx` INT NOT NULL,
    `source` VARCHAR(255) NOT NULL,
    `destination` VARCHAR(255) NOT NULL,
    `isDel` ENUM('Y', 'N') DEFAULT 'N' NOT NULL,
    PRIMARY KEY (`idx`),
    FOREIGN KEY (`domainIdx`) REFERENCES virtual_domains(`idx`) ON DELETE CASCADE,
    FOREIGN KEY (`usrIdx`) REFERENCES virtual_users(`idx`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
