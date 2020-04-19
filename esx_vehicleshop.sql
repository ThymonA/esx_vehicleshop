CREATE TABLE IF NOT EXISTS `vehicleshop_categories` (
  `name` VARCHAR(100) DEFAULT NULL,
  `label` VARCHAR(100) DEFAULT NULL,

  PRIMARY KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `vehicleshop_vehicles` (
  `code` VARCHAR(100) DEFAULT NULL,
  `hash` VARCHAR(11) NOT NULL,
  `price` INT(11) NOT NULL,
  `category` VARCHAR(100) DEFAULT NULL,

  PRIMARY KEY (`code`)
);

CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(40) NOT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` LONGTEXT DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `stored` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`plate`)
);