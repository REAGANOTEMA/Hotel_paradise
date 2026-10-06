-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Oct 05, 2026 at 08:42 AM
-- Server version: 10.11.19-MariaDB
-- PHP Version: 8.4.25

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
(1, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(2, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(3, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(4, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(5, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(6, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(7, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(8, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(9, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(10, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(11, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(12, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(13, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(14, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(15, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(16, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(17, 1, 'restaurant', 'Starters', 'TO BEGIN', 'Warm soups, the sandwich corner and freshly dressed salads.', NULL, 10),
(18, 1, 'restaurant', 'Egg Dishes', 'FROM THE PAN', 'Classic egg plates finished to order.', NULL, 20),
(19, 1, 'restaurant', 'Burgers', 'THE GRILL', 'Charcoal patties, regular or Cajun, in a soft toasted bun.', NULL, 30),
(20, 1, 'restaurant', 'Wraps and Rolex', 'ROLLED FRESH', 'Shredded fillings rolled warm in a soft tortilla.', NULL, 40),
(22, 1, 'restaurant', 'Italian Special Pastas', 'FROM NAPOLI', 'Fresh pasta finished with a melted cheese and a slice of toast.', NULL, 60),
(23, 1, 'restaurant', 'Fisherman\'s Offer', 'FRESH FROM THE NILE', 'Whole tilapia, fried, steamed or grilled, oil free on the grill.', NULL, 70),
(24, 1, 'restaurant', 'Fish Fillets', 'THE CATCH', 'Breaded, battered or simply grilled, with rice or chips.', NULL, 80),
(25, 1, 'restaurant', 'Chicken Lovers', 'POULTRY', 'Marinated overnight, grilled, pan fried or tossed in sauce.', NULL, 90),
(26, 1, 'restaurant', 'Paradise Hunter\'s Delicacies', 'STEAKS AND GRILLS', 'Prime beef fillet, skewers and the hunter\'s favourites.', NULL, 100),
(27, 1, 'restaurant', 'Pork', 'PORK', 'Slow roasted, glazed and grilled to your liking.', NULL, 110),
(28, 1, 'restaurant', 'House Specials', 'FOR THE TABLE', 'Platters built for sharing, served with two accompaniments.', NULL, 120),
(29, 1, 'restaurant', 'Asian Delicacies', 'FAR EAST', 'Mild creamy curries, biryani and coconut dishes with rice or chapatti.', NULL, 130),
(30, 1, 'restaurant', 'Desserts', 'SWEET FINISH', 'Fresh fruit, ice cream and a little sugar.', NULL, 140),
(31, 1, 'restaurant', 'Pizzeria Section', 'PIZZA', 'Baked to order on a stone base, 12 inch.', NULL, 150),
(36, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(47, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(48, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(49, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(50, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(51, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(52, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(53, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(54, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(59, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(70, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(71, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(72, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(73, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(74, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(75, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(76, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(77, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(82, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(93, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(94, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(95, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(96, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(97, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(98, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(99, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(100, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(105, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(116, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(117, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(118, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(119, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(120, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(121, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(122, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(123, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(127, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(128, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(129, 1, 'bar', 'Beers & Ciders', NULL, NULL, NULL, 0),
(130, 1, 'bar', 'Wines & Spirits', NULL, NULL, NULL, 0),
(131, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(166, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(177, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(178, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(179, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(180, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(181, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(182, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(183, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(184, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(185, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(186, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(187, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(188, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(189, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(190, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(191, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(192, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(193, 1, 'restaurant', 'Breakfast', NULL, NULL, NULL, 0),
(194, 1, 'restaurant', 'Main Meals', NULL, NULL, NULL, 0),
(195, 1, 'restaurant', 'Snacks', NULL, NULL, NULL, 0),
(196, 1, 'bar', 'Soft Drinks', NULL, NULL, NULL, 0),
(197, 1, 'bar', 'Cocktails', NULL, NULL, NULL, 0),
(198, 1, 'bar', 'Beers and Ciders', NULL, NULL, NULL, 0),
(199, 1, 'bar', 'Wines and Spirits', NULL, NULL, NULL, 0),
(200, 1, 'room_service', 'Room Service', NULL, NULL, NULL, 0),
(201, 1, 'restaurant', 'Starters', 'TO BEGIN', 'Warm soups, the sandwich corner and freshly dressed salads.', NULL, 10),
(202, 1, 'restaurant', 'Egg Dishes', 'FROM THE PAN', 'Classic egg plates finished to order.', NULL, 20),
(203, 1, 'restaurant', 'Burgers', 'THE GRILL', 'Charcoal patties, regular or Cajun, in a soft toasted bun.', NULL, 30),
(204, 1, 'restaurant', 'Wraps and Rolex', 'ROLLED FRESH', 'Shredded fillings rolled warm in a soft tortilla.', NULL, 40),
(205, 1, 'restaurant', 'Snacks', 'LIGHT BITES', 'Served with a choice of rice or chips.', NULL, 50),
(206, 1, 'restaurant', 'Italian Special Pastas', 'FROM NAPOLI', 'Fresh pasta finished with a melted cheese and a slice of toast.', NULL, 60),
(207, 1, 'restaurant', 'Fisherman\'s Offer', 'FRESH FROM THE NILE', 'Whole tilapia, fried, steamed or grilled, oil free on the grill.', NULL, 70),
(208, 1, 'restaurant', 'Fish Fillets', 'THE CATCH', 'Breaded, battered or simply grilled, with rice or chips.', NULL, 80),
(209, 1, 'restaurant', 'Chicken Lovers', 'POULTRY', 'Marinated overnight, grilled, pan fried or tossed in sauce.', NULL, 90),
(210, 1, 'restaurant', 'Paradise Hunter\'s Delicacies', 'STEAKS AND GRILLS', 'Prime beef fillet, skewers and the hunter\'s favourites.', NULL, 100),
(211, 1, 'restaurant', 'Pork', 'PORK', 'Slow roasted, glazed and grilled to your liking.', NULL, 110),
(212, 1, 'restaurant', 'House Specials', 'FOR THE TABLE', 'Platters built for sharing, served with two accompaniments.', NULL, 120),
(213, 1, 'restaurant', 'Asian Delicacies', 'FAR EAST', 'Mild creamy curries, biryani and coconut dishes with rice or chapatti.', NULL, 130),
(214, 1, 'restaurant', 'Desserts', 'SWEET FINISH', 'Fresh fruit, ice cream and a little sugar.', NULL, 140),
(215, 1, 'restaurant', 'Pizzeria Section', 'PIZZA', 'Baked to order on a stone base, 12 inch.', NULL, 150);

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
(6, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(7, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(8, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(9, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(10, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(11, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(12, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(13, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(14, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(15, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(16, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(17, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(18, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(19, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(20, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(21, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(22, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(23, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(24, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(32, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(33, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(34, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(35, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(36, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(37, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(38, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(39, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(40, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(41, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(42, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(43, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(44, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(45, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(46, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(47, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(48, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(49, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(50, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(51, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(52, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(53, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(54, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(55, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(56, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(57, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(58, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(59, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(60, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(61, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(62, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(63, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(64, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(65, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(66, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(67, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(68, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(69, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(70, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(71, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(72, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(73, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(74, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(75, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(76, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(77, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(78, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(79, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(95, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(96, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(97, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(98, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(99, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(100, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(101, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(102, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(103, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(104, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(105, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(106, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(107, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(108, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(109, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(110, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(111, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(112, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(113, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(114, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(115, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(116, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(117, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(118, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(119, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(120, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(121, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(122, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(123, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(124, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(125, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(126, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(127, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(128, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(129, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(130, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(131, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(132, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(133, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(134, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(135, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(136, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(137, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(138, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(139, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(140, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(141, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(142, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(143, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(144, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(145, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(146, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(147, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(148, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(149, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(150, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(151, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(152, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(153, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(154, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(155, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(156, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(157, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(158, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(159, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(160, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(161, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(162, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(163, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(164, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(165, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(166, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(167, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(168, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(169, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(170, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(171, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(172, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(173, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(174, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(175, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(176, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(177, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(178, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(179, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(180, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(181, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(182, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(183, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(184, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(185, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(186, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(187, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(188, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(189, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(190, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(191, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(192, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(193, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(194, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(195, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(196, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(197, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(198, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(199, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(200, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(201, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(202, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(203, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(204, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(205, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(206, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(207, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(208, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(209, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(210, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(211, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(212, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(213, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(214, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(215, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(216, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(217, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(218, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(219, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(220, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(221, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(222, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(223, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(224, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(225, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(226, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(227, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(228, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(229, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(230, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(231, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(232, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(233, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(234, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(235, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(236, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(237, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(238, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(239, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(240, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(241, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(242, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(243, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(244, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(245, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(246, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(247, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(248, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(249, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(250, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(251, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(252, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(253, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(254, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(255, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(256, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(257, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(258, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(259, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(260, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(261, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(262, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(263, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(264, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(265, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(266, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(267, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(268, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(269, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(270, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(271, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(272, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(273, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(274, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(275, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(276, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(277, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(278, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(279, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(280, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(281, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(282, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(283, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(284, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(285, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(286, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(287, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(288, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(289, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(290, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(291, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(292, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(293, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(294, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(295, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(296, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(297, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(298, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(299, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(300, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(301, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(302, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(303, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(304, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(305, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(306, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(307, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(308, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(309, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(310, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(311, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(312, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(313, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(314, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(315, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(316, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(317, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(318, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(319, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(320, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(321, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(322, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(323, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(324, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(325, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(326, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(327, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(328, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(329, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(330, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(331, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(332, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(384, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(385, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(386, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(387, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(388, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(389, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(390, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(391, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(392, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(393, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(394, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(395, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(396, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(397, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(398, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(399, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(400, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(401, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(402, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(403, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(404, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(405, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(406, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(407, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(408, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(409, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(410, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(411, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(412, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(413, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(414, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(415, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(416, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(417, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(418, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(419, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(420, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(421, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(422, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(423, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(424, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(425, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(426, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(427, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(428, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(429, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(430, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(431, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(432, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(433, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(434, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(435, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(436, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(437, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(438, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(439, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(440, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(441, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(442, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0);
INSERT INTO `menu_items` (`id`, `hotel_id`, `category_id`, `name`, `description`, `price`, `image`, `group_name`, `sort_order`, `active`, `stock_tracked`) VALUES
(443, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(444, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(445, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(446, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(447, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(448, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(449, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(450, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(451, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(452, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(453, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(454, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(455, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(456, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(457, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(458, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(459, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(460, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(461, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(462, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(463, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(464, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(465, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(466, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(467, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(468, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(469, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(470, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(471, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(472, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(473, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(474, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(475, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(476, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(477, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(478, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(479, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(480, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(481, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(482, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(483, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(484, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(485, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(486, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(487, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(488, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(489, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(490, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(491, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(492, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(493, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(494, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(495, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(496, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(497, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(498, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(499, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(500, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(501, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(502, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(503, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(504, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(505, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(506, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(507, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(508, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(509, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(510, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(511, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(512, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(513, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(514, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(515, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(516, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(517, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(518, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(519, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(520, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(521, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(522, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(523, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(524, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(525, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(526, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(527, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(528, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(529, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(530, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(531, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(532, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(533, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(534, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(535, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(536, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(537, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(538, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(539, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(540, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(541, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(542, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(543, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(544, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(545, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(546, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(547, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(548, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(549, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(550, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(551, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(552, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(553, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(554, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(555, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(556, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(557, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(558, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(559, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(560, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(561, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(562, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(563, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(564, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(565, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(566, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(567, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(568, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(592, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(593, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(594, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(595, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(596, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(597, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(598, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(599, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(600, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(601, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(602, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(603, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(604, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(605, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(606, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(607, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(608, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(609, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(610, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(611, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(612, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(613, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(614, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(615, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(616, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(617, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(618, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(619, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(620, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(621, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(622, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(623, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(624, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(625, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(626, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(627, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(628, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(629, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(630, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(631, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(632, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(633, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(634, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(635, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(636, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(637, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(638, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(639, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(640, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(641, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(642, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(643, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(644, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(645, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(646, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(647, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(648, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(649, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(650, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(651, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(652, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(653, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(654, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(655, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(656, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(657, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(658, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(659, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(660, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(661, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(662, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(663, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(664, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(665, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(666, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(667, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(668, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(669, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(670, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(671, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(672, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(673, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(674, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(675, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(676, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(677, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(678, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(679, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(680, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(681, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(682, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(683, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(684, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(685, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(686, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(687, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(688, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(689, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(690, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(691, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(692, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(693, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(694, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(695, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(696, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(697, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(698, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(699, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(700, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(701, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(702, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(703, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(704, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(705, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(706, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(707, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(708, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(709, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(710, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(711, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(712, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(713, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(714, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(715, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(716, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(717, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(718, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(719, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(720, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(721, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(722, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(723, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(724, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(725, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(726, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(727, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(728, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(729, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(730, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(731, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(732, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(733, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(734, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(735, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(736, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(737, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(738, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(739, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(740, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(741, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(742, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(743, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(744, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(745, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(746, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(747, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(748, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(749, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(750, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(751, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(752, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(753, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(754, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(755, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(756, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(757, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(758, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(759, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(760, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(761, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(762, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(763, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(764, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(765, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(766, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(767, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(768, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(769, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(770, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(771, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(772, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(773, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(774, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(775, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(776, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(777, 1, 82, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(778, 1, 82, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(779, 1, 82, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(780, 1, 82, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(781, 1, 93, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(782, 1, 93, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(783, 1, 93, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(784, 1, 94, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(785, 1, 94, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(786, 1, 94, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(787, 1, 94, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(788, 1, 94, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(789, 1, 95, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(790, 1, 95, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(791, 1, 95, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(792, 1, 95, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(793, 1, 96, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(794, 1, 96, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(795, 1, 96, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(796, 1, 97, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(797, 1, 97, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(798, 1, 98, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(799, 1, 98, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(800, 1, 98, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(801, 1, 99, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(802, 1, 99, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(803, 1, 100, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(804, 1, 100, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(928, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(929, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(930, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(931, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(932, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(933, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(934, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(935, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(936, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(937, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(938, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(939, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(940, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(941, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(942, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(943, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(944, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(945, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(946, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(947, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(948, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(949, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(950, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(951, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(952, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(953, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(954, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(955, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(956, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(957, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(958, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(959, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(960, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(961, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(962, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(963, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(964, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(965, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(966, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(967, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(968, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(969, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(970, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(971, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(972, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(973, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(974, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(975, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(976, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(977, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(978, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(979, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(980, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(981, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(982, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(983, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(984, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(985, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(986, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(987, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(988, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(989, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(990, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(991, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(992, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0);
INSERT INTO `menu_items` (`id`, `hotel_id`, `category_id`, `name`, `description`, `price`, `image`, `group_name`, `sort_order`, `active`, `stock_tracked`) VALUES
(993, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(994, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(995, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(996, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(997, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(998, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(999, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(1000, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(1001, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(1002, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(1003, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(1004, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(1005, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(1006, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(1007, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(1008, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(1009, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1010, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1011, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1012, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1013, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1014, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1015, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1016, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1017, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1018, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1019, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1020, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1021, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1022, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1023, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1024, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1025, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1026, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1027, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1028, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1029, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1030, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1031, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1032, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1033, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1034, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1035, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1036, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1037, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1038, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1039, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1040, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1041, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1042, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1043, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1044, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1045, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1046, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1047, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1048, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1049, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1050, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1051, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1052, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1053, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1054, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1055, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1056, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1057, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1058, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1059, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1060, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1061, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1062, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1063, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1064, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1065, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1066, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1067, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1068, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1069, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1070, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1071, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1072, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1073, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1074, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1075, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1076, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1077, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1078, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1079, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1080, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1081, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1082, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1083, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1084, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1085, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1086, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1087, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1088, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1089, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1090, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1091, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1092, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1093, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1094, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1095, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1096, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1097, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1098, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1099, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1100, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1101, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1102, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1103, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1104, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1105, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1106, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1107, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1108, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1109, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1110, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1111, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1112, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1113, 1, 82, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1114, 1, 82, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1115, 1, 82, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1116, 1, 82, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1117, 1, 93, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1118, 1, 93, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1119, 1, 93, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1120, 1, 94, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1121, 1, 94, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1122, 1, 94, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1123, 1, 94, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1124, 1, 94, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1125, 1, 95, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1126, 1, 95, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1127, 1, 95, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1128, 1, 95, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1129, 1, 96, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1130, 1, 96, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1131, 1, 96, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1132, 1, 97, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1133, 1, 97, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1134, 1, 98, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1135, 1, 98, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1136, 1, 98, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1137, 1, 99, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1138, 1, 99, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1139, 1, 100, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1140, 1, 100, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1141, 1, 105, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1142, 1, 105, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1143, 1, 105, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1144, 1, 105, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1145, 1, 116, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1146, 1, 116, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1147, 1, 116, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1148, 1, 117, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1149, 1, 117, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1150, 1, 117, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1151, 1, 117, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1152, 1, 117, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1153, 1, 118, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1154, 1, 118, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1155, 1, 118, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1156, 1, 118, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1157, 1, 119, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1158, 1, 119, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1159, 1, 119, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1160, 1, 120, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1161, 1, 120, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1162, 1, 121, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1163, 1, 121, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1164, 1, 121, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1165, 1, 122, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1166, 1, 122, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1167, 1, 123, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1168, 1, 123, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1264, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(1265, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(1266, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(1267, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(1268, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(1269, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(1270, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(1271, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(1272, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(1273, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(1274, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(1275, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(1276, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(1277, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(1278, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(1279, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(1280, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(1281, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(1282, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(1283, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(1284, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(1285, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(1286, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(1287, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(1288, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(1289, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(1290, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(1291, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(1292, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(1293, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(1294, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(1295, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(1296, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(1297, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(1298, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(1299, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(1300, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(1301, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(1302, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(1303, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(1304, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(1305, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(1306, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(1307, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(1308, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(1309, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(1310, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(1311, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(1312, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(1313, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(1314, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(1315, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(1316, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(1317, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(1318, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(1319, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(1320, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(1321, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(1322, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(1323, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(1324, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(1325, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(1326, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(1327, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(1328, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(1329, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(1330, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(1331, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(1332, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(1333, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(1334, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(1335, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(1336, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(1337, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(1338, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(1339, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(1340, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(1341, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(1342, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(1343, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(1344, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(1345, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(1346, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(1347, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(1348, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(1349, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(1350, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(1351, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(1352, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(1353, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(1354, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(1355, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(1356, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(1357, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(1358, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(1359, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(1360, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(1361, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(1362, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(1363, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(1364, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(1365, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(1366, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(1367, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(1368, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(1369, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(1370, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(1371, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(1372, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(1373, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(1374, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(1375, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(1376, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(1377, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(1378, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(1379, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(1380, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(1381, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(1382, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1),
(1383, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(1384, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(1385, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(1386, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(1387, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(1388, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(1389, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(1390, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(1391, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(1392, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(1393, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(1394, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(1395, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(1396, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(1397, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(1398, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(1399, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(1400, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(1401, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(1402, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(1403, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(1404, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(1405, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(1406, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(1407, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(1408, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(1409, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(1410, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(1411, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(1412, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(1413, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(1414, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(1415, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(1416, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(1417, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(1418, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(1419, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(1420, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(1421, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(1422, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(1423, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(1424, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(1425, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(1426, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 0, 0),
(1427, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 0, 0),
(1428, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 0, 0),
(1429, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 0, 0),
(1430, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 0, 0),
(1431, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 0, 0),
(1432, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 0, 0),
(1433, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 0, 0),
(1434, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 0, 0),
(1435, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 0, 0),
(1436, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 0, 0),
(1437, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 0, 0),
(1438, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 0, 0),
(1439, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 0, 1),
(1440, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 0, 1),
(1441, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 0, 1),
(1442, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 0, 0),
(1443, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 0, 0),
(1444, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 0, 0),
(1445, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 0, 0),
(1446, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 0, 0),
(1447, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 0, 0),
(1448, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 0, 1),
(1449, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 0, 1),
(1450, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 0, 1),
(1451, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 0, 0),
(1452, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 0, 0),
(1453, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 0, 0),
(1454, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 0, 1),
(1455, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 0, 1),
(1456, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 0, 1),
(1457, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 0, 1),
(1458, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 0, 1),
(1459, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 0, 1),
(1460, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 0, 1),
(1461, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 0, 1),
(1462, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 0, 1),
(1463, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 0, 1);
INSERT INTO `menu_items` (`id`, `hotel_id`, `category_id`, `name`, `description`, `price`, `image`, `group_name`, `sort_order`, `active`, `stock_tracked`) VALUES
(1464, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 0, 1),
(1465, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 0, 1),
(1466, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 0, 1),
(1467, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 0, 1),
(1468, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 0, 1),
(1469, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 0, 1),
(1470, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 0, 1),
(1471, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 0, 1),
(1472, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 0, 1),
(1473, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 0, 1),
(1474, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 0, 1),
(1475, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 0, 1),
(1476, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 0, 1),
(1477, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 0, 1),
(1478, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 0, 1),
(1479, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 0, 1),
(1480, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 0, 1),
(1481, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 0, 1),
(1482, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 0, 1),
(1483, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 0, 0),
(1484, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 0, 0),
(1485, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 0, 0),
(1486, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 0, 1),
(1487, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 0, 1),
(1488, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 0, 0),
(1489, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 0, 0),
(1490, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 0, 0),
(1491, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 0, 0),
(1492, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 0, 0),
(1493, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 0, 0),
(1494, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 0, 0),
(1495, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 0, 0),
(1496, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 0, 0),
(1497, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 0, 0),
(1498, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 0, 0),
(1499, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 0, 0),
(1500, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 0, 0),
(1501, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 0, 1),
(1502, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 0, 0),
(1503, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 0, 0),
(1504, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 0, 0),
(1505, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 0, 0),
(1506, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 0, 0),
(1507, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1508, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1509, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1510, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1511, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1512, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1513, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1514, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1515, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1516, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1517, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1518, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1519, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1520, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1521, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1522, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1523, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1524, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1525, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1526, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1527, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1528, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1529, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1530, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1531, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1532, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1533, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1534, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1535, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1536, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1537, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1538, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1539, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1540, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1541, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1542, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1543, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1544, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1545, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1546, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1547, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1548, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1549, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1550, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1551, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1552, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1553, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1554, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1555, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1556, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1557, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1558, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1559, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1560, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1561, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1562, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1563, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1564, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1565, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1566, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1567, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1568, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1569, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1570, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1571, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1572, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1573, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1574, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1575, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1576, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1577, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1578, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1579, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1580, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1581, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1582, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1583, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1584, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1585, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1586, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1587, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1588, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1589, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1590, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1591, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1592, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1593, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1594, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1595, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1596, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1597, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1598, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1599, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1600, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1601, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1602, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1603, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1604, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1605, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1606, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1607, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1608, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1609, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1610, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1611, 1, 82, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1612, 1, 82, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1613, 1, 82, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1614, 1, 82, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1615, 1, 93, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1616, 1, 93, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1617, 1, 93, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1618, 1, 94, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1619, 1, 94, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1620, 1, 94, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1621, 1, 94, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1622, 1, 94, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1623, 1, 95, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1624, 1, 95, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1625, 1, 95, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1626, 1, 95, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1627, 1, 96, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1628, 1, 96, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1629, 1, 96, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1630, 1, 97, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1631, 1, 97, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1632, 1, 98, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1633, 1, 98, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1634, 1, 98, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1635, 1, 99, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1636, 1, 99, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1637, 1, 100, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1638, 1, 100, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1639, 1, 105, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1640, 1, 105, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1641, 1, 105, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1642, 1, 105, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1643, 1, 116, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1644, 1, 116, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1645, 1, 116, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1646, 1, 117, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1647, 1, 117, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1648, 1, 117, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1649, 1, 117, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1650, 1, 117, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1651, 1, 118, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1652, 1, 118, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1653, 1, 118, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1654, 1, 118, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1655, 1, 119, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1656, 1, 119, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1657, 1, 119, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1658, 1, 120, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1659, 1, 120, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1660, 1, 121, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1661, 1, 121, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1662, 1, 121, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1663, 1, 122, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1664, 1, 122, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1665, 1, 123, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1666, 1, 123, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1667, 1, 127, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1668, 1, 127, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1669, 1, 127, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1670, 1, 128, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1671, 1, 128, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1672, 1, 131, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1673, 1, 131, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1674, 1, 166, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1675, 1, 166, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1676, 1, 166, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1677, 1, 166, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1678, 1, 177, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1679, 1, 177, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1680, 1, 177, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1681, 1, 178, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1682, 1, 178, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1683, 1, 178, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1684, 1, 178, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1685, 1, 178, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1686, 1, 179, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1687, 1, 179, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1688, 1, 179, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1689, 1, 179, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1690, 1, 180, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1691, 1, 180, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1692, 1, 180, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1693, 1, 181, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1694, 1, 181, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1695, 1, 182, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1696, 1, 182, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1697, 1, 182, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1698, 1, 183, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1699, 1, 183, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1700, 1, 184, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1701, 1, 184, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1762, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1763, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1764, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1765, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1766, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1767, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1768, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1769, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1770, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1771, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1772, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1773, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1774, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1775, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1776, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1777, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1778, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1779, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1780, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1781, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1782, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1783, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1784, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1785, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1786, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1787, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1788, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1789, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1790, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1791, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1792, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1793, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1794, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1795, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1796, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1797, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1798, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1799, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1800, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1801, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1802, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1803, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1804, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1805, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1806, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1807, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1808, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1809, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1810, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1811, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1812, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1813, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1814, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1815, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1816, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1817, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1818, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1819, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1820, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1821, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1822, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1823, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1824, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1825, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1826, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1827, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1828, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1829, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1830, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1831, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1832, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1833, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1834, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1835, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1836, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1837, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1838, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1839, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1840, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1841, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1842, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1843, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1844, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1845, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1846, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1847, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1848, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1849, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1850, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1851, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1852, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1853, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1854, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1855, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1856, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1857, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1858, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1859, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1860, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1861, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1862, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1863, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1864, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1865, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1866, 1, 82, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1867, 1, 82, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1868, 1, 82, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1869, 1, 82, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1870, 1, 93, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1871, 1, 93, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1872, 1, 93, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1873, 1, 94, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1874, 1, 94, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1875, 1, 94, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1876, 1, 94, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1877, 1, 94, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1878, 1, 95, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1879, 1, 95, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1880, 1, 95, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1881, 1, 95, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1882, 1, 96, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1883, 1, 96, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1884, 1, 96, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1885, 1, 97, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1886, 1, 97, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1887, 1, 98, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1888, 1, 98, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1889, 1, 98, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1890, 1, 99, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1891, 1, 99, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1892, 1, 100, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1893, 1, 100, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1894, 1, 105, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1895, 1, 105, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1896, 1, 105, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1897, 1, 105, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1898, 1, 116, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1899, 1, 116, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1900, 1, 116, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1901, 1, 117, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1902, 1, 117, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1903, 1, 117, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1904, 1, 117, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1905, 1, 117, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1906, 1, 118, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1907, 1, 118, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1908, 1, 118, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1909, 1, 118, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1910, 1, 119, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1911, 1, 119, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1912, 1, 119, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1913, 1, 120, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1914, 1, 120, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1915, 1, 121, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1916, 1, 121, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1917, 1, 121, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1918, 1, 122, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1919, 1, 122, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1920, 1, 123, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1921, 1, 123, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1922, 1, 127, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1923, 1, 127, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1924, 1, 127, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1925, 1, 128, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1926, 1, 128, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1927, 1, 131, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1928, 1, 131, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1929, 1, 166, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1930, 1, 166, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1931, 1, 166, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1932, 1, 166, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1933, 1, 177, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1934, 1, 177, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1935, 1, 177, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1936, 1, 178, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1937, 1, 178, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1938, 1, 178, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1939, 1, 178, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1940, 1, 178, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1941, 1, 179, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1942, 1, 179, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1943, 1, 179, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1944, 1, 179, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1945, 1, 180, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1946, 1, 180, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1947, 1, 180, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1948, 1, 181, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1949, 1, 181, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1950, 1, 182, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1951, 1, 182, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1952, 1, 182, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1953, 1, 183, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1954, 1, 183, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1955, 1, 184, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1956, 1, 184, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(1957, 1, 185, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(1958, 1, 185, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(1959, 1, 185, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(1960, 1, 186, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(1961, 1, 186, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(1962, 1, 186, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(1963, 1, 186, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(1964, 1, 186, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(1965, 1, 187, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(1966, 1, 187, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(1967, 1, 187, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(1968, 1, 187, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(1969, 1, 188, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(1970, 1, 188, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(1971, 1, 188, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(1972, 1, 189, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(1973, 1, 189, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(1974, 1, 190, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1975, 1, 190, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1976, 1, 190, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(1977, 1, 191, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(1978, 1, 191, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(1979, 1, 192, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(1980, 1, 192, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2017, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2018, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2019, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2020, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2021, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2022, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2023, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2024, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2025, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2026, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2027, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2028, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2029, 1, 4, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2030, 1, 4, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2031, 1, 4, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2032, 1, 5, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1);
INSERT INTO `menu_items` (`id`, `hotel_id`, `category_id`, `name`, `description`, `price`, `image`, `group_name`, `sort_order`, `active`, `stock_tracked`) VALUES
(2033, 1, 5, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2034, 1, 6, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2035, 1, 6, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2036, 1, 6, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2037, 1, 7, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2038, 1, 7, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2039, 1, 8, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2040, 1, 8, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2041, 1, 9, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2042, 1, 9, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2043, 1, 9, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2044, 1, 10, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2045, 1, 10, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2046, 1, 10, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2047, 1, 10, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2048, 1, 10, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2049, 1, 11, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2050, 1, 11, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2051, 1, 11, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2052, 1, 11, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2053, 1, 12, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2054, 1, 12, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2055, 1, 12, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2056, 1, 13, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2057, 1, 13, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2058, 1, 14, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2059, 1, 14, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2060, 1, 14, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2061, 1, 15, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2062, 1, 15, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2063, 1, 16, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2064, 1, 16, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2065, 1, 36, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2066, 1, 36, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2067, 1, 36, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2068, 1, 36, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2069, 1, 47, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2070, 1, 47, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2071, 1, 47, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2072, 1, 48, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2073, 1, 48, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2074, 1, 48, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2075, 1, 48, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2076, 1, 48, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2077, 1, 49, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2078, 1, 49, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2079, 1, 49, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2080, 1, 49, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2081, 1, 50, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2082, 1, 50, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2083, 1, 50, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2084, 1, 51, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2085, 1, 51, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2086, 1, 52, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2087, 1, 52, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2088, 1, 52, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2089, 1, 53, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2090, 1, 53, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2091, 1, 54, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2092, 1, 54, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2093, 1, 59, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2094, 1, 59, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2095, 1, 59, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2096, 1, 59, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2097, 1, 70, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2098, 1, 70, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2099, 1, 70, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2100, 1, 71, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2101, 1, 71, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2102, 1, 71, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2103, 1, 71, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2104, 1, 71, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2105, 1, 72, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2106, 1, 72, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2107, 1, 72, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2108, 1, 72, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2109, 1, 73, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2110, 1, 73, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2111, 1, 73, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2112, 1, 74, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2113, 1, 74, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2114, 1, 75, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2115, 1, 75, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2116, 1, 75, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2117, 1, 76, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2118, 1, 76, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2119, 1, 77, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2120, 1, 77, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2121, 1, 82, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2122, 1, 82, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2123, 1, 82, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2124, 1, 82, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2125, 1, 93, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2126, 1, 93, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2127, 1, 93, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2128, 1, 94, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2129, 1, 94, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2130, 1, 94, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2131, 1, 94, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2132, 1, 94, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2133, 1, 95, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2134, 1, 95, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2135, 1, 95, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2136, 1, 95, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2137, 1, 96, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2138, 1, 96, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2139, 1, 96, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2140, 1, 97, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2141, 1, 97, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2142, 1, 98, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2143, 1, 98, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2144, 1, 98, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2145, 1, 99, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2146, 1, 99, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2147, 1, 100, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2148, 1, 100, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2149, 1, 105, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2150, 1, 105, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2151, 1, 105, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2152, 1, 105, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2153, 1, 116, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2154, 1, 116, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2155, 1, 116, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2156, 1, 117, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2157, 1, 117, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2158, 1, 117, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2159, 1, 117, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2160, 1, 117, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2161, 1, 118, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2162, 1, 118, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2163, 1, 118, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2164, 1, 118, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2165, 1, 119, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2166, 1, 119, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2167, 1, 119, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2168, 1, 120, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2169, 1, 120, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2170, 1, 121, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2171, 1, 121, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2172, 1, 121, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2173, 1, 122, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2174, 1, 122, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2175, 1, 123, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2176, 1, 123, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2177, 1, 127, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2178, 1, 127, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2179, 1, 127, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2180, 1, 128, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2181, 1, 128, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2182, 1, 131, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2183, 1, 131, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2184, 1, 166, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2185, 1, 166, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2186, 1, 166, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2187, 1, 166, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2188, 1, 177, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2189, 1, 177, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2190, 1, 177, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2191, 1, 178, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2192, 1, 178, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2193, 1, 178, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2194, 1, 178, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2195, 1, 178, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2196, 1, 179, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2197, 1, 179, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2198, 1, 179, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2199, 1, 179, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2200, 1, 180, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2201, 1, 180, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2202, 1, 180, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2203, 1, 181, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2204, 1, 181, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2205, 1, 182, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2206, 1, 182, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2207, 1, 182, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2208, 1, 183, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2209, 1, 183, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2210, 1, 184, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2211, 1, 184, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2212, 1, 185, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2213, 1, 185, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2214, 1, 185, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2215, 1, 186, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2216, 1, 186, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2217, 1, 186, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2218, 1, 186, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2219, 1, 186, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2220, 1, 187, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2221, 1, 187, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2222, 1, 187, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2223, 1, 187, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2224, 1, 188, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2225, 1, 188, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2226, 1, 188, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2227, 1, 189, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2228, 1, 189, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2229, 1, 190, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2230, 1, 190, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2231, 1, 190, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2232, 1, 191, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2233, 1, 191, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2234, 1, 192, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2235, 1, 192, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2236, 1, 193, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 0, 0),
(2237, 1, 193, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 0, 0),
(2238, 1, 193, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 0, 0),
(2239, 1, 194, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 0, 1),
(2240, 1, 194, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 0, 1),
(2241, 1, 194, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, NULL, NULL, 0, 0, 1),
(2242, 1, 194, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 0, 1),
(2243, 1, 194, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 0, 1),
(2244, 1, 195, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 0, 1),
(2245, 1, 195, 'Samosas', 'Three vegetable or meat samosas', 10000.00, NULL, NULL, 0, 0, 1),
(2246, 1, 195, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 0, 1),
(2247, 1, 195, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 0, 1),
(2248, 1, 196, 'Coca Cola 300ml', 'Ice cold bottle', 3000.00, NULL, NULL, 0, 1, 1),
(2249, 1, 196, 'Fanta 300ml', 'Orange or passion fruit', 3000.00, NULL, NULL, 0, 1, 1),
(2250, 1, 196, 'Mineral Water 500ml', 'Chilled bottled water', 2000.00, NULL, NULL, 0, 1, 1),
(2251, 1, 197, 'Paradise Sunset', 'House signature cocktail with a Nile twist', 25000.00, NULL, NULL, 0, 1, 1),
(2252, 1, 197, 'Nile Breeze', 'Light, refreshing cocktail of the house', 25000.00, NULL, NULL, 0, 1, 1),
(2253, 1, 198, 'Nile Special', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2254, 1, 198, 'Club Pilsener', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2255, 1, 198, 'Bell Lager', '500ml bottle', 5000.00, NULL, NULL, 0, 1, 1),
(2256, 1, 199, 'House White Wine', 'Glass of the house white wine', 20000.00, NULL, NULL, 0, 1, 1),
(2257, 1, 199, 'Local Spirit', 'Uganda Waragi or other local spirit', 15000.00, NULL, NULL, 0, 1, 1),
(2258, 1, 200, 'Room Service Breakfast', 'Full breakfast delivered to your room', 28000.00, NULL, NULL, 0, 1, 1),
(2259, 1, 200, 'Room Service Platter', 'Nile grilled selection delivered to your room', 45000.00, NULL, NULL, 0, 1, 1),
(2272, 1, 17, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, NULL, 'Soups', 10, 1, 0),
(2273, 1, 17, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, NULL, 'Soups', 20, 1, 0),
(2274, 1, 17, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, NULL, 'Sandwich Corner', 30, 1, 0),
(2275, 1, 17, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, NULL, 'Sandwich Corner', 40, 1, 0),
(2276, 1, 17, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, NULL, 'Sandwich Corner', 50, 1, 0),
(2277, 1, 17, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, NULL, 'Sandwich Corner', 60, 1, 0),
(2278, 1, 17, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, NULL, 'Salads', 70, 1, 0),
(2279, 1, 17, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, NULL, 'Salads', 80, 1, 0),
(2280, 1, 17, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, NULL, 'Salads', 90, 1, 0),
(2281, 1, 18, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, NULL, 'Egg Dishes', 10, 1, 0),
(2282, 1, 18, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, NULL, 'Egg Dishes', 20, 1, 0),
(2283, 1, 18, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, NULL, 'Egg Dishes', 30, 1, 0),
(2284, 1, 19, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, NULL, 'Burgers', 10, 1, 0),
(2285, 1, 19, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, NULL, 'Burgers', 20, 1, 1),
(2286, 1, 19, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, NULL, 'Burgers', 30, 1, 1),
(2287, 1, 19, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, NULL, 'Burgers', 40, 1, 1),
(2288, 1, 20, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, NULL, 'Wraps', 10, 1, 0),
(2289, 1, 20, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, NULL, 'Wraps', 20, 1, 0),
(2290, 1, 20, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, NULL, 'Wraps', 30, 1, 0),
(2291, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, NULL, 'Snacks', 10, 1, 0),
(2292, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, NULL, 'Snacks', 20, 1, 0),
(2293, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, NULL, 'Snacks', 30, 1, 0),
(2294, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, NULL, 'Snacks', 40, 1, 1),
(2295, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, NULL, 'Snacks', 50, 1, 1),
(2296, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, NULL, 'Snacks', 60, 1, 1),
(2297, 1, 22, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, NULL, 'Pasta', 10, 1, 0),
(2298, 1, 22, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, NULL, 'Pasta', 20, 1, 0),
(2299, 1, 22, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, NULL, 'Pasta', 30, 1, 0),
(2300, 1, 23, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 10, 1, 1),
(2301, 1, 23, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, NULL, 'Whole Fish', 20, 1, 1),
(2302, 1, 23, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 30, 1, 1),
(2303, 1, 23, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, NULL, 'Whole Fish', 40, 1, 1),
(2304, 1, 23, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, NULL, 'Whole Fish', 50, 1, 1),
(2305, 1, 24, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, NULL, 'Fish Fillets', 10, 1, 1),
(2306, 1, 24, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, NULL, 'Fish Fillets', 20, 1, 1),
(2307, 1, 24, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, NULL, 'Fish Fillets', 30, 1, 1),
(2308, 1, 24, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, NULL, 'Fish Fillets', 40, 1, 1),
(2309, 1, 25, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, NULL, 'Chicken Lovers', 10, 1, 1),
(2310, 1, 25, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, NULL, 'Chicken Lovers', 20, 1, 1),
(2311, 1, 25, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, NULL, 'Chicken Lovers', 30, 1, 1),
(2312, 1, 25, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, NULL, 'Chicken Lovers', 40, 1, 1),
(2313, 1, 25, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, NULL, 'Chicken Lovers', 50, 1, 1),
(2314, 1, 26, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, NULL, 'Steaks', 10, 1, 1),
(2315, 1, 26, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, NULL, 'Steaks', 20, 1, 1),
(2316, 1, 26, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, NULL, 'Steaks', 30, 1, 1),
(2317, 1, 26, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, NULL, 'Steaks', 40, 1, 1),
(2318, 1, 26, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, NULL, 'Steaks', 50, 1, 1),
(2319, 1, 26, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, NULL, 'Steaks', 60, 1, 1),
(2320, 1, 26, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, NULL, 'Steaks', 70, 1, 1),
(2321, 1, 26, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, NULL, 'Steaks', 80, 1, 1),
(2322, 1, 27, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 10, 1, 1),
(2323, 1, 27, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, NULL, 'Pork', 20, 1, 1),
(2324, 1, 27, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, NULL, 'Pork', 30, 1, 1),
(2325, 1, 27, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, NULL, 'Pork', 40, 1, 1),
(2326, 1, 27, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, NULL, 'Pork', 50, 1, 1),
(2327, 1, 28, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, NULL, 'House Specials', 10, 1, 1),
(2328, 1, 28, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, NULL, 'House Specials', 20, 1, 1),
(2329, 1, 29, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, NULL, 'Curries', 10, 1, 0),
(2330, 1, 29, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, NULL, 'Curries', 20, 1, 0),
(2331, 1, 29, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, NULL, 'Biryani', 30, 1, 0),
(2332, 1, 29, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, NULL, 'Biryani', 40, 1, 1),
(2333, 1, 29, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, NULL, 'Curries', 50, 1, 1),
(2334, 1, 30, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, NULL, 'Desserts', 10, 1, 0),
(2335, 1, 30, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, NULL, 'Desserts', 20, 1, 0),
(2336, 1, 30, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, NULL, 'Desserts', 30, 1, 0),
(2337, 1, 30, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, NULL, 'Desserts', 40, 1, 0),
(2338, 1, 30, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, NULL, 'Desserts', 50, 1, 0),
(2339, 1, 30, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, NULL, 'Desserts', 60, 1, 0),
(2340, 1, 30, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, NULL, 'Desserts', 70, 1, 0),
(2341, 1, 31, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, NULL, 'Pizza', 10, 1, 0),
(2342, 1, 31, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, NULL, 'Pizza', 20, 1, 0),
(2343, 1, 31, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, NULL, 'Pizza', 30, 1, 0),
(2344, 1, 31, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, NULL, 'Pizza', 40, 1, 0),
(2345, 1, 31, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, NULL, 'Pizza', 50, 1, 0),
(2346, 1, 31, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 60, 1, 0),
(2347, 1, 31, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, NULL, 'Pizza', 70, 1, 1),
(2348, 1, 31, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, NULL, 'Pizza', 80, 1, 0),
(2349, 1, 31, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, NULL, 'Pizza', 90, 1, 0),
(2350, 1, 31, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, NULL, 'Pizza', 100, 1, 0),
(2351, 1, 31, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, NULL, 'Calzone', 110, 1, 0),
(2352, 1, 31, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, NULL, 'Pizza', 120, 1, 0);

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
-- Table structure for table `notification_devices`
--

CREATE TABLE `notification_devices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `platform` enum('web','android','ios','other') NOT NULL,
  `push_token` varchar(500) NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `last_seen_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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

INSERT INTO `payments` (`id`, `hotel_id`, `user_id`, `invoice_id`, `order_id`, `reservation_id`, `amount`, `method`, `provider`, `provider_reference`, `status`, `created_at`) VALUES
(1, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(2, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(3, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(4, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(5, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(6, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(7, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(8, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL),
(9, 1, 6, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL);

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
(7, 'email', 'hotel@hotelparadiseonthenile.info', '2026-10-05 05:31:09', '2026-10-05 05:31:09'),
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
-- Indexes for table `notification_devices`
--
ALTER TABLE `notification_devices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_push_token` (`push_token`(191)),
  ADD KEY `fk_nd_user` (`user_id`);

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
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=216;

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
-- AUTO_INCREMENT for table `notification_devices`
--
ALTER TABLE `notification_devices`
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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=160;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
