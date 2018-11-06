-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: May 15, 2018 at 10:46 AM
-- Server version: 5.7.21
-- PHP Version: 7.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ctcweb9_trip`
--

-- --------------------------------------------------------

--
-- Table structure for table `changehistory`
--

CREATE TABLE `changehistory` (
  `id` int(11) NOT NULL,
  `tripid` int(11) NOT NULL,
  `memberid` int(11) NOT NULL,
  `timestamp` datetime NOT NULL,
  `guid` char(36) NOT NULL,
  `action` varchar(20) NOT NULL COMMENT 'either ''updatetrip'',''updateparticipant'',''insertparticipant'' or ''email''',
  `column` varchar(50) DEFAULT NULL,
  `line` int(11) DEFAULT NULL COMMENT 'null indicates change to trips table',
  `before` text,
  `after` text,
  `subject` text,
  `body` text,
  `emailAudit` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `edit`
--

CREATE TABLE `edit` (
  `id` int(11) NOT NULL,
  `tripid` int(11) NOT NULL,
  `memberid` int(50) NOT NULL,
  `read` datetime DEFAULT NULL COMMENT 'UTC',
  `current` datetime NOT NULL COMMENT 'UTC',
  `isDirty` bit(1) NOT NULL DEFAULT b'0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `participants`
--

CREATE TABLE `participants` (
  `id` int(11) NOT NULL COMMENT 'READONLY',
  `tripid` int(11) NOT NULL COMMENT 'READONLY',
  `line` int(11) NOT NULL DEFAULT '0' COMMENT 'READONLY',
  `isRemoved` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Removed',
  `memberid` int(11) DEFAULT NULL,
  `isLeader` tinyint(1) NOT NULL COMMENT 'Leader',
  `name` varchar(50) DEFAULT NULL COMMENT 'Name -- if null use value from ctcweb9_ctc.members',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email -- if null use the primaryEmail value from from ctcweb9_ctc.members table',
  `phone` varchar(20) DEFAULT NULL COMMENT 'Phone -- if null use the homePhone from from ctcweb9_ctc.memberships table',
  `isVehicleProvider` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Car?',
  `vehicleRego` varchar(10) DEFAULT NULL COMMENT 'Rego',
  `status` text COMMENT 'Status',
  `isEmailPending` tinyint(1) NOT NULL DEFAULT '0',
  `isPLBProvider` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Does this participant plan on bringing a PLB on the trip'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `trips`
--

CREATE TABLE `trips` (
  `id` int(11) NOT NULL COMMENT 'READONLY',
  `eventid` int(11) DEFAULT NULL COMMENT 'READONLY',
  `title` varchar(120) DEFAULT NULL COMMENT 'Title -- if null use the value from from ctcweb9_newsletter.event table',
  `date` date NOT NULL COMMENT 'Date',
  `originalDate` date NOT NULL,
  `length` varchar(50) DEFAULT NULL COMMENT 'Length',
  `departurePoint` varchar(255) DEFAULT NULL COMMENT 'Departure Point -- if null use the value from from ctcweb9_newsletter.event table',
  `grade` varchar(50) DEFAULT NULL COMMENT 'Grade -- if null use the value from from ctcweb9_newsletter.event table',
  `cost` varchar(50) DEFAULT NULL COMMENT 'Cost -- if null use the value from from ctcweb9_newsletter.event table',
  `closeDate` date NOT NULL COMMENT 'Close Date',
  `status` text COMMENT 'Notes -- status text, normally updated by the leader to communicate to participants',
  `mapHtml` text COMMENT 'Map HTML',
  `isAdHoc` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'READONLY',
  `isRemoved` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Deleted flag'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `changehistory`
--
ALTER TABLE `changehistory`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `edit`
--
ALTER TABLE `edit`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tripid` (`tripid`);

--
-- Indexes for table `participants`
--
ALTER TABLE `participants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tripid` (`tripid`,`line`);

--
-- Indexes for table `trips`
--
ALTER TABLE `trips`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `eventid` (`eventid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `changehistory`
--
ALTER TABLE `changehistory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4399;

--
-- AUTO_INCREMENT for table `edit`
--
ALTER TABLE `edit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13945;

--
-- AUTO_INCREMENT for table `participants`
--
ALTER TABLE `participants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'READONLY', AUTO_INCREMENT=1771;

--
-- AUTO_INCREMENT for table `trips`
--
ALTER TABLE `trips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'READONLY', AUTO_INCREMENT=383;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
