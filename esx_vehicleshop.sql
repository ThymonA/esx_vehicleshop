CREATE TABLE `vehicleshop_categories` (
	`name` VARCHAR(100) DEFAULT NULL,
	`label` VARCHAR(100) DEFAULT NULL,

	PRIMARY KEY (`name`)
);

CREATE TABLE `vehicleshop_vehicles` (
	`code` VARCHAR(100) DEFAULT NULL,
    `hash` INT(11) NOT NULL,
	`price` INT(11) NOT NULL,
	`category` VARCHAR(100) DEFAULT NULL,

	PRIMARY KEY (`code`)
);