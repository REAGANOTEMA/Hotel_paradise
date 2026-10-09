-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 09, 2026 at 10:25 AM
-- Server version: 10.11.19-MariaDB
-- PHP Version: 8.4.26

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
  `last_login_at` datetime DEFAULT NULL
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
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `guests`
--

INSERT INTO `guests` (`id`, `user_id`, `hotel_id`, `full_name`, `phone`, `email`, `nationality`, `id_type`, `id_number`, `created_at`, `updated_at`) VALUES
(1, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(2, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(3, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(4, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(5, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(6, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(7, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(8, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(9, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(10, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(11, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(12, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(13, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(14, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(15, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(16, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(17, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(18, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(19, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(20, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(21, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(22, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(23, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(24, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(25, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(26, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(27, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(28, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(29, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(30, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(31, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(32, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(33, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(34, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(35, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(36, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(37, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(38, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(39, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(40, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL),
(41, NULL, 1, 'Grace Akello', '+256 770 111 001', 'grace.akello@example.com', 'Ugandan', 'National ID', 'CM11-8890', NULL, NULL),
(42, NULL, 1, 'John Mukasa', '+256 770 111 002', 'john.mukasa@example.com', 'Ugandan', 'Passport', 'UG-P-4471', NULL, NULL),
(43, NULL, 1, 'Sarah Namuli', '+256 770 111 003', 'sarah.namuli@example.com', 'Ugandan', 'National ID', 'CM22-0317', NULL, NULL),
(44, NULL, 1, 'David Okello', '+256 770 111 004', 'david.okello@example.com', 'Kenyan', 'Passport', 'KE-A-9012', NULL, NULL),
(45, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL);

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
-- Table structure for table `inventory_categories`
--

CREATE TABLE `inventory_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(120) NOT NULL,
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `inventory_categories`
--

INSERT INTO `inventory_categories` (`id`, `name`, `active`) VALUES
(1, 'Beverages', 1),
(2, 'Kitchen', 1),
(3, 'Housekeeping Supplies', 1),
(4, 'Maintenance', 1),
(5, 'Stationery', 1);

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
  `active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `inventory_items`
--

INSERT INTO `inventory_items` (`id`, `hotel_id`, `category_id`, `code`, `name`, `unit`, `reorder_level`, `active`) VALUES
(1, 1, 1, 'NVG-BEV-001', 'Nile Special Beer', 'carton', 6.00, 1),
(2, 1, 1, 'NVG-BEV-002', 'Coca Cola', 'crate', 4.00, 1),
(3, 1, 1, 'NVG-BEV-003', 'Bottled Water 500ml', 'carton', 8.00, 1),
(4, 1, 2, 'NVG-KIT-001', 'Cooking Oil 6L', 'jerry', 3.00, 1),
(5, 1, 2, 'NVG-KIT-002', 'Fresh Tomatoes', 'kg', 10.00, 1),
(6, 1, 2, 'NVG-KIT-003', 'Beef', 'kg', 12.00, 1),
(7, 1, 2, 'NVG-KIT-004', 'Mixing Flour 50kg', 'bag', 2.00, 1),
(8, 1, 2, 'NVG-KIT-005', 'Fresh Eggs', 'tray', 6.00, 1),
(9, 1, 3, 'NVG-HSK-001', 'Laundry Bar Soap', 'bar', 20.00, 1),
(10, 1, 3, 'NVG-HSK-002', 'Toilet Paper', 'roll', 60.00, 1),
(11, 1, 3, 'NVG-HSK-003', 'All Purpose Cleaner', 'litre', 8.00, 1),
(12, 1, 4, 'NVG-MNT-001', 'Electrical Tape', 'roll', 4.00, 1),
(13, 1, 4, 'NVG-MNT-002', 'LED Bulb 9W', 'piece', 10.00, 1),
(14, 1, 5, 'NVG-STN-001', 'A4 Printer Paper', 'ream', 5.00, 1),
(15, 1, 5, 'NVG-STN-002', 'Receipt Roll 80mm', 'roll', 20.00, 1);

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
  `invoice_number` varchar(80) NOT NULL,
  `subtotal` decimal(14,2) DEFAULT 0.00,
  `tax` decimal(14,2) DEFAULT 0.00,
  `total` decimal(14,2) DEFAULT 0.00,
  `status` enum('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `invoices`
--

INSERT INTO `invoices` (`id`, `hotel_id`, `guest_id`, `invoice_number`, `subtotal`, `tax`, `total`, `status`, `created_at`) VALUES
(1, 1, 1, 'INV-HPN-20260925-0001', 744000.00, 0.00, 744000.00, 'paid', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
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
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `posted_by` bigint(20) UNSIGNED DEFAULT NULL,
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
(130, 1, 'bar', 'Wines & Spirits', NULL, NULL, NULL, 0);

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
(2352, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, 'assorted-meat-and-salami.webp', 'Pizza', 120, 1, 0);

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
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `menu_item_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` decimal(12,2) NOT NULL,
  `unit_price` decimal(14,2) NOT NULL,
  `total` decimal(14,2) NOT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
  `reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL,
  `method` varchar(50) NOT NULL,
  `provider` varchar(100) DEFAULT NULL,
  `provider_reference` varchar(190) DEFAULT NULL,
  `status` enum('pending','successful','failed','refunded','reversed') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `hotel_id`, `user_id`, `customer_id`, `invoice_id`, `order_id`, `reservation_id`, `amount`, `method`, `provider`, `provider_reference`, `status`, `created_at`) VALUES
(1, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(2, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(3, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(4, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(5, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(6, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(7, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(8, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(9, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL);

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
  `created_at` timestamp NULL DEFAULT NULL
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
  `created_at` timestamp NULL DEFAULT NULL
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
  `notes` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `reservations`
--

INSERT INTO `reservations` (`id`, `hotel_id`, `guest_id`, `booking_number`, `source`, `check_in`, `check_out`, `adults`, `children`, `status`, `room_rate`, `nights`, `subtotal`, `tax`, `total`, `paid`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'HPN-20260925-001', 'phone', '2026-09-25 14:00:00', '2026-09-28 11:00:00', 2, 0, 'checked_in', 248000.00, 3, 744000.00, 0.00, 744000.00, 744000.00, 'Birthday weekend by the Nile', '2026-10-05 05:33:34', NULL),
(2, 1, 2, 'HPN-20260925-002', 'website', '2026-10-02 14:00:00', '2026-10-04 11:00:00', 2, 1, 'confirmed', 202000.00, 2, 404000.00, 0.00, 404000.00, 0.00, '', '2026-10-05 05:33:34', NULL),
(3, 1, 3, 'HPN-20260925-003', 'walk_in', '2026-10-05 14:00:00', '2026-10-07 11:00:00', 3, 0, 'confirmed', 213000.00, 2, 426000.00, 0.00, 426000.00, 0.00, '', '2026-10-05 05:33:34', NULL),
(4, 1, 4, 'HPN-20260925-004', 'agent', '2026-09-20 14:00:00', '2026-09-23 11:00:00', 2, 0, 'checked_out', 314000.00, 3, 942000.00, 0.00, 942000.00, 942000.00, 'Family holiday', '2026-10-05 05:33:34', NULL);

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
(1, 1, 1, 1, 1, 248000.00),
(2, 2, 4, 30, 1, 202000.00),
(3, 3, 3, 15, 1, 213000.00),
(4, 4, 2, 8, 1, 314000.00),
(5, 1, 8, 1, 1, 248000.00),
(6, 2, 11, 30, 1, 202000.00),
(7, 3, 10, 15, 1, 213000.00),
(8, 4, 9, 8, 1, 314000.00),
(9, 1, 15, 1, 1, 248000.00),
(10, 2, 18, 30, 1, 202000.00),
(11, 3, 17, 15, 1, 213000.00),
(12, 4, 16, 8, 1, 314000.00),
(13, 1, 22, 1, 1, 248000.00),
(14, 2, 25, 30, 1, 202000.00),
(15, 3, 24, 15, 1, 213000.00),
(16, 4, 23, 8, 1, 314000.00),
(17, 1, 29, 1, 1, 248000.00),
(18, 2, 32, 30, 1, 202000.00),
(19, 3, 31, 15, 1, 213000.00),
(20, 4, 30, 8, 1, 314000.00),
(21, 1, 36, 1, 1, 248000.00),
(22, 2, 39, 30, 1, 202000.00),
(23, 3, 38, 15, 1, 213000.00),
(24, 4, 37, 8, 1, 314000.00),
(25, 1, 43, 1, 1, 248000.00),
(26, 2, 46, 30, 1, 202000.00),
(27, 3, 45, 15, 1, 213000.00),
(28, 4, 44, 8, 1, 314000.00),
(29, 1, 50, 1, 1, 248000.00),
(30, 2, 53, 30, 1, 202000.00),
(31, 3, 52, 15, 1, 213000.00),
(32, 4, 51, 8, 1, 314000.00),
(33, 1, 57, 1, 1, 248000.00),
(34, 2, 60, 30, 1, 202000.00),
(35, 3, 59, 15, 1, 213000.00),
(36, 4, 58, 8, 1, 314000.00);

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
  `status` enum('available','reserved','occupied','dirty','cleaning','inspected','maintenance','out_of_service') DEFAULT 'available'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `hotel_id`, `room_type_id`, `room_number`, `floor`, `status`) VALUES
(1, 1, 57, 'S101', 'Floor 1', 'available'),
(2, 1, 57, 'S102', 'Floor 1', 'available'),
(3, 1, 57, 'S103', 'Floor 1', 'available'),
(4, 1, 57, 'S104', 'Floor 1', 'available'),
(5, 1, 57, 'S105', 'Floor 1', 'available'),
(6, 1, 57, 'S106', 'Floor 1', 'available'),
(8, 1, 58, 'F101', 'Floor 1', 'available'),
(9, 1, 58, 'F102', 'Floor 1', 'available'),
(10, 1, 58, 'F103', 'Floor 1', 'available'),
(11, 1, 58, 'F104', 'Floor 1', 'available'),
(12, 1, 58, 'F105', 'Floor 1', 'available'),
(13, 1, 58, 'F106', 'Floor 1', 'available'),
(14, 1, 58, 'F107', 'Floor 1', 'available'),
(15, 1, 59, 'T201', 'Floor 2', 'available'),
(16, 1, 59, 'T202', 'Floor 2', 'available'),
(17, 1, 59, 'T203', 'Floor 2', 'available'),
(18, 1, 59, 'T204', 'Floor 2', 'available'),
(19, 1, 59, 'T205', 'Floor 2', 'available'),
(20, 1, 59, 'T206', 'Floor 2', 'available'),
(21, 1, 59, 'T207', 'Floor 2', 'available'),
(22, 1, 59, 'T208', 'Floor 2', 'available'),
(23, 1, 59, 'T209', 'Floor 2', 'available'),
(24, 1, 59, 'T210', 'Floor 2', 'available'),
(25, 1, 59, 'T211', 'Floor 2', 'available'),
(26, 1, 59, 'T212', 'Floor 2', 'available'),
(30, 1, 60, 'ED201', 'Floor 2', 'available'),
(31, 1, 60, 'ED202', 'Floor 2', 'available'),
(32, 1, 60, 'ED203', 'Floor 2', 'available'),
(33, 1, 60, 'ED204', 'Floor 2', 'available'),
(34, 1, 60, 'ED205', 'Floor 2', 'available'),
(35, 1, 60, 'ED206', 'Floor 2', 'available'),
(36, 1, 60, 'ED207', 'Floor 2', 'available'),
(37, 1, 60, 'ED208', 'Floor 2', 'available'),
(38, 1, 60, 'ED209', 'Floor 2', 'available'),
(39, 1, 60, 'ED210', 'Floor 2', 'available'),
(45, 1, 61, 'DD301', 'Floor 3', 'available'),
(46, 1, 61, 'DD302', 'Floor 3', 'available'),
(47, 1, 61, 'DD303', 'Floor 3', 'available'),
(48, 1, 61, 'DD304', 'Floor 3', 'available'),
(49, 1, 61, 'DD305', 'Floor 3', 'available'),
(50, 1, 61, 'DD306', 'Floor 3', 'available'),
(51, 1, 61, 'DD307', 'Floor 3', 'available'),
(52, 1, 61, 'DD308', 'Floor 3', 'available'),
(53, 1, 61, 'DD309', 'Floor 3', 'available'),
(54, 1, 61, 'DD310', 'Floor 3', 'available'),
(55, 1, 61, 'DD311', 'Floor 3', 'available'),
(56, 1, 61, 'DD312', 'Floor 3', 'available'),
(57, 1, 61, 'DD313', 'Floor 3', 'available'),
(58, 1, 61, 'DD314', 'Floor 3', 'available'),
(60, 1, 62, 'TW301', 'Floor 3', 'available'),
(61, 1, 62, 'TW302', 'Floor 3', 'available'),
(62, 1, 62, 'TW303', 'Floor 3', 'available'),
(63, 1, 62, 'TW304', 'Floor 3', 'available'),
(64, 1, 62, 'TW305', 'Floor 3', 'available'),
(65, 1, 62, 'TW306', 'Floor 3', 'available'),
(66, 1, 62, 'TW307', 'Floor 3', 'available'),
(67, 1, 62, 'TW308', 'Floor 3', 'available'),
(68, 1, 62, 'TW309', 'Floor 3', 'available'),
(69, 1, 62, 'TW310', 'Floor 3', 'available'),
(70, 1, 62, 'TW311', 'Floor 3', 'available'),
(71, 1, 62, 'TW312', 'Floor 3', 'available'),
(75, 1, 63, 'SG301', 'Floor 3', 'available'),
(76, 1, 63, 'SG302', 'Floor 3', 'available'),
(77, 1, 63, 'SG303', 'Floor 3', 'available'),
(78, 1, 63, 'SG304', 'Floor 3', 'available'),
(79, 1, 63, 'SG305', 'Floor 3', 'available'),
(80, 1, 63, 'SG306', 'Floor 3', 'available'),
(81, 1, 63, 'SG307', 'Floor 3', 'available'),
(82, 1, 63, 'SG308', 'Floor 3', 'available');

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
  `active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `room_types`
--

INSERT INTO `room_types` (`id`, `hotel_id`, `name`, `description`, `max_guests`, `base_rate`, `active`) VALUES
(1, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(2, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(3, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(4, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(5, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(6, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(7, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(8, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(9, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(10, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(11, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(12, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(13, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(14, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(15, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(16, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(17, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(18, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(19, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(20, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(21, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(22, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(23, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(24, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(25, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(26, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(27, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(28, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(29, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(30, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(31, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(32, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(33, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(34, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(35, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(36, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(37, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(38, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(39, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(40, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(41, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(42, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(43, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(44, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(45, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(46, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(47, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(48, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(49, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(50, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(51, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(52, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(53, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(54, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(55, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(56, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(57, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(58, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(59, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(60, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(61, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(62, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(63, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1);

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
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `hotel_id`, `name`, `contact_person`, `phone`, `email`, `address`, `tax_id`, `active`, `created_at`) VALUES
(1, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(2, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(3, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(4, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(5, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(6, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(7, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(8, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(9, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(10, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(11, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(12, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(13, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(14, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(15, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(16, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(17, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(18, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(19, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(20, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(21, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(22, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(23, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(24, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(25, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(26, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(27, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(28, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(29, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(30, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(31, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(32, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(33, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(34, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(35, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(36, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(37, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(38, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(39, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(40, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL),
(41, 1, 'Nile Distributors Ltd', 'Charles Okello', '+256 771 220 001', 'orders@niledistributors.ug', 'Nasser Road, Jinja', 'NP-0001', 1, NULL),
(42, 1, 'Jinja Fresh Produce', 'Fatuma Nakato', '+256 772 220 002', 'fatuma@jinfresh.ug', 'Main Market, Jinja', 'JF-2200', 1, NULL),
(43, 1, 'Uganda Breweries Supply', 'David Ssewanyana', '+256 773 220 003', 'supply@brewug.ug', 'Kampala', 'UB-3388', 1, NULL),
(44, 1, 'Super Clean Supplies', 'Rita Atim', '+256 774 220 004', 'rt@superclean.ug', 'Madhivani Road, Jinja', 'SC-1144', 1, NULL),
(45, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL);

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
  `password_changed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `hotel_id`, `name`, `email`, `phone`, `password_hash`, `status`, `created_at`, `updated_at`, `profile_image`, `last_login_at`, `password_changed_at`) VALUES
(1, 1, 'Reagan Otema (Administrator)', 'admin@hotelparadiseonthenile.info', '0772 514 889', '$2y$10$liAwR45r6zD/Vl8yzASI3ueZfJGKLnt3PSE2PRPjbL0vogo4Db5A2', 'active', NULL, NULL, NULL, NULL, NULL),
(2, 1, 'Hotel Director', 'director@hotelparadiseonthenile.info', '+256 774 000 001', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(3, 1, 'General Manager', 'gm@hotelparadiseonthenile.info', '+256 774 000 002', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(4, 1, 'Finance Officer', 'accounts@hotelparadiseonthenile.info', '+256 774 000 003', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(5, 1, 'Cashier', 'cashier@hotelparadiseonthenile.info', '+256 774 000 004', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(6, 1, 'Front Desk Reception', 'frontdesk@hotelparadiseonthenile.info', '+256 774 000 005', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(7, 1, 'Restaurant Waiter', 'waiter@hotelparadiseonthenile.info', '+256 774 000 006', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(8, 1, 'Bar Staff', 'bar@hotelparadiseonthenile.info', '+256 774 000 007', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(9, 1, 'Kitchen', 'kitchen@hotelparadiseonthenile.info', '+256 774 000 008', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(10, 1, 'Storekeeper', 'store@hotelparadiseonthenile.info', '+256 774 000 009', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(11, 1, 'Procurement Officer', 'procurement@hotelparadiseonthenile.info', '+256 774 000 010', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(12, 1, 'Housekeeping', 'housekeeping@hotelparadiseonthenile.info', '+256 774 000 011', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(13, 1, 'Internal Auditor', 'auditor@hotelparadiseonthenile.info', '+256 774 000 012', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL, NULL, NULL, NULL),
(66, 1, 'Hotel Paradise Staff', 'staff@hotelparadiseonthenile.info', NULL, '$2y$12$AlYTQE166maMuA7ATDHIBu/E/heL54nmxEUSWcbxDlWp.Ytp.hGL.', 'active', NULL, NULL, NULL, NULL, NULL);

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
  ADD PRIMARY KEY (`id`);

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
  ADD UNIQUE KEY `uq_dining_table` (`outlet_id`,`table_number`);

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
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `requested_by` (`requested_by`);

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
  ADD KEY `hotel_id` (`hotel_id`);

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
  ADD KEY `category_id` (`category_id`);

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
  ADD UNIQUE KEY `invoice_number` (`invoice_number`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_invoice_item_invoice` (`invoice_id`);

--
-- Indexes for table `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_entry_number` (`entry_number`),
  ADD KEY `fk_je_property` (`property_id`),
  ADD KEY `fk_je_period` (`period_id`),
  ADD KEY `fk_je_creator` (`created_by`),
  ADD KEY `fk_je_poster` (`posted_by`);

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
  ADD KEY `shift_id` (`shift_id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `menu_item_id` (`menu_item_id`);

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
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `supplier_id` (`supplier_id`),
  ADD KEY `requisition_id` (`requisition_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `purchase_order_items`
--
ALTER TABLE `purchase_order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `purchase_requisitions`
--
ALTER TABLE `purchase_requisitions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `requested_by` (`requested_by`);

--
-- Indexes for table `purchase_requisition_items`
--
ALTER TABLE `purchase_requisition_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `requisition_id` (`requisition_id`),
  ADD KEY `item_id` (`item_id`);

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
  ADD KEY `guest_id` (`guest_id`);

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
  ADD KEY `room_type_id` (`room_type_id`);

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
  ADD KEY `hotel_id` (`hotel_id`);

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
  ADD KEY `user_id` (`user_id`);

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
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `hotel_id` (`hotel_id`);

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
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `communication_calls`
--
ALTER TABLE `communication_calls`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer_signin_attempts`
--
ALTER TABLE `customer_signin_attempts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customer_tokens`
--
ALTER TABLE `customer_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=224;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2353;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_deliveries`
--
ALTER TABLE `notification_deliveries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_devices`
--
ALTER TABLE `notification_devices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification_events`
--
ALTER TABLE `notification_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

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
