-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 29, 2026 at 09:52 AM
-- Server version: 10.11.19-MariaDB
-- PHP Version: 8.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotelpardise_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `approvals`
--

CREATE TABLE `approvals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `entity_type` varchar(120) NOT NULL,
  `entity_id` bigint(20) UNSIGNED NOT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `approver_id` bigint(20) UNSIGNED DEFAULT NULL,
  `approval_level` int(11) DEFAULT 1,
  `status` enum('pending','approved','rejected','cancelled') DEFAULT 'pending',
  `reason` text DEFAULT NULL,
  `requested_at` datetime DEFAULT current_timestamp(),
  `decided_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `staff_id` bigint(20) UNSIGNED NOT NULL,
  `clock_in` datetime DEFAULT NULL,
  `clock_out` datetime DEFAULT NULL,
  `method` varchar(50) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(120) NOT NULL,
  `entity_type` varchar(120) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(64) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `hotel_id`, `user_id`, `action`, `entity_type`, `entity_id`, `old_values`, `new_values`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 1, 'login', 'user', 1, NULL, NULL, '41.210.141.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:35:01'),
(2, 1, 1, 'integrity_scan', 'integrity', NULL, '{\"flags\":0}', NULL, '41.210.141.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:35:36'),
(3, 1, 1, 'login', 'user', 1, NULL, NULL, '41.210.141.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:36:48'),
(4, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.145.172', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:38:19'),
(5, 1, 6, 'reservation_status', 'reservation', 34, '{\"status\":\"pending\"}', '{\"status\":\"confirmed\"}', '41.210.145.172', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:39:55'),
(6, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.155.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:48:39'),
(7, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.155.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:48:41'),
(8, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.155.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:48:42'),
(9, 1, 1, 'login', 'user', 1, NULL, NULL, '41.210.155.145', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 11:52:09'),
(10, 1, 1, 'web_order', 'order', 1, '{\"order_number\":\"ORD-20261009-001\",\"subtotal\":13000,\"service_charge\":455,\"total\":13455,\"customer\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja city\"}', NULL, '41.210.155.238', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 12:18:03'),
(11, 1, 1, 'web_payment', 'payments', 10, '{\"provider_reference\":\"PAY-20261009-001\",\"source\":\"order\",\"reference\":\"ORD-20261009-001\",\"method\":\"card\",\"amount\":13455,\"status\":\"pending\"}', NULL, '41.210.155.238', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-09 12:19:08'),
(12, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.159.35', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:01:13'),
(13, 1, 6, 'logout', 'user', 6, NULL, NULL, '41.210.159.35', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:04:33'),
(14, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.159.35', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:04:49'),
(15, 1, 2, 'logout', 'user', 2, NULL, NULL, '41.210.159.35', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-09 14:06:51'),
(16, 1, NULL, 'web_event', 'event_requests', 1, '{\"request_number\":\"EVT-20261010-001\",\"event_type\":\"Conference \\/ seminar\",\"event_date\":\"2026-10-11\",\"guests\":36,\"venue\":\"The Nile Hall\",\"phone\":\"0772514889\"}', NULL, '102.86.6.39', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-10 12:29:44'),
(17, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.6.39', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-10 12:30:33'),
(18, 1, 2, 'integrity_scan', 'integrity', NULL, '{\"flags\":0}', NULL, '102.86.6.39', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-10 12:32:19'),
(19, 1, 2, 'logout', 'user', 2, NULL, NULL, '102.86.6.39', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-10 12:33:20'),
(20, 1, 1, 'login', 'user', 1, NULL, NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 12:42:57'),
(21, 1, 1, 'login', 'user', 1, NULL, NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 12:43:00'),
(22, 1, 1, 'change_password', 'user', 1, NULL, NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 12:44:38'),
(23, 1, NULL, 'web_order', 'order', 2, '{\"order_number\":\"ORD-20261010-001\",\"subtotal\":15000,\"service_charge\":525,\"total\":15525,\"customer\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"walukuba\"}', NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 16:44:59'),
(24, 1, NULL, 'web_order', 'order', 3, '{\"order_number\":\"ORD-20261010-002\",\"subtotal\":45000,\"service_charge\":1575,\"total\":46575,\"customer\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"Jinja town\"}', NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 16:48:28'),
(25, 1, NULL, 'web_payment', 'payments', 11, '{\"provider_reference\":\"PAY-20261010-001\",\"source\":\"order\",\"reference\":\"ORD-20261010-002\",\"method\":\"mtn_momo\",\"amount\":46575,\"status\":\"pending\"}', NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 16:49:03'),
(26, 1, NULL, 'web_payment_settled', 'payments', 11, '{\"provider_reference\":\"PAY-20261010-001\",\"source\":\"order\",\"reference\":\"ORD-20261010-002\",\"method\":\"mtn_momo\",\"amount\":46575,\"status\":\"successful\"}', NULL, '102.86.6.39', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 16:49:04'),
(27, 1, 1, 'login', 'user', 1, NULL, NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:51:13'),
(28, 1, 1, 'logout', 'user', 1, NULL, NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:51:23'),
(29, 1, 1, 'login', 'user', 1, NULL, NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:51:31'),
(30, 1, 1, 'logout', 'user', 1, NULL, NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:52:19'),
(31, 1, NULL, 'web_payment', 'payments', 12, '{\"provider_reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"reference\":\"HPN-20261010-001\",\"method\":\"mtn_momo\",\"amount\":264960,\"status\":\"pending\"}', NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:54:40'),
(32, 1, NULL, 'web_payment_settled', 'payments', 12, '{\"provider_reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"reference\":\"HPN-20261010-001\",\"method\":\"mtn_momo\",\"amount\":264960,\"status\":\"successful\"}', NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-10 20:54:41'),
(33, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.3.148', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 03:12:11'),
(34, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.143.6', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 09:12:36'),
(35, 1, NULL, 'web_payment', 'payments', 13, '{\"provider_reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"reference\":\"HPN-20261011-002\",\"method\":\"mtn_momo\",\"amount\":324990,\"status\":\"pending\"}', NULL, '41.210.143.202', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-11 09:48:21'),
(36, 1, NULL, 'web_payment_settled', 'payments', 13, '{\"provider_reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"reference\":\"HPN-20261011-002\",\"method\":\"mtn_momo\",\"amount\":324990,\"status\":\"successful\"}', NULL, '41.210.143.202', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-11 09:48:22'),
(37, 1, 1, 'login', 'user', 1, NULL, NULL, '41.75.179.202', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-11 13:24:15'),
(38, 1, NULL, 'web_order', 'order', 4, '{\"order_number\":\"ORD-20261011-001\",\"subtotal\":15000,\"service_charge\":525,\"total\":15525,\"customer\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '41.210.147.80', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-11 14:46:23'),
(39, 1, NULL, 'web_event', 'event_requests', 2, '{\"request_number\":\"EVT-20261011-001\",\"event_type\":\"Team retreat\",\"event_date\":\"2026-10-17\",\"guests\":100,\"venue\":\"The Nile Hall\",\"phone\":\"0772514889\"}', NULL, '41.210.147.80', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-11 14:49:03'),
(40, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.147.80', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-11 14:49:59'),
(41, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.23.138', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 00:41:29'),
(42, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:12:16'),
(43, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:13:24'),
(44, 1, 2, 'logout', 'user', 2, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:18:47'),
(45, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:18:52'),
(46, 1, 2, 'customer_profile_update', 'customers', 1, '{\"id\":1,\"fields\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]}', NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:29:03'),
(47, 1, 2, 'web_order', 'order', 5, '{\"order_number\":\"ORD-20261013-001\",\"subtotal\":30000,\"service_charge\":1050,\"total\":31050,\"customer\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:29:48'),
(48, 1, 10, 'login', 'user', 10, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:35:07'),
(49, 1, 10, 'logout', 'user', 10, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:36:06'),
(50, 1, 5, 'login', 'user', 5, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:37:01'),
(51, 1, 5, 'logout', 'user', 5, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:38:33'),
(52, 1, 4, 'login', 'user', 4, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:39:02'),
(53, 1, 4, 'logout', 'user', 4, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:39:18'),
(54, 1, 13, 'login', 'user', 13, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:39:39'),
(55, 1, 8, 'login', 'user', 8, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:42:38'),
(56, 1, 8, 'logout', 'user', 8, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:43:11'),
(57, 1, 3, 'login', 'user', 3, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:43:35'),
(58, 1, 3, 'invoice_draft', 'invoice', 10, '[]', '{\"billing_name\":\"ReaganSoft Innovation Ltd\"}', '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:45:30'),
(59, 1, 3, 'logout', 'user', 3, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:47:00'),
(60, 1, 11, 'login', 'user', 11, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:47:43'),
(61, 1, 11, 'logout', 'user', 11, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:48:22'),
(62, 1, 12, 'login', 'user', 12, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:49:30'),
(63, 1, 12, 'logout', 'user', 12, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:49:49'),
(64, 1, 7, 'login', 'user', 7, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:50:04'),
(65, 1, 7, 'logout', 'user', 7, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:50:32'),
(66, 1, 9, 'login', 'user', 9, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:50:58'),
(67, 1, 9, 'logout', 'user', 9, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:51:31'),
(68, 1, 6, 'login', 'user', 6, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:52:04'),
(69, 1, 6, 'logout', 'user', 6, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 10:52:22'),
(70, 1, 1, 'login', 'user', 1, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-13 10:58:25'),
(71, 1, 1, 'logout', 'user', 1, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-13 10:58:53'),
(72, 1, NULL, 'web_order', 'order', 6, '{\"order_number\":\"ORD-20261013-002\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '102.86.9.110', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-13 11:19:23'),
(73, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.9.110', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-13 11:19:59'),
(74, 1, 6, 'login', 'user', 6, NULL, NULL, '102.86.26.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:46:40'),
(75, 1, 6, 'logout', 'user', 6, NULL, NULL, '102.86.26.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:47:18'),
(76, 1, 3, 'login', 'user', 3, NULL, NULL, '102.86.26.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:47:37'),
(77, 1, 3, 'reservation_status', 'reservation', 39, '{\"status\":\"pending\"}', '{\"status\":\"cancelled\"}', '102.86.26.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:51:19'),
(78, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.146.214', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 10:06:52'),
(79, 1, 2, 'trash', 'reservations', 39, NULL, NULL, '41.210.146.214', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 10:07:26'),
(80, 1, 1, 'login', 'user', 1, NULL, NULL, '41.210.145.90', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-14 14:24:24'),
(81, 1, 1, 'logout', 'user', 1, NULL, NULL, '41.210.145.90', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-14 14:24:47'),
(82, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.141.42', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 03:37:35'),
(83, 1, 6, 'login', 'user', 6, NULL, NULL, '41.210.141.42', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 03:38:29'),
(84, 1, NULL, 'web_order', 'order', 7, '{\"order_number\":\"ORD-20261015-001\",\"subtotal\":71000,\"service_charge\":2485,\"total\":73485,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '41.210.141.227', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 05:12:43'),
(85, 1, NULL, 'customer_profile_update', 'customers', 1, '{\"id\":1,\"fields\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]}', NULL, '41.210.141.227', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 05:13:14'),
(86, 1, NULL, 'customer_profile_update', 'customers', 1, '{\"id\":1,\"fields\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]}', NULL, '41.210.141.227', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 05:13:34'),
(87, 1, NULL, 'customer_profile_update', 'customers', 1, '{\"id\":1,\"fields\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]}', NULL, '41.210.141.227', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 05:13:37'),
(88, 1, NULL, 'web_order', 'order', 8, '{\"order_number\":\"ORD-20261015-002\",\"subtotal\":50000,\"service_charge\":1750,\"total\":51750,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '102.86.5.1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-15 08:29:11'),
(89, 1, NULL, 'web_order', 'order', 9, '{\"order_number\":\"ORD-20261015-003\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '102.86.5.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 08:31:05'),
(90, 1, NULL, 'web_payment', 'payments', 14, '{\"provider_reference\":\"PAY-20261015-001\",\"source\":\"order\",\"reference\":\"ORD-20261015-003\",\"method\":\"card\",\"amount\":6210,\"status\":\"pending\"}', NULL, '102.86.5.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 09:21:44'),
(91, 1, NULL, 'web_payment_gateway', 'payments', 14, '{\"provider_reference\":\"PAY-20261015-001\",\"gateway\":\"pesapal\",\"tracking_id\":\"4e20c044-bcd2-43a2-8f85-d9c8b786c508\",\"status\":\"pending\"}', NULL, '102.86.5.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 09:21:46'),
(92, 1, NULL, 'web_order', 'order', 10, '{\"order_number\":\"ORD-20261015-004\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:13:18'),
(93, 1, NULL, 'web_payment', 'payments', 15, '{\"provider_reference\":\"PAY-20261015-002\",\"source\":\"order\",\"reference\":\"ORD-20261015-004\",\"method\":\"mtn_momo\",\"amount\":6210,\"status\":\"pending\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:13:31'),
(94, 1, NULL, 'web_payment_gateway', 'payments', 15, '{\"provider_reference\":\"PAY-20261015-002\",\"gateway\":\"pesapal\",\"tracking_id\":\"27311cfd-a6f7-4a5d-88f7-d9c87a7054f3\",\"status\":\"pending\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:13:34'),
(95, 1, 4, 'login', 'user', 4, NULL, NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:15:05'),
(96, 1, NULL, 'logout', 'user', NULL, NULL, NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:58:34'),
(97, 1, NULL, 'web_order', 'order', 11, '{\"order_number\":\"ORD-20261015-005\",\"subtotal\":30000,\"service_charge\":1050,\"total\":31050,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:58:57'),
(98, 1, NULL, 'web_payment', 'payments', 16, '{\"provider_reference\":\"PAY-20261015-003\",\"source\":\"order\",\"reference\":\"ORD-20261015-005\",\"method\":\"card\",\"amount\":31050,\"status\":\"pending\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:59:12'),
(99, 1, NULL, 'web_payment_gateway', 'payments', 16, '{\"provider_reference\":\"PAY-20261015-003\",\"gateway\":\"pesapal\",\"tracking_id\":\"c4337c8c-f453-4dad-84e3-d9c8ed5aa6f6\",\"status\":\"pending\"}', NULL, '102.86.18.168', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 13:59:14'),
(100, 1, NULL, 'payment_settled', 'payments', 16, '{\"provider_reference\":\"PAY-20261015-003\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-15 14:06:22'),
(101, 1, NULL, 'web_order', 'order', 12, '{\"order_number\":\"ORD-20261015-006\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '41.210.145.52', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 16:45:42'),
(102, 1, NULL, 'web_payment', 'payments', 17, '{\"provider_reference\":\"PAY-20261015-004\",\"source\":\"order\",\"reference\":\"ORD-20261015-006\",\"method\":\"mtn_momo\",\"amount\":6210,\"status\":\"pending\"}', NULL, '41.210.145.52', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 16:45:55'),
(103, 1, NULL, 'web_payment_gateway', 'payments', 17, '{\"provider_reference\":\"PAY-20261015-004\",\"gateway\":\"pesapal\",\"tracking_id\":\"085c626b-a3d3-402f-90c8-d9c8cd5b22e7\",\"status\":\"pending\"}', NULL, '41.210.145.52', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 16:45:58'),
(104, 1, NULL, 'payment_settled', 'payments', 17, '{\"provider_reference\":\"PAY-20261015-004\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-15 16:53:24'),
(105, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.145.52', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 16:58:11'),
(106, 1, 2, 'news_create', 'news_posts', 11, '{\"slug\":\"fundraising-meeting\"}', NULL, '41.210.145.52', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 17:04:47'),
(107, 1, NULL, 'web_order', 'order', 13, '{\"order_number\":\"ORD-20261016-001\",\"subtotal\":15000,\"service_charge\":525,\"total\":15525,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '41.210.143.66', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-16 03:41:40'),
(108, 1, NULL, 'web_payment', 'payments', 18, '{\"provider_reference\":\"PAY-20261016-001\",\"source\":\"order\",\"reference\":\"ORD-20261016-001\",\"method\":\"mtn_momo\",\"amount\":15525,\"status\":\"pending\"}', NULL, '41.210.143.13', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-16 03:43:14'),
(109, 1, NULL, 'web_payment_gateway', 'payments', 18, '{\"provider_reference\":\"PAY-20261016-001\",\"gateway\":\"pesapal\",\"tracking_id\":\"bc2818be-cf10-4d14-a8e9-d9c7ce756d17\",\"status\":\"pending\"}', NULL, '41.210.143.13', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36', '2026-10-16 03:43:16'),
(110, 1, NULL, 'payment_settled', 'payments', 18, '{\"provider_reference\":\"PAY-20261016-001\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-16 03:49:32'),
(111, 1, NULL, 'web_payment', 'payments', 19, '{\"provider_reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"reference\":\"HPN-20261016-001\",\"method\":\"mtn_momo\",\"amount\":661365,\"status\":\"pending\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:06:16'),
(112, 1, NULL, 'web_payment_gateway', 'payments', 19, '{\"provider_reference\":\"PAY-20261016-002\",\"gateway\":\"pesapal\",\"tracking_id\":\"a3c09c5f-57fd-4534-83ca-d9c7dbd48267\",\"status\":\"pending\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:06:18'),
(113, 1, NULL, 'payment_settled', 'payments', 19, '{\"provider_reference\":\"PAY-20261016-002\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-16 13:07:01'),
(114, 1, NULL, 'web_order', 'order', 14, '{\"order_number\":\"ORD-20261016-002\",\"subtotal\":30000,\"service_charge\":1050,\"total\":31050,\"customer\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:10:38'),
(115, 1, NULL, 'web_payment', 'payments', 20, '{\"provider_reference\":\"PAY-20261016-003\",\"source\":\"order\",\"reference\":\"ORD-20261016-002\",\"method\":\"mtn_momo\",\"amount\":31050,\"status\":\"pending\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:10:53'),
(116, 1, NULL, 'web_payment_gateway', 'payments', 20, '{\"provider_reference\":\"PAY-20261016-003\",\"gateway\":\"pesapal\",\"tracking_id\":\"dd02f908-a902-46fe-9113-d9c703f67a4c\",\"status\":\"pending\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:10:55'),
(117, 1, NULL, 'payment_settled', 'payments', 20, '{\"provider_reference\":\"PAY-20261016-003\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-16 13:17:21'),
(118, 1, NULL, 'web_event', 'event_requests', 3, '{\"request_number\":\"EVT-20261016-001\",\"event_type\":\"Other\",\"event_date\":\"2026-10-17\",\"guests\":30,\"venue\":\"The Nile Hall\",\"phone\":\"0772514889\"}', NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:19:18'),
(119, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.159.172', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 13:21:15'),
(120, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.22.125', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 18:57:08'),
(121, 1, 2, 'login', 'user', 2, NULL, NULL, '102.86.22.125', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 03:17:32'),
(122, 1, 2, 'logout', 'user', 2, NULL, NULL, '102.86.22.125', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 03:18:52'),
(123, 1, 13, 'login', 'user', 13, NULL, NULL, '102.86.22.125', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 03:19:01'),
(124, 1, 13, 'login', 'user', 13, NULL, NULL, '102.86.22.125', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 06:19:49'),
(125, 1, NULL, 'web_event', 'event_requests', 4, '{\"request_number\":\"EVT-20261017-001\",\"event_type\":\"Birthday party\",\"event_date\":\"2027-06-10\",\"guests\":10,\"venue\":\"The Riverside Gardens\",\"phone\":\"0761080587\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 08:40:12'),
(126, 1, NULL, 'web_payment', 'payments', 21, '{\"provider_reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"reference\":\"HPN-20261017-001\",\"method\":\"mtn_momo\",\"amount\":256680,\"status\":\"pending\"}', NULL, '41.210.159.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 08:41:50'),
(127, 1, NULL, 'web_payment_gateway', 'payments', 21, '{\"provider_reference\":\"PAY-20261017-001\",\"gateway\":\"pesapal\",\"tracking_id\":\"ee1dfc58-a3d2-4bfc-86e5-d9c65f8a9188\",\"status\":\"pending\"}', NULL, '41.210.159.120', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 08:41:52'),
(128, 1, NULL, 'web_enquiry', 'facility_enquiries', 1, '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"phone\":\"0761080587\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 08:43:47'),
(129, 1, NULL, 'web_order', 'order', 15, '{\"order_number\":\"ORD-20261021-001\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.6.1 Mobile/15E148 Safari/604.1', '2026-10-21 11:20:40'),
(130, 1, NULL, 'web_order', 'order', 16, '{\"order_number\":\"ORD-20261021-002\",\"subtotal\":37000,\"service_charge\":1295,\"total\":38295,\"customer\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.4 Mobile/15E148 Safari/604.1', '2026-10-21 11:21:24'),
(131, 1, NULL, 'web_event', 'event_requests', 5, '{\"request_number\":\"EVT-20261025-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-12-20\",\"guests\":200,\"venue\":\"The Nile Hall\",\"phone\":\"0772514889\"}', NULL, '41.210.141.37', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', '2026-10-24 23:25:33'),
(132, 1, NULL, 'web_guest_message', 'guest_messages', 1, '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"room\":\"\",\"rating\":5,\"phone\":\"0772514889\"}', NULL, '41.210.141.37', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Mobile Safari/537.36', '2026-10-24 23:27:42'),
(133, 1, 2, 'login', 'user', 2, NULL, NULL, '41.210.141.44', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-25 12:18:20'),
(134, 1, 4, 'login', 'user', 4, NULL, NULL, '102.86.25.65', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-25 15:24:32'),
(135, 1, 4, 'login', 'user', 4, NULL, NULL, '102.86.25.65', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-25 17:26:21'),
(136, 1, 4, 'logout', 'user', 4, NULL, NULL, '102.86.25.65', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-25 17:38:53'),
(137, 1, 13, 'login', 'user', 13, NULL, NULL, '102.86.25.65', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-25 17:39:47'),
(138, 1, 8, 'login', 'user', 8, NULL, NULL, '102.86.25.144', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-26 14:37:14'),
(139, 1, 8, 'login', 'user', 8, NULL, NULL, '102.86.25.144', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-26 17:00:26'),
(140, 1, 5, 'login', 'user', 5, NULL, NULL, '102.86.25.144', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-26 17:01:47'),
(141, 1, 5, 'logout', 'user', 5, NULL, NULL, '102.86.25.144', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-26 17:03:07'),
(142, 1, NULL, 'logout', 'user', NULL, NULL, NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 13:25:25'),
(143, 1, NULL, 'web_order', 'order', 17, '{\"order_number\":\"ORD-20261027-001\",\"subtotal\":6000,\"service_charge\":210,\"total\":6210,\"customer\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:01:41'),
(144, 1, NULL, 'web_payment', 'payments', 22, '{\"provider_reference\":\"PAY-20261027-001\",\"source\":\"order\",\"reference\":\"ORD-20261027-001\",\"method\":\"mtn_momo\",\"amount\":6210,\"status\":\"pending\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:02:17'),
(145, 1, NULL, 'web_payment_gateway', 'payments', 22, '{\"provider_reference\":\"PAY-20261027-001\",\"gateway\":\"pesapal\",\"tracking_id\":\"dc22c289-9f61-43c9-9d22-d9bc23d7d57b\",\"status\":\"pending\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:02:19'),
(146, 1, NULL, 'web_event', 'event_requests', 6, '{\"request_number\":\"EVT-20261027-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-10-29\",\"guests\":119,\"venue\":\"The Nile Hall\",\"phone\":\"0772514889\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:07:35'),
(147, 1, NULL, 'web_guest_message', 'guest_messages', 2, '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"rating\":0,\"phone\":\"0772514889\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:09:59'),
(148, 1, NULL, 'payment_settled', 'payments', 22, '{\"provider_reference\":\"PAY-20261027-001\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-27 14:10:21'),
(149, 1, 2, 'login', 'user', 2, NULL, NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:11:26'),
(150, 1, 2, 'open_shift', 'shift', 1, '{\"outlet\":\"restaurant\"}', NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 14:23:16'),
(151, 1, 2, 'logout', 'user', 2, NULL, NULL, '154.227.129.184', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 15:20:38'),
(152, 1, 5, 'login', 'user', 5, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:12:08'),
(153, 1, 5, 'logout', 'user', 5, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:13:32'),
(154, 1, 4, 'login', 'user', 4, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:13:37'),
(155, 1, 4, 'logout', 'user', 4, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:14:28'),
(156, 1, 13, 'login', 'user', 13, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:14:34'),
(157, 1, 13, 'web_order', 'order', 18, '{\"order_number\":\"ORD-20261028-001\",\"subtotal\":47000,\"service_charge\":1645,\"total\":48645,\"customer\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:22:41'),
(158, 1, 13, 'web_payment', 'payments', 23, '{\"provider_reference\":\"PAY-20261028-001\",\"source\":\"order\",\"reference\":\"ORD-20261028-001\",\"method\":\"airtel_money\",\"amount\":48645,\"status\":\"pending\"}', NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:22:49'),
(159, 1, 13, 'web_payment_gateway', 'payments', 23, '{\"provider_reference\":\"PAY-20261028-001\",\"gateway\":\"pesapal\",\"tracking_id\":\"9111b2b1-5bdb-45f5-8711-d9bbedfd4445\",\"status\":\"pending\"}', NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:22:52'),
(160, 1, NULL, 'payment_settled', 'payments', 23, '{\"provider_reference\":\"PAY-20261028-001\",\"from\":\"pending\",\"to\":\"failed\"}', NULL, '185.191.3.19', '', '2026-10-28 09:25:10'),
(161, 1, 13, 'customer_profile_update', 'customers', 8, '{\"id\":8,\"fields\":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]}', NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:29:50'),
(162, 1, 13, 'login', 'user', 13, NULL, NULL, '197.239.11.69', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-28 09:37:00'),
(163, 1, 5, 'login', 'user', 5, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-29 04:39:43'),
(164, 1, 5, 'login', 'user', 5, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-29 04:40:27'),
(165, 1, 5, 'update_profile', 'user', 5, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-29 04:41:28'),
(166, 1, 8, 'login', 'user', 8, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-29 04:48:27'),
(167, 1, 8, 'login', 'user', 8, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:12:03'),
(168, 1, 8, 'open_shift', 'shift', 2, '{\"outlet\":\"bar\"}', NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:13:33'),
(169, 1, 8, 'logout', 'user', 8, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:19:01'),
(170, 1, 6, 'login', 'user', 6, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:19:16'),
(171, 1, 6, 'assign_guest_message', 'guest_messages', 2, '{\"assigned_to\":null}', '{\"assigned_to\":6}', '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:21:35'),
(172, 1, 6, 'reply_guest_message', 'guest_messages', 2, '{\"reply\":null}', '{\"reply\":\"okay sir, our team is coming\"}', '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 05:22:07'),
(173, 1, 6, 'news_create', 'news_posts', 21, '{\"slug\":\"welcome-to-hotel-paradise-on-the-nile\"}', NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 06:29:40'),
(174, 1, 6, 'logout', 'user', 6, NULL, NULL, '102.86.13.247', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-10-29 06:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `beds`
--

CREATE TABLE `beds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(80) NOT NULL,
  `bed_type` varchar(80) NOT NULL,
  `price` decimal(14,2) DEFAULT NULL,
  `status` enum('available','reserved','occupied','out_of_service') DEFAULT 'available'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `call_logs`
--

CREATE TABLE `call_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `caller_id` bigint(20) UNSIGNED DEFAULT NULL,
  `callee_id` bigint(20) UNSIGNED DEFAULT NULL,
  `provider` varchar(120) DEFAULT NULL,
  `provider_call_id` varchar(190) DEFAULT NULL,
  `call_type` enum('voice','video') NOT NULL,
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT 0,
  `status` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cashier_shifts`
--

CREATE TABLE `cashier_shifts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `terminal_id` bigint(20) UNSIGNED NOT NULL,
  `opened_by` bigint(20) UNSIGNED NOT NULL,
  `closed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `opening_float` decimal(14,2) DEFAULT 0.00,
  `expected_total` decimal(14,2) DEFAULT 0.00,
  `actual_total` decimal(14,2) DEFAULT 0.00,
  `variance` decimal(14,2) DEFAULT 0.00,
  `status` enum('open','closed','reconciled') DEFAULT 'open',
  `opened_at` datetime DEFAULT current_timestamp(),
  `closed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chart_of_accounts`
--

CREATE TABLE `chart_of_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `account_code` varchar(30) NOT NULL,
  `account_name` varchar(190) NOT NULL,
  `account_type` enum('asset','liability','equity','income','expense') NOT NULL,
  `parent_id` bigint(20) UNSIGNED DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `chart_of_accounts`
--

INSERT INTO `chart_of_accounts` (`id`, `property_id`, `account_code`, `account_name`, `account_type`, `parent_id`, `active`) VALUES
(1, 1, '1000', 'Cash on hand', 'asset', NULL, 1),
(2, 1, '1010', 'Bank account', 'asset', NULL, 1),
(3, 1, '1020', 'Mobile money wallet', 'asset', NULL, 1),
(4, 1, '1030', 'Card settlement clearing', 'asset', NULL, 1),
(5, 1, '1100', 'Accounts receivable', 'asset', NULL, 1),
(6, 1, '1200', 'Inventory', 'asset', NULL, 1),
(7, 1, '2000', 'Accounts payable', 'liability', NULL, 1),
(8, 1, '2100', 'Tax and service charge payable', 'liability', NULL, 1),
(9, 1, '2200', 'Guest deposits', 'liability', NULL, 1),
(10, 1, '3000', 'Owner equity', 'equity', NULL, 1),
(11, 1, '3900', 'Retained earnings', 'equity', NULL, 1),
(12, 1, '4000', 'Room and venue revenue', 'income', NULL, 1),
(13, 1, '4100', 'Food and beverage revenue', 'income', NULL, 1),
(14, 1, '4200', 'Other operating revenue', 'income', NULL, 1),
(15, 1, '4900', 'Other income', 'income', NULL, 1),
(16, 1, '5000', 'Cost of sales', 'expense', NULL, 1),
(17, 1, '5100', 'Payroll and staff costs', 'expense', NULL, 1),
(18, 1, '5200', 'Utilities', 'expense', NULL, 1),
(19, 1, '5300', 'Repairs and maintenance', 'expense', NULL, 1),
(20, 1, '5400', 'Marketing', 'expense', NULL, 1),
(21, 1, '5500', 'Transport and travel', 'expense', NULL, 1),
(22, 1, '5600', 'Administration', 'expense', NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `communication_calls`
--

CREATE TABLE `communication_calls` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `caller_user_id` bigint(20) UNSIGNED NOT NULL,
  `receiver_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `call_type` enum('internal','external') NOT NULL DEFAULT 'internal',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `duration_seconds` int(10) UNSIGNED DEFAULT NULL,
  `status` enum('initiated','answered','missed','ended') NOT NULL DEFAULT 'initiated',
  `notes` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `full_name` varchar(160) NOT NULL DEFAULT '',
  `email` varchar(190) NOT NULL,
  `phone` varchar(40) NOT NULL DEFAULT '',
  `password_hash` varchar(255) NOT NULL DEFAULT '',
  `google_sub` varchar(128) DEFAULT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login_at` datetime DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `nationality` varchar(80) DEFAULT NULL,
  `national_id` varchar(60) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(120) DEFAULT NULL,
  `country` varchar(120) DEFAULT NULL,
  `postcode` varchar(20) DEFAULT NULL,
  `company` varchar(160) DEFAULT NULL,
  `job_title` varchar(120) DEFAULT NULL,
  `preferred_language` varchar(20) DEFAULT NULL,
  `dietary_preferences` varchar(255) DEFAULT NULL,
  `room_preferences` varchar(255) DEFAULT NULL,
  `marketing_opt_in` tinyint(1) NOT NULL DEFAULT 0,
  `emergency_contact_name` varchar(160) DEFAULT NULL,
  `emergency_contact_phone` varchar(40) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `hotel_id`, `full_name`, `email`, `phone`, `password_hash`, `google_sub`, `status`, `created_at`, `updated_at`, `last_login_at`, `profile_image`, `date_of_birth`, `gender`, `nationality`, `national_id`, `address`, `city`, `country`, `postcode`, `company`, `job_title`, `preferred_language`, `dietary_preferences`, `room_preferences`, `marketing_opt_in`, `emergency_contact_name`, `emergency_contact_phone`, `notes`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'Reagan Otema', 'reaganotema2022@gmail.com', '0772514889', '$2y$10$Tki76GP1jf405y9UUUI1Ret6Xw9sdaPrHVODp.fYu0P7ib/JOSl9.', NULL, 'active', '2026-10-09 12:25:49', '2026-10-27 17:00:18', '2026-10-27 17:00:18', 'cust_1_1792041214_48fb6a55.jpg', '1998-06-01', 'male', 'Ugandan', 'CM9801910356YD', 'JINJA', 'JINJA', 'Uganda', '904188', 'ReaganSoft Innovation Ltd', 'Director', 'english', 'too much salt', 'quiet side', 1, 'Reagan Otema', '0772514889', 'arrival time', NULL, NULL),
(2, 1, 'Andrew wakabi', 'andrew@gmail.com', '0772514889', '$2y$10$Mi0P4grIsraJuxS5bIgnXuPHhGnH4DMnDGOK3N.UWlY06xPHcfzyC', NULL, 'active', '2026-10-09 16:54:56', '2026-10-09 16:55:09', '2026-10-09 16:55:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(3, 1, 'Okot Denis', 'denisokot47@gmail.com', '0705761090', '$2y$10$0x18s2lSk1oUg7pNubR1TuGeBY.CUHBzCAt6tvD7PomQzOzr/ExTW', NULL, 'active', '2026-10-10 19:46:56', '2026-10-10 19:47:13', '2026-10-10 19:47:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(4, 1, 'Reagan Otema', 'reaganotemas@gmail.com', '0772514889', '$2y$10$uu9Ag/WbheyjzMV18aVJyeSCZfe8nXn7B6ODG1nnowKMpSwjkak1i', NULL, 'active', '2026-10-11 12:45:41', '2026-10-11 12:45:51', '2026-10-11 12:45:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'Lillian Kwagala', 'lilliankwagala29@gmail.com', '0778209207', '$2y$10$xUiaVulNuX1U/plJSDlNN.qW102nTWSh8EcsW8F5v8YVPJ7WJqnHa', NULL, 'active', '2026-10-13 13:34:15', '2026-10-13 13:34:28', '2026-10-13 13:34:28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(6, 1, 'Atim Jeremiah Okello', 'jeremiahotile@gmail.com', '0706407275', '$2y$10$Us7OW21XLg5j2b0ZDwuEhugzgGY36SHTCysMk3OgW1rUtfB0Ka2OK', NULL, 'active', '2026-10-21 14:19:54', '2026-10-21 14:20:02', '2026-10-21 14:20:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(7, 1, 'WOZISI WILLIAM', 'willywozisi@gmail.com', '0705491314', '$2y$10$CN0jitVXBhQ4Z./N3l6so.eXAAOKmWzEi/mPTsFgZhzyjouI6aZkq', NULL, 'active', '2026-10-21 14:20:30', '2026-10-21 14:20:38', '2026-10-21 14:20:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL),
(8, 1, 'paiton witness', 'paiton@gmail.com', '0750891058', '$2y$10$noKIHP.ysw.ZEEhKXrMk0O2pELBeUT6gwdSsptb7aNz6pGQhKop2W', NULL, 'active', '2026-10-28 12:21:46', '2026-10-28 12:29:50', '2026-10-28 12:22:02', 'cust_8_1793179790_0c3c549c.jpg', '2003-03-28', '', '', '', '', '', '', '', '', '', '', '', '', 0, '', '', '', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `customer_addresses`
--

CREATE TABLE `customer_addresses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `label` varchar(40) NOT NULL DEFAULT 'home',
  `address_line` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(120) DEFAULT NULL,
  `country` varchar(120) DEFAULT NULL,
  `postcode` varchar(20) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customer_documents`
--

CREATE TABLE `customer_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `doc_type` varchar(40) NOT NULL DEFAULT 'id',
  `title` varchar(160) NOT NULL DEFAULT '',
  `file_name` varchar(255) NOT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size` int(10) UNSIGNED DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customer_signin_attempts`
--

CREATE TABLE `customer_signin_attempts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `email` varchar(190) NOT NULL DEFAULT '',
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `window_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customer_signin_attempts`
--

INSERT INTO `customer_signin_attempts` (`id`, `ip_address`, `email`, `attempts`, `window_at`) VALUES
(1, '102.86.9.118', 'reaganotema2022@gmail.com', 2, '2026-10-09 12:25:33'),
(2, '41.210.143.202', 'reaganotemas@gmail.com', 2, '2026-10-11 12:45:21'),
(4, '154.227.129.184', 'innocentabaasiku9@gmail.com', 6, '2026-10-19 07:49:32'),
(5, '154.227.129.184', 'innocentabaasiku469@gmail.com', 2, '2026-10-19 07:50:12');

-- --------------------------------------------------------

--
-- Table structure for table `customer_tokens`
--

CREATE TABLE `customer_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `purpose` varchar(24) NOT NULL DEFAULT 'session',
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_seen_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customer_tokens`
--

INSERT INTO `customer_tokens` (`id`, `customer_id`, `token_hash`, `purpose`, `expires_at`, `created_at`, `last_seen_at`) VALUES
(2, 1, 'affe6ada25f3e8f97db1b4686af3667b356f947f17a595e07a4fec879543f87c', 'session', '2026-11-08 12:25:58', '2026-10-09 12:25:58', '2026-10-09 20:29:34'),
(3, 1, '1d0e1c469538fed09b8daadb8ba6350d585c5ad7d2ea4f85277663247f6745c0', 'session', '2026-11-08 15:18:33', '2026-10-09 15:18:33', '2026-10-13 14:17:17'),
(5, 2, 'bd029a38119fa03d18c1793b7ec37e63486786b19ff5882188e1d52cb729b470', 'session', '2026-11-08 16:55:09', '2026-10-09 16:55:09', '2026-10-15 21:11:32'),
(7, 3, 'f0a84ae1d463eea025b809a5c8cce8bcfb5e10858621fc93db1401b89788e08e', 'session', '2026-11-09 19:47:13', '2026-10-10 19:47:13', '2026-10-10 19:50:27'),
(9, 4, '848d0c4e9859f56f75e3c54fe906b7a720b06fbf575eb8f21089c39b52aff70b', 'session', '2026-11-10 12:45:51', '2026-10-11 12:45:51', '2026-10-25 15:16:28'),
(10, 1, 'ae4033425e62d001aceac245499acb1e2289421ac6427ef6a251c3a9bc196be6', 'session', '2026-11-12 13:23:05', '2026-10-13 13:23:05', '2026-10-13 13:30:56'),
(12, 5, 'e6b0fdf8048a0c4701df51b1a72b79d516418c87007e540db046f94bce25e37e', 'session', '2026-11-12 13:34:28', '2026-10-13 13:34:28', '2026-10-15 18:01:10'),
(13, 1, '766d088501c000f9458bdf1489d509338fe08f99ca25f763e38169ada8612bc3', 'session', '2026-11-12 14:33:14', '2026-10-13 14:33:14', '2026-10-15 11:26:54'),
(14, 1, 'b4d6f769b3c0ae81dc7dcb0f6570dfdb62fcab51680ede725b651cc736ba7157', 'session', '2026-11-14 08:11:31', '2026-10-15 08:11:31', '2026-10-17 15:11:12'),
(15, 1, '357b5f74b4def2bd8f8cff11fd60b9a892ecb2d8d1cee8c4c2afed1d542c2e04', 'session', '2026-11-14 11:30:31', '2026-10-15 11:30:31', '2026-10-15 12:49:26'),
(16, 1, 'f0c17b1ac0007e88fbc98d0e7272fa2e55c6d682ce32d272499f3df0e81318f1', 'session', '2026-11-14 16:12:44', '2026-10-15 16:12:44', '2026-10-17 07:22:37'),
(17, 1, '4010433e72c36ed204bf47c6e9832c28e678b29ca9c22111a22e9b037b9dc8f0', 'session', '2026-11-16 11:34:23', '2026-10-17 11:34:23', '2026-10-17 11:43:31'),
(19, 6, '52c47c1acb4c8c08bf038b99b425cd15423c85c0d63e74ca178c4bac8b88a117', 'session', '2026-11-20 14:20:02', '2026-10-21 14:20:02', '2026-10-21 14:21:35'),
(21, 7, '46c5000c67e6d1c5e171af06f67a53e6d79f686aa425e0a2e045c4613e2d6eb5', 'session', '2026-11-20 14:20:38', '2026-10-21 14:20:38', '2026-10-21 14:21:26'),
(22, 1, '2b39ba8aeda5dd3777958631ccea9cc3c8f6e50a7c5a515c242008b83dff91ba', 'session', '2026-11-26 17:00:18', '2026-10-27 17:00:18', '2026-10-27 18:29:32');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `code` varchar(30) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `code`, `active`) VALUES
(1, 'Front Desk', 'FD', 1),
(2, 'Housekeeping', 'HK', 1),
(3, 'Restaurant', 'RT', 1),
(4, 'Bar', 'BB', 1),
(5, 'Kitchen', 'KC', 1),
(6, 'Maintenance', 'MT', 1),
(7, 'Events', 'EV', 1),
(8, 'Administration', 'AD', 1),
(9, 'Laundry', 'LD', 1),
(46, 'Reservations', 'RS', 1),
(47, 'Room Service', 'RSV', 1),
(48, 'Swimming Pool', 'POOL', 1),
(49, 'Spa', 'SPA', 1),
(50, 'Store', 'ST', 1),
(51, 'Inventory', 'INV', 1),
(52, 'Procurement', 'PR', 1),
(53, 'Transport', 'TR', 1),
(54, 'Finance', 'FN', 1),
(55, 'Cashier', 'CS', 1),
(56, 'Accounting', 'AC', 1),
(57, 'Auditor', 'AU', 1),
(58, 'Human Resources', 'HR', 1),
(59, 'POS', 'POS', 1),
(60, 'IT & Systems', 'IT', 1),
(61, 'Management', 'MG', 1);

-- --------------------------------------------------------

--
-- Table structure for table `department_messages`
--

CREATE TABLE `department_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `recipient_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recipient_department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `subject` varchar(190) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('sent','read','archived') NOT NULL DEFAULT 'sent',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `department_threads`
--

CREATE TABLE `department_threads` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(190) NOT NULL,
  `thread_type` enum('department','group','direct','management') DEFAULT 'department',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dining_tables`
--

CREATE TABLE `dining_tables` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `outlet_id` bigint(20) UNSIGNED NOT NULL,
  `table_number` varchar(50) NOT NULL,
  `seats` int(11) DEFAULT 2,
  `status` enum('available','occupied','reserved','cleaning','out_of_service') DEFAULT 'available'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `efris_attempts`
--

CREATE TABLE `efris_attempts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `efris_invoice_id` bigint(20) UNSIGNED NOT NULL,
  `attempt_number` int(11) NOT NULL,
  `request_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`request_payload`)),
  `response_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_payload`)),
  `status` varchar(60) NOT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `efris_invoices`
--

CREATE TABLE `efris_invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','queued','submitted','fiscalized','failed','retrying') DEFAULT 'pending',
  `request_reference` varchar(190) DEFAULT NULL,
  `fdn` varchar(190) DEFAULT NULL,
  `verification_code` varchar(190) DEFAULT NULL,
  `qr_data` text DEFAULT NULL,
  `response_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_payload`)),
  `last_error` text DEFAULT NULL,
  `attempts` int(11) DEFAULT 0,
  `submitted_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `efris_transactions`
--

CREATE TABLE `efris_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','submitted','fiscalized','failed','retrying') DEFAULT 'pending',
  `request_reference` varchar(190) DEFAULT NULL,
  `fdn` varchar(190) DEFAULT NULL,
  `verification_code` varchar(190) DEFAULT NULL,
  `qr_data` text DEFAULT NULL,
  `response_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`response_payload`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `event_type` varchar(100) DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  `expected_guests` int(11) DEFAULT 0,
  `status` enum('planned','confirmed','in_progress','completed','cancelled') DEFAULT 'planned',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `event_bookings`
--

CREATE TABLE `event_bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `service_description` varchar(255) NOT NULL,
  `quantity` decimal(14,3) DEFAULT 1.000,
  `unit_price` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `event_requests`
--

CREATE TABLE `event_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `request_number` varchar(24) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `phone` varchar(40) NOT NULL,
  `email` varchar(160) DEFAULT NULL,
  `event_type` varchar(80) NOT NULL,
  `event_date` date DEFAULT NULL,
  `guests` int(10) UNSIGNED DEFAULT NULL,
  `venue` varchar(80) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'new',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_requests`
--

INSERT INTO `event_requests` (`id`, `hotel_id`, `request_number`, `full_name`, `phone`, `email`, `event_type`, `event_date`, `guests`, `venue`, `message`, `status`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'EVT-20261010-001', 'Reagan Otema', '0772514889', 'reaganotemas@gmail.com', 'Conference / seminar', '2026-10-11', 36, 'The Nile Hall', 'confrence', 'new', '2026-10-10 15:29:44', NULL, NULL, NULL),
(2, 1, 'EVT-20261011-001', 'Mafalda', '0772514889', 'reaganotemas@gmail.com', 'Team retreat', '2026-10-17', 100, 'The Nile Hall', 'fundraising', 'new', '2026-10-11 17:49:03', NULL, NULL, NULL),
(3, 1, 'EVT-20261016-001', 'altar at the gates', '0772514889', 'reaganotemas@gmail.com', 'Other', '2026-10-17', 30, 'The Nile Hall', 'we are planning a fundraising meeting from 10am to 1pm this Saturday.', 'new', '2026-10-16 16:19:18', NULL, NULL, NULL),
(4, 1, 'EVT-20261017-001', 'Akware olivia', '0761080587', 'akwareolivia@gmail.com', 'Birthday party', '2027-06-10', 10, 'The Riverside Gardens', NULL, 'new', '2026-10-17 11:40:12', NULL, NULL, NULL),
(5, 1, 'EVT-20261025-001', 'Otema Reagan', '0772514889', 'reaganotema2022@gmail.com', 'Wedding', '2026-12-20', 200, 'The Nile Hall', 'Wedding anniversary', 'new', '2026-10-25 02:25:33', NULL, NULL, NULL),
(6, 1, 'EVT-20261027-001', 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'Wedding', '2026-10-29', 119, 'The Nile Hall', 'wedding anniversary', 'new', '2026-10-27 17:07:35', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `number` varchar(40) NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(80) NOT NULL,
  `description` text NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `status` enum('pending','approved','rejected','paid') DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `references_txt` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `facility_enquiries`
--

CREATE TABLE `facility_enquiries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `enquiry_number` varchar(24) NOT NULL,
  `full_name` varchar(120) NOT NULL,
  `phone` varchar(40) NOT NULL,
  `email` varchar(160) DEFAULT NULL,
  `facility` varchar(80) DEFAULT NULL,
  `preferred_date` date DEFAULT NULL,
  `guests` int(10) UNSIGNED DEFAULT NULL,
  `message` text DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'new',
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `facility_enquiries`
--

INSERT INTO `facility_enquiries` (`id`, `hotel_id`, `enquiry_number`, `full_name`, `phone`, `email`, `facility`, `preferred_date`, `guests`, `message`, `status`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'FAQ-20261017-001', 'olivia', '0761080587', NULL, 'Health club and gym', '2026-10-18', 2, NULL, 'new', '2026-10-17 11:43:47', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `finance_bank_accounts`
--

CREATE TABLE `finance_bank_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `bank_name` varchar(150) DEFAULT NULL,
  `account_name` varchar(190) DEFAULT NULL,
  `account_number_last4` varchar(12) DEFAULT NULL,
  `method` varchar(50) NOT NULL DEFAULT 'bank',
  `account_type` enum('bank','mobile_money','card','other') NOT NULL DEFAULT 'bank',
  `currency` varchar(8) NOT NULL DEFAULT 'UGX',
  `opening_balance` decimal(14,2) NOT NULL DEFAULT 0.00,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_bank_transactions`
--

CREATE TABLE `finance_bank_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `transaction_date` date NOT NULL,
  `direction` enum('in','out') NOT NULL,
  `amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `reference` varchar(190) DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `status` enum('unmatched','matched','ignored') NOT NULL DEFAULT 'unmatched',
  `matched_type` varchar(60) DEFAULT NULL,
  `matched_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_cash_movements`
--

CREATE TABLE `finance_cash_movements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `shift_id` bigint(20) UNSIGNED DEFAULT NULL,
  `outlet` varchar(40) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `movement_type` enum('float','cash_in','cash_out','drop','payout','refund','correction') NOT NULL,
  `direction` enum('in','out') NOT NULL,
  `amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `method` varchar(50) NOT NULL DEFAULT 'cash',
  `reference` varchar(190) DEFAULT NULL,
  `reason` varchar(500) NOT NULL,
  `status` enum('recorded','approved','rejected','reversed') NOT NULL DEFAULT 'recorded',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_reconciliations`
--

CREATE TABLE `finance_reconciliations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `period_start` date NOT NULL,
  `period_end` date NOT NULL,
  `opening_balance` decimal(14,2) NOT NULL DEFAULT 0.00,
  `statement_in` decimal(14,2) NOT NULL DEFAULT 0.00,
  `statement_out` decimal(14,2) NOT NULL DEFAULT 0.00,
  `statement_closing` decimal(14,2) NOT NULL DEFAULT 0.00,
  `book_balance` decimal(14,2) NOT NULL DEFAULT 0.00,
  `difference` decimal(14,2) NOT NULL DEFAULT 0.00,
  `status` enum('draft','reviewed') NOT NULL DEFAULT 'draft',
  `prepared_by` bigint(20) UNSIGNED NOT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `notes` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `finance_transactions`
--

CREATE TABLE `finance_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `transaction_type` enum('income','expense','transfer','adjustment') NOT NULL,
  `reference_type` varchar(80) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `transaction_date` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `financial_periods`
--

CREATE TABLE `financial_periods` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `period_name` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('open','closed') DEFAULT 'open'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `folios`
--

CREATE TABLE `folios` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `folio_number` varchar(80) NOT NULL,
  `status` enum('open','closed') DEFAULT 'open',
  `total` decimal(14,2) DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `folio_items`
--

CREATE TABLE `folio_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `folio_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `reference_type` varchar(80) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quantity` decimal(14,3) DEFAULT 1.000,
  `unit_price` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `discount` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `goods_received`
--

CREATE TABLE `goods_received` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `purchase_order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `grn_number` varchar(80) NOT NULL,
  `received_by` bigint(20) UNSIGNED NOT NULL,
  `received_at` datetime DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guests`
--

CREATE TABLE `guests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `full_name` varchar(190) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  `id_type` varchar(50) DEFAULT NULL,
  `id_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `guests`
--

INSERT INTO `guests` (`id`, `user_id`, `hotel_id`, `full_name`, `phone`, `email`, `nationality`, `id_type`, `id_number`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(2, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(3, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(4, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(5, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(6, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(7, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(8, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(9, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(10, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(11, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(12, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(13, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(14, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(15, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(16, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(17, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(18, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(19, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(20, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(21, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(22, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(23, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(24, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(25, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(26, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(27, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(28, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(29, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(30, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(31, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(32, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(33, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(34, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(35, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(36, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(37, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(38, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(39, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(40, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(41, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL, NULL, NULL),
(42, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL, NULL, NULL),
(43, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL, NULL, NULL),
(44, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL, NULL, NULL),
(45, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL, NULL, NULL),
(46, NULL, 1, 'Otema Reagan', '0772514889', 'reaganotema2022@gmail.com', NULL, NULL, NULL, '2026-10-09 09:26:27', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `guest_accounts`
--

CREATE TABLE `guest_accounts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `marketing_opt_in` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guest_documents`
--

CREATE TABLE `guest_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED NOT NULL,
  `document_type` varchar(80) NOT NULL,
  `document_number` varchar(120) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `expires_on` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guest_folio_entries`
--

CREATE TABLE `guest_folio_entries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `reservation_id` bigint(20) UNSIGNED NOT NULL,
  `entry_type` enum('charge','payment','adjustment','refund') NOT NULL,
  `description` varchar(255) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guest_messages`
--

CREATE TABLE `guest_messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `hotel_id` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `reference` varchar(40) NOT NULL,
  `source` enum('website','in_stay') NOT NULL DEFAULT 'website',
  `kind` enum('message','experience') NOT NULL DEFAULT 'message',
  `full_name` varchar(120) NOT NULL,
  `phone` varchar(40) DEFAULT NULL,
  `email` varchar(160) DEFAULT NULL,
  `department` enum('front_office','kitchen') NOT NULL DEFAULT 'front_office',
  `room_number` varchar(20) DEFAULT NULL,
  `subject` varchar(160) DEFAULT NULL,
  `message` text NOT NULL,
  `rating` tinyint(3) UNSIGNED DEFAULT NULL,
  `status` enum('new','assigned','resolved','featured') NOT NULL DEFAULT 'new',
  `assigned_to` int(10) UNSIGNED DEFAULT NULL,
  `reply` text DEFAULT NULL,
  `replied_by` int(10) UNSIGNED DEFAULT NULL,
  `replied_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `guest_messages`
--

INSERT INTO `guest_messages` (`id`, `hotel_id`, `reference`, `source`, `kind`, `full_name`, `phone`, `email`, `department`, `room_number`, `subject`, `message`, `rating`, `status`, `assigned_to`, `reply`, `replied_by`, `replied_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'GM-20261025-001', 'website', 'experience', 'Otema Reagan', '0772514889', 'reaganotema2022@gmail.com', 'front_office', NULL, NULL, 'The room was incredible and beautiful 😍', 5, 'new', NULL, NULL, NULL, NULL, '2026-10-25 02:27:41', NULL),
(2, 1, 'GM-20261027-001', 'in_stay', 'message', 'julious frontdesk', '0772514889', 'reaganotema2022@gmail.com', 'front_office', '68', 'extra soap', 'please hurry am in the bathroom now.', NULL, 'assigned', 6, 'okay sir, our team is coming', 6, '2026-10-29 08:22:07', '2026-10-27 17:09:59', '2026-10-29 08:22:07');

-- --------------------------------------------------------

--
-- Table structure for table `hotels`
--

CREATE TABLE `hotels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `slug` varchar(190) NOT NULL,
  `city` varchar(100) DEFAULT 'Jinja',
  `country` varchar(100) DEFAULT 'Uganda',
  `currency` char(3) DEFAULT 'UGX',
  `timezone` varchar(64) DEFAULT 'Africa/Kampala',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `hotels`
--

INSERT INTO `hotels` (`id`, `name`, `slug`, `city`, `country`, `currency`, `timezone`, `created_at`, `updated_at`) VALUES
(1, 'Hotel Paradise on the Nile', 'hotel-paradise-on-the-nile', 'Jinja', 'Uganda', 'UGX', 'Africa/Kampala', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `hotel_groups`
--

CREATE TABLE `hotel_groups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `legal_name` varchar(190) DEFAULT NULL,
  `tax_number` varchar(100) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `logo_path` varchar(255) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `hotel_groups`
--

INSERT INTO `hotel_groups` (`id`, `name`, `legal_name`, `tax_number`, `phone`, `email`, `address`, `website`, `logo_path`, `active`, `created_at`, `updated_at`) VALUES
(1, 'Hotel Paradise on the Nile Group', 'Hotel Paradise on the Nile', NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-10-05 05:04:19', '2026-10-05 05:04:19');

-- --------------------------------------------------------

--
-- Table structure for table `housekeeping_tasks`
--

CREATE TABLE `housekeeping_tasks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `assigned_to` bigint(20) UNSIGNED DEFAULT NULL,
  `task_type` enum('cleaning','inspection','turn_down','deep_clean','other') DEFAULT 'cleaning',
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `status` enum('pending','assigned','in_progress','completed','verified','cancelled') DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `verified_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `hp_payment_mix_daily`
-- (See below for the actual view)
--
CREATE TABLE `hp_payment_mix_daily` (
`payment_date` date
,`method` varchar(50)
,`source` varchar(11)
,`payments_count` bigint(21)
,`amount` decimal(36,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `hp_pos_daily_sales`
-- (See below for the actual view)
--
CREATE TABLE `hp_pos_daily_sales` (
`sale_date` date
,`outlet` enum('restaurant','bar','room_service')
,`orders_count` bigint(21)
,`subtotal` decimal(36,2)
,`service_charge` decimal(36,2)
,`discounts` decimal(36,2)
,`order_total` decimal(36,2)
,`net_sales` decimal(36,2)
,`collected` decimal(58,2)
,`outstanding` decimal(59,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `hp_pos_integrity_issues`
-- (See below for the actual view)
--
CREATE TABLE `hp_pos_integrity_issues` (
`issue` varchar(29)
,`ref_id` bigint(20) unsigned
,`reference` varchar(190)
,`detail` varchar(118)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `hp_pos_order_balances`
-- (See below for the actual view)
--
CREATE TABLE `hp_pos_order_balances` (
`id` bigint(20) unsigned
,`order_number` varchar(60)
,`outlet` enum('restaurant','bar','room_service')
,`order_type` enum('table','room','takeaway','delivery')
,`table_name` varchar(60)
,`status` enum('pending','accepted','preparing','ready','served','partially_paid','paid','cancelled')
,`created_at` timestamp
,`subtotal` decimal(14,2)
,`tax` decimal(14,2)
,`discount` decimal(14,2)
,`total` decimal(14,2)
,`paid` decimal(36,2)
,`due` decimal(37,2)
,`payment_state` varchar(14)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `hp_shift_reconciliation`
-- (See below for the actual view)
--
CREATE TABLE `hp_shift_reconciliation` (
`shift_id` bigint(20) unsigned
,`user_id` bigint(20) unsigned
,`cashier` varchar(190)
,`outlet` enum('restaurant','bar','front_desk','kitchen','store')
,`status` enum('open','closed')
,`opened_at` datetime
,`closed_at` datetime
,`opening_cash` decimal(14,2)
,`recorded_expected` decimal(14,2)
,`counted_cash` decimal(14,2)
,`variance` decimal(14,2)
,`cash_taken` decimal(36,2)
,`other_taken` decimal(36,2)
,`payments_count` bigint(21)
,`live_expected_cash` decimal(37,2)
);

-- --------------------------------------------------------

--
-- Table structure for table `integrity_flags`
--

CREATE TABLE `integrity_flags` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `flag_key` varchar(190) NOT NULL,
  `flag_type` varchar(60) NOT NULL,
  `severity` enum('high','medium','low') NOT NULL DEFAULT 'medium',
  `ref_type` varchar(40) NOT NULL DEFAULT '',
  `ref_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `staff_id` bigint(20) UNSIGNED DEFAULT NULL,
  `staff_name` varchar(190) DEFAULT NULL,
  `guest_name` varchar(190) DEFAULT NULL,
  `amount` decimal(14,2) DEFAULT NULL,
  `expected` decimal(14,2) DEFAULT NULL,
  `detail` varchar(500) NOT NULL DEFAULT '',
  `status` enum('open','reviewed','cleared') NOT NULL DEFAULT 'open',
  `resolved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `seen_at` datetime NOT NULL DEFAULT current_timestamp(),
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `inventory_categories`
--

CREATE TABLE `inventory_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `inventory_categories`
--

INSERT INTO `inventory_categories` (`id`, `name`, `active`, `deleted_at`, `deleted_by`) VALUES
(1, 'Beverages', 1, NULL, NULL),
(2, 'Kitchen', 1, NULL, NULL),
(3, 'Housekeeping Supplies', 1, NULL, NULL),
(4, 'Maintenance', 1, NULL, NULL),
(5, 'Stationery', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `inventory_items`
--

CREATE TABLE `inventory_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(40) DEFAULT NULL,
  `name` varchar(190) NOT NULL,
  `unit` varchar(40) NOT NULL DEFAULT 'each',
  `reorder_level` decimal(14,2) DEFAULT 0.00,
  `active` tinyint(1) DEFAULT 1,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL,
  `unit_cost` decimal(14,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `inventory_items`
--

INSERT INTO `inventory_items` (`id`, `hotel_id`, `category_id`, `code`, `name`, `unit`, `reorder_level`, `active`, `deleted_at`, `deleted_by`, `unit_cost`) VALUES
(1, 1, 1, 'NVG-BEV-001', 'Nile Special Beer', 'carton', 6.00, 1, NULL, NULL, 0.00),
(2, 1, 1, 'NVG-BEV-002', 'Coca Cola', 'crate', 4.00, 1, NULL, NULL, 0.00),
(3, 1, 1, 'NVG-BEV-003', 'Bottled Water 500ml', 'carton', 8.00, 1, NULL, NULL, 0.00),
(4, 1, 2, 'NVG-KIT-001', 'Cooking Oil 6L', 'jerry', 3.00, 1, NULL, NULL, 0.00),
(5, 1, 2, 'NVG-KIT-002', 'Fresh Tomatoes', 'kg', 10.00, 1, NULL, NULL, 0.00),
(6, 1, 2, 'NVG-KIT-003', 'Beef', 'kg', 12.00, 1, NULL, NULL, 0.00),
(7, 1, 2, 'NVG-KIT-004', 'Mixing Flour 50kg', 'bag', 2.00, 1, NULL, NULL, 0.00),
(8, 1, 2, 'NVG-KIT-005', 'Fresh Eggs', 'tray', 6.00, 1, NULL, NULL, 0.00),
(9, 1, 3, 'NVG-HSK-001', 'Laundry Bar Soap', 'bar', 20.00, 1, NULL, NULL, 0.00),
(10, 1, 3, 'NVG-HSK-002', 'Toilet Paper', 'roll', 60.00, 1, NULL, NULL, 0.00),
(11, 1, 3, 'NVG-HSK-003', 'All Purpose Cleaner', 'litre', 8.00, 1, NULL, NULL, 0.00),
(12, 1, 4, 'NVG-MNT-001', 'Electrical Tape', 'roll', 4.00, 1, NULL, NULL, 0.00),
(13, 1, 4, 'NVG-MNT-002', 'LED Bulb 9W', 'piece', 10.00, 1, NULL, NULL, 0.00),
(14, 1, 5, 'NVG-STN-001', 'A4 Printer Paper', 'ream', 5.00, 1, NULL, NULL, 0.00),
(15, 1, 5, 'NVG-STN-002', 'Receipt Roll 80mm', 'roll', 20.00, 1, NULL, NULL, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `inventory_movements`
--

CREATE TABLE `inventory_movements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `movement_type` enum('purchase','transfer_in','transfer_out','sale','consumption','wastage','adjustment','return') NOT NULL,
  `quantity` decimal(14,3) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `reference_type` varchar(80) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `billing_name` varchar(190) DEFAULT NULL,
  `billing_email` varchar(190) DEFAULT NULL,
  `billing_phone` varchar(50) DEFAULT NULL,
  `invoice_number` varchar(80) NOT NULL,
  `subtotal` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `discount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'UGX',
  `notes` text DEFAULT NULL,
  `total` decimal(14,2) DEFAULT 0.00,
  `status` enum('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
  `due_date` date DEFAULT NULL,
  `issued_at` datetime DEFAULT NULL,
  `issued_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `invoices`
--

INSERT INTO `invoices` (`id`, `hotel_id`, `guest_id`, `billing_name`, `billing_email`, `billing_phone`, `invoice_number`, `subtotal`, `tax`, `discount`, `currency`, `notes`, `total`, `status`, `due_date`, `issued_at`, `issued_by`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 1, NULL, NULL, NULL, 'INV-HPN-20260925-0001', 744000.00, 0.00, 0.00, 'UGX', NULL, 744000.00, 'paid', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, NULL, 'ReaganSoft Innovation Ltd', 'ceo@reagansofinnovation.com', '0772514889', 'DRF-20261013-001', 0.00, 0.00, 0.00, 'UGX', 'payment must be made after five days', 0.00, 'draft', NULL, NULL, NULL, '2026-10-13 10:45:30', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `invoice_events`
--

CREATE TABLE `invoice_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `event` enum('issue','void','discount','adjust','note') NOT NULL,
  `amount` decimal(14,2) NOT NULL DEFAULT 0.00,
  `reason` text DEFAULT NULL,
  `applier` bigint(20) UNSIGNED DEFAULT NULL,
  `from_value` text DEFAULT NULL,
  `to_value` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `invoice_events`
--

INSERT INTO `invoice_events` (`id`, `invoice_id`, `event`, `amount`, `reason`, `applier`, `from_value`, `to_value`, `created_at`) VALUES
(1, 10, 'note', 0.00, 'Draft started', 3, NULL, NULL, '2026-10-13 13:45:30');

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `item_no` int(11) NOT NULL DEFAULT 0,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(14,3) DEFAULT 1.000,
  `unit_price` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `discount` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `journal_entries`
--

CREATE TABLE `journal_entries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `period_id` bigint(20) UNSIGNED DEFAULT NULL,
  `entry_number` varchar(80) NOT NULL,
  `entry_date` date NOT NULL,
  `description` text NOT NULL,
  `status` enum('draft','posted','reversed') DEFAULT 'draft',
  `source_type` varchar(60) DEFAULT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `posted_by` bigint(20) UNSIGNED DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `reversal_of` bigint(20) UNSIGNED DEFAULT NULL,
  `reversal_reason` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `journal_lines`
--

CREATE TABLE `journal_lines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `journal_entry_id` bigint(20) UNSIGNED NOT NULL,
  `account_id` bigint(20) UNSIGNED NOT NULL,
  `debit` decimal(14,2) DEFAULT 0.00,
  `credit` decimal(14,2) DEFAULT 0.00,
  `memo` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kitchen_order_items`
--

CREATE TABLE `kitchen_order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_item_id` bigint(20) UNSIGNED NOT NULL,
  `station_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('queued','accepted','preparing','ready','served','cancelled') DEFAULT 'queued',
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kitchen_stations`
--

CREATE TABLE `kitchen_stations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `laundry_items`
--

CREATE TABLE `laundry_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `laundry_order_id` bigint(20) UNSIGNED NOT NULL,
  `item_name` varchar(190) NOT NULL,
  `quantity` decimal(14,3) DEFAULT 1.000,
  `unit_price` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `laundry_orders`
--

CREATE TABLE `laundry_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_number` varchar(80) NOT NULL,
  `status` enum('received','processing','ready','delivered','cancelled') DEFAULT 'received',
  `total` decimal(14,2) DEFAULT 0.00,
  `received_at` datetime DEFAULT current_timestamp(),
  `delivered_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leave_requests`
--

CREATE TABLE `leave_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `staff_id` bigint(20) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `leave_type` varchar(80) NOT NULL,
  `reason` text DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `identifier` varchar(190) DEFAULT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  `successful` tinyint(1) NOT NULL DEFAULT 0,
  `failure_reason` varchar(190) DEFAULT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lost_property`
--

CREATE TABLE `lost_property` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `found_by` bigint(20) UNSIGNED DEFAULT NULL,
  `description` text NOT NULL,
  `found_at` datetime DEFAULT current_timestamp(),
  `status` enum('stored','claimed','returned','disposed') DEFAULT 'stored',
  `released_to` varchar(190) DEFAULT NULL,
  `released_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance_assets`
--

CREATE TABLE `maintenance_assets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `asset_code` varchar(80) DEFAULT NULL,
  `location` varchar(190) DEFAULT NULL,
  `status` varchar(80) DEFAULT 'active',
  `purchase_date` date DEFAULT NULL,
  `warranty_end` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `maintenance_tickets`
--

CREATE TABLE `maintenance_tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `asset_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reported_by` bigint(20) UNSIGNED NOT NULL,
  `assigned_to` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(190) NOT NULL,
  `description` text NOT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `status` enum('open','assigned','in_progress','waiting_parts','resolved','closed') DEFAULT 'open',
  `resolved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `menu_categories`
--

CREATE TABLE `menu_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `outlet` enum('restaurant','bar','room_service') NOT NULL,
  `name` varchar(120) NOT NULL,
  `eyebrow` varchar(120) DEFAULT NULL,
  `blurb` text DEFAULT NULL,
  `image` varchar(190) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `menu_categories`
--

INSERT INTO `menu_categories` (`id`, `hotel_id`, `outlet`, `name`, `eyebrow`, `blurb`, `image`, `sort_order`) VALUES
(1, 1, 'restaurant', 'Breakfast', NULL, NULL, 'eggs-and-toast.jpg', 0),
(2, 1, 'restaurant', 'Main Meals', NULL, NULL, 'paradise-rustica-fish.jpg', 0),
(3, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', 'masala-chips.jpg', 0),
(4, 1, 'bar', 'Soft Drinks', NULL, NULL, 'coca-cola-300ml.jpg', 0),
(5, 1, 'bar', 'Cocktails', NULL, NULL, 'paradise-sunset.jpg', 0),
(6, 1, 'bar', 'Beers and Ciders', NULL, NULL, 'bell-lager.jpg', 0),
(7, 1, 'bar', 'Wines and Spirits', NULL, NULL, 'house-white-wine.jpg', 0),
(8, 1, 'room_service', 'Room Service', NULL, NULL, 'food-on-table-hero3-use-it-on-menu-page.jpg', 0),
(17, 1, 'restaurant', 'Starters', 'TO BEGIN', 'Warm soups, the sandwich corner and freshly dressed salads.', 'caesar-salad.jpg', 10),
(18, 1, 'restaurant', 'Egg Dishes', 'FROM THE PAN', 'Classic egg plates finished to order.', 'spanish-omelet.jpg', 20),
(19, 1, 'restaurant', 'Burgers', 'THE GRILL', 'Charcoal patties, regular or Cajun, in a soft toasted bun.', 'king-burger.jpg', 30),
(20, 1, 'restaurant', 'Wraps and Rolex', 'ROLLED FRESH', 'Shredded fillings rolled warm in a soft tortilla.', 'beef-rolex.jpg', 40),
(22, 1, 'restaurant', 'Italian Special Pastas', 'FROM NAPOLI', 'Fresh pasta finished with a melted cheese and a slice of toast.', 'pasta-a-la-carbonara.jpg', 60),
(23, 1, 'restaurant', 'Fisherman\'s Offer', 'FRESH FROM THE NILE', 'Whole tilapia, fried, steamed or grilled, oil free on the grill.', 'grilled-king-fish.jpg', 70),
(24, 1, 'restaurant', 'Fish Fillets', 'THE CATCH', 'Breaded, battered or simply grilled, with rice or chips.', 'pan-grilled-fish-fillet.jpg', 80),
(25, 1, 'restaurant', 'Chicken Lovers', 'POULTRY', 'Marinated overnight, grilled, pan fried or tossed in sauce.', 'bbq-chicken-drumstick.jpg', 90),
(26, 1, 'restaurant', 'Paradise Hunter\'s Delicacies', 'STEAKS AND GRILLS', 'Prime beef fillet, skewers and the hunter\'s favourites.', 'paradise-mixed-grill.jpg', 100),
(27, 1, 'restaurant', 'Pork', 'PORK', 'Slow roasted, glazed and grilled to your liking.', 'honey-mustard-glazed-pork-ribs.jpg', 110),
(28, 1, 'restaurant', 'House Specials', 'FOR THE TABLE', 'Platters built for sharing, served with two accompaniments.', 'mixed-grill-platter.jpg', 120),
(29, 1, 'restaurant', 'Asian Delicacies', 'FAR EAST', 'Mild creamy curries, biryani and coconut dishes with rice or chapatti.', 'chicken-coconut-curry.jpg', 130),
(30, 1, 'restaurant', 'Desserts', 'SWEET FINISH', 'Fresh fruit, ice cream and a little sugar.', 'fruits-image.jpg', 140),
(31, 1, 'restaurant', 'Pizzeria Section', 'PIZZA', 'Baked to order on a stone base, 12 inch.', 'section-pizza.jpg', 150),
(129, 1, 'bar', 'Beers & Ciders', NULL, NULL, NULL, 0),
(130, 1, 'bar', 'Wines & Spirits', NULL, NULL, NULL, 0),
(224, 1, 'restaurant', 'Starters & Salads', 'To begin', 'Fresh greens, tossed to order and dressed at the table.', 'caesar-salad.jpg', 10),
(225, 1, 'restaurant', 'Soups', 'Warmed through', 'Made fresh every morning and served with bread.', 'mushroom-soup.jpg', 20),
(226, 1, 'restaurant', 'Omelets & Snacks', 'From the pan', 'All omelets are served with chips.', 'spanish-omelet.jpg', 30),
(227, 1, 'restaurant', 'Sandwiches', 'The sandwich corner', 'All sandwiches come with chips or salad.', 'classic-blt-sandwich.jpg', 40),
(228, 1, 'restaurant', 'Rolex Wraps & Burritos', 'Rolled to order', 'Warm tortillas, filled as you like them.', 'beef-rolex.jpg', 60),
(229, 1, 'restaurant', 'House Specials & Platters', 'For the table', 'Platters built for sharing, with a side of your choice.', 'mixed-grill-platter.jpg', 80),
(230, 1, 'restaurant', 'Chicken Dishes', 'Poultry', 'Marinated overnight, then grilled, pan fried or tossed in sauce.', 'bbq-chicken-drumstick.jpg', 90),
(231, 1, 'restaurant', 'Beef & Goat Main Courses', 'Steaks and grills', 'Prime beef fillet, tender goat and the hunter’s favourites.', 'king-steak.jpg', 100),
(232, 1, 'restaurant', 'Pork Courses', 'Pork', 'Slow roasted, glazed and grilled to your liking.', 'honey-mustard-glazed-pork-ribs.jpg', 110),
(233, 1, 'restaurant', 'Pizzeria', 'Pizza', 'Baked to order on a stone base. A whole meal on its own, add garlic bread or a salad.', 'section-pizza.jpg', 120),
(234, 1, 'restaurant', 'Italian Pastas', 'From Napoli', 'Pasta choices: spaghetti, penne, fettuccine, farfalle or spirulina.', 'pasta-a-la-carbonara.jpg', 130),
(235, 1, 'restaurant', 'Asian & Indian Curries', 'Far East and sub continent', 'Non veg curries are served with a choice of 1 or 2 accompaniments.', 'chicken-coconut-curry.jpg', 140),
(236, 1, 'restaurant', 'Chinese Corner', 'Wok and steam', 'Sizzling plates, deep fried bites and the full sweet and sour house.', 'sweet-and-sour-chicken.jpg', 150),
(237, 1, 'restaurant', 'Sizzler Hot Plates', 'On a hot plate', 'Brought to the table on a sizzling iron, with rice.', 'sizzler-beef-plate.jpg', 160),
(238, 1, 'restaurant', 'Rice & Noodles', 'Side options', 'Everything to round off a main course.', 'chicken-fried-rice.jpg', 170),
(239, 1, 'restaurant', 'Accompaniments & Extras', 'Side add ons', 'Added to any main course, priced per portion.', 'masala-chips.jpg', 180),
(240, 1, 'restaurant', 'Desserts & Bakery', 'Sweet finish', 'Cakes, pastries and fruit from our own bakery.', 'chocolate-cake-slice.jpg', 190);

-- --------------------------------------------------------

--
-- Table structure for table `menu_items`
--

CREATE TABLE `menu_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(14,2) DEFAULT NULL,
  `image` varchar(190) DEFAULT NULL,
  `group_name` varchar(120) DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  `stock_tracked` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `menu_items`
--

INSERT INTO `menu_items` (`id`, `hotel_id`, `category_id`, `name`, `description`, `price`, `image`, `group_name`, `sort_order`, `active`, `stock_tracked`) VALUES
(1, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(3, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(4, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(5, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(6, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, 'chicken-wings-with-chips.jpg', NULL, 0, 0, 1),
(7, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(8, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(9, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(10, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, 'chicken-samosas-pair.jpg', NULL, 0, 0, 1),
(11, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(12, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(13, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, 'coca-cola-300ml.jpg', NULL, 0, 1, 1),
(14, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, 'fanta-300ml.jpg', NULL, 0, 1, 1),
(15, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, 'mineral-water-500ml.webp', NULL, 0, 1, 1),
(16, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, 'paradise-sunset.jpg', NULL, 0, 1, 1),
(17, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, 'nile-breeze.jpg', NULL, 0, 1, 1),
(18, 1, 6, 'Nile Special', '500ml bottle', 5000.00, 'nile-special.jpg', NULL, 0, 1, 1),
(19, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, 'club-pilsener.jpg', NULL, 0, 1, 1),
(20, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, 'bell-lager.jpg', NULL, 0, 1, 1),
(21, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, 'house-white-wine.jpg', NULL, 0, 1, 1),
(22, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, 'local-spirit.jpg', NULL, 0, 1, 1),
(23, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, 'room-service-breakfast.jpg', NULL, 0, 1, 1),
(24, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, 'room-service-platter.jpg', NULL, 0, 1, 1),
(2272, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, 'mushroom-soup.jpg', 'Soups', 10, 1, 0),
(2273, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, 'clear-chicken-noodle-soup.jpg', 'Soups', 20, 1, 0),
(2274, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, 'classic-blt-sandwich.jpg', 'Sandwich Corner', 30, 1, 0),
(2275, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, 'three-decker-sandwich.webp', 'Sandwich Corner', 40, 1, 0),
(2276, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, 'tuna-melt-sandwich.jpg', 'Sandwich Corner', 50, 1, 0),
(2277, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, 'paradise-club-sandwich.jpg', 'Sandwich Corner', 60, 1, 0),
(2278, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, 'grilled-vegetables-salad.jpg', 'Salads', 70, 1, 0),
(2279, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, 'grilled-chicken-salad.jpg', 'Salads', 80, 1, 0),
(2280, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, 'tuna-salad.jpg', 'Salads', 90, 1, 0),
(2281, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, 'spanish-omelet.jpg', 'Egg Dishes', 10, 1, 0),
(2282, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, 'avocado-with-an-egg.jpg', 'Egg Dishes', 20, 1, 0),
(2283, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, 'bacon-cheese-omelet.jpg', 'Egg Dishes', 30, 1, 0),
(2284, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, 'vegetable-burger.jpg', 'Burgers', 10, 1, 0),
(2285, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, 'chicken-burger.jpg', 'Burgers', 20, 1, 1),
(2286, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, 'bbq-beef-and-chicken-patty.jpg', 'Burgers', 30, 1, 1),
(2287, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, 'double-beef-and-bacon-burger.jpg', 'Burgers', 40, 1, 1),
(2288, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, 'chicken-wrap.jpg', 'Wraps', 10, 1, 0),
(2289, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, 'crunchy-vegetable-wrap.jpg', 'Wraps', 20, 1, 0),
(2290, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, 'chicken-rolex.jpg', 'Wraps', 30, 1, 0),
(2291, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, 'chilli-beef-and-veggie-chips.jpg', 'Snacks', 10, 1, 0),
(2292, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, 'pair-of-chicken-spring-rolls.jpg', 'Snacks', 20, 1, 0),
(2293, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, 'liver-with-shredded-vegetables.jpg', 'Snacks', 30, 1, 0),
(2294, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, 'fish-fingers-with-chips.jpg', 'Snacks', 40, 1, 1),
(2295, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, 'chicken-wings-with-chips.jpg', 'Snacks', 50, 1, 1),
(2296, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, 'chicken-lollipops-with-chips.jpg', 'Snacks', 60, 1, 1),
(2297, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, 'pasta-arabiata.jpg', 'Pasta', 10, 1, 0),
(2298, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, 'pasta-classic-bolognaise.jpg', 'Pasta', 20, 1, 0),
(2299, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, 'pasta-a-la-carbonara.jpg', 'Pasta', 30, 1, 0),
(2300, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, 'premium-whole-fried.jpg', 'Whole Fish', 10, 1, 1),
(2301, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, 'premium-wet-fried-tilapia.jpg', 'Whole Fish', 20, 1, 1),
(2302, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, 'grilled-premium-fish.jpg', 'Whole Fish', 30, 1, 1),
(2303, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, 'large-fried-tilapia.jpg', 'Whole Fish', 40, 1, 1),
(2304, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, 'pan-grilled-fish-fillet.jpg', 'Whole Fish', 50, 1, 1),
(2305, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, 'paradise-rustica-fish.jpg', 'Fish Fillets', 10, 1, 1),
(2306, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, 'mombasa-fish.jpg', 'Fish Fillets', 20, 1, 1),
(2307, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, 'deep-fried-fish-fillet.jpg', 'Fish Fillets', 30, 1, 1),
(2308, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, 'nile-parch-catch-for-a-day.jpg', 'Fish Fillets', 40, 1, 1),
(2309, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, 'chicken-saute.jpg', 'Chicken Lovers', 10, 1, 1),
(2310, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, 'bbq-chicken-drumstick.jpg', 'Chicken Lovers', 20, 1, 1),
(2311, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, 'grilled-quarter-chicken-breast.jpg', 'Chicken Lovers', 30, 1, 1),
(2312, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, 'paradise-grilled-farm-chicken.jpg', 'Chicken Lovers', 40, 1, 1),
(2313, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, 'pan-fried-boneless-chicken-breast.jpg', 'Chicken Lovers', 50, 1, 1),
(2314, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, 'beef-fillet-steak-mushroom-sauce.jpg', 'Steaks', 10, 1, 1),
(2315, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, 'king-steak.jpg', 'Steaks', 20, 1, 1),
(2316, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, 'beef-stroganoff.jpg', 'Steaks', 30, 1, 1),
(2317, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, 'beef-stir-fry.jpg', 'Steaks', 40, 1, 1),
(2318, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, 'paradise-mixed-grill.jpg', 'Steaks', 50, 1, 1),
(2319, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, 'honey-glazed-hawaiian-beef-skewers.jpg', 'Steaks', 60, 1, 1),
(2320, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, 'beef-wet-fry.jpg', 'Steaks', 70, 1, 1),
(2321, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, 'goat-muchomo.jpg', 'Steaks', 80, 1, 1),
(2322, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, 'paradise-grilled-pork-chops.jpg', 'Pork', 10, 1, 1),
(2323, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, 'honey-mustard-glazed-pork-ribs.jpg', 'Pork', 20, 1, 1),
(2324, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, 'pork-muchomo.jpg', 'Pork', 30, 1, 1),
(2325, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, 'sweet-and-sour-pork.jpg', 'Pork', 40, 1, 1),
(2326, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, 'pork-muchomo-and-chops-platter.jpg', 'Pork', 50, 1, 1),
(2327, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, 'paradise-lusaniya.jpg', 'House Specials', 10, 1, 1),
(2328, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, 'mixed-grill-platter.jpg', 'House Specials', 20, 1, 1),
(2329, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, 'mixed-vegetable-curry.jpg', 'Curries', 10, 1, 0),
(2330, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, 'vegetable-korma.jpg', 'Curries', 20, 1, 0),
(2331, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, 'veggie-biryani.jpg', 'Biryani', 30, 1, 0),
(2332, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, 'chicken-biryani.jpg', 'Biryani', 40, 1, 1),
(2333, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, 'chicken-coconut-curry.jpg', 'Curries', 50, 1, 1),
(2334, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, 'fruits.jpg', 'Desserts', 10, 1, 0),
(2335, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, 'fruits-image.jpg', 'Desserts', 20, 1, 0),
(2336, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, 'banana-crepe.webp', 'Desserts', 30, 1, 0),
(2337, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, 'ice-cream.jpg', 'Desserts', 40, 1, 0),
(2338, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, 'cake-of-the-day.jpg', 'Desserts', 50, 1, 0),
(2339, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, 'affogato-espresso-ice-cream.webp', 'Desserts', 60, 1, 0),
(2340, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, 'banana-split.jpg', 'Desserts', 70, 1, 0),
(2341, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, 'classic-margherita.jpg', 'Pizza', 10, 1, 0),
(2342, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, 'sweet-vegetarian.jpg', 'Pizza', 20, 1, 0),
(2343, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, 'quattro-stagioni.jpg', 'Pizza', 30, 1, 0),
(2344, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, 'pepperoni.jpg', 'Pizza', 40, 1, 0),
(2345, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, 'hawaiian.jpg', 'Pizza', 50, 1, 0),
(2346, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, 'farmer-s-pizza.jpg', 'Pizza', 60, 1, 0),
(2347, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, 'tuna.jpg', 'Pizza', 70, 1, 1),
(2348, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, 'diavola.jpg', 'Pizza', 80, 1, 0),
(2349, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, 'bolognese.jpg', 'Pizza', 90, 1, 0),
(2350, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, 'capricciosa.jpg', 'Pizza', 100, 1, 0),
(2351, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, 'calzone-pizza.jpg', 'Calzone', 110, 1, 0),
(2352, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, 'assorted-meat-and-salami.webp', 'Pizza', 120, 1, 0),
(2353, 1, 224, 'Mixed Garden Salad', 'Mixed lettuce, cucumber, tomatoes, onions and avocado.', 12000.00, '', 'Starters & Salads', 10, 1, 1),
(2354, 1, 224, 'Greek Salad', 'Tomatoes, red onions, cucumber, lettuce, feta cheese, black olives and red cabbage.', 15000.00, '', 'Starters & Salads', 20, 1, 1),
(2355, 1, 224, 'Avocado & Lettuce Salad', 'A well designed platter of lettuce, avocado, onions, cherry tomatoes and carrot shavings, finished with 1,000 Island dressing.', 15000.00, '', 'Starters & Salads', 30, 1, 1),
(2356, 1, 224, 'Chicken Oriental Salad', 'Chicken with mayo, cucumber, pineapple, celery and tomatoes.', 20000.00, '', 'Starters & Salads', 50, 1, 1),
(2357, 1, 224, 'Caesar Salad', 'Grilled chicken cubes, avocado, carrot, lettuce, tomato, croutons and Parmesan cheese shavings.', 22000.00, '', 'Starters & Salads', 60, 1, 1),
(2358, 1, 224, 'Chef Salad', 'Crunchy lettuce, chicken flakes, beef strips, tomatoes, onions and bell peppers, topped with boiled Irish potatoes and a hard boiled egg.', 22000.00, '', 'Starters & Salads', 70, 1, 1),
(2359, 1, 224, 'Grilled Vegetables Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dates.', 18000.00, '', 'Starters & Salads', 80, 1, 1),
(2360, 1, 225, 'Clear Vegetable Broth', 'Fresh homemade vegetable soup, served with a garlic bread roll.', 12000.00, '', 'Soups', 20, 1, 1),
(2361, 1, 225, 'Cream of Tomato Soup', 'A puree of tomatoes finished with dairy cream, accompanied with croutons.', 12000.00, '', 'Soups', 30, 1, 1),
(2362, 1, 225, 'Ginger Carrot Soup', 'A creamy soup with a hint of ginger and dairy cream, accompanied with toast.', 12000.00, '', 'Soups', 40, 1, 1),
(2363, 1, 225, 'Clear Beef Noodle Soup', 'Fresh aromatic clear soup comprising julienne of beef, zucchini, carrots, onions and fresh noodles.', 15000.00, '', 'Soups', 50, 1, 1),
(2364, 1, 225, 'Clear Chicken Noodle Soup', 'Fresh aromatic clear soup comprising julienne of chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, '', 'Soups', 60, 1, 1),
(2365, 1, 226, 'French Cinnamon Toast', 'Garnished with mini fruit.', 12000.00, '', 'Omelets & Snacks', 10, 1, 1),
(2366, 1, 226, 'Eggs and Toast', 'Two eggs cooked to your style with home fries.', 12000.00, '', 'Omelets & Snacks', 20, 1, 1),
(2367, 1, 226, 'Mushroom and Cheese Omelet', 'Savory mushroom and cheddar, topped with a grilled tomato.', 15000.00, '', 'Omelets & Snacks', 30, 1, 1),
(2368, 1, 226, 'Mexican Omelet', 'Mushroom, green pepper, cheese, tomato and green chili.', 15000.00, '', 'Omelets & Snacks', 40, 1, 1),
(2369, 1, 226, 'Bacon Cheese Omelet', 'Crunchy bacon in three eggs, infused with cheese and a touch of pepper spice.', 18000.00, '', 'Omelets & Snacks', 60, 1, 1),
(2370, 1, 226, 'Yummy Chicken Omelet', 'Diced chicken with a hint of cheese, infused with onions and tomatoes.', 17000.00, '', 'Omelets & Snacks', 80, 1, 1),
(2371, 1, 226, 'Chicken Gizzards', 'Boiled, fried and finished in homemade tomato sauce. Served with chips.', 18000.00, '', 'Omelets & Snacks', 90, 1, 1),
(2372, 1, 226, 'Fish Fingers', 'Tender breaded fish, served with tartar sauce.', 25000.00, '', 'Omelets & Snacks', 100, 1, 1),
(2373, 1, 226, 'Mushroom Fries', 'Crispy chips tossed in brown mushroom sauce.', 12000.00, '', 'Omelets & Snacks', 130, 1, 1),
(2374, 1, 226, 'Plain Chips with Garnish', 'Plain chips with a garnish.', 10000.00, '', 'Omelets & Snacks', 140, 1, 1),
(2375, 1, 226, 'Masala Chips', 'Chips tossed in hot or mild Indian spices, tomato sauce and coriander leaves.', 15000.00, '', 'Omelets & Snacks', 150, 1, 1),
(2376, 1, 226, 'Bacon Cheese Fries', 'Diced bacon, spring onions and tomato sauce, tossed with chips and finished with cheese.', 22000.00, '', 'Omelets & Snacks', 160, 1, 1),
(2377, 1, 226, 'Chapatti Plain', 'A plain hand rolled chapatti.', 6000.00, '', 'Omelets & Snacks', 170, 1, 1),
(2378, 1, 226, 'Vegetable Spring Rolls', 'Vegetable spring rolls.', 5000.00, '', 'Omelets & Snacks', 180, 1, 1),
(2379, 1, 226, 'Pair of Chicken Spring Rolls', 'Two chicken spring rolls.', 6000.00, '', 'Omelets & Snacks', 190, 1, 1),
(2380, 1, 226, 'Trio of Samosas (Beef)', 'Three pieces of beef samosas.', 5000.00, '', 'Omelets & Snacks', 200, 1, 1),
(2381, 1, 226, 'Trio of Samosas (Vegetable)', 'Three pieces of vegetable samosas.', 5000.00, '', 'Omelets & Snacks', 210, 1, 1),
(2382, 1, 226, 'Chicken Samosas (Pair)', '', 5000.00, '', 'Omelets & Snacks', 220, 1, 1),
(2383, 1, 227, 'Tomato, Cheese & Avocado Sandwich', 'Grated cheddar cheese, tomatoes, lettuce and avocado on whole wheat, white bread or French loaf.', 18000.00, '', 'Sandwiches', 10, 1, 1),
(2384, 1, 227, 'Pulled Pork Sandwich', 'Pork flakes in mayo or sweet chili sauce, lettuce, brown onions, tomatoes and cucumber pickles.', 24000.00, '', 'Sandwiches', 20, 1, 1),
(2385, 1, 227, 'Chicken Salad Sandwich', 'Chicken with mayo, lettuce, onions, celery and tomatoes on a three decker toast.', 24000.00, '', 'Sandwiches', 30, 1, 1),
(2386, 1, 227, 'Steak Cheese Sandwich', 'Tender steak with cheese, tomato and lettuce.', 25000.00, '', 'Sandwiches', 50, 1, 1),
(2387, 1, 227, 'BBQ Beef Sandwich', 'Beef strips sautéed with vegetables, onions, bell pepper and mushroom in tangy BBQ sauce.', 25000.00, '', 'Sandwiches', 60, 1, 1),
(2388, 1, 227, 'Tuna Melt Sandwich', 'Tuna chunks with mayo, red onions, tomatoes and lettuce.', 25000.00, '', 'Sandwiches', 70, 1, 1),
(2389, 1, 19, 'BBQ Burger', 'A grilled beef or chicken patty finished in a tangy BBQ sauce.', 27000.00, '', 'Burgers', 10, 1, 1),
(2390, 1, 19, 'Chicken Burger', 'A grilled regular or Cajun chicken patty with lettuce, onions, tomatoes and chili mayo.', 25000.00, '', 'Burgers', 20, 1, 1),
(2391, 1, 19, 'Beef Burger', 'A grilled regular or Cajun beef patty with lettuce, onions, tomatoes and chili mayo.', 25000.00, '', 'Burgers', 30, 1, 1),
(2392, 1, 19, 'Mushroom & Cheese Burger', 'A grilled beef patty topped with melted cheese and a creamy mushroom sauce.', 22000.00, '', 'Burgers', 50, 1, 1),
(2393, 1, 19, 'King Burger', 'A double patty with bacon, cheese, caramelized onions, lettuce, pickles and tomato.', 35000.00, '', 'Burgers', 60, 1, 1),
(2394, 1, 228, 'Beef Rolex', 'A combination of eggs, beef, red onions, tomatoes and green pepper.', 15000.00, '', 'Rolex Wraps & Burritos', 20, 1, 1),
(2395, 1, 228, 'Chicken Rolex', 'A combination of three eggs, grilled chicken cubes, red onions, tomatoes and green pepper.', 15000.00, '', 'Rolex Wraps & Burritos', 30, 1, 1),
(2396, 1, 228, 'Classic BLT Wrap', 'Crispy bacon, lettuce and tomatoes in a tortilla.', 17000.00, '', 'Rolex Wraps & Burritos', 50, 1, 1),
(2397, 1, 228, 'Chicken / Beef Burrito', 'Grilled tender strips with white onions wrapped in a tortilla, topped with cheese and served with guacamole.', 27000.00, '', 'Rolex Wraps & Burritos', 60, 1, 1),
(2398, 1, 228, 'Fajita Chicken / Beef', 'Sautéed with coriander, onions and oyster sauce. Your choice of tortilla or sizzler plate, served with rice.', 30000.00, '', 'Rolex Wraps & Burritos', 70, 1, 1),
(2399, 1, 23, 'Fish Florentine', 'Grilled tilapia fillet with creamy spinach and cheese.', 32000.00, '', 'Fisherman\'s Offer', 10, 1, 1),
(2400, 1, 23, 'Poached Fish', 'Tilapia fillet gently cooked in rich fish stock with fresh mushrooms and potatoes.', 30000.00, '', 'Fisherman\'s Offer', 20, 1, 1),
(2401, 1, 23, 'Catch of the Day (Nile Perch)', 'Pan grilled Nile perch fillet.', 32000.00, 'nile-parch-catch-for-a-day.jpg', 'Fisherman\'s Offer', 40, 1, 1),
(2402, 1, 23, 'Deep Fried Fish Fillet', 'A coated tilapia fish fillet.', 32000.00, '', 'Fisherman\'s Offer', 50, 1, 1),
(2403, 1, 23, 'Pan Grilled Fish Fillet', 'A coated tilapia fish fillet.', 32000.00, '', 'Fisherman\'s Offer', 60, 1, 1),
(2404, 1, 23, 'Medium Fried Tilapia', 'Medium fried tilapia served with chips.', 38000.00, '', 'Fisherman\'s Offer', 90, 1, 1),
(2405, 1, 23, 'Medium Steamed Tilapia', 'Medium steamed tilapia served with chips.', 38000.00, '', 'Fisherman\'s Offer', 100, 1, 1),
(2406, 1, 23, 'Premium Whole Fish', 'Steamed or fried whole fish.', 37000.00, '', 'Fisherman\'s Offer', 120, 1, 1),
(2407, 1, 23, 'Grilled Premium Fish', 'Whole oven grilled oil free premium tilapia.', 43000.00, '', 'Fisherman\'s Offer', 130, 1, 1),
(2408, 1, 23, 'Large Fried Tilapia', 'Large fried tilapia served with chips.', 43000.00, '', 'Fisherman\'s Offer', 140, 1, 1),
(2409, 1, 23, 'Large Steamed Tilapia', 'Large steamed tilapia served with chips.', 43000.00, '', 'Fisherman\'s Offer', 150, 1, 1),
(2410, 1, 23, 'King Wet Fried Tilapia', 'King wet fried tilapia.', 45000.00, '', 'Fisherman\'s Offer', 160, 1, 1),
(2411, 1, 23, 'King Size Whole Fish', 'A fish fillet, English, grilled or crumbed, on spinach drizzled with mushroom sauce.', 42000.00, '', 'Fisherman\'s Offer', 170, 1, 1),
(2412, 1, 23, 'Grilled King Fish', 'Whole oven grilled oil free king tilapia.', 48000.00, '', 'Fisherman\'s Offer', 180, 1, 1),
(2413, 1, 23, 'Fried King Prawns', 'King prawns prepared in a seasoned butter sauce.', 45000.00, '', 'Fisherman\'s Offer', 190, 1, 1),
(2414, 1, 23, 'Golden Grilled Salmon', 'Grilled salmon on a bed of spinach, laced with white mushroom sauce.', 45000.00, '', 'Fisherman\'s Offer', 200, 1, 1),
(2415, 1, 230, 'Chicken Sauté', 'Sautéed chicken with brown mushroom and spring onions, served with mushroom sauce.', 30000.00, '', 'Chicken Dishes', 10, 1, 1),
(2416, 1, 230, 'Grilled Quarter Chicken (Breast)', 'Well marinated charcoal or oven roasted tender chicken breast.', 30000.00, '', 'Chicken Dishes', 30, 1, 1),
(2417, 1, 230, 'Grilled Quarter Chicken (Thigh)', 'Well marinated charcoal or oven roasted tender chicken thigh.', 30000.00, '', 'Chicken Dishes', 40, 1, 1),
(2418, 1, 230, 'Mushroom Chicken', 'Pan fried chicken cubes infused in a creamy white mushroom sauce and spring onions.', 32000.00, '', 'Chicken Dishes', 50, 1, 1),
(2419, 1, 230, 'Supreme Chicken', 'Fresh pan fried boneless chicken breast in mushroom sauce.', 32000.00, '', 'Chicken Dishes', 60, 1, 1),
(2420, 1, 231, 'Goat Sizzler', 'Stir fried dry goat flakes with vegetables and rosemary.', 27000.00, '', 'Beef & Goat Main Courses', 10, 1, 1),
(2421, 1, 231, 'Beef in Guinness', 'Steak simmered in Guinness beer and a creamy sauce.', 30000.00, '', 'Beef & Goat Main Courses', 70, 1, 1),
(2422, 1, 231, 'Goat Rack Tender', 'Pan fried rib rack.', 32000.00, '', 'Beef & Goat Main Courses', 80, 1, 1),
(2423, 1, 231, 'Liver Princess', 'Flakes of liver toasted with shredded vegetables.', 30000.00, '', 'Beef & Goat Main Courses', 90, 1, 1),
(2424, 1, 231, 'Beef Fillet Steak (Pepper Sauce)', 'Beef fillet steak in a black peppercorn sauce.', 35000.00, '', 'Beef & Goat Main Courses', 100, 1, 1),
(2425, 1, 231, 'Beef Fillet Steak (Mushroom Sauce)', 'Beef fillet steak in a creamy brown mushroom sauce.', 35000.00, '', 'Beef & Goat Main Courses', 110, 1, 1),
(2426, 1, 231, 'Beef Fillet Steak (Dry Onion)', 'Beef fillet steak with dry onion.', 35000.00, '', 'Beef & Goat Main Courses', 120, 1, 1),
(2427, 1, 232, 'Trio of Pork', 'A combination of pork ribs, pork muchomo and pork chops on a single platter.', 45000.00, '', 'Pork Courses', 50, 1, 1),
(2428, 1, 233, 'Classico e Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 24000.00, 'classic-margherita.jpg', 'Pizzeria', 10, 1, 1),
(2429, 1, 233, 'Pugliese', 'Tomato, black olives, oregano and cheese.', 24000.00, '', 'Pizzeria', 30, 1, 1),
(2430, 1, 233, 'Pata', 'Chips, tomato and cheese.', 26000.00, '', 'Pizzeria', 40, 1, 1),
(2431, 1, 233, 'Salami', 'Tomato, cheese and salami.', 26000.00, '', 'Pizzeria', 60, 1, 1),
(2432, 1, 233, 'Prosciutto Funghi', 'Ham, mushroom and cheese.', 26000.00, '', 'Pizzeria', 80, 1, 1),
(2433, 1, 233, 'Prosciutto', 'Cooked ham, tomato and mozzarella.', 27000.00, '', 'Pizzeria', 90, 1, 1),
(2434, 1, 233, 'Bolognaise', 'Spicy minced meat, mozzarella and tomato.', 27000.00, '', 'Pizzeria', 100, 1, 1),
(2435, 1, 233, 'Pollo Pizza', 'Italian chicken pizza with green pepper, onions and mushroom.', 27000.00, '', 'Pizzeria', 140, 1, 1),
(2436, 1, 233, 'Calzone Pizza', 'Minced meat, carrots and green pepper, folded into a semi circular bread shape.', 30000.00, '', 'Pizzeria', 160, 1, 1),
(2437, 1, 233, 'Farmer\'s Pizza', 'Chicken and mushroom.', 30000.00, '', 'Pizzeria', 170, 1, 1),
(2438, 1, 233, 'Paradise Special Pizza', 'Minced meat, salami, ham, mushroom, green pepper and onions.', 35000.00, '', 'Pizzeria', 180, 1, 1),
(2439, 1, 234, 'Pasta Arabiata', 'Pasta in a tomato and fresh chili sauce, topped with cheese.', 20000.00, '', 'Italian Pastas', 10, 1, 1),
(2440, 1, 234, 'Pasta a la Napolitana', 'Pasta in herby tomato and cheese sauce.', 18000.00, '', 'Italian Pastas', 20, 1, 1),
(2441, 1, 234, 'Pasta Genovese', 'Pasta in pesto sauce.', 22000.00, '', 'Italian Pastas', 30, 1, 1),
(2442, 1, 234, 'Pasta a la Carbonara', 'Pasta with egg and bacon in a creamy sauce, topped with cheese.', 25000.00, '', 'Italian Pastas', 40, 1, 1),
(2443, 1, 234, 'Pasta Classic Bolognaise', 'Pasta in a minced meat, garlic, tomato and red wine sauce, topped with cheese.', 25000.00, '', 'Italian Pastas', 50, 1, 1),
(2444, 1, 234, 'Pasta ala Cavolfiore e Salsiccia', 'Pasta with cauliflower and sausage in an egg and bacon creamy sauce.', 22000.00, '', 'Italian Pastas', 60, 1, 1),
(2445, 1, 234, 'Pasta a la Contadina', 'Pasta in chicken, garlic, coriander, white wine and a creamy coconut sauce.', 25000.00, '', 'Italian Pastas', 70, 1, 1),
(2446, 1, 235, 'Aloo Mutter', 'Diced potatoes and cowpeas prepared in a creamy sauce.', 18000.00, '', 'Asian & Indian Curries', 10, 1, 1),
(2447, 1, 235, 'Vegetable Chow Mein', 'Noodles with oyster and soy sauce, tossed with fresh vegetables.', 20000.00, '', 'Asian & Indian Curries', 40, 1, 1),
(2448, 1, 235, 'Chicken Tikka', '', 28000.00, '', 'Asian & Indian Curries', 60, 1, 1),
(2449, 1, 235, 'Chili Chicken', '', 28000.00, '', 'Asian & Indian Curries', 70, 1, 1),
(2450, 1, 235, 'Chicken Biryani', 'Cubes of chicken cooked in a creamy sauce, mixed with rice.', 32000.00, '', 'Asian & Indian Curries', 80, 1, 1),
(2451, 1, 235, 'Fish Biryani', 'Cubes of fish cooked in a creamy sauce, mixed with rice.', 32000.00, '', 'Asian & Indian Curries', 90, 1, 1),
(2452, 1, 235, 'Goat Biryani', 'Cubes of goat cooked in a creamy sauce, mixed with rice.', 32000.00, '', 'Asian & Indian Curries', 100, 1, 1),
(2453, 1, 235, 'Chicken Tikka Masala', '', 30000.00, '', 'Asian & Indian Curries', 120, 1, 1),
(2454, 1, 235, 'Chicken Makhani', 'Boneless tandoori marinated chicken cooked in butter and tomato gravy.', 30000.00, '', 'Asian & Indian Curries', 130, 1, 1),
(2455, 1, 235, 'Fish Curry Diamond', '', 30000.00, '', 'Asian & Indian Curries', 140, 1, 1),
(2456, 1, 235, 'Fish Tikka', '', 30000.00, '', 'Asian & Indian Curries', 150, 1, 1),
(2457, 1, 235, 'Fish Tikka Masala', '', 32000.00, '', 'Asian & Indian Curries', 160, 1, 1),
(2458, 1, 235, 'Half Tandoori Chicken', 'Chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.', 37000.00, '', 'Asian & Indian Curries', 170, 1, 1),
(2459, 1, 235, 'Full Tandoori Chicken', 'A full chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.', 47000.00, '', 'Asian & Indian Curries', 180, 1, 1),
(2460, 1, 236, 'Vegetable Spring Roll (1pc)', '', 1000.00, 'vegetable-spring-rolls.jpg', 'Chinese Corner', 10, 1, 1),
(2461, 1, 236, 'Chicken Spring Roll (1pc)', '', 2500.00, 'chicken-spring-rolls.webp', 'Chinese Corner', 20, 1, 1),
(2462, 1, 236, 'Pork Spring Roll (1pc)', '', 2500.00, 'pork-spring-roll.jpg', 'Chinese Corner', 30, 1, 1),
(2463, 1, 236, 'Vegetable Wanton', '', 5000.00, 'vegetable-wonton.jpg', 'Chinese Corner', 40, 1, 1),
(2464, 1, 236, 'Special Chicken Wings (1pc)', '', 7000.00, 'special-chicken-wings.webp', 'Chinese Corner', 50, 1, 1),
(2465, 1, 236, 'Fried Wanton (Chicken or Beef)', '', 8000.00, 'fried-wonton-chicken.jpg', 'Chinese Corner', 60, 1, 1),
(2466, 1, 236, 'Golden Fried Cauliflower', '', 10000.00, '', 'Chinese Corner', 70, 1, 1),
(2467, 1, 236, 'Fried Chips Plain', '', 10000.00, '', 'Chinese Corner', 80, 1, 1),
(2468, 1, 236, 'Special Beef Simsim', '', 15000.00, '', 'Chinese Corner', 90, 1, 1),
(2469, 1, 236, 'Smoked Fish', '', 15000.00, '', 'Chinese Corner', 100, 1, 1),
(2470, 1, 236, 'Salty Chicken / Beef', '', 15000.00, 'salty-chicken.webp', 'Chinese Corner', 110, 1, 1),
(2471, 1, 236, 'Foil Wrapped Chicken', '', 15000.00, '', 'Chinese Corner', 120, 1, 1),
(2472, 1, 236, 'French Fries with Garlic Sauce', '', 15000.00, '', 'Chinese Corner', 130, 1, 1),
(2473, 1, 236, 'Fried Egg Rolled Chicken (Pair)', '', 18000.00, 'fried-eggs-rolled-chicken.jpg', 'Chinese Corner', 140, 1, 1),
(2474, 1, 236, 'Fried Chicken Wings', '', 20000.00, '', 'Chinese Corner', 150, 1, 1),
(2475, 1, 236, 'Crispy Chicken Legs', '', 20000.00, 'cripcy-chicken-legs.jpg', 'Chinese Corner', 160, 1, 1),
(2476, 1, 236, 'Golden Fried Prawns', '', 20000.00, '', 'Chinese Corner', 170, 1, 1),
(2477, 1, 236, 'Fried Baby Corn with Cashew Nuts', '', 20000.00, '', 'Chinese Corner', 180, 1, 1),
(2478, 1, 236, 'Fried Summary Chicken', '', 25000.00, '', 'Chinese Corner', 190, 1, 1),
(2479, 1, 236, 'Sauté Chicken Sichuan Style', '', 25000.00, 'saute-chicken-sichuan-style.jpg', 'Chinese Corner', 200, 1, 1),
(2480, 1, 236, 'Chicken Curry', '', 25000.00, '', 'Chinese Corner', 210, 1, 1),
(2481, 1, 236, 'Fried French Beans with Garlic Sauce', '', 25000.00, '', 'Chinese Corner', 220, 1, 1),
(2482, 1, 236, 'Chinese Cabbage Sichuan Style (Hot)', '', 25000.00, 'chinese-cabbage-sichuan-style.jpg', 'Chinese Corner', 230, 1, 1),
(2483, 1, 236, 'Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)', '', 25000.00, 'mixed-vegetable-onions-cabbage-carrots-pepper-mushroom.jpg', 'Chinese Corner', 240, 1, 1),
(2484, 1, 236, 'Stir-Fried Chicken with Cashew Nuts', '', 30000.00, '', 'Chinese Corner', 250, 1, 1),
(2485, 1, 236, 'Spicy Half Chicken with Vegetables', '', 30000.00, '', 'Chinese Corner', 260, 1, 1),
(2486, 1, 236, 'Fried Chicken with Chinese Black Bean Sauce', '', 30000.00, '', 'Chinese Corner', 270, 1, 1),
(2487, 1, 236, 'Sweet and Sour Chicken', '', 30000.00, '', 'Chinese Corner', 280, 1, 1),
(2488, 1, 236, 'Sliced Chicken with Garlic Sauce', '', 30000.00, 'chicken-saute.jpg', 'Chinese Corner', 290, 1, 1),
(2489, 1, 236, 'Sliced Beef with Chinese Cabbage', '', 30000.00, 'beef-stir-fry.jpg', 'Chinese Corner', 300, 1, 1),
(2490, 1, 236, 'Shredded Beef with Onions', '', 30000.00, 'shredded-beef-with-vegetables.jpg', 'Chinese Corner', 310, 1, 1),
(2491, 1, 236, 'Sweet and Sour Beef', '', 30000.00, 'sweet-and-sour-pork.jpg', 'Chinese Corner', 320, 1, 1),
(2492, 1, 236, 'Sliced Beef in Oyster Sauce', '', 30000.00, '', 'Chinese Corner', 330, 1, 1),
(2493, 1, 236, 'Shredded Beef with Vegetables', '', 30000.00, '', 'Chinese Corner', 340, 1, 1),
(2494, 1, 236, 'Sliced Beef with Pineapple Sauce', '', 30000.00, '', 'Chinese Corner', 350, 1, 1),
(2495, 1, 236, 'Beef Curry', '', 30000.00, '', 'Chinese Corner', 360, 1, 1),
(2496, 1, 236, 'Sweet and Sour Pork (Chinese)', '', 30000.00, '', 'Chinese Corner', 370, 1, 1),
(2497, 1, 236, 'Shredded Pork with Green Pepper', '', 30000.00, '', 'Chinese Corner', 380, 1, 1),
(2498, 1, 236, 'Sauté Pork Sichuan Style (Hot)', '', 30000.00, 'saute-pork-sichuan-style.webp', 'Chinese Corner', 390, 1, 1),
(2499, 1, 236, 'Spicy Pork with Garlic Sauce', '', 30000.00, '', 'Chinese Corner', 400, 1, 1),
(2500, 1, 236, 'Sweet and Sour Fish Finger', '', 30000.00, '', 'Chinese Corner', 410, 1, 1),
(2501, 1, 236, 'Spicy Fish with Ginger & Garlic Sauce', '', 30000.00, '', 'Chinese Corner', 420, 1, 1),
(2502, 1, 236, 'Sliced Fish with Vegetables', '', 30000.00, '', 'Chinese Corner', 430, 1, 1),
(2503, 1, 236, 'Sliced Fish in Special Hot Sweet & Sour Sauce', '', 30000.00, '', 'Chinese Corner', 440, 1, 1),
(2504, 1, 236, 'Special Mixed Vegetables & Sprouts', '', 30000.00, 'special-mixed-vegetables-and-sprout.jpg', 'Chinese Corner', 450, 1, 1),
(2505, 1, 236, 'Fried Mixed Chicken, Beef & Goat Meat', '', 35000.00, 'fried-mixed-chicken-beef-and-goat-meet.jpg', 'Chinese Corner', 460, 1, 1),
(2506, 1, 236, 'Fried Shredded Chicken with Bamboo Shoots', '', 35000.00, 'fried-shredded-chicken-with-baboo-shoots.jpg', 'Chinese Corner', 470, 1, 1),
(2507, 1, 236, 'Sliced Pork with Mushroom and Bamboo Shoots', '', 35000.00, 'sliced-pork-and-mushroom-with-bamboo-shoots.jpg', 'Chinese Corner', 480, 1, 1),
(2508, 1, 236, 'Fried Beijing Duck with Vegetables', '', 35000.00, '', 'Chinese Corner', 490, 1, 1),
(2509, 1, 236, 'Fried Duck with Bamboo Shoots', '', 35000.00, '', 'Chinese Corner', 500, 1, 1),
(2510, 1, 236, 'Fried Prawns with Cashew Nuts', '', 45000.00, 'fried-prawns-cashew-nuts.jpg', 'Chinese Corner', 510, 1, 1),
(2511, 1, 236, 'Sauté Prawns with Black Bean Sauce', '', 45000.00, 'saute-prawns-with-black-bean-sauce.webp', 'Chinese Corner', 520, 1, 1),
(2512, 1, 236, 'Fried Prawns with Chinese Black Beans', '', 50000.00, 'fried-prawns-with-chinese-black-bean.jpg', 'Chinese Corner', 530, 1, 1),
(2513, 1, 236, 'Beijing Roasted Duck (Whole)', '', 100000.00, '', 'Chinese Corner', 540, 1, 1),
(2514, 1, 237, 'Sizzler Vegetables Plate', '', 30000.00, '', 'Sizzler Hot Plates', 10, 1, 1),
(2515, 1, 237, 'Sizzler Pork Plate', '', 35000.00, '', 'Sizzler Hot Plates', 20, 1, 1),
(2516, 1, 237, 'Sizzler Beef Plate', '', 35000.00, '', 'Sizzler Hot Plates', 30, 1, 1),
(2517, 1, 237, 'Sizzler Chicken Plate', '', 35000.00, '', 'Sizzler Hot Plates', 40, 1, 1),
(2518, 1, 237, 'Sizzler Shrimps / Prawns Plate', '', 50000.00, 'sizzler-shrimp-or-prawns-plate.jpg', 'Sizzler Hot Plates', 50, 1, 1),
(2519, 1, 238, 'Steamed Rice', '', 8000.00, '', 'Rice & Noodles', 10, 1, 1),
(2520, 1, 238, 'Fried Rice', '', 8000.00, '', 'Rice & Noodles', 20, 1, 1),
(2521, 1, 238, 'Ginger Fried Rice', '', 8000.00, '', 'Rice & Noodles', 30, 1, 1),
(2522, 1, 238, 'Vegetable Fried Rice', '', 10000.00, '', 'Rice & Noodles', 40, 1, 1),
(2523, 1, 238, 'Vegetable Fried Noodles', '', 12000.00, '', 'Rice & Noodles', 50, 1, 1),
(2524, 1, 238, 'Egg Fried Rice', '', 15000.00, 'eggs-fried-rice.webp', 'Rice & Noodles', 60, 1, 1),
(2525, 1, 238, 'Chicken Fried Rice', '', 25000.00, '', 'Rice & Noodles', 70, 1, 1),
(2526, 1, 238, 'Chicken / Beef / Pork Fried Noodles', '', 25000.00, '', 'Rice & Noodles', 80, 1, 1),
(2527, 1, 239, 'Extra Mushroom', '', 4000.00, '', 'Accompaniments & Extras', 10, 1, 1),
(2528, 1, 239, 'Extra Avocado', '', 4000.00, '', 'Accompaniments & Extras', 20, 1, 1),
(2529, 1, 239, 'Extra Fried Egg', '', 4000.00, 'extra-fried-eggs.jpg', 'Accompaniments & Extras', 30, 1, 1),
(2530, 1, 239, 'Extra Bacon', '', 7000.00, '', 'Accompaniments & Extras', 40, 1, 1),
(2531, 1, 239, 'Extra Cheese', '', 7000.00, '', 'Accompaniments & Extras', 50, 1, 1),
(2532, 1, 240, 'Cookies', '', 1000.00, '', 'Desserts & Bakery', 10, 1, 1),
(2533, 1, 240, 'Croissant', '', 2000.00, 'croissants.jpg', 'Desserts & Bakery', 20, 1, 1),
(2534, 1, 240, 'Beef / Chicken Pie', '', 5000.00, 'beef-or-chicken-pie.jpg', 'Desserts & Bakery', 30, 1, 1),
(2535, 1, 240, 'Sausage Roll', '', 5000.00, '', 'Desserts & Bakery', 40, 1, 1),
(2536, 1, 240, 'Bread Loaf', '', 6000.00, '', 'Desserts & Bakery', 50, 1, 1),
(2537, 1, 240, 'Marble Cake Slice', '', 7000.00, '', 'Desserts & Bakery', 60, 1, 1),
(2538, 1, 240, 'Chocolate Cake Slice', '', 7000.00, '', 'Desserts & Bakery', 70, 1, 1),
(2539, 1, 240, 'Strawberry Cake Slice', '', 7000.00, '', 'Desserts & Bakery', 80, 1, 1),
(2540, 1, 240, 'Lemon Cake Slice', '', 7000.00, '', 'Desserts & Bakery', 90, 1, 1),
(2541, 1, 240, 'Vanilla Cake Slice', '', 7000.00, '', 'Desserts & Bakery', 100, 1, 1),
(2542, 1, 240, 'Butter Bread', '', 7000.00, '', 'Desserts & Bakery', 110, 1, 1),
(2543, 1, 240, 'French Bread', '', 7000.00, '', 'Desserts & Bakery', 120, 1, 1),
(2544, 1, 240, 'Cinnamon Roll', '', 8000.00, '', 'Desserts & Bakery', 130, 1, 1),
(2545, 1, 240, 'Ice Cream (3 Scoops)', 'A bowl of three scoops, with a choice of chocolate, vanilla or strawberry.', 9000.00, 'ice-cream-3-scoop.jpg', 'Desserts & Bakery', 140, 1, 1),
(2546, 1, 240, 'Golden Fried Banana', '', 10000.00, '', 'Desserts & Bakery', 150, 1, 1),
(2547, 1, 240, 'Special Banana with Honey Sauce', '', 12000.00, '', 'Desserts & Bakery', 180, 1, 1),
(2548, 1, 240, 'Pineapple Upside-Down Cake', '', 14000.00, '', 'Desserts & Bakery', 190, 1, 1),
(2549, 1, 240, 'Tropical Fruit Platter', 'A presentation of fresh seasonal fruit: mango, pineapple, melon, orange, grapes and passion fruit.', 15000.00, 'tropical-fruits-platter.jpg', 'Desserts & Bakery', 200, 1, 1),
(2550, 1, 240, 'Lemon Tart', '', 15000.00, '', 'Desserts & Bakery', 220, 1, 1),
(2551, 1, 240, 'Mango Tart', '', 16000.00, '', 'Desserts & Bakery', 240, 1, 1),
(2552, 1, 240, 'White Forest Cake', '', 16000.00, '', 'Desserts & Bakery', 250, 1, 1),
(2553, 1, 240, 'Profiteroles', '', 16000.00, '', 'Desserts & Bakery', 260, 1, 1),
(2554, 1, 240, 'Chocolate Fudge Slice', '', 17000.00, '', 'Desserts & Bakery', 270, 1, 1),
(2555, 1, 240, 'Black Forest Cake (pc)', '', 17000.00, 'black-forest-cake.jpg', 'Desserts & Bakery', 280, 1, 1),
(2556, 1, 240, 'Classic Carrot Cake', '', 19000.00, '', 'Desserts & Bakery', 290, 1, 1),
(2557, 1, 240, 'Chocolate Mousse', '', 20000.00, '', 'Desserts & Bakery', 300, 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `message_reads`
--

CREATE TABLE `message_reads` (
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `read_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `news_posts`
--

CREATE TABLE `news_posts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `slug` varchar(180) NOT NULL,
  `title` varchar(200) NOT NULL,
  `category` varchar(20) NOT NULL DEFAULT 'news',
  `excerpt` varchar(320) NOT NULL DEFAULT '',
  `body` mediumtext DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `department` varchar(120) DEFAULT NULL,
  `location` varchar(120) DEFAULT NULL,
  `employment_type` varchar(60) DEFAULT NULL,
  `salary` varchar(120) DEFAULT NULL,
  `deadline` date DEFAULT NULL,
  `apply_email` varchar(160) DEFAULT NULL,
  `apply_url` varchar(300) DEFAULT NULL,
  `author_name` varchar(120) DEFAULT NULL,
  `author_role` varchar(120) DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `pinned` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(20) NOT NULL DEFAULT 'published',
  `publish_at` datetime NOT NULL DEFAULT current_timestamp(),
  `views` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `news_posts`
--

INSERT INTO `news_posts` (`id`, `hotel_id`, `slug`, `title`, `category`, `excerpt`, `body`, `image`, `department`, `location`, `employment_type`, `salary`, `deadline`, `apply_email`, `apply_url`, `author_name`, `author_role`, `created_by`, `pinned`, `status`, `publish_at`, `views`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'employee-of-the-month', 'Employee of the Month: the team that keeps the Nile calm', 'employee', 'Every month the hotel honours the colleague whose care for our guests stood out above all.', 'Every month the management team reads the guest letters, the front desk log and the kitchen pass, and chooses the colleague whose care for our guests stood out above all.\n\nThis month the honour goes to a member of our housekeeping family whose attention to detail and warm greetings made a difference to every guest they met. From the first folded towel to the last quiet turndown, their work carried the whole hotel.\n\nCongratulations. Thank you for setting the standard the rest of us follow - and for showing, every single day, what Paradise hospitality means.', NULL, 'Housekeeping', 'Hotel Paradise, Jinja', '', '', NULL, 'frontdesk@hotelparadiseonthenile.info', NULL, 'Management Team', 'Hotel Paradise on the Nile', NULL, 1, 'published', '2026-10-11 07:49:03', 0, '2026-10-11 07:49:03', NULL, NULL, NULL),
(2, 1, 'restaurant-manager-vacancy', 'We are hiring: Restaurant & Bar Manager', 'recruitment', 'The hotel is looking for an experienced food and beverage leader to run our riverside restaurant and bar.', 'Hotel Paradise on the Nile is looking for an experienced food and beverage leader to run our riverside restaurant and bar.\n\nYou will own the floor: the daily service, the team rota, the guest experience and the numbers behind it. If you have run a busy restaurant before, care about the small details and can lead a team with warmth, we would like to hear from you.\n\nWhat we offer: a competitive package, duty meals, a supportive team and a working home on the banks of the Nile.', NULL, 'Food and Beverage', 'Hotel Paradise, Jinja', 'Full-time', 'Competitive, negotiable', NULL, 'frontdesk@hotelparadiseonthenile.info', NULL, 'Human Resource', 'Hotel Paradise on the Nile', NULL, 1, 'published', '2026-10-11 07:49:03', 0, '2026-10-11 07:49:03', NULL, NULL, NULL),
(3, 1, 'student-internship-opportunities', 'Opportunities: internships and graduate placements', 'opportunity', 'Applications are open for hospitality, culinary and front office internships with the hotel.', 'Applications are open for hospitality, culinary and front office internships with the hotel.\n\nThis is an invitation to students and fresh graduates who want to learn the trade in a working five star standard hotel: hands-on shifts, real guest work and mentoring from a team that has done it for years.\n\nTell us who you are and what you would like to learn. Send your application to the front desk and mark it \"Internship\".', NULL, 'Human Resource', 'Hotel Paradise, Jinja', 'Internship', 'Allowance provided', NULL, 'frontdesk@hotelparadiseonthenile.info', NULL, 'Human Resource', 'Hotel Paradise on the Nile', NULL, 1, 'published', '2026-10-11 07:49:03', 0, '2026-10-11 07:49:03', NULL, NULL, NULL),
(4, 1, 'new-riverside-tasting-menu', 'New: the riverside tasting menu is here', 'update', 'Our kitchen has written a new tasting menu, served every evening with a view over the Nile.', 'Our kitchen has written a new tasting menu, served every evening with a view over the Nile.\n\nSmall plates, Nile tilapia, and a dessert the pastry section has been refining for weeks. Every course is prepared to order, and the front of house will talk you through the pairing behind each one.\n\nTables are limited each evening. Book ahead, and let the river do the rest.', NULL, 'Kitchen', 'Hotel Paradise, Jinja', '', '', NULL, 'frontdesk@hotelparadiseonthenile.info', NULL, 'Kitchen Team', 'Hotel Paradise on the Nile', NULL, 0, 'published', '2026-10-11 07:49:03', 0, '2026-10-11 07:49:03', NULL, NULL, NULL),
(5, 1, 'welcome-to-our-newsroom', 'Welcome to the Hotel Paradise newsroom', 'news', 'A single place for hotel news, updates, opportunities and the people behind Paradise.', 'This is the hotel telling its own story: announcements, service updates, the opportunities we open to our community, and the people who make Paradise what it is.\n\nKeep this page close. When there is something worth knowing - a new menu, a role we are hiring for, an opportunity for a student, or a colleague worth celebrating - it will be posted here first.', NULL, 'Management', 'Hotel Paradise, Jinja', '', '', NULL, 'frontdesk@hotelparadiseonthenile.info', NULL, 'Management Team', 'Hotel Paradise on the Nile', NULL, 0, 'published', '2026-10-11 07:49:03', 0, '2026-10-11 07:49:03', NULL, NULL, NULL),
(11, 1, 'fundraising-meeting', 'fundraising meeting', 'news', '📢🔥 **OFFICIAL ANNOUNCEMENT: FUNDRAISING MEETING AHEAD OF THE NOVEMBER CONFERENCE** 🔥🙏\r\n\r\n**THE ALTAR AT THE GATES MINISTRIES**\r\n\r\n✨ *Together in Faith. United in Purpose. Building for God\'s Glory.* ✨\r\n\r\nThe Altar at the Gates Ministries warmly invites all believers, ministry partners, friends, well-wishers, and everyon', '', '', '', '', '', '', NULL, '', '', 'Hotel Director', 'Director', 2, 0, 'published', '2026-10-15 20:00:00', 0, '2026-10-15 20:04:47', NULL, NULL, NULL),
(12, 1, 'riverside-terrace-reopens', 'Riverside terrace reopens at Hotel Paradise on the Nile', 'news', 'The terrace is open again for breakfast, sunset drinks and private dinners beside the Nile.', '<p>Our riverside terrace has reopened for guests and visitors. Breakfast is served from 7am, and the terrace stays open through the evening for drinks and private dinners beside the Nile.</p><p>Reservations are recommended for sunset seating. Please speak to the front desk or call the hotel.</p>', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Hotel Paradise on the Nile', 'Front Office', NULL, 0, 'published', '2026-10-25 19:45:49', 0, '2026-10-25 19:45:49', NULL, NULL, NULL),
(13, 1, 'front-desk-agent-2026', 'We are hiring: Front Desk Agent', 'recruitment', 'Join the front office team at Hotel Paradise on the Nile in Jinja.', '<p>We are looking for a welcoming, organised Front Desk Agent to look after arrivals, departures and guest requests. Experience in hospitality is an advantage, but a warm manner and careful record-keeping matter more.</p><p>Send your application to the address below before the closing date.</p>', NULL, 'Front Office', 'Jinja, Uganda', 'Full-time', NULL, '2026-12-31', 'frontdesk@hotelparadiseonthenile.info', NULL, 'Hotel Paradise on the Nile', 'Human Resource', NULL, 0, 'published', '2026-10-25 19:45:49', 0, '2026-10-25 19:45:49', NULL, NULL, NULL),
(14, 1, 'welcome-to-the-paradise-newsroom', 'Welcome to the Paradise newsroom', 'news', 'Stories, service updates and opportunities from Hotel Paradise on the Nile.', 'Welcome to our newsroom. This is where the hotel shares what is happening on the Nile: new services, team news, seasonal offers and the people who make a stay at Paradise memorable.\n\nCheck back for updates, or follow the links on the website to plan your next visit.', NULL, 'Management', NULL, NULL, NULL, NULL, NULL, NULL, 'Hotel Paradise on the Nile', 'Management', NULL, 0, 'published', '2026-10-26 18:43:14', 0, '2026-10-26 18:43:14', NULL, NULL, NULL),
(15, 1, 'join-the-paradise-team', 'Join the Paradise team', 'recruitment', 'We are always looking for warm, careful people to join the hotel.', 'Hotel Paradise on the Nile is built on people who care about the small details. We welcome applications from experienced hospitality professionals and from people starting their first role in the industry.\n\nSend your application to the front desk or use the contact details on the website. Please tell us the role you are interested in and a little about yourself.', NULL, 'Human Resource', NULL, NULL, NULL, NULL, NULL, NULL, 'Hotel Paradise on the Nile', 'Human Resource', NULL, 0, 'published', '2026-10-26 18:43:14', 0, '2026-10-26 18:43:14', NULL, NULL, NULL),
(21, 1, 'welcome-to-hotel-paradise-on-the-nile', 'Welcome to Hotel Paradise on the Nile , Your Perfect Getaway in Jinja', 'news', '# Welcome to Hotel Paradise on the Nile\r\n\r\nWelcome to Hotel Paradise on the Nile, your welcoming destination in the beautiful town of Jinja, Uganda.\r\n\r\nAt Hotel Paradise on the Nile, we believe every guest deserves a warm welcome, attentive service, and a comfortable stay. Whether you are visiting Jinja for business, l', '# Welcome to Hotel Paradise on the Nile\r\n\r\nWelcome to Hotel Paradise on the Nile, your welcoming destination in the beautiful town of Jinja, Uganda.\r\n\r\nAt Hotel Paradise on the Nile, we believe every guest deserves a warm welcome, attentive service, and a comfortable stay. Whether you are visiting Jinja for business, leisure, a family holiday, or a peaceful escape, our team looks forward to making your experience memorable.\r\n\r\n## Experience Jinja with Us\r\n\r\nJinja is a wonderful destination for travellers looking to discover Uganda\'s natural beauty, culture, and exciting experiences. Hotel Paradise on the Nile provides a welcoming base for visitors exploring the area and enjoying everything Jinja has to offer.\r\n\r\n## Our Commitment to You\r\n\r\nOur team is dedicated to providing friendly hospitality and assisting guests throughout their stay. From the moment you arrive until the time you depart, we aim to make your experience pleasant and enjoyable.\r\n\r\n## Plan Your Stay\r\n\r\nPlanning a visit to Jinja? We invite you to consider Hotel Paradise on the Nile for your next stay.\r\n\r\nFor reservations, room availability, and enquiries, please contact our team directly through our official hotel contact channels.\r\n\r\n## We Look Forward to Welcoming You\r\n\r\nThank you for considering Hotel Paradise on the Nile. We look forward to welcoming you and making your visit to Jinja a memorable one.\r\n\r\n**Hotel Paradise on the Nile – Your Stay, Our Hospitality.**', './images/news/news-welcome-to-hotel-paradise-on-the-nile-20261029092940-d95732.jpg', 'Front Office', '', '', '', NULL, '', '', 'Front Desk Reception', 'Front Desk', 6, 0, 'published', '2026-10-29 08:41:00', 0, '2026-10-29 09:29:40', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(100) NOT NULL,
  `title` varchar(190) NOT NULL,
  `body` text NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `body`, `data`, `read_at`, `created_at`) VALUES
(1, 2, 'booking', 'New website booking HPN-20261009-001', 'Otema Reagan asked for Suite for 13 nights, 2026-10-10 to 2026-10-23. Total UGX 3,336,840.', '{\"booking_number\":\"HPN-20261009-001\",\"room_type\":\"Suite\",\"nights\":13,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-23\",\"total\":3336840,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', '2026-10-10 15:31:05', '2026-10-09 09:26:27'),
(2, 3, 'booking', 'New website booking HPN-20261009-001', 'Otema Reagan asked for Suite for 13 nights, 2026-10-10 to 2026-10-23. Total UGX 3,336,840.', '{\"booking_number\":\"HPN-20261009-001\",\"room_type\":\"Suite\",\"nights\":13,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-23\",\"total\":3336840,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 09:26:27'),
(3, 6, 'booking', 'New website booking HPN-20261009-001', 'Otema Reagan asked for Suite for 13 nights, 2026-10-10 to 2026-10-23. Total UGX 3,336,840.', '{\"booking_number\":\"HPN-20261009-001\",\"room_type\":\"Suite\",\"nights\":13,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-23\",\"total\":3336840,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 09:26:27'),
(4, 66, 'booking', 'New website booking HPN-20261009-001', 'Otema Reagan asked for Suite for 13 nights, 2026-10-10 to 2026-10-23. Total UGX 3,336,840.', '{\"booking_number\":\"HPN-20261009-001\",\"room_type\":\"Suite\",\"nights\":13,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-23\",\"total\":3336840,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 09:26:27'),
(5, 2, 'order', 'New website order ORD-20261009-001', 'Otema Reagan placed a takeaway order, 1 item, total UGX 13,455.', '{\"order_number\":\"ORD-20261009-001\",\"items\":1,\"total\":13455,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja city\"}', '2026-10-10 15:31:05', '2026-10-09 12:18:03'),
(6, 3, 'order', 'New website order ORD-20261009-001', 'Otema Reagan placed a takeaway order, 1 item, total UGX 13,455.', '{\"order_number\":\"ORD-20261009-001\",\"items\":1,\"total\":13455,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja city\"}', NULL, '2026-10-09 12:18:03'),
(8, 9, 'order', 'New website order ORD-20261009-001', 'Otema Reagan placed a takeaway order, 1 item, total UGX 13,455.', '{\"order_number\":\"ORD-20261009-001\",\"items\":1,\"total\":13455,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja city\"}', NULL, '2026-10-09 12:18:03'),
(9, 66, 'order', 'New website order ORD-20261009-001', 'Otema Reagan placed a takeaway order, 1 item, total UGX 13,455.', '{\"order_number\":\"ORD-20261009-001\",\"items\":1,\"total\":13455,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja city\"}', NULL, '2026-10-09 12:18:03'),
(10, 2, 'payment', 'Payment request PAY-20261009-001', 'Otema Reagan started a CARD payment of UGX 13,455 for the order ORD-20261009-001.', '{\"reference\":\"PAY-20261009-001\",\"source\":\"order\",\"amount\":13455,\"method\":\"card\",\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\"}', '2026-10-10 15:31:04', '2026-10-09 12:19:08'),
(11, 3, 'payment', 'Payment request PAY-20261009-001', 'Otema Reagan started a CARD payment of UGX 13,455 for the order ORD-20261009-001.', '{\"reference\":\"PAY-20261009-001\",\"source\":\"order\",\"amount\":13455,\"method\":\"card\",\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\"}', NULL, '2026-10-09 12:19:08'),
(12, 4, 'payment', 'Payment request PAY-20261009-001', 'Otema Reagan started a CARD payment of UGX 13,455 for the order ORD-20261009-001.', '{\"reference\":\"PAY-20261009-001\",\"source\":\"order\",\"amount\":13455,\"method\":\"card\",\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\"}', NULL, '2026-10-09 12:19:08'),
(14, 66, 'payment', 'Payment request PAY-20261009-001', 'Otema Reagan started a CARD payment of UGX 13,455 for the order ORD-20261009-001.', '{\"reference\":\"PAY-20261009-001\",\"source\":\"order\",\"amount\":13455,\"method\":\"card\",\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\"}', NULL, '2026-10-09 12:19:08'),
(15, 2, 'booking', 'New website booking HPN-20261009-002', 'REAGAN OTEMA asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-002\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"REAGAN OTEMA\",\"phone\":\"0772514889\"}', '2026-10-10 15:31:03', '2026-10-09 13:53:21'),
(16, 3, 'booking', 'New website booking HPN-20261009-002', 'REAGAN OTEMA asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-002\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"REAGAN OTEMA\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:53:21'),
(17, 6, 'booking', 'New website booking HPN-20261009-002', 'REAGAN OTEMA asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-002\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"REAGAN OTEMA\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:53:21'),
(18, 66, 'booking', 'New website booking HPN-20261009-002', 'REAGAN OTEMA asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-002\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"REAGAN OTEMA\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:53:21'),
(19, 2, 'booking', 'New website booking HPN-20261009-003', 'Andrew Wakabi asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-003\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"Andrew Wakabi\",\"phone\":\"0772514889\"}', '2026-10-10 15:31:02', '2026-10-09 13:57:56'),
(20, 3, 'booking', 'New website booking HPN-20261009-003', 'Andrew Wakabi asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-003\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"Andrew Wakabi\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:57:56'),
(21, 6, 'booking', 'New website booking HPN-20261009-003', 'Andrew Wakabi asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-003\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"Andrew Wakabi\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:57:56'),
(22, 66, 'booking', 'New website booking HPN-20261009-003', 'Andrew Wakabi asked for Family Room for 5 nights, 2026-10-10 to 2026-10-15. Total UGX 1,624,950.', '{\"booking_number\":\"HPN-20261009-003\",\"room_type\":\"Family Room\",\"nights\":5,\"check_in\":\"2026-10-10\",\"check_out\":\"2026-10-15\",\"total\":1624950,\"guest\":\"Andrew Wakabi\",\"phone\":\"0772514889\"}', NULL, '2026-10-09 13:57:56'),
(23, 2, 'communication', 'New event enquiry EVT-20261010-001', 'Reagan Otema wants to plan conference / seminar (EVT-20261010-001). 36 guests. 2026-10-11. Please call 0772514889.', '{\"request_number\":\"EVT-20261010-001\",\"event_type\":\"Conference \\/ seminar\",\"event_date\":\"2026-10-11\",\"guests\":36,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', '2026-10-10 15:31:00', '2026-10-10 12:29:44'),
(24, 3, 'communication', 'New event enquiry EVT-20261010-001', 'Reagan Otema wants to plan conference / seminar (EVT-20261010-001). 36 guests. 2026-10-11. Please call 0772514889.', '{\"request_number\":\"EVT-20261010-001\",\"event_type\":\"Conference \\/ seminar\",\"event_date\":\"2026-10-11\",\"guests\":36,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 12:29:44'),
(25, 66, 'communication', 'New event enquiry EVT-20261010-001', 'Reagan Otema wants to plan conference / seminar (EVT-20261010-001). 36 guests. 2026-10-11. Please call 0772514889.', '{\"request_number\":\"EVT-20261010-001\",\"event_type\":\"Conference \\/ seminar\",\"event_date\":\"2026-10-11\",\"guests\":36,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 12:29:44'),
(26, 2, 'order', 'New website order ORD-20261010-001', 'Okot Denis placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261010-001\",\"items\":1,\"total\":15525,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"walukuba\"}', NULL, '2026-10-10 16:44:59'),
(27, 3, 'order', 'New website order ORD-20261010-001', 'Okot Denis placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261010-001\",\"items\":1,\"total\":15525,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"walukuba\"}', NULL, '2026-10-10 16:44:59'),
(29, 9, 'order', 'New website order ORD-20261010-001', 'Okot Denis placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261010-001\",\"items\":1,\"total\":15525,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"walukuba\"}', NULL, '2026-10-10 16:44:59'),
(30, 66, 'order', 'New website order ORD-20261010-001', 'Okot Denis placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261010-001\",\"items\":1,\"total\":15525,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"walukuba\"}', NULL, '2026-10-10 16:44:59'),
(31, 2, 'order', 'New website order ORD-20261010-002', 'Okot Denis placed a takeaway order, 1 item, total UGX 46,575.', '{\"order_number\":\"ORD-20261010-002\",\"items\":1,\"total\":46575,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"Jinja town\"}', NULL, '2026-10-10 16:48:28'),
(32, 3, 'order', 'New website order ORD-20261010-002', 'Okot Denis placed a takeaway order, 1 item, total UGX 46,575.', '{\"order_number\":\"ORD-20261010-002\",\"items\":1,\"total\":46575,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"Jinja town\"}', NULL, '2026-10-10 16:48:28'),
(34, 9, 'order', 'New website order ORD-20261010-002', 'Okot Denis placed a takeaway order, 1 item, total UGX 46,575.', '{\"order_number\":\"ORD-20261010-002\",\"items\":1,\"total\":46575,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"Jinja town\"}', NULL, '2026-10-10 16:48:28'),
(35, 66, 'order', 'New website order ORD-20261010-002', 'Okot Denis placed a takeaway order, 1 item, total UGX 46,575.', '{\"order_number\":\"ORD-20261010-002\",\"items\":1,\"total\":46575,\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\",\"address\":\"Jinja town\"}', NULL, '2026-10-10 16:48:28'),
(36, 2, 'payment', 'Payment request PAY-20261010-001', 'Okot Denis started a MTN_MOMO payment of UGX 46,575 for the order ORD-20261010-002.', '{\"reference\":\"PAY-20261010-001\",\"source\":\"order\",\"amount\":46575,\"method\":\"mtn_momo\",\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\"}', NULL, '2026-10-10 16:49:03'),
(37, 3, 'payment', 'Payment request PAY-20261010-001', 'Okot Denis started a MTN_MOMO payment of UGX 46,575 for the order ORD-20261010-002.', '{\"reference\":\"PAY-20261010-001\",\"source\":\"order\",\"amount\":46575,\"method\":\"mtn_momo\",\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\"}', NULL, '2026-10-10 16:49:03'),
(38, 4, 'payment', 'Payment request PAY-20261010-001', 'Okot Denis started a MTN_MOMO payment of UGX 46,575 for the order ORD-20261010-002.', '{\"reference\":\"PAY-20261010-001\",\"source\":\"order\",\"amount\":46575,\"method\":\"mtn_momo\",\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\"}', NULL, '2026-10-10 16:49:03'),
(40, 66, 'payment', 'Payment request PAY-20261010-001', 'Okot Denis started a MTN_MOMO payment of UGX 46,575 for the order ORD-20261010-002.', '{\"reference\":\"PAY-20261010-001\",\"source\":\"order\",\"amount\":46575,\"method\":\"mtn_momo\",\"guest\":\"Okot Denis\",\"phone\":\"+256779562514\"}', NULL, '2026-10-10 16:49:03'),
(41, 2, 'booking', 'New website booking HPN-20261010-001', 'Otema Reagan asked for Standard Single for 2 nights, 2026-10-11 to 2026-10-13. Total UGX 264,960.', '{\"booking_number\":\"HPN-20261010-001\",\"room_type\":\"Standard Single\",\"nights\":2,\"check_in\":\"2026-10-11\",\"check_out\":\"2026-10-13\",\"total\":264960,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:14'),
(42, 3, 'booking', 'New website booking HPN-20261010-001', 'Otema Reagan asked for Standard Single for 2 nights, 2026-10-11 to 2026-10-13. Total UGX 264,960.', '{\"booking_number\":\"HPN-20261010-001\",\"room_type\":\"Standard Single\",\"nights\":2,\"check_in\":\"2026-10-11\",\"check_out\":\"2026-10-13\",\"total\":264960,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:14'),
(43, 6, 'booking', 'New website booking HPN-20261010-001', 'Otema Reagan asked for Standard Single for 2 nights, 2026-10-11 to 2026-10-13. Total UGX 264,960.', '{\"booking_number\":\"HPN-20261010-001\",\"room_type\":\"Standard Single\",\"nights\":2,\"check_in\":\"2026-10-11\",\"check_out\":\"2026-10-13\",\"total\":264960,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:14'),
(44, 66, 'booking', 'New website booking HPN-20261010-001', 'Otema Reagan asked for Standard Single for 2 nights, 2026-10-11 to 2026-10-13. Total UGX 264,960.', '{\"booking_number\":\"HPN-20261010-001\",\"room_type\":\"Standard Single\",\"nights\":2,\"check_in\":\"2026-10-11\",\"check_out\":\"2026-10-13\",\"total\":264960,\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:14'),
(45, 2, 'payment', 'Payment request PAY-20261010-002', 'Otema Reagan started a MTN_MOMO payment of UGX 264,960 for the booking HPN-20261010-001.', '{\"reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"amount\":264960,\"method\":\"mtn_momo\",\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:40'),
(46, 3, 'payment', 'Payment request PAY-20261010-002', 'Otema Reagan started a MTN_MOMO payment of UGX 264,960 for the booking HPN-20261010-001.', '{\"reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"amount\":264960,\"method\":\"mtn_momo\",\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:40'),
(47, 4, 'payment', 'Payment request PAY-20261010-002', 'Otema Reagan started a MTN_MOMO payment of UGX 264,960 for the booking HPN-20261010-001.', '{\"reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"amount\":264960,\"method\":\"mtn_momo\",\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:40'),
(49, 66, 'payment', 'Payment request PAY-20261010-002', 'Otema Reagan started a MTN_MOMO payment of UGX 264,960 for the booking HPN-20261010-001.', '{\"reference\":\"PAY-20261010-002\",\"source\":\"booking\",\"amount\":264960,\"method\":\"mtn_momo\",\"guest\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-10 20:54:40'),
(50, 1, 'booking', 'New website booking HPN-20261011-001', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-001\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:44:29'),
(51, 2, 'booking', 'New website booking HPN-20261011-001', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-001\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:44:29'),
(52, 3, 'booking', 'New website booking HPN-20261011-001', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-001\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:44:29'),
(53, 6, 'booking', 'New website booking HPN-20261011-001', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-001\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:44:29'),
(54, 66, 'booking', 'New website booking HPN-20261011-001', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-001\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:44:29'),
(55, 1, 'booking', 'New website booking HPN-20261011-002', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-002\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:46:59'),
(56, 2, 'booking', 'New website booking HPN-20261011-002', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-002\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:46:59'),
(57, 3, 'booking', 'New website booking HPN-20261011-002', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-002\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:46:59'),
(58, 6, 'booking', 'New website booking HPN-20261011-002', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-002\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:46:59'),
(59, 66, 'booking', 'New website booking HPN-20261011-002', 'Reagan Otema asked for Family Room for 1 night, 2026-10-12 to 2026-10-13. Total UGX 324,990.', '{\"booking_number\":\"HPN-20261011-002\",\"room_type\":\"Family Room\",\"nights\":1,\"check_in\":\"2026-10-12\",\"check_out\":\"2026-10-13\",\"total\":324990,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:46:59'),
(60, 1, 'payment', 'Payment request PAY-20261011-001', 'Reagan Otema started a MTN_MOMO payment of UGX 324,990 for the booking HPN-20261011-002.', '{\"reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"amount\":324990,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:48:21'),
(61, 2, 'payment', 'Payment request PAY-20261011-001', 'Reagan Otema started a MTN_MOMO payment of UGX 324,990 for the booking HPN-20261011-002.', '{\"reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"amount\":324990,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:48:21'),
(62, 3, 'payment', 'Payment request PAY-20261011-001', 'Reagan Otema started a MTN_MOMO payment of UGX 324,990 for the booking HPN-20261011-002.', '{\"reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"amount\":324990,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:48:21'),
(63, 4, 'payment', 'Payment request PAY-20261011-001', 'Reagan Otema started a MTN_MOMO payment of UGX 324,990 for the booking HPN-20261011-002.', '{\"reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"amount\":324990,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:48:21'),
(65, 66, 'payment', 'Payment request PAY-20261011-001', 'Reagan Otema started a MTN_MOMO payment of UGX 324,990 for the booking HPN-20261011-002.', '{\"reference\":\"PAY-20261011-001\",\"source\":\"booking\",\"amount\":324990,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 09:48:21'),
(66, 2, 'order', 'New website order ORD-20261011-001', 'mama mafalda placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261011-001\",\"items\":1,\"total\":15525,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-11 14:46:23'),
(67, 3, 'order', 'New website order ORD-20261011-001', 'mama mafalda placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261011-001\",\"items\":1,\"total\":15525,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-11 14:46:23'),
(69, 9, 'order', 'New website order ORD-20261011-001', 'mama mafalda placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261011-001\",\"items\":1,\"total\":15525,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-11 14:46:23'),
(70, 66, 'order', 'New website order ORD-20261011-001', 'mama mafalda placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261011-001\",\"items\":1,\"total\":15525,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-11 14:46:23'),
(71, 2, 'communication', 'New event enquiry EVT-20261011-001', 'Mafalda wants to plan team retreat (EVT-20261011-001). 100 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261011-001\",\"event_type\":\"Team retreat\",\"event_date\":\"2026-10-17\",\"guests\":100,\"venue\":\"The Nile Hall\",\"name\":\"Mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 14:49:03'),
(72, 3, 'communication', 'New event enquiry EVT-20261011-001', 'Mafalda wants to plan team retreat (EVT-20261011-001). 100 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261011-001\",\"event_type\":\"Team retreat\",\"event_date\":\"2026-10-17\",\"guests\":100,\"venue\":\"The Nile Hall\",\"name\":\"Mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 14:49:03'),
(73, 66, 'communication', 'New event enquiry EVT-20261011-001', 'Mafalda wants to plan team retreat (EVT-20261011-001). 100 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261011-001\",\"event_type\":\"Team retreat\",\"event_date\":\"2026-10-17\",\"guests\":100,\"venue\":\"The Nile Hall\",\"name\":\"Mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-11 14:49:03'),
(74, 1, 'order', 'New website order ORD-20261013-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261013-001\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '2026-10-13 10:29:48'),
(75, 2, 'order', 'New website order ORD-20261013-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261013-001\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '2026-10-13 10:29:48'),
(76, 3, 'order', 'New website order ORD-20261013-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261013-001\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '2026-10-13 10:29:48'),
(78, 9, 'order', 'New website order ORD-20261013-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261013-001\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '2026-10-13 10:29:48'),
(79, 66, 'order', 'New website order ORD-20261013-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261013-001\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"+256772514889\",\"address\":\"JINJA\"}', NULL, '2026-10-13 10:29:48'),
(80, 1, 'order', 'New website order ORD-20261013-002', 'Otema Reagan placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261013-002\",\"items\":1,\"total\":6210,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-13 11:19:23'),
(81, 2, 'order', 'New website order ORD-20261013-002', 'Otema Reagan placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261013-002\",\"items\":1,\"total\":6210,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-13 11:19:23'),
(82, 3, 'order', 'New website order ORD-20261013-002', 'Otema Reagan placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261013-002\",\"items\":1,\"total\":6210,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-13 11:19:23'),
(84, 9, 'order', 'New website order ORD-20261013-002', 'Otema Reagan placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261013-002\",\"items\":1,\"total\":6210,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-13 11:19:23'),
(85, 66, 'order', 'New website order ORD-20261013-002', 'Otema Reagan placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261013-002\",\"items\":1,\"total\":6210,\"guest\":\"Otema Reagan\",\"phone\":\"+256772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-13 11:19:23'),
(86, 1, 'order', 'New website order ORD-20261015-001', 'Reagan Otema placed a takeaway order, 2 items, total UGX 73,485.', '{\"order_number\":\"ORD-20261015-001\",\"items\":2,\"total\":73485,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 05:12:43'),
(87, 2, 'order', 'New website order ORD-20261015-001', 'Reagan Otema placed a takeaway order, 2 items, total UGX 73,485.', '{\"order_number\":\"ORD-20261015-001\",\"items\":2,\"total\":73485,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 05:12:43'),
(88, 3, 'order', 'New website order ORD-20261015-001', 'Reagan Otema placed a takeaway order, 2 items, total UGX 73,485.', '{\"order_number\":\"ORD-20261015-001\",\"items\":2,\"total\":73485,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 05:12:43'),
(90, 9, 'order', 'New website order ORD-20261015-001', 'Reagan Otema placed a takeaway order, 2 items, total UGX 73,485.', '{\"order_number\":\"ORD-20261015-001\",\"items\":2,\"total\":73485,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 05:12:43'),
(91, 66, 'order', 'New website order ORD-20261015-001', 'Reagan Otema placed a takeaway order, 2 items, total UGX 73,485.', '{\"order_number\":\"ORD-20261015-001\",\"items\":2,\"total\":73485,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 05:12:43'),
(92, 1, 'order', 'New website order ORD-20261015-002', 'Reagan Otema placed a takeaway order, 1 item, total UGX 51,750.', '{\"order_number\":\"ORD-20261015-002\",\"items\":1,\"total\":51750,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 08:29:11'),
(93, 2, 'order', 'New website order ORD-20261015-002', 'Reagan Otema placed a takeaway order, 1 item, total UGX 51,750.', '{\"order_number\":\"ORD-20261015-002\",\"items\":1,\"total\":51750,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 08:29:11'),
(94, 3, 'order', 'New website order ORD-20261015-002', 'Reagan Otema placed a takeaway order, 1 item, total UGX 51,750.', '{\"order_number\":\"ORD-20261015-002\",\"items\":1,\"total\":51750,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 08:29:11'),
(96, 9, 'order', 'New website order ORD-20261015-002', 'Reagan Otema placed a takeaway order, 1 item, total UGX 51,750.', '{\"order_number\":\"ORD-20261015-002\",\"items\":1,\"total\":51750,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 08:29:11'),
(97, 66, 'order', 'New website order ORD-20261015-002', 'Reagan Otema placed a takeaway order, 1 item, total UGX 51,750.', '{\"order_number\":\"ORD-20261015-002\",\"items\":1,\"total\":51750,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-15 08:29:11'),
(98, 1, 'order', 'New website order ORD-20261015-003', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-003\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '2026-10-15 08:31:05'),
(99, 2, 'order', 'New website order ORD-20261015-003', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-003\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '2026-10-15 08:31:05'),
(100, 3, 'order', 'New website order ORD-20261015-003', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-003\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '2026-10-15 08:31:05'),
(102, 9, 'order', 'New website order ORD-20261015-003', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-003\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '2026-10-15 08:31:05'),
(103, 66, 'order', 'New website order ORD-20261015-003', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-003\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja mpummude\"}', NULL, '2026-10-15 08:31:05'),
(104, 1, 'payment', 'Payment request PAY-20261015-001', 'Reagan Otema started a CARD payment of UGX 6,210 for the order ORD-20261015-003.', '{\"reference\":\"PAY-20261015-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 09:21:44'),
(105, 2, 'payment', 'Payment request PAY-20261015-001', 'Reagan Otema started a CARD payment of UGX 6,210 for the order ORD-20261015-003.', '{\"reference\":\"PAY-20261015-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 09:21:44'),
(106, 3, 'payment', 'Payment request PAY-20261015-001', 'Reagan Otema started a CARD payment of UGX 6,210 for the order ORD-20261015-003.', '{\"reference\":\"PAY-20261015-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 09:21:44'),
(107, 4, 'payment', 'Payment request PAY-20261015-001', 'Reagan Otema started a CARD payment of UGX 6,210 for the order ORD-20261015-003.', '{\"reference\":\"PAY-20261015-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 09:21:44'),
(109, 66, 'payment', 'Payment request PAY-20261015-001', 'Reagan Otema started a CARD payment of UGX 6,210 for the order ORD-20261015-003.', '{\"reference\":\"PAY-20261015-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 09:21:44'),
(110, 1, 'order', 'New website order ORD-20261015-004', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-004\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:13:18'),
(111, 2, 'order', 'New website order ORD-20261015-004', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-004\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:13:18'),
(112, 3, 'order', 'New website order ORD-20261015-004', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-004\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:13:18'),
(114, 9, 'order', 'New website order ORD-20261015-004', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-004\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:13:18'),
(115, 66, 'order', 'New website order ORD-20261015-004', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-004\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:13:18'),
(116, 1, 'payment', 'Payment request PAY-20261015-002', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-004.', '{\"reference\":\"PAY-20261015-002\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:13:31'),
(117, 2, 'payment', 'Payment request PAY-20261015-002', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-004.', '{\"reference\":\"PAY-20261015-002\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:13:31'),
(118, 3, 'payment', 'Payment request PAY-20261015-002', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-004.', '{\"reference\":\"PAY-20261015-002\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:13:31'),
(119, 4, 'payment', 'Payment request PAY-20261015-002', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-004.', '{\"reference\":\"PAY-20261015-002\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:13:31'),
(121, 66, 'payment', 'Payment request PAY-20261015-002', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-004.', '{\"reference\":\"PAY-20261015-002\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:13:31'),
(122, 1, 'order', 'New website order ORD-20261015-005', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261015-005\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:58:57'),
(123, 2, 'order', 'New website order ORD-20261015-005', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261015-005\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:58:57'),
(124, 3, 'order', 'New website order ORD-20261015-005', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261015-005\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:58:57'),
(126, 9, 'order', 'New website order ORD-20261015-005', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261015-005\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:58:57'),
(127, 66, 'order', 'New website order ORD-20261015-005', 'Reagan Otema placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261015-005\",\"items\":1,\"total\":31050,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 13:58:57'),
(128, 1, 'payment', 'Payment request PAY-20261015-003', 'Reagan Otema started a CARD payment of UGX 31,050 for the order ORD-20261015-005.', '{\"reference\":\"PAY-20261015-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:59:12'),
(129, 2, 'payment', 'Payment request PAY-20261015-003', 'Reagan Otema started a CARD payment of UGX 31,050 for the order ORD-20261015-005.', '{\"reference\":\"PAY-20261015-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:59:12'),
(130, 3, 'payment', 'Payment request PAY-20261015-003', 'Reagan Otema started a CARD payment of UGX 31,050 for the order ORD-20261015-005.', '{\"reference\":\"PAY-20261015-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:59:12'),
(131, 4, 'payment', 'Payment request PAY-20261015-003', 'Reagan Otema started a CARD payment of UGX 31,050 for the order ORD-20261015-005.', '{\"reference\":\"PAY-20261015-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:59:12'),
(133, 66, 'payment', 'Payment request PAY-20261015-003', 'Reagan Otema started a CARD payment of UGX 31,050 for the order ORD-20261015-005.', '{\"reference\":\"PAY-20261015-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"card\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 13:59:12'),
(134, 1, 'order', 'New website order ORD-20261015-006', 'mama mafalda placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-006\",\"items\":1,\"total\":6210,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 16:45:42'),
(135, 2, 'order', 'New website order ORD-20261015-006', 'mama mafalda placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-006\",\"items\":1,\"total\":6210,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 16:45:42'),
(136, 3, 'order', 'New website order ORD-20261015-006', 'mama mafalda placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-006\",\"items\":1,\"total\":6210,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 16:45:42'),
(138, 9, 'order', 'New website order ORD-20261015-006', 'mama mafalda placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-006\",\"items\":1,\"total\":6210,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 16:45:42'),
(139, 66, 'order', 'New website order ORD-20261015-006', 'mama mafalda placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261015-006\",\"items\":1,\"total\":6210,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-15 16:45:42'),
(140, 1, 'payment', 'Payment request PAY-20261015-004', 'mama mafalda started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-006.', '{\"reference\":\"PAY-20261015-004\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 16:45:55'),
(141, 2, 'payment', 'Payment request PAY-20261015-004', 'mama mafalda started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-006.', '{\"reference\":\"PAY-20261015-004\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 16:45:55'),
(142, 3, 'payment', 'Payment request PAY-20261015-004', 'mama mafalda started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-006.', '{\"reference\":\"PAY-20261015-004\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 16:45:55'),
(143, 4, 'payment', 'Payment request PAY-20261015-004', 'mama mafalda started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-006.', '{\"reference\":\"PAY-20261015-004\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 16:45:55'),
(145, 66, 'payment', 'Payment request PAY-20261015-004', 'mama mafalda started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261015-006.', '{\"reference\":\"PAY-20261015-004\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-15 16:45:55'),
(146, 1, 'order', 'New website order ORD-20261016-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261016-001\",\"items\":1,\"total\":15525,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-16 03:41:40'),
(147, 2, 'order', 'New website order ORD-20261016-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261016-001\",\"items\":1,\"total\":15525,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-16 03:41:40'),
(148, 3, 'order', 'New website order ORD-20261016-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261016-001\",\"items\":1,\"total\":15525,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-16 03:41:40'),
(150, 9, 'order', 'New website order ORD-20261016-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261016-001\",\"items\":1,\"total\":15525,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-16 03:41:40'),
(151, 66, 'order', 'New website order ORD-20261016-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 15,525.', '{\"order_number\":\"ORD-20261016-001\",\"items\":1,\"total\":15525,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"Jinja\"}', NULL, '2026-10-16 03:41:40'),
(152, 1, 'payment', 'Payment request PAY-20261016-001', 'Reagan Otema started a MTN_MOMO payment of UGX 15,525 for the order ORD-20261016-001.', '{\"reference\":\"PAY-20261016-001\",\"source\":\"order\",\"amount\":15525,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 03:43:14'),
(153, 2, 'payment', 'Payment request PAY-20261016-001', 'Reagan Otema started a MTN_MOMO payment of UGX 15,525 for the order ORD-20261016-001.', '{\"reference\":\"PAY-20261016-001\",\"source\":\"order\",\"amount\":15525,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 03:43:14'),
(154, 3, 'payment', 'Payment request PAY-20261016-001', 'Reagan Otema started a MTN_MOMO payment of UGX 15,525 for the order ORD-20261016-001.', '{\"reference\":\"PAY-20261016-001\",\"source\":\"order\",\"amount\":15525,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 03:43:14'),
(155, 4, 'payment', 'Payment request PAY-20261016-001', 'Reagan Otema started a MTN_MOMO payment of UGX 15,525 for the order ORD-20261016-001.', '{\"reference\":\"PAY-20261016-001\",\"source\":\"order\",\"amount\":15525,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 03:43:14'),
(157, 66, 'payment', 'Payment request PAY-20261016-001', 'Reagan Otema started a MTN_MOMO payment of UGX 15,525 for the order ORD-20261016-001.', '{\"reference\":\"PAY-20261016-001\",\"source\":\"order\",\"amount\":15525,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 03:43:14'),
(158, 1, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(159, 2, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(160, 3, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(161, 4, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(162, 6, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(163, 66, 'booking', 'New website booking HPN-20261016-001', 'Reagan Otema asked for Triple Room for 3 nights, 2026-10-17 to 2026-10-20. Total UGX 661,365.', '{\"booking_number\":\"HPN-20261016-001\",\"room_type\":\"Triple Room\",\"nights\":3,\"check_in\":\"2026-10-17\",\"check_out\":\"2026-10-20\",\"total\":661365,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:05:53'),
(164, 1, 'payment', 'Payment request PAY-20261016-002', 'Reagan Otema started a MTN_MOMO payment of UGX 661,365 for the booking HPN-20261016-001.', '{\"reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"amount\":661365,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:06:16'),
(165, 2, 'payment', 'Payment request PAY-20261016-002', 'Reagan Otema started a MTN_MOMO payment of UGX 661,365 for the booking HPN-20261016-001.', '{\"reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"amount\":661365,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:06:16'),
(166, 3, 'payment', 'Payment request PAY-20261016-002', 'Reagan Otema started a MTN_MOMO payment of UGX 661,365 for the booking HPN-20261016-001.', '{\"reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"amount\":661365,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:06:16'),
(167, 4, 'payment', 'Payment request PAY-20261016-002', 'Reagan Otema started a MTN_MOMO payment of UGX 661,365 for the booking HPN-20261016-001.', '{\"reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"amount\":661365,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:06:16'),
(169, 66, 'payment', 'Payment request PAY-20261016-002', 'Reagan Otema started a MTN_MOMO payment of UGX 661,365 for the booking HPN-20261016-001.', '{\"reference\":\"PAY-20261016-002\",\"source\":\"booking\",\"amount\":661365,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:06:16'),
(170, 1, 'order', 'New website order ORD-20261016-002', 'mama mafalda placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261016-002\",\"items\":1,\"total\":31050,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-16 13:10:38'),
(171, 2, 'order', 'New website order ORD-20261016-002', 'mama mafalda placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261016-002\",\"items\":1,\"total\":31050,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-16 13:10:38'),
(172, 3, 'order', 'New website order ORD-20261016-002', 'mama mafalda placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261016-002\",\"items\":1,\"total\":31050,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-16 13:10:38');
INSERT INTO `notifications` (`id`, `user_id`, `type`, `title`, `body`, `data`, `read_at`, `created_at`) VALUES
(174, 9, 'order', 'New website order ORD-20261016-002', 'mama mafalda placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261016-002\",\"items\":1,\"total\":31050,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-16 13:10:38'),
(175, 66, 'order', 'New website order ORD-20261016-002', 'mama mafalda placed a takeaway order, 1 item, total UGX 31,050.', '{\"order_number\":\"ORD-20261016-002\",\"items\":1,\"total\":31050,\"guest\":\"mama mafalda\",\"phone\":\"0772514889\",\"address\":\"jinja\"}', NULL, '2026-10-16 13:10:38'),
(176, 1, 'payment', 'Payment request PAY-20261016-003', 'mama mafalda started a MTN_MOMO payment of UGX 31,050 for the order ORD-20261016-002.', '{\"reference\":\"PAY-20261016-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:10:53'),
(177, 2, 'payment', 'Payment request PAY-20261016-003', 'mama mafalda started a MTN_MOMO payment of UGX 31,050 for the order ORD-20261016-002.', '{\"reference\":\"PAY-20261016-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', '2026-10-16 16:23:08', '2026-10-16 13:10:53'),
(178, 3, 'payment', 'Payment request PAY-20261016-003', 'mama mafalda started a MTN_MOMO payment of UGX 31,050 for the order ORD-20261016-002.', '{\"reference\":\"PAY-20261016-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:10:53'),
(179, 4, 'payment', 'Payment request PAY-20261016-003', 'mama mafalda started a MTN_MOMO payment of UGX 31,050 for the order ORD-20261016-002.', '{\"reference\":\"PAY-20261016-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:10:53'),
(181, 66, 'payment', 'Payment request PAY-20261016-003', 'mama mafalda started a MTN_MOMO payment of UGX 31,050 for the order ORD-20261016-002.', '{\"reference\":\"PAY-20261016-003\",\"source\":\"order\",\"amount\":31050,\"method\":\"mtn_momo\",\"guest\":\"mama mafalda\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:10:53'),
(182, 1, 'communication', 'New event enquiry EVT-20261016-001', 'altar at the gates wants to plan other (EVT-20261016-001). 30 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261016-001\",\"event_type\":\"Other\",\"event_date\":\"2026-10-17\",\"guests\":30,\"venue\":\"The Nile Hall\",\"name\":\"altar at the gates\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:19:18'),
(183, 2, 'communication', 'New event enquiry EVT-20261016-001', 'altar at the gates wants to plan other (EVT-20261016-001). 30 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261016-001\",\"event_type\":\"Other\",\"event_date\":\"2026-10-17\",\"guests\":30,\"venue\":\"The Nile Hall\",\"name\":\"altar at the gates\",\"phone\":\"0772514889\"}', '2026-10-16 16:22:11', '2026-10-16 13:19:18'),
(184, 3, 'communication', 'New event enquiry EVT-20261016-001', 'altar at the gates wants to plan other (EVT-20261016-001). 30 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261016-001\",\"event_type\":\"Other\",\"event_date\":\"2026-10-17\",\"guests\":30,\"venue\":\"The Nile Hall\",\"name\":\"altar at the gates\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:19:18'),
(185, 66, 'communication', 'New event enquiry EVT-20261016-001', 'altar at the gates wants to plan other (EVT-20261016-001). 30 guests. 2026-10-17. Please call 0772514889.', '{\"request_number\":\"EVT-20261016-001\",\"event_type\":\"Other\",\"event_date\":\"2026-10-17\",\"guests\":30,\"venue\":\"The Nile Hall\",\"name\":\"altar at the gates\",\"phone\":\"0772514889\"}', NULL, '2026-10-16 13:19:18'),
(186, 1, 'communication', 'New event enquiry EVT-20261017-001', 'Akware olivia wants to plan birthday party (EVT-20261017-001). 10 guests. 2027-06-10. Please call 0761080587.', '{\"request_number\":\"EVT-20261017-001\",\"event_type\":\"Birthday party\",\"event_date\":\"2027-06-10\",\"guests\":10,\"venue\":\"The Riverside Gardens\",\"name\":\"Akware olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:40:12'),
(187, 2, 'communication', 'New event enquiry EVT-20261017-001', 'Akware olivia wants to plan birthday party (EVT-20261017-001). 10 guests. 2027-06-10. Please call 0761080587.', '{\"request_number\":\"EVT-20261017-001\",\"event_type\":\"Birthday party\",\"event_date\":\"2027-06-10\",\"guests\":10,\"venue\":\"The Riverside Gardens\",\"name\":\"Akware olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:40:12'),
(188, 3, 'communication', 'New event enquiry EVT-20261017-001', 'Akware olivia wants to plan birthday party (EVT-20261017-001). 10 guests. 2027-06-10. Please call 0761080587.', '{\"request_number\":\"EVT-20261017-001\",\"event_type\":\"Birthday party\",\"event_date\":\"2027-06-10\",\"guests\":10,\"venue\":\"The Riverside Gardens\",\"name\":\"Akware olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:40:12'),
(189, 66, 'communication', 'New event enquiry EVT-20261017-001', 'Akware olivia wants to plan birthday party (EVT-20261017-001). 10 guests. 2027-06-10. Please call 0761080587.', '{\"request_number\":\"EVT-20261017-001\",\"event_type\":\"Birthday party\",\"event_date\":\"2027-06-10\",\"guests\":10,\"venue\":\"The Riverside Gardens\",\"name\":\"Akware olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:40:12'),
(190, 1, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(191, 2, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(192, 3, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(193, 4, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(194, 6, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(195, 66, 'booking', 'New website booking HPN-20261017-001', 'Reagan Otema asked for Suite for 1 night, 2026-10-18 to 2026-10-19. Total UGX 256,680.', '{\"booking_number\":\"HPN-20261017-001\",\"room_type\":\"Suite\",\"nights\":1,\"check_in\":\"2026-10-18\",\"check_out\":\"2026-10-19\",\"total\":256680,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:36'),
(196, 1, 'payment', 'Payment request PAY-20261017-001', 'Reagan Otema started a MTN_MOMO payment of UGX 256,680 for the booking HPN-20261017-001.', '{\"reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"amount\":256680,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:50'),
(197, 2, 'payment', 'Payment request PAY-20261017-001', 'Reagan Otema started a MTN_MOMO payment of UGX 256,680 for the booking HPN-20261017-001.', '{\"reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"amount\":256680,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:50'),
(198, 3, 'payment', 'Payment request PAY-20261017-001', 'Reagan Otema started a MTN_MOMO payment of UGX 256,680 for the booking HPN-20261017-001.', '{\"reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"amount\":256680,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:50'),
(199, 4, 'payment', 'Payment request PAY-20261017-001', 'Reagan Otema started a MTN_MOMO payment of UGX 256,680 for the booking HPN-20261017-001.', '{\"reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"amount\":256680,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:50'),
(201, 66, 'payment', 'Payment request PAY-20261017-001', 'Reagan Otema started a MTN_MOMO payment of UGX 256,680 for the booking HPN-20261017-001.', '{\"reference\":\"PAY-20261017-001\",\"source\":\"booking\",\"amount\":256680,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-17 08:41:50'),
(202, 1, 'communication', 'New facility enquiry FAQ-20261017-001', 'olivia asked about Health club and gym (FAQ-20261017-001). 2026-10-18. 2 people. Please call 0761080587.', '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"name\":\"olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:43:47'),
(203, 2, 'communication', 'New facility enquiry FAQ-20261017-001', 'olivia asked about Health club and gym (FAQ-20261017-001). 2026-10-18. 2 people. Please call 0761080587.', '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"name\":\"olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:43:47'),
(204, 3, 'communication', 'New facility enquiry FAQ-20261017-001', 'olivia asked about Health club and gym (FAQ-20261017-001). 2026-10-18. 2 people. Please call 0761080587.', '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"name\":\"olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:43:47'),
(205, 6, 'communication', 'New facility enquiry FAQ-20261017-001', 'olivia asked about Health club and gym (FAQ-20261017-001). 2026-10-18. 2 people. Please call 0761080587.', '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"name\":\"olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:43:47'),
(206, 66, 'communication', 'New facility enquiry FAQ-20261017-001', 'olivia asked about Health club and gym (FAQ-20261017-001). 2026-10-18. 2 people. Please call 0761080587.', '{\"enquiry_number\":\"FAQ-20261017-001\",\"facility\":\"Health club and gym\",\"preferred_date\":\"2026-10-18\",\"guests\":2,\"name\":\"olivia\",\"phone\":\"0761080587\"}', NULL, '2026-10-17 08:43:47'),
(207, 1, 'order', 'New website order ORD-20261021-001', 'Atim Jeremiah Okello placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261021-001\",\"items\":1,\"total\":6210,\"guest\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', NULL, '2026-10-21 11:20:40'),
(208, 2, 'order', 'New website order ORD-20261021-001', 'Atim Jeremiah Okello placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261021-001\",\"items\":1,\"total\":6210,\"guest\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', '2026-10-27 17:15:21', '2026-10-21 11:20:40'),
(209, 3, 'order', 'New website order ORD-20261021-001', 'Atim Jeremiah Okello placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261021-001\",\"items\":1,\"total\":6210,\"guest\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', NULL, '2026-10-21 11:20:40'),
(211, 9, 'order', 'New website order ORD-20261021-001', 'Atim Jeremiah Okello placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261021-001\",\"items\":1,\"total\":6210,\"guest\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', NULL, '2026-10-21 11:20:40'),
(212, 66, 'order', 'New website order ORD-20261021-001', 'Atim Jeremiah Okello placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261021-001\",\"items\":1,\"total\":6210,\"guest\":\"Atim Jeremiah Okello\",\"phone\":\"0706407275\",\"address\":\"Main Street\"}', NULL, '2026-10-21 11:20:40'),
(213, 1, 'order', 'New website order ORD-20261021-002', 'WOZISI WILLIAM placed a takeaway order, 1 item, total UGX 38,295.', '{\"order_number\":\"ORD-20261021-002\",\"items\":1,\"total\":38295,\"guest\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', NULL, '2026-10-21 11:21:24'),
(214, 2, 'order', 'New website order ORD-20261021-002', 'WOZISI WILLIAM placed a takeaway order, 1 item, total UGX 38,295.', '{\"order_number\":\"ORD-20261021-002\",\"items\":1,\"total\":38295,\"guest\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', '2026-10-27 17:15:06', '2026-10-21 11:21:24'),
(215, 3, 'order', 'New website order ORD-20261021-002', 'WOZISI WILLIAM placed a takeaway order, 1 item, total UGX 38,295.', '{\"order_number\":\"ORD-20261021-002\",\"items\":1,\"total\":38295,\"guest\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', NULL, '2026-10-21 11:21:24'),
(217, 9, 'order', 'New website order ORD-20261021-002', 'WOZISI WILLIAM placed a takeaway order, 1 item, total UGX 38,295.', '{\"order_number\":\"ORD-20261021-002\",\"items\":1,\"total\":38295,\"guest\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', NULL, '2026-10-21 11:21:24'),
(218, 66, 'order', 'New website order ORD-20261021-002', 'WOZISI WILLIAM placed a takeaway order, 1 item, total UGX 38,295.', '{\"order_number\":\"ORD-20261021-002\",\"items\":1,\"total\":38295,\"guest\":\"WOZISI WILLIAM\",\"phone\":\"0705491314\",\"address\":\"Lubas Rd\"}', NULL, '2026-10-21 11:21:24'),
(219, 1, 'communication', 'New event enquiry EVT-20261025-001', 'Otema Reagan wants to plan wedding (EVT-20261025-001). 200 guests. 2026-12-20. Please call 0772514889.', '{\"request_number\":\"EVT-20261025-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-12-20\",\"guests\":200,\"venue\":\"The Nile Hall\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:25:33'),
(220, 2, 'communication', 'New event enquiry EVT-20261025-001', 'Otema Reagan wants to plan wedding (EVT-20261025-001). 200 guests. 2026-12-20. Please call 0772514889.', '{\"request_number\":\"EVT-20261025-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-12-20\",\"guests\":200,\"venue\":\"The Nile Hall\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:25:33'),
(221, 3, 'communication', 'New event enquiry EVT-20261025-001', 'Otema Reagan wants to plan wedding (EVT-20261025-001). 200 guests. 2026-12-20. Please call 0772514889.', '{\"request_number\":\"EVT-20261025-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-12-20\",\"guests\":200,\"venue\":\"The Nile Hall\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:25:33'),
(222, 66, 'communication', 'New event enquiry EVT-20261025-001', 'Otema Reagan wants to plan wedding (EVT-20261025-001). 200 guests. 2026-12-20. Please call 0772514889.', '{\"request_number\":\"EVT-20261025-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-12-20\",\"guests\":200,\"venue\":\"The Nile Hall\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:25:33'),
(223, 1, 'communication', 'New guest experience', 'Otema Reagan left 5 stars about their stay (GM-20261025-001).', '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"rating\":5,\"room\":\"\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:27:42'),
(224, 2, 'communication', 'New guest experience', 'Otema Reagan left 5 stars about their stay (GM-20261025-001).', '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"rating\":5,\"room\":\"\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:27:42'),
(225, 3, 'communication', 'New guest experience', 'Otema Reagan left 5 stars about their stay (GM-20261025-001).', '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"rating\":5,\"room\":\"\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:27:42'),
(226, 6, 'communication', 'New guest experience', 'Otema Reagan left 5 stars about their stay (GM-20261025-001).', '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"rating\":5,\"room\":\"\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:27:42'),
(227, 66, 'communication', 'New guest experience', 'Otema Reagan left 5 stars about their stay (GM-20261025-001).', '{\"reference\":\"GM-20261025-001\",\"kind\":\"experience\",\"department\":\"front_office\",\"rating\":5,\"room\":\"\",\"name\":\"Otema Reagan\",\"phone\":\"0772514889\"}', NULL, '2026-10-24 23:27:42'),
(228, 1, 'order', 'New website order ORD-20261027-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261027-001\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '2026-10-27 14:01:41'),
(229, 2, 'order', 'New website order ORD-20261027-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261027-001\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '2026-10-27 14:01:41'),
(230, 3, 'order', 'New website order ORD-20261027-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261027-001\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '2026-10-27 14:01:41'),
(232, 9, 'order', 'New website order ORD-20261027-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261027-001\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '2026-10-27 14:01:41'),
(233, 66, 'order', 'New website order ORD-20261027-001', 'Reagan Otema placed a takeaway order, 1 item, total UGX 6,210.', '{\"order_number\":\"ORD-20261027-001\",\"items\":1,\"total\":6210,\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\",\"address\":\"jinja town\"}', NULL, '2026-10-27 14:01:41'),
(234, 1, 'payment', 'Payment request PAY-20261027-001', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261027-001.', '{\"reference\":\"PAY-20261027-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:02:17'),
(235, 2, 'payment', 'Payment request PAY-20261027-001', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261027-001.', '{\"reference\":\"PAY-20261027-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', '2026-10-27 17:14:37', '2026-10-27 14:02:17'),
(236, 3, 'payment', 'Payment request PAY-20261027-001', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261027-001.', '{\"reference\":\"PAY-20261027-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:02:17'),
(237, 4, 'payment', 'Payment request PAY-20261027-001', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261027-001.', '{\"reference\":\"PAY-20261027-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:02:17'),
(239, 66, 'payment', 'Payment request PAY-20261027-001', 'Reagan Otema started a MTN_MOMO payment of UGX 6,210 for the order ORD-20261027-001.', '{\"reference\":\"PAY-20261027-001\",\"source\":\"order\",\"amount\":6210,\"method\":\"mtn_momo\",\"guest\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:02:17'),
(240, 1, 'communication', 'New event enquiry EVT-20261027-001', 'Reagan Otema wants to plan wedding (EVT-20261027-001). 119 guests. 2026-10-29. Please call 0772514889.', '{\"request_number\":\"EVT-20261027-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-10-29\",\"guests\":119,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:07:35'),
(241, 2, 'communication', 'New event enquiry EVT-20261027-001', 'Reagan Otema wants to plan wedding (EVT-20261027-001). 119 guests. 2026-10-29. Please call 0772514889.', '{\"request_number\":\"EVT-20261027-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-10-29\",\"guests\":119,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', '2026-10-27 17:14:08', '2026-10-27 14:07:35'),
(242, 3, 'communication', 'New event enquiry EVT-20261027-001', 'Reagan Otema wants to plan wedding (EVT-20261027-001). 119 guests. 2026-10-29. Please call 0772514889.', '{\"request_number\":\"EVT-20261027-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-10-29\",\"guests\":119,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:07:35'),
(243, 66, 'communication', 'New event enquiry EVT-20261027-001', 'Reagan Otema wants to plan wedding (EVT-20261027-001). 119 guests. 2026-10-29. Please call 0772514889.', '{\"request_number\":\"EVT-20261027-001\",\"event_type\":\"Wedding\",\"event_date\":\"2026-10-29\",\"guests\":119,\"venue\":\"The Nile Hall\",\"name\":\"Reagan Otema\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:07:35'),
(244, 1, 'communication', 'New guest message GM-20261027-001', 'julious frontdesk wrote to the front office (room 68): please hurry am in the bathroom now.', '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"name\":\"julious frontdesk\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:09:59'),
(245, 2, 'communication', 'New guest message GM-20261027-001', 'julious frontdesk wrote to the front office (room 68): please hurry am in the bathroom now.', '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"name\":\"julious frontdesk\",\"phone\":\"0772514889\"}', '2026-10-27 17:13:52', '2026-10-27 14:09:59'),
(246, 3, 'communication', 'New guest message GM-20261027-001', 'julious frontdesk wrote to the front office (room 68): please hurry am in the bathroom now.', '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"name\":\"julious frontdesk\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:09:59'),
(247, 6, 'communication', 'New guest message GM-20261027-001', 'julious frontdesk wrote to the front office (room 68): please hurry am in the bathroom now.', '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"name\":\"julious frontdesk\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:09:59'),
(248, 66, 'communication', 'New guest message GM-20261027-001', 'julious frontdesk wrote to the front office (room 68): please hurry am in the bathroom now.', '{\"reference\":\"GM-20261027-001\",\"kind\":\"message\",\"department\":\"front_office\",\"room\":\"68\",\"name\":\"julious frontdesk\",\"phone\":\"0772514889\"}', NULL, '2026-10-27 14:09:59'),
(249, 1, 'order', 'New website order ORD-20261028-001', 'paiton witness placed a takeaway order, 1 item, total UGX 48,645.', '{\"order_number\":\"ORD-20261028-001\",\"items\":1,\"total\":48645,\"guest\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '2026-10-28 09:22:41'),
(250, 2, 'order', 'New website order ORD-20261028-001', 'paiton witness placed a takeaway order, 1 item, total UGX 48,645.', '{\"order_number\":\"ORD-20261028-001\",\"items\":1,\"total\":48645,\"guest\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '2026-10-28 09:22:41'),
(251, 3, 'order', 'New website order ORD-20261028-001', 'paiton witness placed a takeaway order, 1 item, total UGX 48,645.', '{\"order_number\":\"ORD-20261028-001\",\"items\":1,\"total\":48645,\"guest\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '2026-10-28 09:22:41'),
(253, 9, 'order', 'New website order ORD-20261028-001', 'paiton witness placed a takeaway order, 1 item, total UGX 48,645.', '{\"order_number\":\"ORD-20261028-001\",\"items\":1,\"total\":48645,\"guest\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '2026-10-28 09:22:41'),
(254, 66, 'order', 'New website order ORD-20261028-001', 'paiton witness placed a takeaway order, 1 item, total UGX 48,645.', '{\"order_number\":\"ORD-20261028-001\",\"items\":1,\"total\":48645,\"guest\":\"paiton witness\",\"phone\":\"0750891058\",\"address\":\"mpumudde, jinja.\"}', NULL, '2026-10-28 09:22:41'),
(255, 1, 'payment', 'Payment request PAY-20261028-001', 'paiton witness started a AIRTEL_MONEY payment of UGX 48,645 for the order ORD-20261028-001.', '{\"reference\":\"PAY-20261028-001\",\"source\":\"order\",\"amount\":48645,\"method\":\"airtel_money\",\"guest\":\"paiton witness\",\"phone\":\"0750891058\"}', NULL, '2026-10-28 09:22:49'),
(256, 2, 'payment', 'Payment request PAY-20261028-001', 'paiton witness started a AIRTEL_MONEY payment of UGX 48,645 for the order ORD-20261028-001.', '{\"reference\":\"PAY-20261028-001\",\"source\":\"order\",\"amount\":48645,\"method\":\"airtel_money\",\"guest\":\"paiton witness\",\"phone\":\"0750891058\"}', NULL, '2026-10-28 09:22:49'),
(257, 3, 'payment', 'Payment request PAY-20261028-001', 'paiton witness started a AIRTEL_MONEY payment of UGX 48,645 for the order ORD-20261028-001.', '{\"reference\":\"PAY-20261028-001\",\"source\":\"order\",\"amount\":48645,\"method\":\"airtel_money\",\"guest\":\"paiton witness\",\"phone\":\"0750891058\"}', NULL, '2026-10-28 09:22:49'),
(258, 4, 'payment', 'Payment request PAY-20261028-001', 'paiton witness started a AIRTEL_MONEY payment of UGX 48,645 for the order ORD-20261028-001.', '{\"reference\":\"PAY-20261028-001\",\"source\":\"order\",\"amount\":48645,\"method\":\"airtel_money\",\"guest\":\"paiton witness\",\"phone\":\"0750891058\"}', NULL, '2026-10-28 09:22:49'),
(260, 66, 'payment', 'Payment request PAY-20261028-001', 'paiton witness started a AIRTEL_MONEY payment of UGX 48,645 for the order ORD-20261028-001.', '{\"reference\":\"PAY-20261028-001\",\"source\":\"order\",\"amount\":48645,\"method\":\"airtel_money\",\"guest\":\"paiton witness\",\"phone\":\"0750891058\"}', NULL, '2026-10-28 09:22:49');

-- --------------------------------------------------------

--
-- Table structure for table `notification_deliveries`
--

CREATE TABLE `notification_deliveries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `notification_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `device_id` bigint(20) UNSIGNED DEFAULT NULL,
  `channel` enum('web_push','fcm','apns','in_app') NOT NULL DEFAULT 'web_push',
  `status` enum('queued','accepted','delivered','failed','read') NOT NULL DEFAULT 'queued',
  `provider_message_id` varchar(190) DEFAULT NULL,
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_error` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notification_deliveries`
--

INSERT INTO `notification_deliveries` (`id`, `notification_id`, `user_id`, `device_id`, `channel`, `status`, `provider_message_id`, `attempts`, `last_error`, `created_at`, `updated_at`) VALUES
(1, 26, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-10 16:44:59', '2026-10-10 20:51:53'),
(2, 31, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-10 16:48:28', '2026-10-10 20:51:53'),
(3, 36, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-10 16:49:03', '2026-10-10 20:51:53'),
(4, 41, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-10 20:54:14', '2026-10-11 03:12:55'),
(5, 45, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-10 20:54:40', '2026-10-11 03:12:55'),
(6, 51, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-11 09:44:29', '2026-10-15 03:37:36'),
(7, 56, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-11 09:46:59', '2026-10-15 03:37:36'),
(8, 61, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-11 09:48:21', '2026-10-15 03:37:36'),
(9, 66, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-11 14:46:23', '2026-10-15 03:38:14'),
(10, 71, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-11 14:49:03', '2026-10-15 03:38:14'),
(11, 75, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-13 10:29:48', '2026-10-15 16:58:12'),
(12, 81, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-13 11:19:23', '2026-10-15 16:58:12'),
(13, 87, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 05:12:43', '2026-10-15 17:00:15'),
(14, 93, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 08:29:11', '2026-10-15 17:00:15'),
(15, 99, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 08:31:05', '2026-10-15 17:00:15'),
(16, 105, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 09:21:44', '2026-10-15 17:00:15'),
(17, 111, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 13:13:18', '2026-10-15 17:00:15'),
(18, 117, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 13:13:31', '2026-10-15 17:00:15'),
(19, 123, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 13:58:57', '2026-10-15 17:00:15'),
(20, 129, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 13:59:12', '2026-10-15 17:00:15'),
(21, 135, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 16:45:42', '2026-10-15 17:00:15'),
(22, 141, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-15 16:45:55', '2026-10-15 17:00:15'),
(23, 147, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 03:41:40', '2026-10-16 13:23:43'),
(24, 153, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 03:43:14', '2026-10-16 13:23:43'),
(25, 159, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 13:05:53', '2026-10-16 13:23:43'),
(26, 165, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 13:06:16', '2026-10-16 13:23:43'),
(27, 171, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 13:10:38', '2026-10-16 13:23:43'),
(28, 177, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 13:10:53', '2026-10-16 13:23:43'),
(29, 183, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-16 13:19:18', '2026-10-16 13:23:43'),
(30, 187, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-17 08:40:12', '2026-10-25 15:25:02'),
(31, 191, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-17 08:41:36', '2026-10-25 15:25:02'),
(32, 197, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-17 08:41:50', '2026-10-25 15:25:02'),
(33, 203, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-17 08:43:47', '2026-10-25 15:25:02'),
(34, 208, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-21 11:20:40', '2026-10-25 15:25:02'),
(35, 214, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-21 11:21:24', '2026-10-25 15:25:02'),
(36, 220, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-24 23:25:33', '2026-10-25 15:25:02'),
(37, 224, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-24 23:27:42', '2026-10-25 15:25:02'),
(38, 229, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-27 14:01:41', '2026-10-27 14:13:30'),
(39, 235, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-27 14:02:17', '2026-10-27 14:13:30'),
(40, 241, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-27 14:07:35', '2026-10-27 14:13:30'),
(41, 245, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-27 14:09:59', '2026-10-27 14:13:30'),
(42, 250, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:41', '2026-10-29 04:40:39'),
(43, 250, 2, 2, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:41', '2026-10-29 04:40:39'),
(44, 250, 2, 3, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:41', '2026-10-29 04:40:39'),
(45, 256, 2, 1, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:49', '2026-10-29 04:40:39'),
(46, 256, 2, 2, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:49', '2026-10-29 04:40:39'),
(47, 256, 2, 3, 'web_push', 'failed', NULL, 5, 'Could not build the web push payload', '2026-10-28 09:22:49', '2026-10-29 04:40:39');

-- --------------------------------------------------------

--
-- Table structure for table `notification_devices`
--

CREATE TABLE `notification_devices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `platform` enum('web','android','ios','other') NOT NULL,
  `push_token` varchar(500) NOT NULL,
  `p256dh` varchar(255) DEFAULT NULL,
  `auth` varchar(255) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `user_agent` varchar(255) DEFAULT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `notification_devices`
--

INSERT INTO `notification_devices` (`id`, `user_id`, `platform`, `push_token`, `p256dh`, `auth`, `active`, `user_agent`, `last_seen_at`, `created_at`) VALUES
(1, 2, 'web', 'https://fcm.googleapis.com/fcm/send/dQSwhGlnihM:APA91bGlVCc-UWLbJSHeCkM9AoeGth3S-HcBdOkMHygUNQIX4zWpIBbbq6cIKuLTl_xgvQok4FKV1Lfq4yCKgGQ_DuuKk-7VWrDmVs8aaEzVSi208_eCcdeEn96QvteYk-ewLi_v0FRA', 'BJ1FkswdKer5U07DLqhR-Qi-cP8Sl8041YRiuhFNLXIDNfHn0xXGvpc4auWwXmDhZfLTxxmuYOhUBhHWPeRIh5o', 'UO_wsWz8HD8mkyp2XUD4FQ', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-10 15:31:18', '2026-10-10 12:31:18'),
(2, 2, 'web', 'https://fcm.googleapis.com/fcm/send/dn5O1TX4SFM:APA91bHk7FXrjXbDOQSwksfv0Z1PVNMTJMONpfMNjfyJ4wicjR0j1cvBeUN4QycBpzlvKRav2k6M2pi0LwIxRSPI-361oQEfDWZ1JtgDy-KlmqUiRXBt1HTEb1ejoBmU4erC3_6Ac2l-', 'BPoz9kL5GZP0iroblz1bbe3oK1t3zsfZGSFdaJXZ0eNldNLdB7Je5wDDGQKQ1HWhcKzvQFqkfTvnu4KnPqcJAEQ', 'HX6sVi6kdlrB6-vYbwhyog', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 17:13:42', '2026-10-27 14:13:42'),
(3, 2, 'web', 'https://fcm.googleapis.com/fcm/send/czZR83VyPa0:APA91bFVdZwdNaQML-Ds_7uIEn-7dVtOPaPbqKej9OaCNWIQV95E7-AlgWoEXyBYHB3j6izJkt9aGQbywrFek3QFF8f1NyRH7T_rvY_2JSqXtdlvPHRo34DPflk3-0CWKleWFG00Agdl', 'BHD26vTlUucaMIvUJdXn2qQ0TgF-x9E_aybGozR1IyyJy4e4Sd-4gw5Q7vnV5adFBmwCaON8FLpubGZbLfJFKLs', 'sFiearEp19SLq3tIsBu1Dw', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-27 17:13:42', '2026-10-27 14:13:42');

-- --------------------------------------------------------

--
-- Table structure for table `notification_events`
--

CREATE TABLE `notification_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_key` varchar(190) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `entity_type` varchar(60) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notification_events`
--

INSERT INTO `notification_events` (`id`, `event_key`, `event_type`, `entity_type`, `entity_id`, `created_at`) VALUES
(1, 'booking:HPN-20261009-001', 'booking', NULL, NULL, '2026-10-09 09:26:27'),
(2, 'order:ORD-20261009-001', 'order', NULL, NULL, '2026-10-09 12:18:03'),
(3, 'payment:PAY-20261009-001', 'payment', NULL, NULL, '2026-10-09 12:19:08'),
(4, 'booking:HPN-20261009-002', 'booking', NULL, NULL, '2026-10-09 13:53:21'),
(5, 'booking:HPN-20261009-003', 'booking', NULL, NULL, '2026-10-09 13:57:56'),
(6, 'event:EVT-20261010-001', 'communication', NULL, NULL, '2026-10-10 12:29:44'),
(7, 'order:ORD-20261010-001', 'order', NULL, NULL, '2026-10-10 16:44:59'),
(8, 'order:ORD-20261010-002', 'order', NULL, NULL, '2026-10-10 16:48:28'),
(9, 'payment:PAY-20261010-001', 'payment', NULL, NULL, '2026-10-10 16:49:03'),
(10, 'booking:HPN-20261010-001', 'booking', NULL, NULL, '2026-10-10 20:54:14'),
(11, 'payment:PAY-20261010-002', 'payment', NULL, NULL, '2026-10-10 20:54:40'),
(12, 'booking:HPN-20261011-001', 'booking', NULL, NULL, '2026-10-11 09:44:29'),
(13, 'booking:HPN-20261011-002', 'booking', NULL, NULL, '2026-10-11 09:46:59'),
(14, 'payment:PAY-20261011-001', 'payment', NULL, NULL, '2026-10-11 09:48:21'),
(15, 'order:ORD-20261011-001', 'order', NULL, NULL, '2026-10-11 14:46:23'),
(16, 'event:EVT-20261011-001', 'communication', NULL, NULL, '2026-10-11 14:49:03'),
(17, 'order:ORD-20261013-001', 'order', NULL, NULL, '2026-10-13 10:29:48'),
(18, 'order:ORD-20261013-002', 'order', NULL, NULL, '2026-10-13 11:19:23'),
(19, 'order:ORD-20261015-001', 'order', NULL, NULL, '2026-10-15 05:12:43'),
(20, 'order:ORD-20261015-002', 'order', NULL, NULL, '2026-10-15 08:29:11'),
(21, 'order:ORD-20261015-003', 'order', NULL, NULL, '2026-10-15 08:31:05'),
(22, 'payment:PAY-20261015-001', 'payment', NULL, NULL, '2026-10-15 09:21:44'),
(23, 'order:ORD-20261015-004', 'order', NULL, NULL, '2026-10-15 13:13:18'),
(24, 'payment:PAY-20261015-002', 'payment', NULL, NULL, '2026-10-15 13:13:31'),
(25, 'order:ORD-20261015-005', 'order', NULL, NULL, '2026-10-15 13:58:57'),
(26, 'payment:PAY-20261015-003', 'payment', NULL, NULL, '2026-10-15 13:59:12'),
(27, 'order:ORD-20261015-006', 'order', NULL, NULL, '2026-10-15 16:45:42'),
(28, 'payment:PAY-20261015-004', 'payment', NULL, NULL, '2026-10-15 16:45:55'),
(29, 'order:ORD-20261016-001', 'order', NULL, NULL, '2026-10-16 03:41:40'),
(30, 'payment:PAY-20261016-001', 'payment', NULL, NULL, '2026-10-16 03:43:14'),
(31, 'booking:HPN-20261016-001', 'booking', NULL, NULL, '2026-10-16 13:05:53'),
(32, 'payment:PAY-20261016-002', 'payment', NULL, NULL, '2026-10-16 13:06:16'),
(33, 'order:ORD-20261016-002', 'order', NULL, NULL, '2026-10-16 13:10:38'),
(34, 'payment:PAY-20261016-003', 'payment', NULL, NULL, '2026-10-16 13:10:53'),
(35, 'event:EVT-20261016-001', 'communication', NULL, NULL, '2026-10-16 13:19:18'),
(36, 'event:EVT-20261017-001', 'communication', NULL, NULL, '2026-10-17 08:40:12'),
(37, 'booking:HPN-20261017-001', 'booking', NULL, NULL, '2026-10-17 08:41:36'),
(38, 'payment:PAY-20261017-001', 'payment', NULL, NULL, '2026-10-17 08:41:50'),
(39, 'facility:FAQ-20261017-001', 'communication', NULL, NULL, '2026-10-17 08:43:47'),
(40, 'order:ORD-20261021-001', 'order', NULL, NULL, '2026-10-21 11:20:40'),
(41, 'order:ORD-20261021-002', 'order', NULL, NULL, '2026-10-21 11:21:24'),
(42, 'event:EVT-20261025-001', 'communication', NULL, NULL, '2026-10-24 23:25:33'),
(43, 'gx:GM-20261025-001', 'communication', NULL, NULL, '2026-10-24 23:27:42'),
(44, 'order:ORD-20261027-001', 'order', NULL, NULL, '2026-10-27 14:01:41'),
(45, 'payment:PAY-20261027-001', 'payment', NULL, NULL, '2026-10-27 14:02:17'),
(46, 'event:EVT-20261027-001', 'communication', NULL, NULL, '2026-10-27 14:07:35'),
(47, 'gm:GM-20261027-001', 'communication', NULL, NULL, '2026-10-27 14:09:59'),
(48, 'order:ORD-20261028-001', 'order', NULL, NULL, '2026-10-28 09:22:41'),
(49, 'payment:PAY-20261028-001', 'payment', NULL, NULL, '2026-10-28 09:22:49');

-- --------------------------------------------------------

--
-- Table structure for table `notification_preferences`
--

CREATE TABLE `notification_preferences` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `booking_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `order_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `payment_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `communication_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `incident_alerts` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `shift_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_number` varchar(60) NOT NULL,
  `outlet` enum('restaurant','bar','room_service') NOT NULL,
  `order_type` enum('table','room','takeaway','delivery') NOT NULL,
  `table_name` varchar(60) DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_name` varchar(160) DEFAULT NULL,
  `customer_phone` varchar(40) DEFAULT NULL,
  `customer_email` varchar(190) DEFAULT NULL,
  `delivery_address` varchar(255) DEFAULT NULL,
  `delivery_notes` text DEFAULT NULL,
  `status` enum('pending','accepted','preparing','ready','served','partially_paid','paid','cancelled') DEFAULT 'pending',
  `discount` decimal(14,2) DEFAULT 0.00,
  `subtotal` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `hotel_id`, `user_id`, `shift_id`, `order_number`, `outlet`, `order_type`, `table_name`, `room_id`, `customer_name`, `customer_phone`, `customer_email`, `delivery_address`, `delivery_notes`, `status`, `discount`, `subtotal`, `tax`, `total`, `created_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 1, NULL, 'ORD-20261009-001', 'restaurant', 'takeaway', NULL, NULL, 'Otema Reagan', '+256772514889', 'reaganotema2022@gmail.com', 'Jinja city', 'Add salt', 'pending', 0.00, 13000.00, 455.00, 13455.00, '2026-10-09 12:18:03', NULL, NULL),
(2, 1, 1, NULL, 'ORD-20261010-001', 'restaurant', 'takeaway', NULL, NULL, 'Okot Denis', '+256779562514', 'denisokot47@gmail.com', 'walukuba', 'Please hurry withbmy order i need it now.', 'pending', 0.00, 15000.00, 525.00, 15525.00, '2026-10-10 16:44:59', NULL, NULL),
(3, 1, 1, NULL, 'ORD-20261010-002', 'restaurant', 'takeaway', NULL, NULL, 'Okot Denis', '+256779562514', 'denisokot47@gmail.com', 'Jinja town', 'I need salt.', 'pending', 0.00, 45000.00, 1575.00, 46575.00, '2026-10-10 16:48:28', NULL, NULL),
(4, 1, 1, NULL, 'ORD-20261011-001', 'restaurant', 'takeaway', NULL, NULL, 'mama mafalda', '0772514889', 'reaganotemas@gmail.com', 'jinja', 'less salt', 'pending', 0.00, 15000.00, 525.00, 15525.00, '2026-10-11 14:46:23', NULL, NULL),
(5, 1, 1, NULL, 'ORD-20261013-001', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '+256772514889', 'reaganotema2022@gmail.com', 'JINJA', 'too much salt', 'pending', 0.00, 30000.00, 1050.00, 31050.00, '2026-10-13 10:29:48', NULL, NULL),
(6, 1, 1, NULL, 'ORD-20261013-002', 'restaurant', 'takeaway', NULL, NULL, 'Otema Reagan', '+256772514889', 'reaganotema2022@gmail.com', 'Jinja', 'Less salt', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-13 11:19:23', NULL, NULL),
(7, 1, 1, NULL, 'ORD-20261015-001', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'Jinja', 'Less salt', 'pending', 0.00, 71000.00, 2485.00, 73485.00, '2026-10-15 05:12:43', NULL, NULL),
(8, 1, 1, NULL, 'ORD-20261015-002', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'Jinja', 'Less salt', 'pending', 0.00, 50000.00, 1750.00, 51750.00, '2026-10-15 08:29:11', NULL, NULL),
(9, 1, 1, NULL, 'ORD-20261015-003', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'jinja mpummude', 'please make sure the food is hot', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-15 08:31:05', NULL, NULL),
(10, 1, 1, NULL, 'ORD-20261015-004', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'jinja', 'not salty', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-15 13:13:18', NULL, NULL),
(11, 1, 1, NULL, 'ORD-20261015-005', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'jinja', 'not salty', 'pending', 0.00, 30000.00, 1050.00, 31050.00, '2026-10-15 13:58:57', NULL, NULL),
(12, 1, 1, NULL, 'ORD-20261015-006', 'restaurant', 'takeaway', NULL, NULL, 'mama mafalda', '0772514889', 'reaganotemas@gmail.com', 'jinja', 'put less salt', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-15 16:45:42', NULL, NULL),
(13, 1, 1, NULL, 'ORD-20261016-001', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'Jinja', 'Less salt', 'pending', 0.00, 15000.00, 525.00, 15525.00, '2026-10-16 03:41:40', NULL, NULL),
(14, 1, 1, NULL, 'ORD-20261016-002', 'restaurant', 'takeaway', NULL, NULL, 'mama mafalda', '0772514889', 'reaganotemas@gmail.com', 'jinja', 'put less salt', 'pending', 0.00, 30000.00, 1050.00, 31050.00, '2026-10-16 13:10:38', NULL, NULL),
(15, 1, 1, NULL, 'ORD-20261021-001', 'restaurant', 'takeaway', NULL, NULL, 'Atim Jeremiah Okello', '0706407275', 'jeremiahotile@gmail.com', 'Main Street', '', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-21 11:20:40', NULL, NULL),
(16, 1, 1, NULL, 'ORD-20261021-002', 'restaurant', 'takeaway', NULL, NULL, 'WOZISI WILLIAM', '0705491314', 'willywozisi@gmail.com', 'Lubas Rd', '', 'pending', 0.00, 37000.00, 1295.00, 38295.00, '2026-10-21 11:21:24', NULL, NULL),
(17, 1, 1, NULL, 'ORD-20261027-001', 'restaurant', 'takeaway', NULL, NULL, 'Reagan Otema', '0772514889', 'reaganotema2022@gmail.com', 'jinja town', 'less salt', 'pending', 0.00, 6000.00, 210.00, 6210.00, '2026-10-27 14:01:41', NULL, NULL),
(18, 1, 1, NULL, 'ORD-20261028-001', 'restaurant', 'takeaway', NULL, NULL, 'paiton witness', '0750891058', 'paiton@gmail.com', 'mpumudde, jinja.', 'less salt please.', 'pending', 0.00, 47000.00, 1645.00, 48645.00, '2026-10-28 09:22:41', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `menu_item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `custom_name` varchar(190) DEFAULT NULL,
  `quantity` decimal(12,2) NOT NULL,
  `unit_price` decimal(14,2) NOT NULL,
  `total` decimal(14,2) NOT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `menu_item_id`, `custom_name`, `quantity`, `unit_price`, `total`, `notes`) VALUES
(1, 1, 2282, NULL, 1.00, 13000.00, 13000.00, 'Web takeaway order from Otema Reagan, +256772514889'),
(2, 2, 2279, NULL, 1.00, 15000.00, 15000.00, 'Web takeaway order from Okot Denis, +256779562514'),
(3, 3, 24, NULL, 1.00, 45000.00, 45000.00, 'Web takeaway order from Okot Denis, +256779562514'),
(4, 4, 2290, NULL, 1.00, 15000.00, 15000.00, 'Web takeaway order from mama mafalda, 0772514889'),
(5, 5, 2294, NULL, 1.00, 30000.00, 30000.00, 'Web takeaway order from Reagan Otema, +256772514889'),
(6, 6, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Otema Reagan, +256772514889'),
(7, 7, 2389, NULL, 1.00, 65000.00, 65000.00, 'Web takeaway order from Reagan Otema, 0772514889 Ã¢â‚¬â€ Companion: Chips. Also: Grilled Veggies Salad, Tuna Salad.'),
(8, 7, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(9, 8, 2398, NULL, 1.00, 50000.00, 50000.00, 'Web takeaway order from Reagan Otema, 0772514889 Ã¢â‚¬â€ Companion: As it comes. Also: Tuna Salad.'),
(10, 9, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(11, 10, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(12, 11, 2293, NULL, 1.00, 30000.00, 30000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(13, 12, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from mama mafalda, 0772514889'),
(14, 13, 2320, NULL, 1.00, 15000.00, 15000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(15, 14, 2294, NULL, 1.00, 30000.00, 30000.00, 'Web takeaway order from mama mafalda, 0772514889'),
(16, 15, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Atim Jeremiah Okello, 0706407275'),
(17, 16, 2406, NULL, 1.00, 37000.00, 37000.00, 'Web takeaway order from WOZISI WILLIAM, 0705491314 Ã¢â‚¬â€ Companion: Chips.'),
(18, 17, 2292, NULL, 1.00, 6000.00, 6000.00, 'Web takeaway order from Reagan Otema, 0772514889'),
(19, 18, 2318, NULL, 1.00, 47000.00, 47000.00, 'Web takeaway order from paiton witness, 0750891058');

-- --------------------------------------------------------

--
-- Table structure for table `outlets`
--

CREATE TABLE `outlets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `code` varchar(60) NOT NULL,
  `outlet_type` enum('restaurant','bar','pool','spa','room_service','laundry','shop','other') NOT NULL DEFAULT 'other',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `customer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `invoice_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `shift_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL,
  `method` varchar(50) NOT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `provider_reference` varchar(190) DEFAULT NULL,
  `checkout_token` varchar(190) DEFAULT NULL,
  `status` enum('pending','successful','failed','refunded','reversed') DEFAULT 'pending',
  `verified_at` datetime DEFAULT NULL,
  `gateway_result` text DEFAULT NULL,
  `payer_phone` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `hotel_id`, `user_id`, `customer_id`, `invoice_id`, `order_id`, `shift_id`, `reservation_id`, `amount`, `method`, `provider`, `provider_reference`, `checkout_token`, `status`, `verified_at`, `gateway_result`, `payer_phone`, `created_at`) VALUES
(1, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(2, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(3, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(4, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(5, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(6, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(7, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(8, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(9, 1, 6, NULL, 1, NULL, NULL, 1, 744000.00, 'cash', NULL, NULL, NULL, 'successful', NULL, NULL, NULL, NULL),
(10, 1, NULL, 1, NULL, 1, NULL, NULL, 13455.00, 'card', 'pesapal', 'PAY-20261009-001', NULL, 'pending', NULL, NULL, NULL, '2026-10-09 12:19:08'),
(11, 1, NULL, 3, NULL, 3, NULL, NULL, 46575.00, 'mtn_momo', 'pesapal', 'PAY-20261010-001', NULL, 'successful', NULL, NULL, NULL, '2026-10-10 16:49:03'),
(12, 1, NULL, 1, NULL, NULL, NULL, 37, 264960.00, 'mtn_momo', 'pesapal', 'PAY-20261010-002', NULL, 'successful', NULL, NULL, NULL, '2026-10-10 20:54:40'),
(13, 1, NULL, 4, NULL, NULL, NULL, 39, 324990.00, 'mtn_momo', 'pesapal', 'PAY-20261011-001', NULL, 'successful', NULL, NULL, NULL, '2026-10-11 09:48:21'),
(14, 1, NULL, 1, NULL, 9, NULL, NULL, 6210.00, 'card', 'pesapal', 'PAY-20261015-001', 'b1794a8e8bada8cf5e960c45eee53ae2', 'pending', NULL, '{\"gateway\":\"pesapal\",\"tracking_id\":\"4e20c044-bcd2-43a2-8f85-d9c8b786c508\",\"env\":\"live\",\"initiated_at\":\"2026-10-15T12:21:46+03:00\"}', NULL, '2026-10-15 09:21:44'),
(15, 1, NULL, 1, NULL, 10, NULL, NULL, 6210.00, 'mtn_momo', 'pesapal', 'PAY-20261015-002', 'dfd39218f470a9d8ac3fedb1b44b6cc2', 'pending', NULL, '{\"gateway\":\"pesapal\",\"tracking_id\":\"27311cfd-a6f7-4a5d-88f7-d9c87a7054f3\",\"env\":\"live\",\"initiated_at\":\"2026-10-15T16:13:34+03:00\"}', NULL, '2026-10-15 13:13:31'),
(16, 1, NULL, 1, NULL, 11, NULL, NULL, 31050.00, 'mtn_momo', 'pesapal', 'PAY-20261015-003', '367cc4c2d176b18656080039b6a6519c', 'failed', '2026-10-15 17:06:22', '{\"gateway\":\"pesapal\",\"tracking_id\":\"c4337c8c-f453-4dad-84e3-d9c8ed5aa6f6\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":31050,\"created_date\":\"2026-10-15T17:06:22.117\",\"confirmation_code\":\"44251459812\",\"order_tracking_id\":\"c4337c8c-f453-4dad-84e3-d9c8ed5aa6f6\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx14889\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261015-003&OrderTrackingId=c4337c8c-f453-4dad-84e3-d9c8ed5aa6f6&OrderMerchantReference=PAY-20261015-003\",\"status_code\":2,\"merchant_reference\":\"PAY-20261015-003\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx14889', '2026-10-15 13:59:12'),
(17, 1, NULL, 4, NULL, 12, NULL, NULL, 6210.00, 'mtn_momo', 'pesapal', 'PAY-20261015-004', '1e5490c8053b7bec2788480fe998ee09', 'failed', '2026-10-15 19:53:24', '{\"gateway\":\"pesapal\",\"tracking_id\":\"085c626b-a3d3-402f-90c8-d9c8cd5b22e7\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":6210,\"created_date\":\"2026-10-15T19:53:23.477\",\"confirmation_code\":\"44257084334\",\"order_tracking_id\":\"085c626b-a3d3-402f-90c8-d9c8cd5b22e7\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx27243\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261015-004&OrderTrackingId=085c626b-a3d3-402f-90c8-d9c8cd5b22e7&OrderMerchantReference=PAY-20261015-004\",\"status_code\":2,\"merchant_reference\":\"PAY-20261015-004\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx27243', '2026-10-15 16:45:55'),
(18, 1, NULL, 1, NULL, 13, NULL, NULL, 15525.00, 'mtn_momo', 'pesapal', 'PAY-20261016-001', '8a1fddbb0b218329b88b3ea0484e88d1', 'failed', '2026-10-16 06:49:32', '{\"gateway\":\"pesapal\",\"tracking_id\":\"bc2818be-cf10-4d14-a8e9-d9c7ce756d17\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":15525,\"created_date\":\"2026-10-16T06:49:32.077\",\"confirmation_code\":\"44264178790\",\"order_tracking_id\":\"bc2818be-cf10-4d14-a8e9-d9c7ce756d17\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx14889\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261016-001&OrderTrackingId=bc2818be-cf10-4d14-a8e9-d9c7ce756d17&OrderMerchantReference=PAY-20261016-001\",\"status_code\":2,\"merchant_reference\":\"PAY-20261016-001\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx14889', '2026-10-16 03:43:14'),
(19, 1, NULL, 4, NULL, NULL, NULL, 40, 661365.00, 'mtn_momo', 'pesapal', 'PAY-20261016-002', '72afaef855f73f058aad2d58dd5f0423', 'failed', '2026-10-16 16:08:34', '{\"gateway\":\"pesapal\",\"tracking_id\":\"a3c09c5f-57fd-4534-83ca-d9c7dbd48267\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":661365,\"created_date\":\"2026-10-16T16:08:35.077\",\"confirmation_code\":\"3B18A9161026M\",\"order_tracking_id\":\"a3c09c5f-57fd-4534-83ca-d9c7dbd48267\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx55519\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261016-002&OrderTrackingId=a3c09c5f-57fd-4534-83ca-d9c7dbd48267&OrderMerchantReference=PAY-20261016-002\",\"status_code\":2,\"merchant_reference\":\"PAY-20261016-002\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx55519', '2026-10-16 13:06:16'),
(20, 1, NULL, 4, NULL, 14, NULL, NULL, 31050.00, 'mtn_momo', 'pesapal', 'PAY-20261016-003', '503bffbcfc7a38114b6da858f24076ea', 'failed', '2026-10-16 16:17:21', '{\"gateway\":\"pesapal\",\"tracking_id\":\"dd02f908-a902-46fe-9113-d9c703f67a4c\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":31050,\"created_date\":\"2026-10-16T16:17:21.21\",\"confirmation_code\":\"44275586634\",\"order_tracking_id\":\"dd02f908-a902-46fe-9113-d9c703f67a4c\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx14889\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261016-003&OrderTrackingId=dd02f908-a902-46fe-9113-d9c703f67a4c&OrderMerchantReference=PAY-20261016-003\",\"status_code\":2,\"merchant_reference\":\"PAY-20261016-003\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx14889', '2026-10-16 13:10:53'),
(21, 1, NULL, 1, NULL, NULL, NULL, 41, 256680.00, 'mtn_momo', 'pesapal', 'PAY-20261017-001', '98b02307bea5a73265647c5d52f0c1c0', 'pending', NULL, '{\"gateway\":\"pesapal\",\"tracking_id\":\"ee1dfc58-a3d2-4bfc-86e5-d9c65f8a9188\",\"env\":\"live\",\"initiated_at\":\"2026-10-17T11:41:52+03:00\"}', NULL, '2026-10-17 08:41:50'),
(22, 1, NULL, 1, NULL, 17, NULL, NULL, 6210.00, 'mtn_momo', 'pesapal', 'PAY-20261027-001', 'b05812d81531a906326e1d5d62784706', 'failed', '2026-10-27 17:10:21', '{\"gateway\":\"pesapal\",\"tracking_id\":\"dc22c289-9f61-43c9-9d22-d9bc23d7d57b\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":6210,\"created_date\":\"2026-10-27T17:10:20.657\",\"confirmation_code\":\"44581987317\",\"order_tracking_id\":\"dc22c289-9f61-43c9-9d22-d9bc23d7d57b\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx14889\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261027-001&OrderTrackingId=dc22c289-9f61-43c9-9d22-d9bc23d7d57b&OrderMerchantReference=PAY-20261027-001\",\"status_code\":2,\"merchant_reference\":\"PAY-20261027-001\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx14889', '2026-10-27 14:02:17'),
(23, 1, NULL, 8, NULL, 18, NULL, NULL, 48645.00, 'mtn_momo', 'pesapal', 'PAY-20261028-001', 'e23a02943cde5a7203cef697d398d5e9', 'failed', '2026-10-28 12:25:11', '{\"gateway\":\"pesapal\",\"tracking_id\":\"9111b2b1-5bdb-45f5-8711-d9bbedfd4445\",\"code\":2,\"description\":\"Failed\",\"raw\":{\"payment_method\":\"MTNUG\",\"amount\":48645,\"created_date\":\"2026-10-28T12:25:11.513\",\"confirmation_code\":\"3C47DD281026P\",\"order_tracking_id\":\"9111b2b1-5bdb-45f5-8711-d9bbedfd4445\",\"payment_status_description\":\"Failed\",\"description\":null,\"message\":\"Request processed successfully\",\"payment_account\":\"2567xxx91058\",\"call_back_url\":\"https://hotelparadiseonthenile.info/backend-php/api.php?act=pesapal_callback&reference=PAY-20261028-001&OrderTrackingId=9111b2b1-5bdb-45f5-8711-d9bbedfd4445&OrderMerchantReference=PAY-20261028-001\",\"status_code\":2,\"merchant_reference\":\"PAY-20261028-001\",\"account_number\":null,\"payment_status_code\":\"\",\"currency\":\"UGX\",\"error\":{\"error_type\":null,\"code\":null,\"message\":null},\"status\":\"200\"}}', '2567xxx91058', '2026-10-28 09:22:49');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(150) NOT NULL,
  `display_name` varchar(190) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pool_visits`
--

CREATE TABLE `pool_visits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `visitor_name` varchar(190) DEFAULT NULL,
  `entry_time` datetime DEFAULT current_timestamp(),
  `exit_time` datetime DEFAULT NULL,
  `fee` decimal(14,2) DEFAULT 0.00,
  `payment_status` enum('unpaid','paid','waived') DEFAULT 'unpaid',
  `recorded_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pos_payments`
--

CREATE TABLE `pos_payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sale_id` bigint(20) UNSIGNED NOT NULL,
  `payment_method` enum('cash','card','mobile_money','bank_transfer','room_charge','other') NOT NULL,
  `provider` varchar(120) DEFAULT NULL,
  `provider_reference` varchar(190) DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL,
  `status` enum('pending','successful','failed','refunded','reversed') DEFAULT 'successful',
  `paid_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pos_sales`
--

CREATE TABLE `pos_sales` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `outlet_id` bigint(20) UNSIGNED DEFAULT NULL,
  `terminal_id` bigint(20) UNSIGNED NOT NULL,
  `shift_id` bigint(20) UNSIGNED DEFAULT NULL,
  `order_id` bigint(20) UNSIGNED DEFAULT NULL,
  `receipt_number` varchar(100) NOT NULL,
  `subtotal` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `discount` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00,
  `status` enum('completed','voided','refunded','partially_refunded') DEFAULT 'completed',
  `sold_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pos_sale_items`
--

CREATE TABLE `pos_sale_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sale_id` bigint(20) UNSIGNED NOT NULL,
  `menu_item_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(14,3) DEFAULT 1.000,
  `unit_price` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `discount` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pos_terminals`
--

CREATE TABLE `pos_terminals` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `outlet_id` bigint(20) UNSIGNED DEFAULT NULL,
  `terminal_code` varchar(80) NOT NULL,
  `name` varchar(120) NOT NULL,
  `device_identifier` varchar(190) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pos_voids_refunds`
--

CREATE TABLE `pos_voids_refunds` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `sale_id` bigint(20) UNSIGNED NOT NULL,
  `type` enum('void','refund') NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `reason` text NOT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('requested','approved','rejected','completed') DEFAULT 'requested',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_group_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `code` varchar(50) NOT NULL,
  `city` varchar(100) DEFAULT 'Jinja',
  `country` varchar(100) DEFAULT 'Uganda',
  `address` text DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `currency` char(3) NOT NULL DEFAULT 'UGX',
  `timezone` varchar(64) NOT NULL DEFAULT 'Africa/Kampala',
  `check_in_time` time DEFAULT '14:00:00',
  `check_out_time` time DEFAULT '11:00:00',
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`id`, `hotel_group_id`, `name`, `code`, `city`, `country`, `address`, `phone`, `email`, `currency`, `timezone`, `check_in_time`, `check_out_time`, `active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Hotel Paradise on the Nile', 'HPN-JINJA', 'Jinja', 'Uganda', NULL, NULL, NULL, 'UGX', 'Africa/Kampala', '14:00:00', '11:00:00', 1, '2026-10-05 05:04:19', '2026-10-05 05:04:19');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_orders`
--

CREATE TABLE `purchase_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `number` varchar(40) NOT NULL,
  `supplier_id` bigint(20) UNSIGNED NOT NULL,
  `requisition_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('draft','sent','partially_received','received','cancelled') DEFAULT 'sent',
  `expected_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_order_items`
--

CREATE TABLE `purchase_order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` decimal(14,2) NOT NULL,
  `unit_cost` decimal(14,2) NOT NULL,
  `total` decimal(14,2) NOT NULL,
  `received_qty` decimal(14,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_requisitions`
--

CREATE TABLE `purchase_requisitions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `number` varchar(40) NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `requested_by` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL,
  `decision_reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchase_requisition_items`
--

CREATE TABLE `purchase_requisition_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `requisition_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `requested_qty` decimal(14,2) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `est_cost` decimal(14,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `receipt_deliveries`
--

CREATE TABLE `receipt_deliveries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `payment_id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL DEFAULT 1,
  `source` varchar(20) NOT NULL DEFAULT '',
  `reference` varchar(120) NOT NULL DEFAULT '',
  `channel` enum('email','print','staff') NOT NULL DEFAULT 'email',
  `recipient` varchar(190) NOT NULL DEFAULT '',
  `status` enum('sent','failed') NOT NULL DEFAULT 'failed',
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_error` varchar(500) DEFAULT NULL,
  `provider_message_id` varchar(190) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `receipt_deliveries`
--

INSERT INTO `receipt_deliveries` (`id`, `payment_id`, `hotel_id`, `source`, `reference`, `channel`, `recipient`, `status`, `attempts`, `last_error`, `provider_message_id`, `created_at`, `updated_at`) VALUES
(1, 11, 1, 'order', 'ORD-20261010-002', 'email', 'denisokot47@gmail.com', 'sent', 1, NULL, NULL, '2026-10-10 19:49:03', '2026-10-10 19:49:03'),
(2, 11, 1, 'order', 'ORD-20261010-002', 'staff', 'director@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 19:49:03', '2026-10-10 19:49:03'),
(3, 11, 1, 'order', 'ORD-20261010-002', 'staff', 'cashier@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 19:49:04', '2026-10-10 19:49:04'),
(4, 11, 1, 'order', 'ORD-20261010-002', 'staff', 'kitchen@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 19:49:04', '2026-10-10 19:49:04'),
(5, 11, 1, 'order', 'ORD-20261010-002', 'staff', 'staff@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 19:49:04', '2026-10-10 19:49:04'),
(6, 12, 1, 'booking', 'HPN-20261010-001', 'email', 'reaganotema2022@gmail.com', 'sent', 1, NULL, NULL, '2026-10-10 23:54:40', '2026-10-10 23:54:40'),
(7, 12, 1, 'booking', 'HPN-20261010-001', 'staff', 'director@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 23:54:40', '2026-10-10 23:54:40'),
(8, 12, 1, 'booking', 'HPN-20261010-001', 'staff', 'accounts@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 23:54:40', '2026-10-10 23:54:40'),
(9, 12, 1, 'booking', 'HPN-20261010-001', 'staff', 'frontdesk@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 23:54:41', '2026-10-10 23:54:41'),
(10, 12, 1, 'booking', 'HPN-20261010-001', 'staff', 'staff@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-10 23:54:41', '2026-10-10 23:54:41'),
(11, 13, 1, 'booking', 'HPN-20261011-002', 'email', 'reaganotema2022@gmail.com', 'sent', 1, NULL, NULL, '2026-10-11 12:48:21', '2026-10-11 12:48:21'),
(12, 13, 1, 'booking', 'HPN-20261011-002', 'staff', 'director@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-11 12:48:21', '2026-10-11 12:48:21'),
(13, 13, 1, 'booking', 'HPN-20261011-002', 'staff', 'accounts@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-11 12:48:21', '2026-10-11 12:48:21'),
(14, 13, 1, 'booking', 'HPN-20261011-002', 'staff', 'frontdesk@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-11 12:48:22', '2026-10-11 12:48:22'),
(15, 13, 1, 'booking', 'HPN-20261011-002', 'staff', 'staff@hotelparadiseonthenile.info', 'sent', 1, NULL, NULL, '2026-10-11 12:48:22', '2026-10-11 12:48:22');

-- --------------------------------------------------------

--
-- Table structure for table `reception_activity_log`
--

CREATE TABLE `reception_activity_log` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `activity_type` varchar(100) NOT NULL,
  `notes` text DEFAULT NULL,
  `consent_recorded` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reception_records`
--

CREATE TABLE `reception_records` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `category` varchar(100) NOT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `title` varchar(190) NOT NULL,
  `description` text NOT NULL,
  `status` enum('open','acknowledged','assigned','resolved','closed') DEFAULT 'open',
  `owner_acknowledged_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reservations`
--

CREATE TABLE `reservations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED NOT NULL,
  `booking_number` varchar(60) NOT NULL,
  `source` enum('website','walk_in','phone','email','agent','other') DEFAULT 'walk_in',
  `check_in` datetime NOT NULL,
  `check_out` datetime NOT NULL,
  `adults` int(11) DEFAULT 1,
  `children` int(11) DEFAULT 0,
  `status` enum('pending','confirmed','checked_in','checked_out','cancelled','no_show') DEFAULT 'pending',
  `room_rate` decimal(14,2) DEFAULT 0.00,
  `nights` int(11) DEFAULT 1,
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00,
  `tax` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `paid` decimal(14,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `reservations`
--

INSERT INTO `reservations` (`id`, `hotel_id`, `guest_id`, `booking_number`, `source`, `check_in`, `check_out`, `adults`, `children`, `status`, `room_rate`, `nights`, `subtotal`, `tax`, `total`, `paid`, `notes`, `created_at`, `updated_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 1, 'HPN-20260925-001', 'phone', '2026-09-25 14:00:00', '2026-09-28 11:00:00', 2, 0, 'checked_in', 248000.00, 3, 744000.00, 0.00, 744000.00, 744000.00, 'Birthday weekend by the Nile', '2026-10-05 05:33:34', NULL, NULL, NULL),
(2, 1, 2, 'HPN-20260925-002', 'website', '2026-10-02 14:00:00', '2026-10-04 11:00:00', 2, 1, 'confirmed', 202000.00, 2, 404000.00, 0.00, 404000.00, 0.00, '', '2026-10-05 05:33:34', NULL, NULL, NULL),
(3, 1, 3, 'HPN-20260925-003', 'walk_in', '2026-10-05 14:00:00', '2026-10-07 11:00:00', 3, 0, 'confirmed', 213000.00, 2, 426000.00, 0.00, 426000.00, 0.00, '', '2026-10-05 05:33:34', NULL, NULL, NULL),
(4, 1, 4, 'HPN-20260925-004', 'agent', '2026-09-20 14:00:00', '2026-09-23 11:00:00', 2, 0, 'checked_out', 314000.00, 3, 942000.00, 0.00, 942000.00, 942000.00, 'Family holiday', '2026-10-05 05:33:34', NULL, NULL, NULL),
(34, 1, 46, 'HPN-20261009-001', 'website', '2026-10-10 14:00:00', '2026-10-23 11:00:00', 1, 0, 'confirmed', 248000.00, 13, 3224000.00, 112840.00, 3336840.00, 0.00, NULL, '2026-10-09 09:26:27', '2026-10-09 11:39:55', NULL, NULL),
(35, 1, 46, 'HPN-20261009-002', 'website', '2026-10-10 14:00:00', '2026-10-15 11:00:00', 1, 0, 'pending', 314000.00, 5, 1570000.00, 54950.00, 1624950.00, 0.00, NULL, '2026-10-09 13:53:21', NULL, NULL, NULL),
(36, 1, 46, 'HPN-20261009-003', 'website', '2026-10-10 14:00:00', '2026-10-15 11:00:00', 1, 0, 'pending', 314000.00, 5, 1570000.00, 54950.00, 1624950.00, 0.00, NULL, '2026-10-09 13:57:56', NULL, NULL, NULL),
(37, 1, 46, 'HPN-20261010-001', 'website', '2026-10-11 14:00:00', '2026-10-13 11:00:00', 2, 0, 'pending', 128000.00, 2, 256000.00, 8960.00, 264960.00, 0.00, NULL, '2026-10-10 20:54:14', NULL, NULL, NULL),
(38, 1, 46, 'HPN-20261011-001', 'website', '2026-10-12 14:00:00', '2026-10-13 11:00:00', 1, 0, 'pending', 314000.00, 1, 314000.00, 10990.00, 324990.00, 0.00, NULL, '2026-10-11 09:44:29', NULL, NULL, NULL),
(39, 1, 46, 'HPN-20261011-002', 'website', '2026-10-12 14:00:00', '2026-10-13 11:00:00', 1, 0, 'cancelled', 314000.00, 1, 314000.00, 10990.00, 324990.00, 0.00, NULL, '2026-10-11 09:46:59', '2026-10-14 08:51:19', '2026-10-14 10:07:26', 2),
(40, 1, 46, 'HPN-20261016-001', 'website', '2026-10-17 14:00:00', '2026-10-20 11:00:00', 1, 0, 'pending', 213000.00, 3, 639000.00, 22365.00, 661365.00, 0.00, NULL, '2026-10-16 13:05:53', NULL, NULL, NULL),
(41, 1, 46, 'HPN-20261017-001', 'website', '2026-10-18 14:00:00', '2026-10-19 11:00:00', 1, 0, 'pending', 248000.00, 1, 248000.00, 8680.00, 256680.00, 0.00, NULL, '2026-10-17 08:41:36', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `reservation_rooms`
--

CREATE TABLE `reservation_rooms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `reservation_id` bigint(20) UNSIGNED NOT NULL,
  `room_type_id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `nightly_rate` decimal(14,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `reservation_rooms`
--

INSERT INTO `reservation_rooms` (`id`, `reservation_id`, `room_type_id`, `room_id`, `quantity`, `nightly_rate`) VALUES
(1, 1, 57, 1, 1, 248000.00),
(2, 2, 60, 30, 1, 202000.00),
(3, 3, 59, 15, 1, 213000.00),
(4, 4, 58, 8, 1, 314000.00),
(37, 34, 57, NULL, 1, 248000.00),
(38, 35, 58, NULL, 1, 314000.00),
(39, 36, 58, NULL, 1, 314000.00),
(40, 37, 63, NULL, 1, 128000.00),
(41, 38, 58, NULL, 1, 314000.00),
(42, 39, 58, NULL, 1, 314000.00),
(43, 40, 59, NULL, 1, 213000.00),
(44, 41, 57, NULL, 1, 248000.00);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`) VALUES
(4, 'accountant'),
(16, 'auditor'),
(8, 'bar_staff'),
(5, 'cashier'),
(2, 'director'),
(14, 'events_manager'),
(3, 'general_manager'),
(98, 'guest'),
(12, 'housekeeping'),
(161, 'human_resource'),
(97, 'inventory_manager'),
(9, 'kitchen'),
(13, 'maintenance'),
(15, 'marketing'),
(11, 'procurement'),
(6, 'receptionist'),
(10, 'storekeeper'),
(1, 'super_admin'),
(7, 'waiter');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `permission_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `room_type_id` bigint(20) UNSIGNED NOT NULL,
  `room_number` varchar(30) NOT NULL,
  `floor` varchar(30) DEFAULT NULL,
  `status` enum('available','reserved','occupied','dirty','cleaning','inspected','maintenance','out_of_service') DEFAULT 'available',
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_number`, `floor`, `status`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 57, 'S101', 'Floor 1', 'occupied', NULL, NULL),
(2, 1, 57, 'S102', 'Floor 1', 'available', NULL, NULL),
(3, 1, 57, 'S103', 'Floor 1', 'available', NULL, NULL),
(4, 1, 57, 'S104', 'Floor 1', 'available', NULL, NULL),
(5, 1, 57, 'S105', 'Floor 1', 'available', NULL, NULL),
(6, 1, 57, 'S106', 'Floor 1', 'available', NULL, NULL),
(8, 1, 58, 'F101', 'Floor 1', 'available', NULL, NULL),
(9, 1, 58, 'F102', 'Floor 1', 'available', NULL, NULL),
(10, 1, 58, 'F103', 'Floor 1', 'available', NULL, NULL),
(11, 1, 58, 'F104', 'Floor 1', 'available', NULL, NULL),
(12, 1, 58, 'F105', 'Floor 1', 'available', NULL, NULL),
(13, 1, 58, 'F106', 'Floor 1', 'available', NULL, NULL),
(14, 1, 58, 'F107', 'Floor 1', 'available', NULL, NULL),
(15, 1, 59, 'T201', 'Floor 2', 'available', NULL, NULL),
(16, 1, 59, 'T202', 'Floor 2', 'available', NULL, NULL),
(17, 1, 59, 'T203', 'Floor 2', 'available', NULL, NULL),
(18, 1, 59, 'T204', 'Floor 2', 'available', NULL, NULL),
(19, 1, 59, 'T205', 'Floor 2', 'available', NULL, NULL),
(20, 1, 59, 'T206', 'Floor 2', 'available', NULL, NULL),
(21, 1, 59, 'T207', 'Floor 2', 'available', NULL, NULL),
(22, 1, 59, 'T208', 'Floor 2', 'available', NULL, NULL),
(23, 1, 59, 'T209', 'Floor 2', 'available', NULL, NULL),
(24, 1, 59, 'T210', 'Floor 2', 'available', NULL, NULL),
(25, 1, 59, 'T211', 'Floor 2', 'available', NULL, NULL),
(26, 1, 59, 'T212', 'Floor 2', 'available', NULL, NULL),
(30, 1, 60, 'ED201', 'Floor 2', 'available', NULL, NULL),
(31, 1, 60, 'ED202', 'Floor 2', 'available', NULL, NULL),
(32, 1, 60, 'ED203', 'Floor 2', 'available', NULL, NULL),
(33, 1, 60, 'ED204', 'Floor 2', 'available', NULL, NULL),
(34, 1, 60, 'ED205', 'Floor 2', 'available', NULL, NULL),
(35, 1, 60, 'ED206', 'Floor 2', 'available', NULL, NULL),
(36, 1, 60, 'ED207', 'Floor 2', 'available', NULL, NULL),
(37, 1, 60, 'ED208', 'Floor 2', 'available', NULL, NULL),
(38, 1, 60, 'ED209', 'Floor 2', 'available', NULL, NULL),
(39, 1, 60, 'ED210', 'Floor 2', 'available', NULL, NULL),
(45, 1, 61, 'DD301', 'Floor 3', 'available', NULL, NULL),
(46, 1, 61, 'DD302', 'Floor 3', 'available', NULL, NULL),
(47, 1, 61, 'DD303', 'Floor 3', 'available', NULL, NULL),
(48, 1, 61, 'DD304', 'Floor 3', 'available', NULL, NULL),
(49, 1, 61, 'DD305', 'Floor 3', 'available', NULL, NULL),
(50, 1, 61, 'DD306', 'Floor 3', 'available', NULL, NULL),
(51, 1, 61, 'DD307', 'Floor 3', 'available', NULL, NULL),
(52, 1, 61, 'DD308', 'Floor 3', 'available', NULL, NULL),
(53, 1, 61, 'DD309', 'Floor 3', 'available', NULL, NULL),
(54, 1, 61, 'DD310', 'Floor 3', 'available', NULL, NULL),
(55, 1, 61, 'DD311', 'Floor 3', 'available', NULL, NULL),
(56, 1, 61, 'DD312', 'Floor 3', 'available', NULL, NULL),
(57, 1, 61, 'DD313', 'Floor 3', 'available', NULL, NULL),
(58, 1, 61, 'DD314', 'Floor 3', 'available', NULL, NULL),
(60, 1, 62, 'TW301', 'Floor 3', 'available', NULL, NULL),
(61, 1, 62, 'TW302', 'Floor 3', 'available', NULL, NULL),
(62, 1, 62, 'TW303', 'Floor 3', 'available', NULL, NULL),
(63, 1, 62, 'TW304', 'Floor 3', 'available', NULL, NULL),
(64, 1, 62, 'TW305', 'Floor 3', 'available', NULL, NULL),
(65, 1, 62, 'TW306', 'Floor 3', 'available', NULL, NULL),
(66, 1, 62, 'TW307', 'Floor 3', 'available', NULL, NULL),
(67, 1, 62, 'TW308', 'Floor 3', 'available', NULL, NULL),
(68, 1, 62, 'TW309', 'Floor 3', 'available', NULL, NULL),
(69, 1, 62, 'TW310', 'Floor 3', 'available', NULL, NULL),
(70, 1, 62, 'TW311', 'Floor 3', 'available', NULL, NULL),
(71, 1, 62, 'TW312', 'Floor 3', 'available', NULL, NULL),
(75, 1, 63, 'SG301', 'Floor 3', 'available', NULL, NULL),
(76, 1, 63, 'SG302', 'Floor 3', 'available', NULL, NULL),
(77, 1, 63, 'SG303', 'Floor 3', 'available', NULL, NULL),
(78, 1, 63, 'SG304', 'Floor 3', 'available', NULL, NULL),
(79, 1, 63, 'SG305', 'Floor 3', 'available', NULL, NULL),
(80, 1, 63, 'SG306', 'Floor 3', 'available', NULL, NULL),
(81, 1, 63, 'SG307', 'Floor 3', 'available', NULL, NULL),
(82, 1, 63, 'SG308', 'Floor 3', 'available', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `room_status_history`
--

CREATE TABLE `room_status_history` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `room_id` bigint(20) UNSIGNED NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) NOT NULL,
  `changed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `room_types`
--

CREATE TABLE `room_types` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text DEFAULT NULL,
  `max_guests` int(11) NOT NULL DEFAULT 1,
  `base_rate` decimal(14,2) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `room_types`
--

INSERT INTO `room_types` (`id`, `hotel_id`, `name`, `description`, `max_guests`, `base_rate`, `active`, `deleted_at`, `deleted_by`) VALUES
(57, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1, NULL, NULL),
(58, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1, NULL, NULL),
(59, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1, NULL, NULL),
(60, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1, NULL, NULL),
(61, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1, NULL, NULL),
(62, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1, NULL, NULL),
(63, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(128) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` mediumtext DEFAULT NULL,
  `last_activity` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `shifts`
--

CREATE TABLE `shifts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `outlet` enum('restaurant','bar','front_desk','kitchen','store') NOT NULL,
  `opened_at` datetime NOT NULL,
  `closed_at` datetime DEFAULT NULL,
  `opening_cash` decimal(14,2) DEFAULT 0.00,
  `expected_cash` decimal(14,2) DEFAULT 0.00,
  `counted_cash` decimal(14,2) DEFAULT 0.00,
  `variance` decimal(14,2) DEFAULT 0.00,
  `status` enum('open','closed') DEFAULT 'open'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `shifts`
--

INSERT INTO `shifts` (`id`, `hotel_id`, `user_id`, `outlet`, `opened_at`, `closed_at`, `opening_cash`, `expected_cash`, `counted_cash`, `variance`, `status`) VALUES
(1, 1, 2, 'restaurant', '2026-10-27 17:23:16', NULL, 0.00, 0.00, 0.00, 0.00, 'open'),
(2, 1, 8, 'bar', '2026-10-29 08:13:33', NULL, 0.00, 0.00, 0.00, 0.00, 'open');

-- --------------------------------------------------------

--
-- Table structure for table `spa_appointments`
--

CREATE TABLE `spa_appointments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `service_id` bigint(20) UNSIGNED NOT NULL,
  `therapist_id` bigint(20) UNSIGNED DEFAULT NULL,
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  `status` enum('booked','checked_in','in_progress','completed','cancelled','no_show') DEFAULT 'booked',
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `spa_services`
--

CREATE TABLE `spa_services` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `duration_minutes` int(11) DEFAULT 60,
  `price` decimal(14,2) DEFAULT 0.00,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `staff_profiles`
--

CREATE TABLE `staff_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `staff_number` varchar(80) NOT NULL,
  `job_title` varchar(150) DEFAULT NULL,
  `employment_type` varchar(80) DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `national_id` varchar(100) DEFAULT NULL,
  `emergency_contact` varchar(190) DEFAULT NULL,
  `emergency_phone` varchar(50) DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stock_counts`
--

CREATE TABLE `stock_counts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `count_number` varchar(40) NOT NULL,
  `status` enum('draft','final') DEFAULT 'draft',
  `counted_by` bigint(20) UNSIGNED NOT NULL,
  `counted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stock_count_items`
--

CREATE TABLE `stock_count_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `count_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `system_qty` decimal(14,2) NOT NULL,
  `counted_qty` decimal(14,2) NOT NULL,
  `variance` decimal(14,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `stock_levels`
--

CREATE TABLE `stock_levels` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `location` varchar(60) NOT NULL DEFAULT 'Main Store',
  `quantity` decimal(14,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `stock_levels`
--

INSERT INTO `stock_levels` (`id`, `hotel_id`, `item_id`, `location`, `quantity`) VALUES
(1, 1, 1, 'Main Store', 20.00),
(2, 1, 2, 'Main Store', 15.00),
(3, 1, 3, 'Main Store', 30.00),
(4, 1, 4, 'Main Store', 5.00),
(5, 1, 5, 'Main Store', 25.00),
(6, 1, 6, 'Main Store', 30.00),
(7, 1, 7, 'Main Store', 3.00),
(8, 1, 8, 'Main Store', 8.00),
(9, 1, 9, 'Main Store', 40.00),
(10, 1, 10, 'Main Store', 100.00),
(11, 1, 11, 'Main Store', 10.00),
(12, 1, 12, 'Main Store', 6.00),
(13, 1, 13, 'Main Store', 15.00),
(14, 1, 14, 'Main Store', 8.00),
(15, 1, 15, 'Main Store', 25.00);

-- --------------------------------------------------------

--
-- Table structure for table `stock_movements`
--

CREATE TABLE `stock_movements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `item_id` bigint(20) UNSIGNED NOT NULL,
  `location` varchar(60) NOT NULL,
  `type` enum('purchase_in','issue','waste','transfer_in','transfer_out','count_adjust','opening') NOT NULL,
  `quantity` decimal(14,2) NOT NULL,
  `unit_cost` decimal(14,2) DEFAULT 0.00,
  `reference_type` varchar(60) DEFAULT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `contact_person` varchar(120) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `tax_id` varchar(80) DEFAULT NULL,
  `active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `hotel_id`, `name`, `contact_person`, `phone`, `email`, `address`, `tax_id`, `active`, `created_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(2, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(3, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(4, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(5, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(6, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(7, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(8, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(9, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(10, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(11, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(12, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(13, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(14, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(15, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(16, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(17, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(18, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(19, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(20, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(21, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(22, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(23, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(24, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(25, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(26, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(27, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(28, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(29, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(30, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(31, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(32, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(33, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(34, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(35, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(36, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(37, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(38, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(39, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(40, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL),
(41, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL, NULL, NULL),
(42, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL, NULL, NULL),
(43, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL, NULL, NULL),
(44, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL, NULL, NULL),
(45, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `system_filters`
--

CREATE TABLE `system_filters` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `screen_key` varchar(100) NOT NULL,
  `filter_key` varchar(100) NOT NULL,
  `filter_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED DEFAULT NULL,
  `setting_key` varchar(190) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `is_encrypted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `thread_members`
--

CREATE TABLE `thread_members` (
  `thread_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `joined_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transport_requests`
--

CREATE TABLE `transport_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `vehicle_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pickup_location` varchar(255) NOT NULL,
  `destination` varchar(255) NOT NULL,
  `pickup_at` datetime NOT NULL,
  `status` enum('requested','assigned','in_progress','completed','cancelled') DEFAULT 'requested',
  `fee` decimal(14,2) DEFAULT 0.00,
  `created_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `two_factor_settings`
--

CREATE TABLE `two_factor_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT 0,
  `secret_encrypted` text DEFAULT NULL,
  `recovery_codes_encrypted` text DEFAULT NULL,
  `enabled_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED DEFAULT NULL,
  `name` varchar(190) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `status` enum('pending','active','suspended') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `deleted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `hotel_id`, `name`, `email`, `phone`, `password_hash`, `status`, `created_at`, `updated_at`, `profile_image`, `last_login_at`, `password_changed_at`, `deleted_at`, `deleted_by`) VALUES
(1, 1, 'Reagan Otema (Administrator)', 'admin@hotelparadiseonthenile.info', '0772 514 889', '$2y$10$j6OYaPsHSYx7pFkmJ5.QFebkCRxpcqI62S/v8a8W4oio.6dyh1hoC', 'active', NULL, NULL, NULL, NULL, '2026-10-10 15:44:38', NULL, NULL),
(2, 1, 'Hotel Director', 'director@hotelparadiseonthenile.info', '+256 774 000 001', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 1, 'General Manager', 'gm@hotelparadiseonthenile.info', '+256 774 000 002', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(4, 1, 'Finance Officer', 'accounts@hotelparadiseonthenile.info', '+256 774 000 003', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 1, 'Cashier', 'cashier@hotelparadiseonthenile.info', '+256 774 000 004', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, '2026-10-29 04:41:28', NULL, NULL, NULL, NULL, NULL),
(6, 1, 'Front Desk Reception', 'frontdesk@hotelparadiseonthenile.info', '+256 774 000 005', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, 1, 'Restaurant Waiter', 'waiter@hotelparadiseonthenile.info', '+256 774 000 006', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(8, 1, 'Bar Staff', 'bar@hotelparadiseonthenile.info', '+256 774 000 007', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(9, 1, 'Kitchen', 'kitchen@hotelparadiseonthenile.info', '+256 774 000 008', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, 1, 'Storekeeper', 'store@hotelparadiseonthenile.info', '+256 774 000 009', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(11, 1, 'Procurement Officer', 'procurement@hotelparadiseonthenile.info', '+256 774 000 010', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, 1, 'Housekeeping', 'housekeeping@hotelparadiseonthenile.info', '+256 774 000 011', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(13, 1, 'Internal Auditor', 'auditor@hotelparadiseonthenile.info', '+256 774 000 012', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(66, 1, 'Hotel Paradise Staff', 'staff@hotelparadiseonthenile.info', NULL, '$2y$12$AlYTQE166maMuA7ATDHIBu/E/heL54nmxEUSWcbxDlWp.Ytp.hGL.', 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_department_access`
--

CREATE TABLE `user_department_access` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `job_title` varchar(150) DEFAULT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `gender` varchar(30) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  `national_id` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `emergency_contact_name` varchar(190) DEFAULT NULL,
  `emergency_contact_phone` varchar(50) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_profiles`
--

INSERT INTO `user_profiles` (`id`, `user_id`, `profile_image`, `job_title`, `department_id`, `gender`, `date_of_birth`, `nationality`, `national_id`, `address`, `city`, `emergency_contact_name`, `emergency_contact_phone`, `bio`, `updated_at`) VALUES
(1, 66, NULL, 'Hotel Paradise Staff', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Hotel Paradise on the Nile management system user', '2026-10-05 05:03:06');

-- --------------------------------------------------------

--
-- Table structure for table `user_property_access`
--

CREATE TABLE `user_property_access` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 16),
(66, 1),
(66, 2),
(66, 3),
(66, 4),
(66, 5),
(66, 6),
(66, 7),
(66, 8),
(66, 9),
(66, 10),
(66, 11),
(66, 12),
(66, 13),
(66, 14),
(66, 15),
(66, 16);

-- --------------------------------------------------------

--
-- Table structure for table `user_sessions`
--

CREATE TABLE `user_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `session_hash` char(64) NOT NULL,
  `ip_address` varchar(64) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `last_seen_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `revoked_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `property_id` bigint(20) UNSIGNED NOT NULL,
  `registration_number` varchar(50) NOT NULL,
  `vehicle_name` varchar(120) NOT NULL,
  `driver_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('available','on_trip','maintenance','inactive') DEFAULT 'available'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `voice_recordings`
--

CREATE TABLE `voice_recordings` (
  `id` int(10) UNSIGNED NOT NULL,
  `hotel_id` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `filename` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `filesize` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `mime_type` varchar(120) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `voids`
--

CREATE TABLE `voids` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `ref_type` enum('order','payment','invoice','reservation') NOT NULL,
  `ref_id` bigint(20) UNSIGNED NOT NULL,
  `reason` varchar(255) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `website_integration_settings`
--

CREATE TABLE `website_integration_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(120) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `website_integration_settings`
--

INSERT INTO `website_integration_settings` (`id`, `setting_key`, `setting_value`, `updated_at`) VALUES
(1, 'domain', 'https://hotelparadiseonthenile.info', '2026-10-05 05:03:06'),
(2, 'system_path', '/system/', '2026-10-05 05:03:06'),
(3, 'hotel_name', 'Hotel Paradise on the Nile', '2026-10-05 05:03:06'),
(4, 'designer', 'Reagansoft Innovation Limited', '2026-10-05 05:03:06');

-- --------------------------------------------------------

--
-- Table structure for table `website_settings`
--

CREATE TABLE `website_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `website_settings`
--

INSERT INTO `website_settings` (`id`, `setting_key`, `setting_value`, `created_at`, `updated_at`) VALUES
(1, 'site_name', 'Hotel Paradise on the Nile', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(2, 'legal_name', 'Hotel Paradise on the Nile Ltd', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(3, 'address', 'Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(4, 'po_box', 'P.O. Box 1139, Jinja, Uganda', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(5, 'phone_primary', '+256 759 504 928', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(6, 'phone_secondary', '+256 773 565 668', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(7, 'email', 'frontdesk@hotelparadiseonthenile.info', '2026-10-05 05:31:09', '2026-10-09 07:17:53'),
(8, 'website', 'www.hotelparadiseonthenile.info', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(9, 'certification', 'UNBS Certified (US 130:2017)', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(10, 'management_system_path', '/system/', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
(11, 'designed_by', 'Reagansoft Innovation Limited', '2026-10-05 05:31:09', '2026-10-05 05:31:09');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `approvals`
--
ALTER TABLE `approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_approval_property` (`property_id`),
  ADD KEY `fk_approval_requester` (`requested_by`),
  ADD KEY `fk_approval_approver` (`approver_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_att_staff` (`staff_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_action_created` (`action`,`created_at`),
  ADD KEY `idx_audit_created` (`created_at`),
  ADD KEY `idx_audit_day` (`created_at`),
  ADD KEY `hp_perf_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `hp_perf_audit_created` (`created_at`);

--
-- Indexes for table `beds`
--
ALTER TABLE `beds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `call_logs`
--
ALTER TABLE `call_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_call_property` (`property_id`),
  ADD KEY `fk_call_caller` (`caller_id`),
  ADD KEY `fk_call_callee` (`callee_id`);

--
-- Indexes for table `cashier_shifts`
--
ALTER TABLE `cashier_shifts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_shift_terminal` (`terminal_id`),
  ADD KEY `fk_shift_opened` (`opened_by`),
  ADD KEY `fk_shift_closed` (`closed_by`);

--
-- Indexes for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_account_code` (`property_id`,`account_code`),
  ADD KEY `fk_coa_parent` (`parent_id`);

--
-- Indexes for table `communication_calls`
--
ALTER TABLE `communication_calls`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `caller_user_id` (`caller_user_id`),
  ADD KEY `receiver_user_id` (`receiver_user_id`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_customers_email` (`email`),
  ADD UNIQUE KEY `uniq_customers_google` (`google_sub`),
  ADD KEY `idx_customers_phone` (`phone`);

--
-- Indexes for table `customer_addresses`
--
ALTER TABLE `customer_addresses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_customer_addr` (`customer_id`);

--
-- Indexes for table `customer_documents`
--
ALTER TABLE `customer_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_customer_docs` (`customer_id`);

--
-- Indexes for table `customer_signin_attempts`
--
ALTER TABLE `customer_signin_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_attempt_ip` (`ip_address`),
  ADD KEY `idx_attempt_email` (`email`);

--
-- Indexes for table `customer_tokens`
--
ALTER TABLE `customer_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_token_hash` (`token_hash`),
  ADD KEY `idx_token_customer` (`customer_id`),
  ADD KEY `idx_token_expires` (`expires_at`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `department_messages`
--
ALTER TABLE `department_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `recipient_user_id` (`recipient_user_id`),
  ADD KEY `recipient_department_id` (`recipient_department_id`);

--
-- Indexes for table `department_threads`
--
ALTER TABLE `department_threads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_thread_property` (`property_id`),
  ADD KEY `fk_thread_department` (`department_id`),
  ADD KEY `fk_thread_creator` (`created_by`);

--
-- Indexes for table `dining_tables`
--
ALTER TABLE `dining_tables`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_dining_table` (`outlet_id`,`table_number`),
  ADD KEY `hp_pos_table_outlet_status` (`outlet_id`,`status`);

--
-- Indexes for table `efris_attempts`
--
ALTER TABLE `efris_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_efris_attempt_invoice` (`efris_invoice_id`);

--
-- Indexes for table `efris_invoices`
--
ALTER TABLE `efris_invoices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_efris_invoice` (`invoice_id`);

--
-- Indexes for table `efris_transactions`
--
ALTER TABLE `efris_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_event_property` (`property_id`);

--
-- Indexes for table `event_bookings`
--
ALTER TABLE `event_bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_event_booking_event` (`event_id`),
  ADD KEY `fk_event_booking_guest` (`guest_id`);

--
-- Indexes for table `event_requests`
--
ALTER TABLE `event_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_event_number` (`request_number`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `requested_by` (`requested_by`),
  ADD KEY `idx_exp_status` (`status`),
  ADD KEY `idx_expenses_status` (`status`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `hp_perf_expense_status` (`status`);

--
-- Indexes for table `facility_enquiries`
--
ALTER TABLE `facility_enquiries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_enquiry_number` (`enquiry_number`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `finance_bank_accounts`
--
ALTER TABLE `finance_bank_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fin_bank_method` (`method`,`active`),
  ADD KEY `idx_fin_bank_active` (`active`);

--
-- Indexes for table `finance_bank_transactions`
--
ALTER TABLE `finance_bank_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fin_bank_tx_account` (`account_id`,`transaction_date`),
  ADD KEY `idx_fin_bank_tx_status` (`status`,`transaction_date`),
  ADD KEY `idx_fin_bank_tx_ref` (`reference`);

--
-- Indexes for table `finance_cash_movements`
--
ALTER TABLE `finance_cash_movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fin_cash_shift` (`shift_id`,`created_at`),
  ADD KEY `idx_fin_cash_status` (`status`,`created_at`),
  ADD KEY `idx_fin_cash_type` (`movement_type`,`created_at`);

--
-- Indexes for table `finance_reconciliations`
--
ALTER TABLE `finance_reconciliations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fin_recon_account` (`account_id`,`period_end`),
  ADD KEY `idx_fin_recon_status` (`status`,`period_end`);

--
-- Indexes for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `financial_periods`
--
ALTER TABLE `financial_periods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_period` (`property_id`,`start_date`,`end_date`);

--
-- Indexes for table `folios`
--
ALTER TABLE `folios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_folio_number` (`folio_number`),
  ADD KEY `fk_folio_property` (`property_id`),
  ADD KEY `fk_folio_guest` (`guest_id`),
  ADD KEY `fk_folio_res` (`reservation_id`);

--
-- Indexes for table `folio_items`
--
ALTER TABLE `folio_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_folio_item_folio` (`folio_id`),
  ADD KEY `fk_folio_item_dept` (`department_id`);

--
-- Indexes for table `goods_received`
--
ALTER TABLE `goods_received`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_grn_number` (`grn_number`),
  ADD KEY `fk_grn_po` (`purchase_order_id`),
  ADD KEY `fk_grn_property` (`property_id`),
  ADD KEY `fk_grn_user` (`received_by`);

--
-- Indexes for table `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `idx_guest_email` (`email`),
  ADD KEY `idx_guest_phone` (`phone`),
  ADD KEY `idx_guests_email` (`email`),
  ADD KEY `idx_guests_phone` (`phone`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `hp_perf_guest_email` (`email`),
  ADD KEY `hp_perf_guest_phone` (`phone`);

--
-- Indexes for table `guest_accounts`
--
ALTER TABLE `guest_accounts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_guest_account_user` (`user_id`);

--
-- Indexes for table `guest_documents`
--
ALTER TABLE `guest_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_guest_doc_guest` (`guest_id`);

--
-- Indexes for table `guest_folio_entries`
--
ALTER TABLE `guest_folio_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reservation_id` (`reservation_id`);

--
-- Indexes for table `guest_messages`
--
ALTER TABLE `guest_messages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_gm_reference` (`reference`),
  ADD KEY `idx_gm_status` (`status`),
  ADD KEY `idx_gm_dept_status` (`department`,`status`),
  ADD KEY `idx_gm_kind_status` (`kind`,`status`),
  ADD KEY `idx_gm_assigned` (`assigned_to`),
  ADD KEY `idx_gm_created` (`created_at`);

--
-- Indexes for table `hotels`
--
ALTER TABLE `hotels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `hotel_groups`
--
ALTER TABLE `hotel_groups`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `housekeeping_tasks`
--
ALTER TABLE `housekeeping_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_hk_property` (`property_id`),
  ADD KEY `fk_hk_room` (`room_id`),
  ADD KEY `fk_hk_assignee` (`assigned_to`),
  ADD KEY `fk_hk_verifier` (`verified_by`);

--
-- Indexes for table `integrity_flags`
--
ALTER TABLE `integrity_flags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_integrity_flag_key` (`flag_key`),
  ADD KEY `idx_integrity_status` (`status`),
  ADD KEY `idx_integrity_severity` (`severity`),
  ADD KEY `idx_integrity_type` (`flag_type`);

--
-- Indexes for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `idx_inv_active` (`active`),
  ADD KEY `idx_inventory_active` (`active`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `hp_perf_inventory_active` (`active`);

--
-- Indexes for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_im_property` (`property_id`),
  ADD KEY `fk_im_item` (`item_id`),
  ADD KEY `fk_im_department` (`department_id`),
  ADD KEY `fk_im_user` (`created_by`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `idx_invoices_guest` (`guest_id`),
  ADD KEY `idx_invoices_open` (`hotel_id`,`status`,`issued_at`),
  ADD KEY `idx_invoices_status` (`status`),
  ADD KEY `idx_invoices_issued_at` (`issued_at`),
  ADD KEY `idx_invoices_billing_name` (`billing_name`),
  ADD KEY `idx_invoices_billing_email` (`billing_email`);

--
-- Indexes for table `invoice_events`
--
ALTER TABLE `invoice_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice_events_invoice` (`invoice_id`),
  ADD KEY `idx_invoice_events_created` (`created_at`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice_items_no` (`invoice_id`,`item_no`);

--
-- Indexes for table `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_entry_number` (`entry_number`),
  ADD KEY `fk_je_property` (`property_id`),
  ADD KEY `fk_je_period` (`period_id`),
  ADD KEY `fk_je_creator` (`created_by`),
  ADD KEY `fk_je_poster` (`posted_by`),
  ADD KEY `idx_fin_journal_source` (`source_type`,`source_id`);

--
-- Indexes for table `journal_lines`
--
ALTER TABLE `journal_lines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_jl_entry` (`journal_entry_id`),
  ADD KEY `fk_jl_account` (`account_id`);

--
-- Indexes for table `kitchen_order_items`
--
ALTER TABLE `kitchen_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_koi_order_item` (`order_item_id`),
  ADD KEY `fk_koi_station` (`station_id`);

--
-- Indexes for table `kitchen_stations`
--
ALTER TABLE `kitchen_stations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ks_property` (`property_id`);

--
-- Indexes for table `laundry_items`
--
ALTER TABLE `laundry_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_li_order` (`laundry_order_id`);

--
-- Indexes for table `laundry_orders`
--
ALTER TABLE `laundry_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_laundry_order` (`order_number`),
  ADD KEY `fk_laundry_property` (`property_id`),
  ADD KEY `fk_laundry_guest` (`guest_id`),
  ADD KEY `fk_laundry_room` (`room_id`);

--
-- Indexes for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_leave_staff` (`staff_id`),
  ADD KEY `fk_leave_approver` (`approved_by`);

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_login_user` (`user_id`);

--
-- Indexes for table `lost_property`
--
ALTER TABLE `lost_property`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_lp_property` (`property_id`),
  ADD KEY `fk_lp_room` (`room_id`),
  ADD KEY `fk_lp_guest` (`guest_id`),
  ADD KEY `fk_lp_finder` (`found_by`);

--
-- Indexes for table `maintenance_assets`
--
ALTER TABLE `maintenance_assets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_asset_code` (`property_id`,`asset_code`);

--
-- Indexes for table `maintenance_tickets`
--
ALTER TABLE `maintenance_tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_mt_property` (`property_id`),
  ADD KEY `fk_mt_department` (`department_id`),
  ADD KEY `fk_mt_room` (`room_id`),
  ADD KEY `fk_mt_asset` (`asset_id`),
  ADD KEY `fk_mt_reporter` (`reported_by`),
  ADD KEY `fk_mt_assignee` (`assigned_to`);

--
-- Indexes for table `menu_categories`
--
ALTER TABLE `menu_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `message_reads`
--
ALTER TABLE `message_reads`
  ADD PRIMARY KEY (`message_id`,`user_id`),
  ADD KEY `fk_mr_user` (`user_id`);

--
-- Indexes for table `news_posts`
--
ALTER TABLE `news_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_news_slug` (`slug`),
  ADD KEY `idx_news_cat` (`category`),
  ADD KEY `idx_news_status` (`status`,`publish_at`),
  ADD KEY `idx_news_pinned` (`pinned`,`publish_at`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_notification_user` (`user_id`);

--
-- Indexes for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_delivery_once` (`notification_id`,`device_id`),
  ADD KEY `idx_delivery_user` (`user_id`),
  ADD KEY `idx_delivery_status` (`status`);

--
-- Indexes for table `notification_devices`
--
ALTER TABLE `notification_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_push_token` (`push_token`(191)),
  ADD KEY `fk_nd_user` (`user_id`);

--
-- Indexes for table `notification_events`
--
ALTER TABLE `notification_events`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_event_key` (`event_key`),
  ADD KEY `idx_event_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `idx_ord_created` (`created_at`),
  ADD KEY `idx_ord_status` (`status`),
  ADD KEY `idx_ord_outlet` (`outlet`),
  ADD KEY `idx_orders_status` (`status`),
  ADD KEY `idx_orders_outlet` (`outlet`),
  ADD KEY `idx_orders_day` (`created_at`),
  ADD KEY `hp_perf_ord_status` (`status`),
  ADD KEY `hp_perf_ord_outlet` (`outlet`),
  ADD KEY `hp_perf_ord_created` (`created_at`),
  ADD KEY `hp_pos_ord_shift_status` (`shift_id`,`status`),
  ADD KEY `hp_pos_ord_day_outlet` (`created_at`,`outlet`,`status`),
  ADD KEY `hp_pos_ord_customer_phone` (`customer_phone`),
  ADD KEY `hp_pos_ord_room_status` (`room_id`,`status`,`created_at`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `menu_item_id` (`menu_item_id`),
  ADD KEY `hp_order_items_custom_name` (`custom_name`);

--
-- Indexes for table `outlets`
--
ALTER TABLE `outlets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_outlet` (`property_id`,`code`),
  ADD KEY `fk_outlet_department` (`department_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_reset_user` (`user_id`),
  ADD KEY `idx_reset_expiry` (`expires_at`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_payments_checkout_token` (`checkout_token`),
  ADD KEY `idx_pay_order` (`order_id`),
  ADD KEY `idx_pay_res` (`reservation_id`),
  ADD KEY `idx_pay_cust` (`customer_id`),
  ADD KEY `idx_pay_status_created` (`status`,`created_at`),
  ADD KEY `idx_pay_provider_ref` (`provider_reference`),
  ADD KEY `idx_payments_order` (`order_id`),
  ADD KEY `idx_payments_reservation` (`reservation_id`),
  ADD KEY `idx_payments_customer` (`customer_id`),
  ADD KEY `idx_payments_invoice` (`invoice_id`),
  ADD KEY `idx_pay_user` (`user_id`),
  ADD KEY `hp_perf_pay_order` (`order_id`),
  ADD KEY `hp_perf_pay_reservation` (`reservation_id`),
  ADD KEY `hp_perf_pay_created` (`created_at`),
  ADD KEY `hp_perf_pay_customer` (`customer_id`),
  ADD KEY `hp_pos_pay_order_status` (`order_id`,`status`),
  ADD KEY `hp_pos_pay_shift_cash` (`shift_id`,`status`,`method`,`created_at`),
  ADD KEY `hp_pos_pay_user_cash` (`user_id`,`status`,`method`,`created_at`),
  ADD KEY `hp_pos_pay_method_day` (`status`,`method`,`created_at`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_permission_name` (`name`);

--
-- Indexes for table `pool_visits`
--
ALTER TABLE `pool_visits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pool_property` (`property_id`),
  ADD KEY `fk_pool_guest` (`guest_id`),
  ADD KEY `fk_pool_user` (`recorded_by`);

--
-- Indexes for table `pos_payments`
--
ALTER TABLE `pos_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_pos_payment_sale` (`sale_id`);

--
-- Indexes for table `pos_sales`
--
ALTER TABLE `pos_sales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_receipt_number` (`receipt_number`),
  ADD KEY `fk_sale_property` (`property_id`),
  ADD KEY `fk_sale_outlet` (`outlet_id`),
  ADD KEY `fk_sale_terminal` (`terminal_id`),
  ADD KEY `fk_sale_shift` (`shift_id`),
  ADD KEY `fk_sale_order` (`order_id`),
  ADD KEY `fk_sale_user` (`sold_by`);

--
-- Indexes for table `pos_sale_items`
--
ALTER TABLE `pos_sale_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_sale_item_sale` (`sale_id`),
  ADD KEY `fk_sale_item_menu` (`menu_item_id`);

--
-- Indexes for table `pos_terminals`
--
ALTER TABLE `pos_terminals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_pos_terminal` (`property_id`,`terminal_code`),
  ADD KEY `fk_pos_outlet` (`outlet_id`);

--
-- Indexes for table `pos_voids_refunds`
--
ALTER TABLE `pos_voids_refunds`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_vr_sale` (`sale_id`),
  ADD KEY `fk_vr_requester` (`requested_by`),
  ADD KEY `fk_vr_approver` (`approved_by`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_property_code` (`code`),
  ADD KEY `fk_property_group` (`hotel_group_id`);

--
-- Indexes for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `requisition_id` (`requisition_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `idx_po_status` (`status`),
  ADD KEY `idx_po_supplier` (`supplier_id`);

--
-- Indexes for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`),
  ADD KEY `idx_poi_order` (`order_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `purchase_requisitions`
--
ALTER TABLE `purchase_requisitions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `requested_by` (`requested_by`),
  ADD KEY `idx_pr_status` (`status`),
  ADD KEY `idx_requisitions_status` (`status`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `hp_perf_requisition_status` (`status`);

--
-- Indexes for table `purchase_requisition_items`
--
ALTER TABLE `purchase_requisition_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pri_req` (`requisition_id`),
  ADD KEY `idx_pri_item` (`item_id`),
  ADD KEY `requisition_id` (`requisition_id`);

--
-- Indexes for table `receipt_deliveries`
--
ALTER TABLE `receipt_deliveries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_receipt_payment_channel` (`payment_id`,`channel`,`recipient`(160)),
  ADD KEY `idx_receipt_source` (`source`);

--
-- Indexes for table `reception_activity_log`
--
ALTER TABLE `reception_activity_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `guest_id` (`guest_id`),
  ADD KEY `reservation_id` (`reservation_id`);

--
-- Indexes for table `reception_records`
--
ALTER TABLE `reception_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_rec_property` (`property_id`),
  ADD KEY `fk_rec_department` (`department_id`),
  ADD KEY `fk_rec_creator` (`created_by`),
  ADD KEY `fk_rec_guest` (`guest_id`),
  ADD KEY `fk_rec_room` (`room_id`);

--
-- Indexes for table `reservations`
--
ALTER TABLE `reservations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `booking_number` (`booking_number`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `guest_id` (`guest_id`),
  ADD KEY `idx_res_status` (`status`),
  ADD KEY `idx_res_checkin` (`check_in`),
  ADD KEY `idx_res_checkout` (`check_out`),
  ADD KEY `idx_res_created` (`created_at`),
  ADD KEY `idx_reservations_status` (`status`),
  ADD KEY `idx_reservations_dates` (`check_in`,`check_out`),
  ADD KEY `idx_deleted_at` (`deleted_at`),
  ADD KEY `hp_perf_res_status` (`status`),
  ADD KEY `hp_perf_res_checkin` (`check_in`),
  ADD KEY `hp_perf_res_checkout` (`check_out`);

--
-- Indexes for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reservation_id` (`reservation_id`),
  ADD KEY `room_type_id` (`room_type_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_id`,`permission_id`),
  ADD KEY `fk_rp_permission` (`permission_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hotel_id` (`hotel_id`,`room_number`),
  ADD KEY `room_type_id` (`room_type_id`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `room_status_history`
--
ALTER TABLE `room_status_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_rsh_room` (`room_id`),
  ADD KEY `fk_rsh_user` (`changed_by`);

--
-- Indexes for table `room_types`
--
ALTER TABLE `room_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_session_user` (`user_id`);

--
-- Indexes for table `shifts`
--
ALTER TABLE `shifts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `hp_pos_shift_user_status` (`user_id`,`status`,`opened_at`),
  ADD KEY `hp_pos_shift_opened` (`opened_at`);

--
-- Indexes for table `spa_appointments`
--
ALTER TABLE `spa_appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_spaa_property` (`property_id`),
  ADD KEY `fk_spaa_guest` (`guest_id`),
  ADD KEY `fk_spaa_service` (`service_id`),
  ADD KEY `fk_spaa_therapist` (`therapist_id`);

--
-- Indexes for table `spa_services`
--
ALTER TABLE `spa_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_spas_property` (`property_id`);

--
-- Indexes for table `staff_profiles`
--
ALTER TABLE `staff_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_staff_number` (`property_id`,`staff_number`),
  ADD KEY `fk_staff_user` (`user_id`),
  ADD KEY `fk_staff_department` (`department_id`);

--
-- Indexes for table `stock_counts`
--
ALTER TABLE `stock_counts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `count_number` (`count_number`),
  ADD KEY `counted_by` (`counted_by`);

--
-- Indexes for table `stock_count_items`
--
ALTER TABLE `stock_count_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `count_id` (`count_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `stock_levels`
--
ALTER TABLE `stock_levels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `item_id` (`item_id`,`location`);

--
-- Indexes for table `stock_movements`
--
ALTER TABLE `stock_movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `system_filters`
--
ALTER TABLE `system_filters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`screen_key`,`filter_key`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_setting` (`property_id`,`setting_key`);

--
-- Indexes for table `thread_members`
--
ALTER TABLE `thread_members`
  ADD PRIMARY KEY (`thread_id`,`user_id`),
  ADD KEY `fk_tm_user` (`user_id`);

--
-- Indexes for table `transport_requests`
--
ALTER TABLE `transport_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tr_property` (`property_id`),
  ADD KEY `fk_tr_guest` (`guest_id`),
  ADD KEY `fk_tr_vehicle` (`vehicle_id`),
  ADD KEY `fk_tr_creator` (`created_by`);

--
-- Indexes for table `two_factor_settings`
--
ALTER TABLE `two_factor_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_2fa_user` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `idx_deleted_at` (`deleted_at`);

--
-- Indexes for table `user_department_access`
--
ALTER TABLE `user_department_access`
  ADD PRIMARY KEY (`user_id`,`department_id`),
  ADD KEY `fk_uda_department` (`department_id`);

--
-- Indexes for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `user_property_access`
--
ALTER TABLE `user_property_access`
  ADD PRIMARY KEY (`user_id`,`property_id`),
  ADD KEY `fk_upa_property` (`property_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_id`,`role_id`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_hash` (`session_hash`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_vehicle_reg` (`property_id`,`registration_number`),
  ADD KEY `fk_vehicle_driver` (`driver_user_id`);

--
-- Indexes for table `voice_recordings`
--
ALTER TABLE `voice_recordings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_vr_hotel` (`hotel_id`),
  ADD KEY `idx_vr_user` (`user_id`),
  ADD KEY `idx_vr_created` (`created_at`);

--
-- Indexes for table `voids`
--
ALTER TABLE `voids`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hp_pos_void_ref` (`ref_type`,`ref_id`,`created_at`);

--
-- Indexes for table `website_integration_settings`
--
ALTER TABLE `website_integration_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `website_settings`
--
ALTER TABLE `website_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `approvals`
--
ALTER TABLE `approvals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;

--
-- AUTO_INCREMENT for table `beds`
--
ALTER TABLE `beds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `call_logs`
--
ALTER TABLE `call_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cashier_shifts`
--
ALTER TABLE `cashier_shifts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `communication_calls`
--
ALTER TABLE `communication_calls`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `customer_addresses`
--
ALTER TABLE `customer_addresses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer_documents`
--
ALTER TABLE `customer_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer_signin_attempts`
--
ALTER TABLE `customer_signin_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `customer_tokens`
--
ALTER TABLE `customer_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- AUTO_INCREMENT for table `department_messages`
--
ALTER TABLE `department_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `department_threads`
--
ALTER TABLE `department_threads`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `dining_tables`
--
ALTER TABLE `dining_tables`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `efris_attempts`
--
ALTER TABLE `efris_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `efris_invoices`
--
ALTER TABLE `efris_invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `efris_transactions`
--
ALTER TABLE `efris_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `event_bookings`
--
ALTER TABLE `event_bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `event_requests`
--
ALTER TABLE `event_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `facility_enquiries`
--
ALTER TABLE `facility_enquiries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `finance_bank_accounts`
--
ALTER TABLE `finance_bank_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_bank_transactions`
--
ALTER TABLE `finance_bank_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_cash_movements`
--
ALTER TABLE `finance_cash_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_reconciliations`
--
ALTER TABLE `finance_reconciliations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `financial_periods`
--
ALTER TABLE `financial_periods`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `folios`
--
ALTER TABLE `folios`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `folio_items`
--
ALTER TABLE `folio_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `goods_received`
--
ALTER TABLE `goods_received`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guests`
--
ALTER TABLE `guests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `guest_accounts`
--
ALTER TABLE `guest_accounts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guest_documents`
--
ALTER TABLE `guest_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guest_folio_entries`
--
ALTER TABLE `guest_folio_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guest_messages`
--
ALTER TABLE `guest_messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `hotels`
--
ALTER TABLE `hotels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `hotel_groups`
--
ALTER TABLE `hotel_groups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `housekeeping_tasks`
--
ALTER TABLE `housekeeping_tasks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `integrity_flags`
--
ALTER TABLE `integrity_flags`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `invoice_events`
--
ALTER TABLE `invoice_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `journal_entries`
--
ALTER TABLE `journal_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `journal_lines`
--
ALTER TABLE `journal_lines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kitchen_order_items`
--
ALTER TABLE `kitchen_order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kitchen_stations`
--
ALTER TABLE `kitchen_stations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `laundry_items`
--
ALTER TABLE `laundry_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `laundry_orders`
--
ALTER TABLE `laundry_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `leave_requests`
--
ALTER TABLE `leave_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lost_property`
--
ALTER TABLE `lost_property`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance_assets`
--
ALTER TABLE `maintenance_assets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `maintenance_tickets`
--
ALTER TABLE `maintenance_tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `menu_categories`
--
ALTER TABLE `menu_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=241;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2558;

--
-- AUTO_INCREMENT for table `news_posts`
--
ALTER TABLE `news_posts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=261;

--
-- AUTO_INCREMENT for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `notification_devices`
--
ALTER TABLE `notification_devices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `notification_events`
--
ALTER TABLE `notification_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=50;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `outlets`
--
ALTER TABLE `outlets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pool_visits`
--
ALTER TABLE `pool_visits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pos_payments`
--
ALTER TABLE `pos_payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pos_sales`
--
ALTER TABLE `pos_sales`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pos_sale_items`
--
ALTER TABLE `pos_sale_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pos_terminals`
--
ALTER TABLE `pos_terminals`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pos_voids_refunds`
--
ALTER TABLE `pos_voids_refunds`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_requisitions`
--
ALTER TABLE `purchase_requisitions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchase_requisition_items`
--
ALTER TABLE `purchase_requisition_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `receipt_deliveries`
--
ALTER TABLE `receipt_deliveries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `reception_activity_log`
--
ALTER TABLE `reception_activity_log`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reception_records`
--
ALTER TABLE `reception_records`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=163;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;

--
-- AUTO_INCREMENT for table `room_status_history`
--
ALTER TABLE `room_status_history`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `room_types`
--
ALTER TABLE `room_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `spa_appointments`
--
ALTER TABLE `spa_appointments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `spa_services`
--
ALTER TABLE `spa_services`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `staff_profiles`
--
ALTER TABLE `staff_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stock_counts`
--
ALTER TABLE `stock_counts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stock_count_items`
--
ALTER TABLE `stock_count_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `stock_levels`
--
ALTER TABLE `stock_levels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `stock_movements`
--
ALTER TABLE `stock_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `system_filters`
--
ALTER TABLE `system_filters`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transport_requests`
--
ALTER TABLE `transport_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `two_factor_settings`
--
ALTER TABLE `two_factor_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

--
-- AUTO_INCREMENT for table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_sessions`
--
ALTER TABLE `user_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `voice_recordings`
--
ALTER TABLE `voice_recordings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `voids`
--
ALTER TABLE `voids`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `website_integration_settings`
--
ALTER TABLE `website_integration_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `website_settings`
--
ALTER TABLE `website_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

-- --------------------------------------------------------

--
-- Structure for view `hp_payment_mix_daily`
--
DROP TABLE IF EXISTS `hp_payment_mix_daily`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hotelpardise`@`localhost` SQL SECURITY INVOKER VIEW `hp_payment_mix_daily`  AS SELECT cast(`payments`.`created_at` as date) AS `payment_date`, `payments`.`method` AS `method`, CASE WHEN `payments`.`order_id` is not null THEN 'pos_order' WHEN `payments`.`reservation_id` is not null THEN 'reservation' WHEN `payments`.`invoice_id` is not null THEN 'invoice' ELSE 'other' END AS `source`, count(0) AS `payments_count`, round(sum(`payments`.`amount`),2) AS `amount` FROM `payments` WHERE `payments`.`status` = 'successful' GROUP BY cast(`payments`.`created_at` as date), `payments`.`method`, CASE WHEN `payments`.`order_id` is not null THEN 'pos_order' WHEN `payments`.`reservation_id` is not null THEN 'reservation' WHEN `payments`.`invoice_id` is not null THEN 'invoice' ELSE 'other' END ;

-- --------------------------------------------------------

--
-- Structure for view `hp_pos_daily_sales`
--
DROP TABLE IF EXISTS `hp_pos_daily_sales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hotelpardise`@`localhost` SQL SECURITY INVOKER VIEW `hp_pos_daily_sales`  AS SELECT cast(`o`.`created_at` as date) AS `sale_date`, `o`.`outlet` AS `outlet`, count(0) AS `orders_count`, round(sum(`o`.`subtotal`),2) AS `subtotal`, round(sum(`o`.`tax`),2) AS `service_charge`, round(sum(`o`.`discount`),2) AS `discounts`, round(sum(`o`.`total`),2) AS `order_total`, round(sum(case when `o`.`status` = 'cancelled' then 0 else `o`.`total` end),2) AS `net_sales`, round(coalesce(sum(`p`.`paid`),0.00),2) AS `collected`, round(coalesce(sum(case when `o`.`status` = 'cancelled' then 0 else greatest(`o`.`total` - coalesce(`p`.`paid`,0.00),0.00) end),0.00),2) AS `outstanding` FROM (`orders` `o` left join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) WHERE `o`.`deleted_at` is null GROUP BY cast(`o`.`created_at` as date), `o`.`outlet` ;

-- --------------------------------------------------------

--
-- Structure for view `hp_pos_integrity_issues`
--
DROP TABLE IF EXISTS `hp_pos_integrity_issues`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hotelpardise`@`localhost` SQL SECURITY INVOKER VIEW `hp_pos_integrity_issues`  AS SELECT 'order_total_mismatch' AS `issue`, `o`.`id` AS `ref_id`, `o`.`order_number` AS `reference`, concat('Total ',`o`.`total`,' does not equal subtotal ',`o`.`subtotal`,' + service ',`o`.`tax`,' - discount ',`o`.`discount`) AS `detail` FROM `orders` AS `o` WHERE `o`.`deleted_at` is null AND abs(`o`.`total` - (`o`.`subtotal` + `o`.`tax` - `o`.`discount`)) > 0.01union allselect 'order_paid_above_total' AS `issue`,`o`.`id` AS `ref_id`,`o`.`order_number` AS `reference`,concat('Successful payments ',`p`.`paid`,' exceed order total ',`o`.`total`) AS `detail` from (`orders` `o` join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) where `o`.`deleted_at` is null and `p`.`paid` > `o`.`total` + 0.01 union all select 'cancelled_order_with_payments' AS `issue`,`o`.`id` AS `ref_id`,`o`.`order_number` AS `reference`,concat('Cancelled order still has successful payments totalling ',`p`.`paid`) AS `detail` from (`orders` `o` join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) where `o`.`deleted_at` is null and `o`.`status` = 'cancelled' union all select 'unpaid_status_with_payments' AS `issue`,`o`.`id` AS `ref_id`,`o`.`order_number` AS `reference`,concat('Status is ',`o`.`status`,' but successful payments already total ',`p`.`paid`) AS `detail` from (`orders` `o` join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) where `o`.`deleted_at` is null and `o`.`status` not in ('paid','partially_paid','cancelled') and `p`.`paid` > 0.001 union all select 'paid_status_mismatch' AS `issue`,`o`.`id` AS `ref_id`,`o`.`order_number` AS `reference`,concat('Status is ',`o`.`status`,' but payments total ',`p`.`paid`,' of ',`o`.`total`) AS `detail` from (`orders` `o` join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) where `o`.`deleted_at` is null and `o`.`status` in ('paid','partially_paid') and (`o`.`status` = 'paid' and `p`.`paid` + 0.001 < `o`.`total` or `o`.`status` = 'partially_paid' and (`p`.`paid` <= 0.001 or `p`.`paid` + 0.001 >= `o`.`total`)) union all select 'order_lines_total_mismatch' AS `issue`,`o`.`id` AS `ref_id`,`o`.`order_number` AS `reference`,concat('Order lines total ',coalesce(`i`.`lines_total`,0),' does not equal subtotal ',`o`.`subtotal`) AS `detail` from (`orders` `o` left join (select `order_items`.`order_id` AS `order_id`,sum(`order_items`.`total`) AS `lines_total` from `order_items` group by `order_items`.`order_id`) `i` on(`i`.`order_id` = `o`.`id`)) where `o`.`deleted_at` is null and abs(`o`.`subtotal` - coalesce(`i`.`lines_total`,0)) > 0.01 union all select 'negative_payment' AS `issue`,`p`.`id` AS `ref_id`,coalesce(`p`.`provider_reference`,concat('payment-',`p`.`id`)) AS `reference`,concat('Successful payment has a negative amount ',`p`.`amount`) AS `detail` from `payments` `p` where `p`.`status` = 'successful' and `p`.`amount` < 0 union all select 'payment_missing_created_at' AS `issue`,`p`.`id` AS `ref_id`,coalesce(`p`.`provider_reference`,concat('payment-',`p`.`id`)) AS `reference`,concat('Successful payment of ',`p`.`amount`,' has no created_at, so it cannot be placed in a shift or day') AS `detail` from `payments` `p` where `p`.`status` = 'successful' and `p`.`created_at` is null union all select 'closed_shift_cash_mismatch' AS `issue`,`r`.`shift_id` AS `ref_id`,concat('shift-',`r`.`shift_id`) AS `reference`,concat('Stored expected ',`r`.`recorded_expected`,' but linked cash gives ',`r`.`live_expected_cash`) AS `detail` from `hp_shift_reconciliation` `r` where `r`.`status` = 'closed' and abs(`r`.`recorded_expected` - `r`.`live_expected_cash`) > 0.01  ;

-- --------------------------------------------------------

--
-- Structure for view `hp_pos_order_balances`
--
DROP TABLE IF EXISTS `hp_pos_order_balances`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hotelpardise`@`localhost` SQL SECURITY INVOKER VIEW `hp_pos_order_balances`  AS SELECT `o`.`id` AS `id`, `o`.`order_number` AS `order_number`, `o`.`outlet` AS `outlet`, `o`.`order_type` AS `order_type`, `o`.`table_name` AS `table_name`, `o`.`status` AS `status`, `o`.`created_at` AS `created_at`, `o`.`subtotal` AS `subtotal`, `o`.`tax` AS `tax`, `o`.`discount` AS `discount`, `o`.`total` AS `total`, coalesce(`p`.`paid`,0.00) AS `paid`, round(greatest(`o`.`total` - coalesce(`p`.`paid`,0.00),0.00),2) AS `due`, CASE WHEN `o`.`status` = 'cancelled' THEN 'cancelled' WHEN coalesce(`p`.`paid`,0.00) <= 0.001 THEN 'unpaid' WHEN coalesce(`p`.`paid`,0.00) + 0.001 >= `o`.`total` THEN 'paid' ELSE 'partially_paid' END AS `payment_state` FROM (`orders` `o` left join (select `payments`.`order_id` AS `order_id`,sum(`payments`.`amount`) AS `paid` from `payments` where `payments`.`status` = 'successful' and `payments`.`order_id` is not null group by `payments`.`order_id`) `p` on(`p`.`order_id` = `o`.`id`)) WHERE `o`.`deleted_at` is null ;

-- --------------------------------------------------------

--
-- Structure for view `hp_shift_reconciliation`
--
DROP TABLE IF EXISTS `hp_shift_reconciliation`;

CREATE ALGORITHM=UNDEFINED DEFINER=`hotelpardise`@`localhost` SQL SECURITY INVOKER VIEW `hp_shift_reconciliation`  AS SELECT `s`.`id` AS `shift_id`, `s`.`user_id` AS `user_id`, `u`.`name` AS `cashier`, `s`.`outlet` AS `outlet`, `s`.`status` AS `status`, `s`.`opened_at` AS `opened_at`, `s`.`closed_at` AS `closed_at`, `s`.`opening_cash` AS `opening_cash`, `s`.`expected_cash` AS `recorded_expected`, `s`.`counted_cash` AS `counted_cash`, `s`.`variance` AS `variance`, round(coalesce(sum(case when `p`.`method` = 'cash' then `p`.`amount` else 0 end),0.00),2) AS `cash_taken`, round(coalesce(sum(case when `p`.`method` <> 'cash' then `p`.`amount` else 0 end),0.00),2) AS `other_taken`, count(`p`.`id`) AS `payments_count`, round(`s`.`opening_cash` + coalesce(sum(case when `p`.`method` = 'cash' then `p`.`amount` else 0 end),0.00),2) AS `live_expected_cash` FROM ((`shifts` `s` left join `users` `u` on(`u`.`id` = `s`.`user_id`)) left join `payments` `p` on(`p`.`status` = 'successful' and (`p`.`shift_id` = `s`.`id` or `p`.`shift_id` is null and `p`.`user_id` = `s`.`user_id` and `p`.`created_at` >= `s`.`opened_at` and `p`.`created_at` <= coalesce(`s`.`closed_at`,current_timestamp())))) GROUP BY `s`.`id`, `s`.`user_id`, `u`.`name`, `s`.`outlet`, `s`.`status`, `s`.`opened_at`, `s`.`closed_at`, `s`.`opening_cash`, `s`.`expected_cash`, `s`.`counted_cash`, `s`.`variance` ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `approvals`
--
ALTER TABLE `approvals`
  ADD CONSTRAINT `fk_approval_approver` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_approval_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_approval_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `fk_att_staff` FOREIGN KEY (`staff_id`) REFERENCES `staff_profiles` (`id`);

--
-- Constraints for table `beds`
--
ALTER TABLE `beds`
  ADD CONSTRAINT `beds_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Constraints for table `call_logs`
--
ALTER TABLE `call_logs`
  ADD CONSTRAINT `fk_call_callee` FOREIGN KEY (`callee_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_call_caller` FOREIGN KEY (`caller_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_call_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `cashier_shifts`
--
ALTER TABLE `cashier_shifts`
  ADD CONSTRAINT `fk_shift_closed` FOREIGN KEY (`closed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_shift_opened` FOREIGN KEY (`opened_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_shift_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `pos_terminals` (`id`);

--
-- Constraints for table `chart_of_accounts`
--
ALTER TABLE `chart_of_accounts`
  ADD CONSTRAINT `fk_coa_parent` FOREIGN KEY (`parent_id`) REFERENCES `chart_of_accounts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_coa_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `communication_calls`
--
ALTER TABLE `communication_calls`
  ADD CONSTRAINT `communication_calls_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `communication_calls_ibfk_2` FOREIGN KEY (`caller_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `communication_calls_ibfk_3` FOREIGN KEY (`receiver_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `communication_calls_ibfk_4` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `department_messages`
--
ALTER TABLE `department_messages`
  ADD CONSTRAINT `department_messages_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `department_messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `department_messages_ibfk_3` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `department_messages_ibfk_4` FOREIGN KEY (`recipient_department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `department_threads`
--
ALTER TABLE `department_threads`
  ADD CONSTRAINT `fk_thread_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_thread_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_thread_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `dining_tables`
--
ALTER TABLE `dining_tables`
  ADD CONSTRAINT `fk_table_outlet` FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`);

--
-- Constraints for table `efris_attempts`
--
ALTER TABLE `efris_attempts`
  ADD CONSTRAINT `fk_efris_attempt_invoice` FOREIGN KEY (`efris_invoice_id`) REFERENCES `efris_invoices` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `efris_invoices`
--
ALTER TABLE `efris_invoices`
  ADD CONSTRAINT `fk_efris_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`);

--
-- Constraints for table `events`
--
ALTER TABLE `events`
  ADD CONSTRAINT `fk_event_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `event_bookings`
--
ALTER TABLE `event_bookings`
  ADD CONSTRAINT `fk_event_booking_event` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_event_booking_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `finance_transactions`
--
ALTER TABLE `finance_transactions`
  ADD CONSTRAINT `finance_transactions_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `finance_transactions_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `finance_transactions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `financial_periods`
--
ALTER TABLE `financial_periods`
  ADD CONSTRAINT `fk_period_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `folios`
--
ALTER TABLE `folios`
  ADD CONSTRAINT `fk_folio_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_folio_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_folio_res` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `folio_items`
--
ALTER TABLE `folio_items`
  ADD CONSTRAINT `fk_folio_item_dept` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_folio_item_folio` FOREIGN KEY (`folio_id`) REFERENCES `folios` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `goods_received`
--
ALTER TABLE `goods_received`
  ADD CONSTRAINT `fk_grn_po` FOREIGN KEY (`purchase_order_id`) REFERENCES `purchase_orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_grn_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_grn_user` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `guests`
--
ALTER TABLE `guests`
  ADD CONSTRAINT `guests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `guests_ibfk_2` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `guest_accounts`
--
ALTER TABLE `guest_accounts`
  ADD CONSTRAINT `fk_guest_account_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guest_documents`
--
ALTER TABLE `guest_documents`
  ADD CONSTRAINT `fk_guest_doc_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `guest_folio_entries`
--
ALTER TABLE `guest_folio_entries`
  ADD CONSTRAINT `guest_folio_entries_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`);

--
-- Constraints for table `housekeeping_tasks`
--
ALTER TABLE `housekeeping_tasks`
  ADD CONSTRAINT `fk_hk_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_hk_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_hk_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_hk_verifier` FOREIGN KEY (`verified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD CONSTRAINT `inventory_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `inventory_categories` (`id`);

--
-- Constraints for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `fk_im_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_im_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`),
  ADD CONSTRAINT `fk_im_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_im_user` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `invoice_events`
--
ALTER TABLE `invoice_events`
  ADD CONSTRAINT `fk_invoice_events_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD CONSTRAINT `fk_invoice_item_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD CONSTRAINT `fk_je_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_je_period` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_je_poster` FOREIGN KEY (`posted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_je_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `journal_lines`
--
ALTER TABLE `journal_lines`
  ADD CONSTRAINT `fk_jl_account` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`),
  ADD CONSTRAINT `fk_jl_entry` FOREIGN KEY (`journal_entry_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `kitchen_order_items`
--
ALTER TABLE `kitchen_order_items`
  ADD CONSTRAINT `fk_koi_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_koi_station` FOREIGN KEY (`station_id`) REFERENCES `kitchen_stations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `kitchen_stations`
--
ALTER TABLE `kitchen_stations`
  ADD CONSTRAINT `fk_ks_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `laundry_items`
--
ALTER TABLE `laundry_items`
  ADD CONSTRAINT `fk_li_order` FOREIGN KEY (`laundry_order_id`) REFERENCES `laundry_orders` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `laundry_orders`
--
ALTER TABLE `laundry_orders`
  ADD CONSTRAINT `fk_laundry_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_laundry_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_laundry_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `leave_requests`
--
ALTER TABLE `leave_requests`
  ADD CONSTRAINT `fk_leave_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leave_staff` FOREIGN KEY (`staff_id`) REFERENCES `staff_profiles` (`id`);

--
-- Constraints for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD CONSTRAINT `fk_login_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `lost_property`
--
ALTER TABLE `lost_property`
  ADD CONSTRAINT `fk_lp_finder` FOREIGN KEY (`found_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_lp_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_lp_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_lp_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `maintenance_assets`
--
ALTER TABLE `maintenance_assets`
  ADD CONSTRAINT `fk_asset_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `maintenance_tickets`
--
ALTER TABLE `maintenance_tickets`
  ADD CONSTRAINT `fk_mt_asset` FOREIGN KEY (`asset_id`) REFERENCES `maintenance_assets` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mt_assignee` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mt_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_mt_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_mt_reporter` FOREIGN KEY (`reported_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_mt_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD CONSTRAINT `menu_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `menu_categories` (`id`);

--
-- Constraints for table `message_reads`
--
ALTER TABLE `message_reads`
  ADD CONSTRAINT `fk_mr_message` FOREIGN KEY (`message_id`) REFERENCES `department_messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_mr_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notification_devices`
--
ALTER TABLE `notification_devices`
  ADD CONSTRAINT `fk_nd_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`menu_item_id`) REFERENCES `menu_items` (`id`);

--
-- Constraints for table `outlets`
--
ALTER TABLE `outlets`
  ADD CONSTRAINT `fk_outlet_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `fk_outlet_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD CONSTRAINT `password_reset_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pool_visits`
--
ALTER TABLE `pool_visits`
  ADD CONSTRAINT `fk_pool_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pool_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_pool_user` FOREIGN KEY (`recorded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pos_payments`
--
ALTER TABLE `pos_payments`
  ADD CONSTRAINT `fk_pos_payment_sale` FOREIGN KEY (`sale_id`) REFERENCES `pos_sales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pos_sales`
--
ALTER TABLE `pos_sales`
  ADD CONSTRAINT `fk_sale_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sale_outlet` FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sale_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_sale_shift` FOREIGN KEY (`shift_id`) REFERENCES `cashier_shifts` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sale_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `pos_terminals` (`id`),
  ADD CONSTRAINT `fk_sale_user` FOREIGN KEY (`sold_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pos_sale_items`
--
ALTER TABLE `pos_sale_items`
  ADD CONSTRAINT `fk_sale_item_menu` FOREIGN KEY (`menu_item_id`) REFERENCES `menu_items` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_sale_item_sale` FOREIGN KEY (`sale_id`) REFERENCES `pos_sales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pos_terminals`
--
ALTER TABLE `pos_terminals`
  ADD CONSTRAINT `fk_pos_outlet` FOREIGN KEY (`outlet_id`) REFERENCES `outlets` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_pos_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `pos_voids_refunds`
--
ALTER TABLE `pos_voids_refunds`
  ADD CONSTRAINT `fk_vr_approver` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vr_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_vr_sale` FOREIGN KEY (`sale_id`) REFERENCES `pos_sales` (`id`);

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `fk_property_group` FOREIGN KEY (`hotel_group_id`) REFERENCES `hotel_groups` (`id`);

--
-- Constraints for table `purchase_orders`
--
ALTER TABLE `purchase_orders`
  ADD CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  ADD CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`requisition_id`) REFERENCES `purchase_requisitions` (`id`),
  ADD CONSTRAINT `purchase_orders_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  ADD CONSTRAINT `purchase_order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `purchase_orders` (`id`),
  ADD CONSTRAINT `purchase_order_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Constraints for table `purchase_requisitions`
--
ALTER TABLE `purchase_requisitions`
  ADD CONSTRAINT `purchase_requisitions_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `purchase_requisitions_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `purchase_requisition_items`
--
ALTER TABLE `purchase_requisition_items`
  ADD CONSTRAINT `purchase_requisition_items_ibfk_1` FOREIGN KEY (`requisition_id`) REFERENCES `purchase_requisitions` (`id`),
  ADD CONSTRAINT `purchase_requisition_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Constraints for table `reception_activity_log`
--
ALTER TABLE `reception_activity_log`
  ADD CONSTRAINT `reception_activity_log_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `reception_activity_log_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `reception_activity_log_ibfk_3` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reception_activity_log_ibfk_4` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reception_records`
--
ALTER TABLE `reception_records`
  ADD CONSTRAINT `fk_rec_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_rec_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `fk_rec_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_rec_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_rec_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `reservations`
--
ALTER TABLE `reservations`
  ADD CONSTRAINT `reservations_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `reservations_ibfk_2` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`);

--
-- Constraints for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  ADD CONSTRAINT `reservation_rooms_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`),
  ADD CONSTRAINT `reservation_rooms_ibfk_2` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`),
  ADD CONSTRAINT `reservation_rooms_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `fk_rp_permission` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_rp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `rooms_ibfk_2` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`);

--
-- Constraints for table `room_status_history`
--
ALTER TABLE `room_status_history`
  ADD CONSTRAINT `fk_rsh_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  ADD CONSTRAINT `fk_rsh_user` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `room_types`
--
ALTER TABLE `room_types`
  ADD CONSTRAINT `room_types_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `fk_session_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `shifts`
--
ALTER TABLE `shifts`
  ADD CONSTRAINT `shifts_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `shifts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `spa_appointments`
--
ALTER TABLE `spa_appointments`
  ADD CONSTRAINT `fk_spaa_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_spaa_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_spaa_service` FOREIGN KEY (`service_id`) REFERENCES `spa_services` (`id`),
  ADD CONSTRAINT `fk_spaa_therapist` FOREIGN KEY (`therapist_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `spa_services`
--
ALTER TABLE `spa_services`
  ADD CONSTRAINT `fk_spas_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);

--
-- Constraints for table `staff_profiles`
--
ALTER TABLE `staff_profiles`
  ADD CONSTRAINT `fk_staff_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `fk_staff_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_staff_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `stock_counts`
--
ALTER TABLE `stock_counts`
  ADD CONSTRAINT `stock_counts_ibfk_1` FOREIGN KEY (`counted_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `stock_count_items`
--
ALTER TABLE `stock_count_items`
  ADD CONSTRAINT `stock_count_items_ibfk_1` FOREIGN KEY (`count_id`) REFERENCES `stock_counts` (`id`),
  ADD CONSTRAINT `stock_count_items_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Constraints for table `stock_levels`
--
ALTER TABLE `stock_levels`
  ADD CONSTRAINT `stock_levels_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Constraints for table `stock_movements`
--
ALTER TABLE `stock_movements`
  ADD CONSTRAINT `stock_movements_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`id`);

--
-- Constraints for table `system_filters`
--
ALTER TABLE `system_filters`
  ADD CONSTRAINT `system_filters_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD CONSTRAINT `fk_setting_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `thread_members`
--
ALTER TABLE `thread_members`
  ADD CONSTRAINT `fk_tm_thread` FOREIGN KEY (`thread_id`) REFERENCES `department_threads` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tm_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transport_requests`
--
ALTER TABLE `transport_requests`
  ADD CONSTRAINT `fk_tr_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tr_guest` FOREIGN KEY (`guest_id`) REFERENCES `guests` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_tr_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`),
  ADD CONSTRAINT `fk_tr_vehicle` FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `two_factor_settings`
--
ALTER TABLE `two_factor_settings`
  ADD CONSTRAINT `fk_2fa_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `user_department_access`
--
ALTER TABLE `user_department_access`
  ADD CONSTRAINT `fk_uda_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_uda_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_profiles_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_property_access`
--
ALTER TABLE `user_property_access`
  ADD CONSTRAINT `fk_upa_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_upa_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Constraints for table `user_sessions`
--
ALTER TABLE `user_sessions`
  ADD CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `fk_vehicle_driver` FOREIGN KEY (`driver_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_vehicle_property` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
