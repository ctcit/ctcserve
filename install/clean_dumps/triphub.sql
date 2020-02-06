-- phpMyAdmin SQL Dump
-- version 4.8.1
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Dec 04, 2019 at 08:41 AM
-- Server version: 5.7.22
-- PHP Version: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `triphub`
--
CREATE DATABASE IF NOT EXISTS `triphub` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `triphub`;

-- --------------------------------------------------------

--
-- Table structure for table `edit`
--

CREATE TABLE `edit` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier for the table',
  `tripId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `stamp` datetime NOT NULL COMMENT 'UTC',
  `isEdited` bit(1) NOT NULL DEFAULT b'0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

CREATE TABLE `history` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier for the table',
  `timestamp` datetime NOT NULL,
  `action` text NOT NULL,
  `table` text NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `tripId` int(11) NOT NULL,
  `participantId` int(11) DEFAULT NULL,
  `column` text,
  `before` text,
  `after` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `log`
--

CREATE TABLE `log` (
  `id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `level` text NOT NULL,
  `message` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier for the table',
  `tripId` int(11) NOT NULL,
  `isDeleted` bit(1) NOT NULL DEFAULT b'0',
  `memberId` int(11) DEFAULT NULL,
  `name` text NOT NULL COMMENT 'Name',
  `email` text NOT NULL COMMENT 'Email',
  `phone` text NOT NULL COMMENT 'Phone',
  `isLeader` bit(1) NOT NULL COMMENT 'Leader?',
  `isPlbProvider` bit(1) NOT NULL COMMENT 'PLB?',
  `isVehicleProvider` bit(1) NOT NULL COMMENT 'Has Car?',
  `vehicleRego` text NOT NULL COMMENT 'Car Rego',
  `logisticInfo` text NOT NULL COMMENT 'Logistic Info',
  `displayPriority` double DEFAULT NULL,
  `emergencyContactName` text NOT NULL COMMENT 'Emergency Contact Name',
  `emergencyContactPhone` text NOT NULL COMMENT 'Emergency Contact Phone'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `id` int(11) NOT NULL COMMENT 'Unique identifier for the table',
  `isApproved` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Set when approved by the trip convenor',
  `isDeleted` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Set when deleted',
  `isSocial` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Is Social Event',
  `isNoSignup` bit(1) NOT NULL DEFAULT b'0' COMMENT 'No signup (for social events)',
  `title` varchar(100) NOT NULL COMMENT 'Title',
  `openDate` date NOT NULL COMMENT 'Open Date',
  `closeDate` date NOT NULL COMMENT 'Close Date',
  `tripDate` date NOT NULL COMMENT 'Trip Date',
  `length` tinyint(4) NOT NULL COMMENT 'Length of trip (in days)',
  `departurePoint` varchar(100) NOT NULL COMMENT 'Departure Point',
  `departureDetails` text,
  `map1` text NOT NULL COMMENT 'First map reference',
  `map2` text NOT NULL COMMENT 'Second map reference',
  `map3` text NOT NULL COMMENT 'Third map reference',
  `mapRoute` text NOT NULL,
  `cost` varchar(100) NOT NULL COMMENT 'Cost',
  `grade` varchar(100) NOT NULL COMMENT 'Grade',
  `isLimited` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Has limited number of participants',
  `maxParticipants` tinyint(4) NOT NULL COMMENT 'Maximum number of trampers',
  `description` text NOT NULL COMMENT 'Description',
  `logisticInfo` text NOT NULL COMMENT 'Logistic Information',
  `historyId` int(11) NOT NULL,
  `legacyTripId` int(11) DEFAULT NULL,
  `legacyEventId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vnl_events`
-- (See below for the actual view)
--
CREATE TABLE `vnl_events` (
`dateDisplay` date
,`datePlus` char(0)
,`social` bit(1)
,`trip` int(1)
,`departurePoint` varchar(117)
,`text` text
,`title` varchar(100)
,`grade` varchar(100)
,`leader` text
,`leaderPlus` char(0)
,`leaderPhone` text
,`leaderEmail` text
,`close1` date
,`map1` text
,`cost` varchar(100)
,`issueDate` date
,`isCurrent` tinyint(1)
);

-- --------------------------------------------------------

--
-- Structure for view `vnl_events`
--
DROP TABLE IF EXISTS `vnl_events`;

CREATE ALGORITHM=UNDEFINED DEFINER=`admin`@`%` SQL SECURITY DEFINER VIEW `vnl_events`  AS  select `trips`.`tripDate` AS `dateDisplay`,'' AS `datePlus`,`trips`.`isSocial` AS `social`,if((`trips`.`isSocial` = 1),0,1) AS `trip`,if((isnull(`trips`.`departurePoint`) or (`trips`.`departurePoint` = '')),'',concat('Departure point: ',`trips`.`departurePoint`)) AS `departurePoint`,`trips`.`description` AS `text`,`trips`.`title` AS `title`,`trips`.`grade` AS `grade`,`participants`.`name` AS `leader`,'' AS `leaderPlus`,`participants`.`phone` AS `leaderPhone`,`participants`.`email` AS `leaderEmail`,`trips`.`closeDate` AS `close1`,`trips`.`map1` AS `map1`,`trips`.`cost` AS `cost`,`newsletter`.`newsletters`.`issueDate` AS `issueDate`,`newsletter`.`newsletters`.`isCurrent` AS `isCurrent` from ((`trips` join `participants` on((`trips`.`id` = `participants`.`tripId`))) join `newsletter`.`newsletters`) where ((`participants`.`isLeader` = 1) and (`trips`.`tripDate` >= `newsletter`.`newsletters`.`issueDate`) and `newsletter`.`newsletters`.`isCurrent`) order by `trips`.`tripDate`,`trips`.`length`,`trips`.`title` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `edit`
--
ALTER TABLE `edit`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `history`
--
ALTER TABLE `history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `trip_id` (`tripId`);

--
-- Indexes for table `log`
--
ALTER TABLE `log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `edit`
--
ALTER TABLE `edit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the table';

--
-- AUTO_INCREMENT for table `history`
--
ALTER TABLE `history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the table';

--
-- AUTO_INCREMENT for table `log`
--
ALTER TABLE `log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the table';

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for the table';
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
