-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: CourtFinder
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `basketballcourt`
--

DROP TABLE IF EXISTS `basketballcourt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `basketballcourt` (
  `CourtID` int NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `Location` varchar(255) NOT NULL,
  `Facilities` varchar(255) DEFAULT NULL,
  `AvailStatus` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`CourtID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `basketballcourt`
--

LOCK TABLES `basketballcourt` WRITE;
/*!40000 ALTER TABLE `basketballcourt` DISABLE KEYS */;
INSERT INTO `basketballcourt` VALUES (1,'Main Court','100 Oak St','Lights, Benches',1),(2,'Park Court','200 Elm St','Water Fountain',1),(3,'Rec Center','300 Pine St','Indoor, AC',1),(4,'School Gym','400 Maple St','Bleachers',0),(5,'Beach Court','500 Shore Dr','Outdoor, Sand',1),(6,'YMCA Court','600 Main St','Indoor, Lockers',1),(7,'North Park','700 North Ave','Lights',1),(8,'South Gym','800 South Blvd','AC, Scoreboard',0),(9,'West Side','900 West Rd','Outdoor',1),(10,'East Court','1000 East Ln','Benches, Lights',1),(11,'College Gym','1100 Campus Dr','Indoor, Bleachers',1),(12,'Downtown','1200 Center St','Outdoor, Lights',1),(13,'Lakeside','1300 Lake Rd','Outdoor',0),(14,'Hill Court','1400 Hill St','Benches',1),(15,'Valley Gym','1500 Valley Dr','Indoor, AC',1),(16,'Church Gym','1600 Faith St','Indoor',1),(17,'Club Court','1700 Club Ln','Lights, Lockers',0),(18,'Plaza Court','1800 Plaza Ave','Outdoor',1),(19,'River Park','1900 River Rd','Benches, Lights',1),(20,'Sunset Court','2000 Sunset Dr','Outdoor, Sand',1);
/*!40000 ALTER TABLE `basketballcourt` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `basketballsession`
--

DROP TABLE IF EXISTS `basketballsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `basketballsession` (
  `SessionID` int NOT NULL AUTO_INCREMENT,
  `OrganizerID` int NOT NULL,
  `CourtID` int NOT NULL,
  `SkillRequired` varchar(50) DEFAULT NULL,
  `Capacity` int DEFAULT NULL,
  `Duration` int DEFAULT NULL,
  `GameFormat` varchar(50) DEFAULT NULL,
  `Status` varchar(50) DEFAULT 'Scheduled',
  `DateTime` datetime NOT NULL,
  PRIMARY KEY (`SessionID`),
  KEY `OrganizerID` (`OrganizerID`),
  KEY `CourtID` (`CourtID`),
  CONSTRAINT `basketballsession_ibfk_1` FOREIGN KEY (`OrganizerID`) REFERENCES `gameorganizer` (`OrganizerID`),
  CONSTRAINT `basketballsession_ibfk_2` FOREIGN KEY (`CourtID`) REFERENCES `basketballcourt` (`CourtID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `basketballsession`
--

LOCK TABLES `basketballsession` WRITE;
/*!40000 ALTER TABLE `basketballsession` DISABLE KEYS */;
INSERT INTO `basketballsession` VALUES (1,1,1,'Beginner',10,60,'5v5','Scheduled','2026-04-01 18:00:00'),(2,2,2,'Intermediate',8,45,'4v4','Scheduled','2026-04-02 17:00:00'),(3,3,3,'Advanced',10,90,'5v5','Completed','2026-03-15 19:00:00'),(4,4,4,'Beginner',6,30,'3v3','Cancelled','2026-03-20 16:00:00'),(5,5,5,'Intermediate',10,60,'5v5','Scheduled','2026-04-05 10:00:00'),(6,1,6,'Advanced',10,90,'5v5','Scheduled','2026-04-06 18:00:00'),(7,2,7,'Beginner',8,45,'4v4','Scheduled','2026-04-07 17:00:00'),(8,3,8,'Intermediate',6,60,'3v3','Completed','2026-03-10 15:00:00'),(9,4,9,'Advanced',10,90,'5v5','Scheduled','2026-04-08 19:00:00'),(10,5,10,'Beginner',10,60,'5v5','Scheduled','2026-04-09 10:00:00'),(11,1,11,'Intermediate',8,45,'4v4','Completed','2026-03-12 18:00:00'),(12,2,12,'Advanced',10,90,'5v5','Scheduled','2026-04-10 17:00:00'),(13,3,13,'Beginner',6,30,'3v3','Cancelled','2026-03-18 16:00:00'),(14,4,14,'Intermediate',10,60,'5v5','Scheduled','2026-04-11 15:00:00'),(15,5,15,'Advanced',8,90,'4v4','Scheduled','2026-04-12 19:00:00'),(16,1,16,'Beginner',10,45,'5v5','Scheduled','2026-04-13 10:00:00'),(17,2,17,'Intermediate',6,60,'3v3','Cancelled','2026-03-22 18:00:00'),(18,3,18,'Advanced',10,90,'5v5','Completed','2026-03-08 17:00:00'),(19,4,19,'Beginner',8,45,'4v4','Scheduled','2026-04-14 16:00:00'),(20,5,20,'Intermediate',10,60,'5v5','Scheduled','2026-04-15 10:00:00');
/*!40000 ALTER TABLE `basketballsession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamefeedback`
--

DROP TABLE IF EXISTS `gamefeedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gamefeedback` (
  `FeedbackID` int NOT NULL AUTO_INCREMENT,
  `PlayerID` int NOT NULL,
  `SessionID` int NOT NULL,
  `SatisfactionRating` int DEFAULT NULL,
  `CourtConditionRating` int DEFAULT NULL,
  `Comments` varchar(500) DEFAULT NULL,
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`FeedbackID`),
  KEY `PlayerID` (`PlayerID`),
  KEY `SessionID` (`SessionID`),
  CONSTRAINT `gamefeedback_ibfk_1` FOREIGN KEY (`PlayerID`) REFERENCES `player` (`PlayerID`),
  CONSTRAINT `gamefeedback_ibfk_2` FOREIGN KEY (`SessionID`) REFERENCES `basketballsession` (`SessionID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gamefeedback`
--

LOCK TABLES `gamefeedback` WRITE;
/*!40000 ALTER TABLE `gamefeedback` DISABLE KEYS */;
INSERT INTO `gamefeedback` VALUES (1,1,3,5,4,'Fun game','2026-03-15 21:00:00'),(2,2,3,4,3,'Court was slippery','2026-03-15 21:30:00'),(3,3,3,5,5,'Perfect conditions','2026-03-15 22:00:00'),(4,4,3,2,2,'Too crowded','2026-03-15 21:15:00'),(5,5,3,4,4,'Would play again','2026-03-15 22:30:00'),(6,9,3,1,1,'Horrible!','2026-04-02 00:34:29');
/*!40000 ALTER TABLE `gamefeedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gameorganizer`
--

DROP TABLE IF EXISTS `gameorganizer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gameorganizer` (
  `OrganizerID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `Credentials` varchar(255) DEFAULT NULL,
  `GamesHosted` int DEFAULT '0',
  PRIMARY KEY (`OrganizerID`),
  UNIQUE KEY `UserID` (`UserID`),
  CONSTRAINT `gameorganizer_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gameorganizer`
--

LOCK TABLES `gameorganizer` WRITE;
/*!40000 ALTER TABLE `gameorganizer` DISABLE KEYS */;
INSERT INTO `gameorganizer` VALUES (1,1,'Referee',4),(2,2,'Coach',7),(3,3,'Volunteer',2),(4,4,'Staff',5),(5,5,'Coordinator',3);
/*!40000 ALTER TABLE `gameorganizer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `joinrequest`
--

DROP TABLE IF EXISTS `joinrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `joinrequest` (
  `RequestID` int NOT NULL AUTO_INCREMENT,
  `PlayerID` int NOT NULL,
  `SessionID` int NOT NULL,
  `OrganizerID` int NOT NULL,
  `Status` varchar(50) DEFAULT 'Pending',
  `Message` varchar(500) DEFAULT NULL,
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`RequestID`),
  KEY `PlayerID` (`PlayerID`),
  KEY `SessionID` (`SessionID`),
  KEY `OrganizerID` (`OrganizerID`),
  CONSTRAINT `joinrequest_ibfk_1` FOREIGN KEY (`PlayerID`) REFERENCES `player` (`PlayerID`),
  CONSTRAINT `joinrequest_ibfk_2` FOREIGN KEY (`SessionID`) REFERENCES `basketballsession` (`SessionID`),
  CONSTRAINT `joinrequest_ibfk_3` FOREIGN KEY (`OrganizerID`) REFERENCES `gameorganizer` (`OrganizerID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joinrequest`
--

LOCK TABLES `joinrequest` WRITE;
/*!40000 ALTER TABLE `joinrequest` DISABLE KEYS */;
INSERT INTO `joinrequest` VALUES (1,1,2,2,'Approved','Would love to join','2026-03-28 10:00:00'),(3,3,5,5,'Approved','Count me in','2026-03-30 09:00:00'),(4,4,3,3,'Denied','Can I play?','2026-03-14 08:00:00'),(5,5,1,1,'Pending','Any spots left?','2026-03-29 14:00:00'),(6,6,6,1,'Approved','Ready to play','2026-04-01 08:00:00'),(7,7,7,2,'Pending','New player here','2026-04-02 09:00:00'),(8,8,9,4,'Approved','Sign me up','2026-04-03 10:00:00'),(9,9,10,5,'Denied','Too far','2026-04-04 11:00:00'),(10,10,12,2,'Approved','Lets go','2026-04-05 12:00:00'),(11,11,14,4,'Pending','First time','2026-04-06 13:00:00'),(12,12,15,5,'Approved','Excited','2026-04-07 14:00:00'),(13,13,16,1,'Pending','Can I come?','2026-04-08 15:00:00'),(14,14,19,4,'Approved','On my way','2026-04-09 16:00:00'),(15,15,20,5,'Denied','Full?','2026-04-10 17:00:00'),(16,16,1,1,'Approved','Sounds fun','2026-03-30 08:00:00'),(17,17,2,2,'Pending','Room for one?','2026-03-31 09:00:00'),(18,18,5,5,'Approved','Im in','2026-04-01 10:00:00'),(19,19,6,1,'Pending','Please accept','2026-04-02 11:00:00'),(20,20,7,2,'Approved','Cant wait','2026-04-03 12:00:00');
/*!40000 ALTER TABLE `joinrequest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `moderator`
--

DROP TABLE IF EXISTS `moderator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `moderator` (
  `ModeratorID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `AccessLevel` varchar(50) DEFAULT NULL,
  `DisputeNotes` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`ModeratorID`),
  UNIQUE KEY `UserID` (`UserID`),
  CONSTRAINT `moderator_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `moderator`
--

LOCK TABLES `moderator` WRITE;
/*!40000 ALTER TABLE `moderator` DISABLE KEYS */;
INSERT INTO `moderator` VALUES (1,1,'Senior','Handles escalations'),(2,2,'Junior','In training'),(3,3,'Senior','Conduct issues'),(4,4,'Mid','General moderation'),(5,5,'Junior','New moderator');
/*!40000 ALTER TABLE `moderator` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification`
--

DROP TABLE IF EXISTS `notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification` (
  `NotifID` int NOT NULL AUTO_INCREMENT,
  `ReceiverID` int NOT NULL,
  `Type` varchar(50) DEFAULT NULL,
  `Message` varchar(500) DEFAULT NULL,
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `isRead` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`NotifID`),
  KEY `ReceiverID` (`ReceiverID`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`ReceiverID`) REFERENCES `player` (`PlayerID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification`
--

LOCK TABLES `notification` WRITE;
/*!40000 ALTER TABLE `notification` DISABLE KEYS */;
INSERT INTO `notification` VALUES (1,1,'Reminder','Game tomorrow at 6pm','2026-03-31 12:00:00',0),(2,2,'Approval','Your request was approved','2026-03-28 10:30:00',1),(3,3,'Update','Game location changed','2026-03-29 15:00:00',0),(4,4,'Denial','Your request was denied','2026-03-14 09:00:00',1),(5,5,'Reminder','Game this Saturday','2026-04-03 08:00:00',0),(6,6,'Approval','You are in for Friday','2026-04-01 09:00:00',1),(7,7,'Reminder','Game starts at 5pm','2026-04-06 07:00:00',0),(8,8,'Update','Court changed to YMCA','2026-04-03 11:00:00',1),(9,9,'Denial','Session is full','2026-04-04 12:00:00',1),(10,10,'Approval','Welcome to the game','2026-04-05 13:00:00',0),(11,11,'Reminder','Dont forget your shoes','2026-04-06 14:00:00',0),(12,12,'Approval','See you Saturday','2026-04-07 15:00:00',1),(13,13,'Update','Time changed to 11am','2026-04-08 16:00:00',0),(14,14,'Approval','Confirmed for Sunday','2026-04-09 17:00:00',1),(15,15,'Denial','Skill level mismatch','2026-04-10 18:00:00',1),(16,16,'Reminder','Bring water','2026-03-30 09:00:00',0),(17,17,'Update','Game moved indoors','2026-03-31 10:00:00',0),(18,18,'Approval','You are confirmed','2026-04-01 11:00:00',1),(19,19,'Reminder','Game in 2 hours','2026-04-02 12:00:00',0),(20,20,'Approval','Roster spot saved','2026-04-03 13:00:00',1);
/*!40000 ALTER TABLE `notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `player`
--

DROP TABLE IF EXISTS `player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `player` (
  `PlayerID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `SkillLevel` varchar(50) DEFAULT NULL,
  `Position` varchar(50) DEFAULT NULL,
  `GamesPlayed` int DEFAULT '0',
  `Stats` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`PlayerID`),
  UNIQUE KEY `UserID` (`UserID`),
  CONSTRAINT `player_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `user` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `player`
--

LOCK TABLES `player` WRITE;
/*!40000 ALTER TABLE `player` DISABLE KEYS */;
INSERT INTO `player` VALUES (1,1,'Beginner','Point Guard',5,'8 PPG'),(2,2,'Intermediate','Center',12,'11 PPG'),(3,3,'Advanced','Forward',20,'15 PPG'),(4,4,'Beginner','Guard',3,'6 PPG'),(5,5,'Intermediate','Forward',10,'9 PPG'),(6,6,'Advanced','Center',25,'14 PPG'),(7,7,'Beginner','Guard',2,'4 PPG'),(8,8,'Intermediate','Forward',15,'10 PPG'),(9,9,'Advanced','Point Guard',30,'17 PPG'),(10,10,'Beginner','Center',4,'5 PPG'),(11,11,'Intermediate','Guard',8,'7 PPG'),(12,12,'Advanced','Forward',22,'13 PPG'),(13,13,'Beginner','Center',1,'3 PPG'),(14,14,'Intermediate','Point Guard',11,'9 PPG'),(15,15,'Advanced','Guard',18,'12 PPG'),(16,16,'Beginner','Forward',6,'7 PPG'),(17,17,'Intermediate','Center',9,'8 PPG'),(18,18,'Advanced','Guard',28,'16 PPG'),(19,19,'Beginner','Forward',3,'5 PPG'),(20,20,'Intermediate','Point Guard',14,'10 PPG');
/*!40000 ALTER TABLE `player` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `playerrating`
--

DROP TABLE IF EXISTS `playerrating`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `playerrating` (
  `RatingID` int NOT NULL AUTO_INCREMENT,
  `RaterID` int NOT NULL,
  `RatedID` int NOT NULL,
  `SessionID` int NOT NULL,
  `Score` int DEFAULT NULL,
  `Comments` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`RatingID`),
  KEY `RaterID` (`RaterID`),
  KEY `RatedID` (`RatedID`),
  KEY `SessionID` (`SessionID`),
  CONSTRAINT `playerrating_ibfk_1` FOREIGN KEY (`RaterID`) REFERENCES `player` (`PlayerID`),
  CONSTRAINT `playerrating_ibfk_2` FOREIGN KEY (`RatedID`) REFERENCES `user` (`UserID`),
  CONSTRAINT `playerrating_ibfk_3` FOREIGN KEY (`SessionID`) REFERENCES `basketballsession` (`SessionID`),
  CONSTRAINT `playerrating_chk_1` CHECK ((`Score` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `playerrating`
--

LOCK TABLES `playerrating` WRITE;
/*!40000 ALTER TABLE `playerrating` DISABLE KEYS */;
INSERT INTO `playerrating` VALUES (1,1,2,3,5,'Great player'),(2,2,1,3,4,'Good teamwork'),(3,3,4,3,3,'Average'),(4,4,3,3,5,'Very skilled'),(5,5,1,3,4,'Solid effort'),(6,10,2,8,1,'horrible');
/*!40000 ALTER TABLE `playerrating` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `Phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'john','pass1','john@email.com','555-0001'),(2,'ana','pass2','ana@email.com','555-0002'),(3,'susan','pass3','susan@email.com','555-0003'),(4,'mike','pass4','mike@email.com','555-0004'),(5,'lisa','pass5','lisa@email.com','555-0005'),(6,'tom','pass6','tom@email.com','555-0006'),(7,'sara','pass7','sara@email.com','555-0007'),(8,'dave','pass8','dave@email.com','555-0008'),(9,'emma','pass9','emma@email.com','555-0009'),(10,'ryan','pass10','ryan@email.com','555-0010'),(11,'kate','pass11','kate@email.com','555-0011'),(12,'jack','pass12','jack@email.com','555-0012'),(13,'nina','pass13','nina@email.com','555-0013'),(14,'alex','pass14','alex@email.com','555-0014'),(15,'beth','pass15','beth@email.com','555-0015'),(16,'cole','pass16','cole@email.com','555-0016'),(17,'amy','pass17','amy@email.com','555-0017'),(18,'drew','pass18','drew@email.com','555-0018'),(19,'jill','pass19','jill@email.com','555-0019'),(20,'mark','pass20','mark@email.com','555-0020');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userreport`
--

DROP TABLE IF EXISTS `userreport`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `userreport` (
  `ReportID` int NOT NULL AUTO_INCREMENT,
  `ReporterID` int NOT NULL,
  `ReportedID` int NOT NULL,
  `ModeratorID` int DEFAULT NULL,
  `Description` varchar(500) DEFAULT NULL,
  `Status` varchar(50) DEFAULT 'Pending',
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ReportID`),
  KEY `ReporterID` (`ReporterID`),
  KEY `ReportedID` (`ReportedID`),
  KEY `ModeratorID` (`ModeratorID`),
  CONSTRAINT `userreport_ibfk_1` FOREIGN KEY (`ReporterID`) REFERENCES `player` (`PlayerID`),
  CONSTRAINT `userreport_ibfk_2` FOREIGN KEY (`ReportedID`) REFERENCES `user` (`UserID`),
  CONSTRAINT `userreport_ibfk_3` FOREIGN KEY (`ModeratorID`) REFERENCES `moderator` (`ModeratorID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userreport`
--

LOCK TABLES `userreport` WRITE;
/*!40000 ALTER TABLE `userreport` DISABLE KEYS */;
INSERT INTO `userreport` VALUES (1,1,4,1,'Unsportsmanlike conduct','Resolved','2026-03-16 10:00:00'),(2,2,4,2,'Verbal abuse','Pending','2026-03-16 11:00:00'),(3,3,1,NULL,'Late to game','Pending','2026-03-17 09:00:00'),(4,4,2,3,'Rough play','Resolved','2026-03-18 14:00:00'),(5,5,3,NULL,'No-show','Pending','2026-03-19 08:00:00');
/*!40000 ALTER TABLE `userreport` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-02 15:32:52
