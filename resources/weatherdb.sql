-- MySQL dump 10.13  Distrib 8.0.39, for macos14.4 (arm64)
--
-- Host: localhost    Database: WEATHER
-- ------------------------------------------------------
-- Server version	8.0.39

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
-- Current Database: `WEATHER`
--

/*!40000 DROP DATABASE IF EXISTS `WEATHER`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `WEATHER` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `WEATHER`;

--
-- Table structure for table `CURRENT_CONDITIONS`
--

DROP TABLE IF EXISTS `CURRENT_CONDITIONS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CURRENT_CONDITIONS` (
  `current_conditions_id` int unsigned NOT NULL AUTO_INCREMENT,
  `area_id` tinyint unsigned NOT NULL,
  `weather_code_id` smallint unsigned NOT NULL,
  `feels_likeC` tinyint(1) NOT NULL,
  `feels_likeF` tinyint(1) NOT NULL,
  `cloudcover` tinyint(1) NOT NULL,
  `humidity` tinyint(1) NOT NULL,
  `localObsDateTime` varchar(20) NOT NULL,
  `observation_time` varchar(10) NOT NULL,
  `precipInches` float(3,1) unsigned NOT NULL,
  `precipMM` float(3,1) unsigned NOT NULL,
  `pressure` smallint NOT NULL,
  `pressureInches` tinyint(1) NOT NULL,
  `temp_C` tinyint(1) NOT NULL,
  `temp_F` tinyint(1) NOT NULL,
  `uvIndex` tinyint unsigned NOT NULL,
  `visibility` tinyint unsigned NOT NULL,
  `visibilityMiles` tinyint unsigned NOT NULL,
  `winddir16Pt` char(3) NOT NULL,
  `winddirDegree` smallint unsigned NOT NULL,
  `windspeedKmph` tinyint unsigned NOT NULL,
  `windspeedMiles` tinyint unsigned NOT NULL,
  PRIMARY KEY (`current_conditions_id`),
  UNIQUE KEY `conditions_id_UNIQUE` (`current_conditions_id`),
  KEY `FK_area_id_idx` (`area_id`),
  KEY `FK_current_conditions_weather_code_id_idx` (`weather_code_id`),
  CONSTRAINT `FK_current_conditions_area_id` FOREIGN KEY (`area_id`) REFERENCES `NEAREST_AREA` (`area_id`),
  CONSTRAINT `FK_current_conditions_weather_code_id` FOREIGN KEY (`weather_code_id`) REFERENCES `WEATHER_CODE` (`weather_code_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `DAILY_FORECAST`
--

DROP TABLE IF EXISTS `DAILY_FORECAST`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DAILY_FORECAST` (
  `current_conditions_id` int unsigned NOT NULL,
  `forecast_day` tinyint unsigned NOT NULL,
  `area_id` tinyint unsigned NOT NULL,
  `avgTempC` tinyint(1) NOT NULL,
  `avgTempF` tinyint(1) NOT NULL,
  `forecast_date` varchar(10) NOT NULL,
  `maxTempC` tinyint(1) NOT NULL,
  `maxTempF` tinyint(1) NOT NULL,
  `minTempC` tinyint(1) NOT NULL,
  `minTempF` tinyint(1) NOT NULL,
  `sunHour` float(3,1) unsigned NOT NULL,
  `totalSnow_cm` float(3,1) unsigned NOT NULL,
  `uvIndex` tinyint unsigned NOT NULL,
  PRIMARY KEY (`current_conditions_id`,`forecast_day`),
  KEY `idx_forecast_day` (`forecast_day`),
  KEY `FK_area_id_idx` (`area_id`),
  CONSTRAINT `FK_daily_forecast_area_id` FOREIGN KEY (`area_id`) REFERENCES `NEAREST_AREA` (`area_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_daily_forecast_current_conditions` FOREIGN KEY (`current_conditions_id`) REFERENCES `CURRENT_CONDITIONS` (`current_conditions_id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `HOURLY_FORECAST`
--

DROP TABLE IF EXISTS `HOURLY_FORECAST`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `HOURLY_FORECAST` (
  `current_conditions_id` int unsigned NOT NULL,
  `forecast_day` tinyint unsigned NOT NULL,
  `hour` smallint NOT NULL,
  `area_id` tinyint unsigned NOT NULL,
  `weather_code_id` smallint unsigned NOT NULL,
  `dewPointC` tinyint(1) NOT NULL,
  `dewPointF` tinyint(1) NOT NULL,
  `feelsLikeC` tinyint(1) NOT NULL,
  `feelsLikeF` tinyint(1) NOT NULL,
  `heatIndexC` tinyint(1) NOT NULL,
  `heatIndexF` tinyint(1) NOT NULL,
  `windChillC` tinyint(1) NOT NULL,
  `windChillF` tinyint(1) NOT NULL,
  `windGustKmph` tinyint(1) NOT NULL,
  `windGustMiles` tinyint(1) NOT NULL,
  `chanceoffog` tinyint unsigned NOT NULL,
  `chanceoffrost` tinyint unsigned NOT NULL,
  `chanceofhightemp` tinyint unsigned NOT NULL,
  `chanceofovercast` tinyint unsigned NOT NULL,
  `chanceofrain` tinyint unsigned NOT NULL,
  `chanceofremdry` tinyint unsigned NOT NULL,
  `chanceofsnow` tinyint unsigned NOT NULL,
  `chanceofsunshine` tinyint unsigned NOT NULL,
  `chanceofthunder` tinyint unsigned NOT NULL,
  `chanceofwindy` tinyint unsigned NOT NULL,
  `cloudcover` tinyint unsigned NOT NULL,
  `diffRad` float(5,1) NOT NULL,
  `humidity` tinyint unsigned NOT NULL,
  `precipInches` float(3,1) unsigned NOT NULL,
  `precipMM` float(3,1) unsigned NOT NULL,
  `pressure` smallint unsigned NOT NULL,
  `pressureInches` tinyint unsigned NOT NULL,
  `shortRad` float(5,1) NOT NULL,
  `tempC` tinyint(1) NOT NULL,
  `tempF` tinyint(1) NOT NULL,
  `uvIndex` tinyint unsigned NOT NULL,
  `visibility` tinyint unsigned NOT NULL,
  `visibilityMiles` tinyint unsigned NOT NULL,
  `winddir16Pt` char(3) NOT NULL,
  `winddirDegree` smallint unsigned NOT NULL,
  `windspeedKmph` tinyint unsigned NOT NULL,
  `windspeedMiles` tinyint unsigned NOT NULL,
  PRIMARY KEY (`current_conditions_id`,`forecast_day`,`hour`),
  KEY `FK_forecast_day_idx` (`forecast_day`),
  KEY `FK_area_id_idx` (`area_id`),
  KEY `FK_hourly_forecast_weather_code_id_idx` (`weather_code_id`),
  CONSTRAINT `FK_forecast_day` FOREIGN KEY (`forecast_day`) REFERENCES `DAILY_FORECAST` (`forecast_day`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_hourly_forecast_area_id` FOREIGN KEY (`area_id`) REFERENCES `NEAREST_AREA` (`area_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_hourly_forecast_current_conditions` FOREIGN KEY (`current_conditions_id`) REFERENCES `CURRENT_CONDITIONS` (`current_conditions_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_hourly_forecast_weather_code_id` FOREIGN KEY (`weather_code_id`) REFERENCES `WEATHER_CODE` (`weather_code_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `NEAREST_AREA`
--

DROP TABLE IF EXISTS `NEAREST_AREA`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `NEAREST_AREA` (
  `area_id` tinyint unsigned NOT NULL AUTO_INCREMENT,
  `country` varchar(60) NOT NULL,
  `area_name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `latitude` float(5,3) NOT NULL,
  `longitude` float(6,3) NOT NULL,
  `population` mediumint unsigned NOT NULL,
  PRIMARY KEY (`area_id`),
  UNIQUE KEY `area_id_UNIQUE` (`area_id`),
  UNIQUE KEY `country_area_name_UNIQUE` (`country`,`area_name`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `WEATHER_CODE`
--

DROP TABLE IF EXISTS `WEATHER_CODE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `WEATHER_CODE` (
  `weather_code_id` smallint unsigned NOT NULL,
  `weatherDesc` varchar(25) NOT NULL,
  PRIMARY KEY (`weather_code_id`),
  UNIQUE KEY `weather_code_id_UNIQUE` (`weather_code_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-09-17 12:46:53
