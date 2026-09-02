-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 27, 2026 at 04:40 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ecocycle`
--

-- --------------------------------------------------------

--
-- Table structure for table `badges`
--

CREATE TABLE `badges` (
  `id` int(11) NOT NULL,
  `code` varchar(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `description` varchar(200) NOT NULL,
  `icon` varchar(10) NOT NULL DEFAULT '?'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `badges`
--

INSERT INTO `badges` (`id`, `code`, `name`, `description`, `icon`) VALUES
(1, 'first_log', 'First Steps', 'Logged your very first recycling entry.', '🌱'),
(2, 'streak_7', 'Week Warrior', 'Maintained a 7-day recycling streak.', '🔥'),
(3, 'kg_100', 'Century Diverter', 'Diverted 100 kg of material from landfill.', '🏆'),
(4, 'points_1000', 'Point Collector', 'Earned 1,000 lifetime EcoPoints.', '⭐'),
(5, 'all_materials', 'Sorting Master', 'Recycled at least one item of every material type.', '🧭');

-- --------------------------------------------------------

--
-- Table structure for table `partners`
--

CREATE TABLE `partners` (
  `id` int(11) NOT NULL,
  `business_name` varchar(150) NOT NULL,
  `category` varchar(60) NOT NULL,
  `contact_info` varchar(190) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `partners`
--

INSERT INTO `partners` (`id`, `business_name`, `category`, `contact_info`) VALUES
(1, 'Bean & Leaf Café', 'Food & Drink', 'hello@beanandleaf.example'),
(2, 'Verde Grocery Co-op', 'Grocery', 'support@verdegrocery.example'),
(3, 'ReWear Thrift', 'Retail', 'contact@rewear.example'),
(4, 'SolarWorks', 'Eco Products', 'info@solarworks.example'),
(5, 'City Tree Fund', 'Donation', 'give@citytreefund.example');

-- --------------------------------------------------------

--
-- Table structure for table `recycling_logs`
--

CREATE TABLE `recycling_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `material_type` varchar(30) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `weight_kg` decimal(8,2) NOT NULL DEFAULT 0.00,
  `points_awarded` int(11) NOT NULL DEFAULT 0,
  `co2_saved_kg` decimal(8,2) NOT NULL DEFAULT 0.00,
  `verification_status` enum('verified','pending') NOT NULL DEFAULT 'verified',
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recycling_logs`
--

INSERT INTO `recycling_logs` (`id`, `user_id`, `material_type`, `quantity`, `weight_kg`, `points_awarded`, `co2_saved_kg`, `verification_status`, `note`, `created_at`) VALUES
(13, 3, 'metal', 1, 1.23, 15, 4.92, 'verified', NULL, '2026-07-05 22:06:07'),
(14, 3, 'ewaste', 1, 2.81, 42, 5.62, 'verified', NULL, '2026-07-04 22:06:07'),
(15, 3, 'ewaste', 1, 3.20, 48, 6.40, 'verified', NULL, '2026-07-10 22:06:07'),
(16, 3, 'plastic', 1, 1.34, 13, 2.01, 'verified', NULL, '2026-07-11 22:06:07'),
(17, 3, 'organic', 1, 2.55, 10, 1.28, 'verified', NULL, '2026-07-12 22:06:07'),
(18, 3, 'metal', 1, 2.20, 26, 8.80, 'verified', NULL, '2026-07-09 22:06:07'),
(19, 3, 'ewaste', 1, 2.18, 33, 4.36, 'verified', NULL, '2026-07-14 22:06:07'),
(20, 4, 'organic', 1, 1.49, 6, 0.75, 'verified', NULL, '2026-07-02 22:06:07'),
(21, 4, 'glass', 1, 3.34, 20, 1.00, 'verified', NULL, '2026-07-14 22:06:07'),
(22, 4, 'metal', 1, 3.59, 43, 14.36, 'verified', NULL, '2026-07-06 22:06:07'),
(23, 4, 'ewaste', 1, 3.49, 52, 6.98, 'verified', NULL, '2026-07-03 22:06:07'),
(24, 4, 'paper', 1, 0.92, 5, 0.83, 'verified', NULL, '2026-07-05 22:06:07'),
(25, 4, 'paper', 1, 1.28, 6, 1.15, 'verified', NULL, '2026-07-13 22:06:07'),
(26, 4, 'paper', 1, 3.96, 20, 3.56, 'verified', NULL, '2026-07-18 22:06:07'),
(27, 4, 'organic', 1, 1.16, 5, 0.58, 'verified', NULL, '2026-07-14 22:06:07'),
(28, 4, 'glass', 1, 1.81, 11, 0.54, 'verified', NULL, '2026-07-21 22:06:07'),
(29, 4, 'plastic', 1, 2.59, 26, 3.89, 'verified', NULL, '2026-07-18 22:06:07'),
(30, 4, 'ewaste', 1, 2.14, 32, 4.28, 'verified', NULL, '2026-07-08 22:06:07'),
(31, 5, 'plastic', 1, 2.74, 27, 4.11, 'verified', NULL, '2026-07-20 22:06:07'),
(32, 5, 'organic', 1, 3.55, 14, 1.78, 'verified', NULL, '2026-07-06 22:06:07'),
(33, 5, 'paper', 1, 2.82, 14, 2.54, 'verified', NULL, '2026-07-06 22:06:07'),
(34, 5, 'paper', 1, 3.04, 15, 2.74, 'verified', NULL, '2026-07-13 22:06:07'),
(35, 5, 'ewaste', 1, 3.87, 58, 7.74, 'verified', NULL, '2026-07-05 22:06:07'),
(36, 5, 'organic', 1, 3.30, 13, 1.65, 'verified', NULL, '2026-07-06 22:06:07'),
(37, 5, 'plastic', 1, 1.76, 18, 2.64, 'verified', NULL, '2026-07-07 22:06:07'),
(38, 5, 'paper', 1, 1.11, 6, 1.00, 'verified', NULL, '2026-07-17 22:06:07'),
(39, 5, 'paper', 1, 1.36, 7, 1.22, 'verified', NULL, '2026-07-07 22:06:07'),
(40, 6, 'ewaste', 1, 1.19, 18, 2.38, 'verified', NULL, '2026-07-13 22:06:07'),
(41, 6, 'glass', 1, 2.36, 14, 0.71, 'verified', NULL, '2026-07-05 22:06:07'),
(42, 6, 'organic', 1, 2.41, 10, 1.21, 'verified', NULL, '2026-07-03 22:06:07'),
(43, 6, 'metal', 1, 1.95, 23, 7.80, 'verified', NULL, '2026-07-06 22:06:07'),
(44, 6, 'paper', 1, 2.07, 10, 1.86, 'verified', NULL, '2026-07-04 22:06:07'),
(45, 6, 'ewaste', 1, 0.58, 9, 1.16, 'verified', NULL, '2026-07-08 22:06:07'),
(46, 7, 'ewaste', 1, 2.23, 33, 4.46, 'verified', NULL, '2026-07-17 22:06:07'),
(47, 7, 'organic', 1, 0.40, 2, 0.20, 'verified', NULL, '2026-07-03 22:06:07'),
(48, 7, 'glass', 1, 1.39, 8, 0.42, 'verified', NULL, '2026-07-05 22:06:07'),
(49, 7, 'paper', 1, 2.26, 11, 2.03, 'verified', NULL, '2026-07-15 22:06:07'),
(50, 7, 'ewaste', 1, 1.59, 24, 3.18, 'verified', NULL, '2026-07-18 22:06:07'),
(51, 7, 'paper', 1, 3.41, 17, 3.07, 'verified', NULL, '2026-07-07 22:06:07'),
(52, 8, 'glass', 1, 1.61, 10, 0.48, 'verified', NULL, '2026-07-04 22:06:07'),
(53, 8, 'ewaste', 1, 2.72, 41, 5.44, 'verified', NULL, '2026-07-10 22:06:07'),
(54, 8, 'ewaste', 1, 3.33, 50, 6.66, 'verified', NULL, '2026-07-14 22:06:07'),
(55, 8, 'glass', 1, 2.39, 14, 0.72, 'verified', NULL, '2026-07-19 22:06:07'),
(56, 8, 'glass', 1, 1.55, 9, 0.47, 'verified', NULL, '2026-07-15 22:06:07'),
(57, 8, 'metal', 1, 0.34, 4, 1.36, 'verified', NULL, '2026-07-22 22:06:07'),
(58, 8, 'organic', 1, 0.30, 1, 0.15, 'verified', NULL, '2026-07-10 22:06:07'),
(59, 8, 'glass', 1, 3.78, 23, 1.13, 'verified', NULL, '2026-07-09 22:06:07'),
(60, 8, 'organic', 1, 0.99, 4, 0.50, 'verified', NULL, '2026-07-22 22:06:07'),
(61, 8, 'plastic', 1, 3.76, 38, 5.64, 'verified', NULL, '2026-07-18 22:06:07'),
(62, 8, 'organic', 1, 0.64, 3, 0.32, 'verified', NULL, '2026-07-03 22:06:07'),
(63, 8, 'plastic', 1, 2.72, 27, 4.08, 'verified', NULL, '2026-07-03 22:06:07');

-- --------------------------------------------------------

--
-- Table structure for table `redemptions`
--

CREATE TABLE `redemptions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `reward_id` int(11) NOT NULL,
  `redemption_code` varchar(20) NOT NULL,
  `points_spent` int(11) NOT NULL,
  `status` enum('active','used','expired') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rewards`
--

CREATE TABLE `rewards` (
  `id` int(11) NOT NULL,
  `partner_id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `description` varchar(400) NOT NULL,
  `category` varchar(60) NOT NULL DEFAULT 'discount',
  `points_cost` int(11) NOT NULL,
  `quantity_available` int(11) NOT NULL DEFAULT 100,
  `expiry_date` date DEFAULT NULL,
  `icon` varchar(10) NOT NULL DEFAULT '?'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rewards`
--

INSERT INTO `rewards` (`id`, `partner_id`, `title`, `description`, `category`, `points_cost`, `quantity_available`, `expiry_date`, `icon`) VALUES
(1, 1, 'Free Regular Coffee', 'Redeem for one free regular coffee at Bean & Leaf Café.', 'discount', 250, 200, '2027-12-31', '☕'),
(2, 1, '20% Off Any Pastry', 'Enjoy 20% off any freshly baked pastry.', 'discount', 150, 300, '2027-12-31', '🥐'),
(3, 2, '$5 Off Groceries', 'Take $5 off a grocery order of $30 or more at Verde Grocery Co-op.', 'discount', 400, 150, '2027-12-31', '🛒'),
(4, 2, 'Reusable Produce Bag Set', 'A set of 3 organic-cotton mesh produce bags.', 'eco-product', 600, 80, '2027-12-31', '🥬'),
(5, 3, '15% Off Second-Hand Finds', 'Save 15% on your next thrift haul at ReWear.', 'discount', 300, 120, '2027-12-31', '👕'),
(6, 4, 'Solar Phone Charger', 'Compact solar-powered phone charger from SolarWorks.', 'eco-product', 1500, 40, '2027-12-31', '🔋'),
(7, 5, 'Plant a Tree (Donate)', 'Convert 500 points into a real tree planted by the City Tree Fund.', 'donation', 500, 9999, NULL, '🌳'),
(8, 5, 'Fund a Community Compost', 'Donate points toward a neighborhood composting station.', 'donation', 800, 9999, NULL, '♻️');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `neighborhood` varchar(120) NOT NULL DEFAULT 'Greendale',
  `points_balance` int(11) NOT NULL DEFAULT 0,
  `total_points` int(11) NOT NULL DEFAULT 0,
  `streak_count` int(11) NOT NULL DEFAULT 0,
  `last_log_date` date DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `neighborhood`, `points_balance`, `total_points`, `streak_count`, `last_log_date`, `is_admin`, `created_at`) VALUES
(3, 'Maya Chen', 'maya@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Greendale', 187, 187, 3, NULL, 0, '2026-07-22 22:06:07'),
(4, 'Leo Martins', 'leo@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Riverside', 226, 226, 8, NULL, 0, '2026-07-22 22:06:07'),
(5, 'Aisha Khan', 'aisha@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Greendale', 172, 172, 2, NULL, 0, '2026-07-22 22:06:07'),
(6, 'Tom Becker', 'tom@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Hillcrest', 84, 84, 5, NULL, 0, '2026-07-22 22:06:07'),
(7, 'Sofia Rossi', 'sofia@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Riverside', 95, 95, 5, NULL, 0, '2026-07-22 22:06:07'),
(8, 'Noah Williams', 'noah@example.com', '$2y$10$dLjzGoVOSq44YWzCPbxlEuYXjJ3LcvFxmmZvR1Qbn18swA5H.sxvi', 'Hillcrest', 224, 224, 2, NULL, 0, '2026-07-22 22:06:07'),
(9, 'zyk xylo granada', 'yamashirou.06@gmail.com', '$2y$10$ESLinQiuqtJEO2OOi8/pWedMKV9syQHSPjg6d2AjrYPzFH0oHFDpC', 'Banago', 0, 0, 0, NULL, 0, '2026-07-22 22:11:59'),
(10, 'Zyk Granada', 'zyk.granada@ecocycle.local', '$2y$10$bNqe98dgs5j3YZUTlrtpa.Fi1nXM5KLP3V4u7PPhoTVIeFZAM8hky', 'Greendale', 0, 0, 0, NULL, 1, '2026-07-22 22:19:43');

-- --------------------------------------------------------

--
-- Table structure for table `user_badges`
--

CREATE TABLE `user_badges` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `badge_id` int(11) NOT NULL,
  `awarded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_badges`
--

INSERT INTO `user_badges` (`id`, `user_id`, `badge_id`, `awarded_at`) VALUES
(15, 3, 1, '2026-07-22 22:06:07'),
(16, 4, 1, '2026-07-22 22:06:07'),
(17, 4, 2, '2026-07-22 22:06:07'),
(18, 4, 5, '2026-07-22 22:06:07'),
(19, 5, 1, '2026-07-22 22:06:07'),
(20, 6, 1, '2026-07-22 22:06:07'),
(21, 7, 1, '2026-07-22 22:06:07'),
(22, 8, 1, '2026-07-22 22:06:07');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `badges`
--
ALTER TABLE `badges`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `partners`
--
ALTER TABLE `partners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recycling_logs`
--
ALTER TABLE `recycling_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_log_user` (`user_id`);

--
-- Indexes for table `redemptions`
--
ALTER TABLE `redemptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `redemption_code` (`redemption_code`),
  ADD KEY `fk_redeem_user` (`user_id`),
  ADD KEY `fk_redeem_reward` (`reward_id`);

--
-- Indexes for table `rewards`
--
ALTER TABLE `rewards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_reward_partner` (`partner_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_badge` (`user_id`,`badge_id`),
  ADD KEY `fk_ub_badge` (`badge_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `badges`
--
ALTER TABLE `badges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `partners`
--
ALTER TABLE `partners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `recycling_logs`
--
ALTER TABLE `recycling_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `redemptions`
--
ALTER TABLE `redemptions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `rewards`
--
ALTER TABLE `rewards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_badges`
--
ALTER TABLE `user_badges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `recycling_logs`
--
ALTER TABLE `recycling_logs`
  ADD CONSTRAINT `fk_log_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `redemptions`
--
ALTER TABLE `redemptions`
  ADD CONSTRAINT `fk_redeem_reward` FOREIGN KEY (`reward_id`) REFERENCES `rewards` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_redeem_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rewards`
--
ALTER TABLE `rewards`
  ADD CONSTRAINT `fk_reward_partner` FOREIGN KEY (`partner_id`) REFERENCES `partners` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD CONSTRAINT `fk_ub_badge` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ub_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
