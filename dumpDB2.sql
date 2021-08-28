/*
SQLyog Ultimate v12.14 (64 bit)
MySQL - 8.0.24 : Database - db2
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`db2` /*!40100 DEFAULT CHARACTER SET cp1251 */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `db2`;

/*Table structure for table `spr_roles` */

DROP TABLE IF EXISTS `spr_roles`;

CREATE TABLE `spr_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(256) DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=cp1251;

/*Data for the table `spr_roles` */

insert  into `spr_roles`(`id`,`name`) values 
(1,'admin'),
(8,'user');

/*Table structure for table `spr_users` */

DROP TABLE IF EXISTS `spr_users`;

CREATE TABLE `spr_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `login` varchar(32) DEFAULT '',
  `psw` varchar(32) DEFAULT '',
  `email` varchar(64) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_login_un` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=cp1251;

/*Data for the table `spr_users` */

insert  into `spr_users`(`id`,`login`,`psw`,`email`) values 
(1,'admin','21232f297a57a5a743894a0e4a801fc3','admin@gmail.com'),
(2,'user-1','22690a40e12037d691095b7a6441f8e6','user1@gmail.com'),
(3,'user-2','c76defe4f45d2958a0a4bfaa355e320d','user2@gmail.com');

/*Table structure for table `spr_users_roles` */

DROP TABLE IF EXISTS `spr_users_roles`;

CREATE TABLE `spr_users_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int DEFAULT '0',
  `user_id` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unq_user_role` (`role_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `spr_users_roles_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `spr_roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `spr_users_roles_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `spr_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=cp1251;

/*Data for the table `spr_users_roles` */

insert  into `spr_users_roles`(`id`,`role_id`,`user_id`) values 
(1,1,1),
(5,8,2);

/* Trigger structure for table `spr_users` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `spr_users_before_delete` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'127.0.0.1' */ /*!50003 TRIGGER `spr_users_before_delete` BEFORE DELETE ON `spr_users` FOR EACH ROW BEGIN
     
	
	 
	 DECLARE _qty INT DEFAULT 0;
	 
	 SET _qty = (SELECT COUNT(*)  FROM `spr_users_roles` WHERE role_id = 1 AND user_id = old.id);
	 IF _qty > 0 THEN
	 	SIGNAL SQLSTATE '45000' 
	 	SET MESSAGE_TEXT = 'This user is admin!';
	 END IF;
	 
	 /*
	 DECLARE `cr1` CURSOR FOR  
	 SELECT COUNT(*) as qty 
	 FROM `spr_users_roles` 
	 WHERE  role_id = 1 AND 
		user_id = old.id;
		
	 OPEN `cr1`;
	 
	 FETCH `cr1` INTO `_qty`;
	 
	 IF _qty > 0 THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'This user is admin!';
	 END IF;
	 
	 CLOSE cr1;
	 */
	 
    END */$$


DELIMITER ;

/* Procedure structure for procedure `auth` */

/*!50003 DROP PROCEDURE IF EXISTS  `auth` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `auth`(_login VARCHAR(32),_psw VARCHAR(32))
BEGIN
	SELECT id FROM spr_users WHERE login = _login AND psw = _psw;
    END */$$
DELIMITER ;

/* Procedure structure for procedure `get_fields` */

/*!50003 DROP PROCEDURE IF EXISTS  `get_fields` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `get_fields`(_TABLE_NAME varchar(50))
BEGIN
	
   	 
	SELECT  LOWER(column_name)  AS column_name,
		LOWER(data_type)    AS data_type
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE 	TABLE_SCHEMA = DATABASE() AND 
		TABLE_NAME   = _TABLE_NAME; 
	 
    END */$$
DELIMITER ;

/* Procedure structure for procedure `get_roles_byUser` */

/*!50003 DROP PROCEDURE IF EXISTS  `get_roles_byUser` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `get_roles_byUser`(IN _id int)
BEGIN
		
	SELECT IFNULL(GROUP_CONCAT(role_id),'') roles FROM `spr_users_roles` WHERE user_id = _id;
	
	 
	
    END */$$
DELIMITER ;

/* Procedure structure for procedure `spr_users_delete` */

/*!50003 DROP PROCEDURE IF EXISTS  `spr_users_delete` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `spr_users_delete`(_id INT)
BEGIN
	DECLARE _cnt INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;  
		SELECT 'error' as `status`;
	END;
	START transaction;
		DELETE FROM spr_users WHERE id = _id;
	COMMIT;
	SET _cnt = (SELECT COUNT(id) FROM spr_users WHERE id = _id);
	
	IF _cnt = 0 THEN
		SELECT 'ok' AS `status`;
	ELSE
		SELECT 'error' AS `status`;
	END IF;
	
    END */$$
DELIMITER ;

/* Procedure structure for procedure `spr_users_load` */

/*!50003 DROP PROCEDURE IF EXISTS  `spr_users_load` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `spr_users_load`()
BEGIN
	SELECT  id,login,email FROM spr_users;
    END */$$
DELIMITER ;

/* Procedure structure for procedure `spr_users_saveData` */

/*!50003 DROP PROCEDURE IF EXISTS  `spr_users_saveData` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `spr_users_saveData`(_id INT,_login VARCHAR(32),_email VARCHAR(64), _psw VARCHAR(32))
BEGIN
	 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;   
		-- SELECT 'An error has occurred, operation rollbacked and the stored procedure was terminated';
	END;
	
	START transaction;
		
		IF _psw != MD5('') THEN
	
			INSERT INTO spr_users 
			(
				id,
				login,
				email,
				psw
			)
			VALUES (
				_id,
				_login,
				_email,
				_psw
			)
			ON DUPLICATE KEY UPDATE  
				login=_login,
				email=_email,
				psw=_psw;
		ELSE
			UPDATE spr_users SET 
				login = _login,
				email = _email
			WHERE id = _id;
			 
		END IF;
		
		IF _id = 0 THEN
			SELECT id,login,email FROM spr_users WHERE id =(SELECT LAST_INSERT_ID());
		ELSE
			SELECT id,login,email FROM spr_users WHERE id = _id; 
		END IF;
 		
	COMMIT;
	
	
		 
	 	
        
    END */$$
DELIMITER ;

/* Procedure structure for procedure `verifyUniqueLogin` */

/*!50003 DROP PROCEDURE IF EXISTS  `verifyUniqueLogin` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `verifyUniqueLogin`(_login varchar(32))
BEGIN
	SELECT id FROM spr_users WHERE login = _login LIMIT 1;
    END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
