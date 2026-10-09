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
-- Database: `hotelpardise_website`
--

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
(9, 'Laundry', 'LD', 1);

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
(20, NULL, 1, 'Amelia Turner', '+256 770 111 005', 'amelia.turner@example.com', 'British', 'Passport', 'GB-5522', NULL, NULL);

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
(9, 1, 'restaurant', 'Starters', 'TO BEGIN', 'Warm soups, the sandwich corner and freshly dressed salads.', 'caesar-salad.jpg', 10),
(10, 1, 'restaurant', 'Egg Dishes', 'FROM THE PAN', 'Classic egg plates finished to order.', 'spanish-omelet.jpg', 20),
(11, 1, 'restaurant', 'Burgers', 'THE GRILL', 'Charcoal patties, regular or Cajun, in a soft toasted bun.', 'king-burger.jpg', 30),
(12, 1, 'restaurant', 'Wraps and Rolex', 'ROLLED FRESH', 'Shredded fillings rolled warm in a soft tortilla.', 'beef-rolex.jpg', 40),
(14, 1, 'restaurant', 'Italian Special Pastas', 'FROM NAPOLI', 'Fresh pasta finished with a melted cheese and a slice of toast.', 'pasta-a-la-carbonara.jpg', 60),
(15, 1, 'restaurant', 'Fisherman\'s Offer', 'FRESH FROM THE NILE', 'Whole tilapia, fried, steamed or grilled, oil free on the grill.', 'grilled-king-fish.jpg', 70),
(16, 1, 'restaurant', 'Fish Fillets', 'THE CATCH', 'Breaded, battered or simply grilled, with rice or chips.', 'pan-grilled-fish-fillet.jpg', 80),
(17, 1, 'restaurant', 'Chicken Lovers', 'POULTRY', 'Marinated overnight, grilled, pan fried or tossed in sauce.', 'bbq-chicken-drumstick.jpg', 90),
(18, 1, 'restaurant', 'Paradise Hunter\'s Delicacies', 'STEAKS AND GRILLS', 'Prime beef fillet, skewers and the hunter\'s favourites.', 'paradise-mixed-grill.jpg', 100),
(19, 1, 'restaurant', 'Pork', 'PORK', 'Slow roasted, glazed and grilled to your liking.', 'honey-mustard-glazed-pork-ribs.jpg', 110),
(20, 1, 'restaurant', 'House Specials', 'FOR THE TABLE', 'Platters built for sharing, served with two accompaniments.', 'mixed-grill-platter.jpg', 120),
(21, 1, 'restaurant', 'Asian Delicacies', 'FAR EAST', 'Mild creamy curries, biryani and coconut dishes with rice or chapatti.', 'chicken-coconut-curry.jpg', 130),
(22, 1, 'restaurant', 'Desserts', 'SWEET FINISH', 'Fresh fruit, ice cream and a little sugar.', 'fruits-image.jpg', 140),
(23, 1, 'restaurant', 'Pizzeria Section', 'PIZZA', 'Baked to order on a stone base, 12 inch.', 'section-pizza.jpg', 150),
(83, 1, 'bar', 'Beers & Ciders', NULL, NULL, NULL, 0),
(84, 1, 'bar', 'Wines & Spirits', NULL, NULL, NULL, 0);

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
(384, 1, 9, 'Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000.00, 'mushroom-soup.jpg', 'Soups', 10, 1, 0),
(385, 1, 9, 'Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000.00, 'clear-chicken-noodle-soup.jpg', 'Soups', 20, 1, 0),
(386, 1, 9, 'Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000.00, 'classic-blt-sandwich.jpg', 'Sandwich Corner', 30, 1, 0),
(387, 1, 9, 'Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', NULL, 'three-decker-sandwich.webp', 'Sandwich Corner', 40, 1, 0),
(388, 1, 9, 'Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000.00, 'tuna-melt-sandwich.jpg', 'Sandwich Corner', 50, 1, 0),
(389, 1, 9, 'Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000.00, 'paradise-club-sandwich.jpg', 'Sandwich Corner', 60, 1, 0),
(390, 1, 9, 'Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000.00, 'grilled-vegetables-salad.jpg', 'Salads', 70, 1, 0),
(391, 1, 9, 'Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000.00, 'grilled-chicken-salad.jpg', 'Salads', 80, 1, 0),
(392, 1, 9, 'Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000.00, 'tuna-salad.jpg', 'Salads', 90, 1, 0),
(393, 1, 10, 'Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000.00, 'spanish-omelet.jpg', 'Egg Dishes', 10, 1, 0),
(394, 1, 10, 'Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000.00, 'avocado-with-an-egg.jpg', 'Egg Dishes', 20, 1, 0),
(395, 1, 10, 'Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', NULL, 'bacon-cheese-omelet.jpg', 'Egg Dishes', 30, 1, 0),
(396, 1, 11, 'Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000.00, 'vegetable-burger.jpg', 'Burgers', 10, 1, 0),
(397, 1, 11, 'Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', NULL, 'chicken-burger.jpg', 'Burgers', 20, 1, 1),
(398, 1, 11, 'BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', NULL, 'bbq-beef-and-chicken-patty.jpg', 'Burgers', 30, 1, 1),
(399, 1, 11, 'Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', NULL, 'double-beef-and-bacon-burger.jpg', 'Burgers', 40, 1, 1),
(400, 1, 12, 'Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000.00, 'chicken-wrap.jpg', 'Wraps', 10, 1, 0),
(401, 1, 12, 'Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000.00, 'crunchy-vegetable-wrap.jpg', 'Wraps', 20, 1, 0),
(402, 1, 12, 'Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000.00, 'chicken-rolex.jpg', 'Wraps', 30, 1, 0),
(403, 1, 3, 'Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', NULL, 'chilli-beef-and-veggie-chips.jpg', 'Snacks', 10, 1, 0),
(404, 1, 3, 'Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000.00, 'pair-of-chicken-spring-rolls.jpg', 'Snacks', 20, 1, 0),
(405, 1, 3, 'Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000.00, 'liver-with-shredded-vegetables.jpg', 'Snacks', 30, 1, 0),
(406, 1, 3, 'Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000.00, 'fish-fingers-with-chips.jpg', 'Snacks', 40, 1, 1),
(407, 1, 3, 'Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000.00, 'chicken-wings-with-chips.jpg', 'Snacks', 50, 1, 1),
(408, 1, 3, 'Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000.00, 'chicken-lollipops-with-chips.jpg', 'Snacks', 60, 1, 1),
(409, 1, 14, 'Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000.00, 'pasta-arabiata.jpg', 'Pasta', 10, 1, 0),
(410, 1, 14, 'Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000.00, 'pasta-classic-bolognaise.jpg', 'Pasta', 20, 1, 0),
(411, 1, 14, 'Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000.00, 'pasta-a-la-carbonara.jpg', 'Pasta', 30, 1, 0),
(412, 1, 15, 'Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', NULL, 'premium-whole-fried.jpg', 'Whole Fish', 10, 1, 1),
(413, 1, 15, 'Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', NULL, 'premium-wet-fried-tilapia.jpg', 'Whole Fish', 20, 1, 1),
(414, 1, 15, 'Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', NULL, 'grilled-premium-fish.jpg', 'Whole Fish', 30, 1, 1),
(415, 1, 15, 'Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', NULL, 'large-fried-tilapia.jpg', 'Whole Fish', 40, 1, 1),
(416, 1, 15, 'Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', NULL, 'pan-grilled-fish-fillet.jpg', 'Whole Fish', 50, 1, 1),
(417, 1, 16, 'Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000.00, 'paradise-rustica-fish.jpg', 'Fish Fillets', 10, 1, 1),
(418, 1, 16, 'Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000.00, 'mombasa-fish.jpg', 'Fish Fillets', 20, 1, 1),
(419, 1, 16, 'Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000.00, 'deep-fried-fish-fillet.jpg', 'Fish Fillets', 30, 1, 1),
(420, 1, 16, 'Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', NULL, 'nile-parch-catch-for-a-day.jpg', 'Fish Fillets', 40, 1, 1),
(421, 1, 17, 'Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000.00, 'chicken-saute.jpg', 'Chicken Lovers', 10, 1, 1),
(422, 1, 17, 'BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000.00, 'bbq-chicken-drumstick.jpg', 'Chicken Lovers', 20, 1, 1),
(423, 1, 17, 'Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000.00, 'grilled-quarter-chicken-breast.jpg', 'Chicken Lovers', 30, 1, 1),
(424, 1, 17, 'Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000.00, 'paradise-grilled-farm-chicken.jpg', 'Chicken Lovers', 40, 1, 1),
(425, 1, 17, 'Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000.00, 'pan-fried-boneless-chicken-breast.jpg', 'Chicken Lovers', 50, 1, 1),
(426, 1, 18, 'Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000.00, 'beef-fillet-steak-mushroom-sauce.jpg', 'Steaks', 10, 1, 1),
(427, 1, 18, 'King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000.00, 'king-steak.jpg', 'Steaks', 20, 1, 1),
(428, 1, 18, 'Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000.00, 'beef-stroganoff.jpg', 'Steaks', 30, 1, 1),
(429, 1, 18, 'Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000.00, 'beef-stir-fry.jpg', 'Steaks', 40, 1, 1),
(430, 1, 18, 'Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000.00, 'paradise-mixed-grill.jpg', 'Steaks', 50, 1, 1),
(431, 1, 18, 'Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000.00, 'honey-glazed-hawaiian-beef-skewers.jpg', 'Steaks', 60, 1, 1),
(432, 1, 18, 'Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000.00, 'beef-wet-fry.jpg', 'Steaks', 70, 1, 1),
(433, 1, 18, 'Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', NULL, 'goat-muchomo.jpg', 'Steaks', 80, 1, 1),
(434, 1, 19, 'Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', NULL, 'paradise-grilled-pork-chops.jpg', 'Pork', 10, 1, 1),
(435, 1, 19, 'Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', NULL, 'honey-mustard-glazed-pork-ribs.jpg', 'Pork', 20, 1, 1),
(436, 1, 19, 'Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', NULL, 'pork-muchomo.jpg', 'Pork', 30, 1, 1),
(437, 1, 19, 'Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', NULL, 'sweet-and-sour-pork.jpg', 'Pork', 40, 1, 1),
(438, 1, 19, 'Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000.00, 'pork-muchomo-and-chops-platter.jpg', 'Pork', 50, 1, 1),
(439, 1, 20, 'Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000.00, 'paradise-lusaniya.jpg', 'House Specials', 10, 1, 1),
(440, 1, 20, 'Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000.00, 'mixed-grill-platter.jpg', 'House Specials', 20, 1, 1),
(441, 1, 21, 'Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000.00, 'mixed-vegetable-curry.jpg', 'Curries', 10, 1, 0),
(442, 1, 21, 'Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000.00, 'vegetable-korma.jpg', 'Curries', 20, 1, 0),
(443, 1, 21, 'Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000.00, 'veggie-biryani.jpg', 'Biryani', 30, 1, 0),
(444, 1, 21, 'Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000.00, 'chicken-biryani.jpg', 'Biryani', 40, 1, 1),
(445, 1, 21, 'Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000.00, 'chicken-coconut-curry.jpg', 'Curries', 50, 1, 1),
(446, 1, 22, 'Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', NULL, 'fruits.jpg', 'Desserts', 10, 1, 0),
(447, 1, 22, 'Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000.00, 'fruits-image.jpg', 'Desserts', 20, 1, 0),
(448, 1, 22, 'Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000.00, 'banana-crepe.webp', 'Desserts', 30, 1, 0),
(449, 1, 22, 'Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000.00, 'ice-cream.jpg', 'Desserts', 40, 1, 0),
(450, 1, 22, 'Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000.00, 'cake-of-the-day.jpg', 'Desserts', 50, 1, 0),
(451, 1, 22, 'Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000.00, 'affogato-espresso-ice-cream.webp', 'Desserts', 60, 1, 0),
(452, 1, 22, 'Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000.00, 'banana-split.jpg', 'Desserts', 70, 1, 0),
(453, 1, 23, 'Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000.00, 'classic-margherita.jpg', 'Pizza', 10, 1, 0),
(454, 1, 23, 'Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000.00, 'sweet-vegetarian.jpg', 'Pizza', 20, 1, 0),
(455, 1, 23, 'Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000.00, 'quattro-stagioni.jpg', 'Pizza', 30, 1, 0),
(456, 1, 23, 'Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000.00, 'pepperoni.jpg', 'Pizza', 40, 1, 0),
(457, 1, 23, 'Hawaiian', 'Ham or bacon, pineapple and mozzarella.', NULL, 'hawaiian.jpg', 'Pizza', 50, 1, 0),
(458, 1, 23, 'Farmer\'s', 'Chicken, mushroom and mozzarella.', 30000.00, 'farmer-s-pizza.jpg', 'Pizza', 60, 1, 0),
(459, 1, 23, 'Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', NULL, 'tuna.jpg', 'Pizza', 70, 1, 1),
(460, 1, 23, 'Diavola', 'Tomato, chili salami and mozzarella.', 30000.00, 'diavola.jpg', 'Pizza', 80, 1, 0),
(461, 1, 23, 'Bolognese', 'Spicy minced meat, tomato and mozzarella.', NULL, 'bolognese.jpg', 'Pizza', 90, 1, 0),
(462, 1, 23, 'Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000.00, 'capricciosa.jpg', 'Pizza', 100, 1, 0),
(463, 1, 23, 'Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000.00, 'calzone-pizza.jpg', 'Calzone', 110, 1, 0),
(464, 1, 23, 'Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000.00, 'assorted-meat-and-salami.webp', 'Pizza', 120, 1, 0),
(465, 1, 1, 'Full Breakfast', 'Eggs, sausages, toast, baked beans and tea or coffee', 25000.00, NULL, NULL, 0, 1, 0),
(466, 1, 1, 'Continental Breakfast', 'Pastries, fresh fruit, juice and hot drink', 20000.00, NULL, NULL, 0, 1, 0),
(467, 1, 1, 'Local Breakfast', 'Chapati, eggs and a hot local drink', 22000.00, NULL, NULL, 0, 1, 0),
(468, 1, 2, 'Grilled Nile Perch', 'Fresh Nile perch fillet with rice and vegetables', 45000.00, NULL, NULL, 0, 1, 1),
(469, 1, 2, 'Beef Stew and Rice', 'Slow cooked beef stew with steamed rice', 35000.00, NULL, NULL, 0, 1, 1),
(470, 1, 2, 'Chicken and Chips', 'Grilled chicken with golden chips and salad', 38000.00, 'chicken-wings-with-chips.jpg', NULL, 0, 1, 1),
(471, 1, 2, 'Buffet Plate', 'Daily buffet selection, meals from noon to 3pm and 7pm to 11pm', 40000.00, NULL, NULL, 0, 1, 1),
(472, 1, 2, 'Chef Signature Plate', 'A seasonal chef special, ask the kitchen for today', 45000.00, NULL, NULL, 0, 1, 1),
(473, 1, 3, 'Fresh Juice', 'Seasonal fruit juice, made to order', 12000.00, NULL, NULL, 0, 1, 1),
(474, 1, 3, 'Samosas', 'Three vegetable or meat samosas', 10000.00, 'chicken-samosas-pair.jpg', NULL, 0, 1, 1),
(475, 1, 3, 'Chips and Ketchup', 'A generous bowl of golden chips', 12000.00, NULL, NULL, 0, 1, 1),
(476, 1, 3, 'Chapati', 'Freshly rolled and griddled', 5000.00, NULL, NULL, 0, 1, 1);

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
(4, 1, 6, NULL, 1, NULL, 1, 744000.00, 'cash', NULL, NULL, 'successful', NULL);

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
-- Table structure for table `reception_records`
--

CREATE TABLE `reception_records` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `hotel_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(80) NOT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `guest_id` bigint(20) UNSIGNED DEFAULT NULL,
  `room_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(190) NOT NULL,
  `description` text NOT NULL,
  `status` enum('open','acknowledged','assigned','resolved','closed') DEFAULT 'open',
  `director_acknowledged_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
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
(1, 1, 1, 'HPN-20260925-001', 'phone', '2026-09-25 14:00:00', '2026-09-28 11:00:00', 2, 0, 'checked_in', 248000.00, 3, 744000.00, 0.00, 744000.00, 744000.00, 'Birthday weekend by the Nile', '2026-10-05 06:40:51', NULL),
(2, 1, 2, 'HPN-20260925-002', 'website', '2026-10-02 14:00:00', '2026-10-04 11:00:00', 2, 1, 'confirmed', 202000.00, 2, 404000.00, 0.00, 404000.00, 0.00, '', '2026-10-05 06:40:51', NULL),
(3, 1, 3, 'HPN-20260925-003', 'walk_in', '2026-10-05 14:00:00', '2026-10-07 11:00:00', 3, 0, 'confirmed', 213000.00, 2, 426000.00, 0.00, 426000.00, 0.00, '', '2026-10-05 06:40:51', NULL),
(4, 1, 4, 'HPN-20260925-004', 'agent', '2026-09-20 14:00:00', '2026-09-23 11:00:00', 2, 0, 'checked_out', 314000.00, 3, 942000.00, 0.00, 942000.00, 942000.00, 'Family holiday', '2026-10-05 06:40:51', NULL);

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
(9, 1, 16, 1, 1, 248000.00),
(10, 2, 19, 30, 1, 202000.00),
(11, 3, 18, 15, 1, 213000.00),
(12, 4, 17, 8, 1, 314000.00),
(13, 1, 23, 1, 1, 248000.00),
(14, 2, 26, 30, 1, 202000.00),
(15, 3, 25, 15, 1, 213000.00),
(16, 4, 24, 8, 1, 314000.00);

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
(66, 'guest'),
(12, 'housekeeping'),
(65, 'inventory_manager'),
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
(1, 1, 23, 'S101', 'Floor 1', 'available'),
(2, 1, 23, 'S102', 'Floor 1', 'available'),
(3, 1, 23, 'S103', 'Floor 1', 'available'),
(4, 1, 23, 'S104', 'Floor 1', 'available'),
(5, 1, 23, 'S105', 'Floor 1', 'available'),
(6, 1, 23, 'S106', 'Floor 1', 'available'),
(8, 1, 24, 'F101', 'Floor 1', 'available'),
(9, 1, 24, 'F102', 'Floor 1', 'available'),
(10, 1, 24, 'F103', 'Floor 1', 'available'),
(11, 1, 24, 'F104', 'Floor 1', 'available'),
(12, 1, 24, 'F105', 'Floor 1', 'available'),
(13, 1, 24, 'F106', 'Floor 1', 'available'),
(14, 1, 24, 'F107', 'Floor 1', 'available'),
(15, 1, 25, 'T201', 'Floor 2', 'available'),
(16, 1, 25, 'T202', 'Floor 2', 'available'),
(17, 1, 25, 'T203', 'Floor 2', 'available'),
(18, 1, 25, 'T204', 'Floor 2', 'available'),
(19, 1, 25, 'T205', 'Floor 2', 'available'),
(20, 1, 25, 'T206', 'Floor 2', 'available'),
(21, 1, 25, 'T207', 'Floor 2', 'available'),
(22, 1, 25, 'T208', 'Floor 2', 'available'),
(23, 1, 25, 'T209', 'Floor 2', 'available'),
(24, 1, 25, 'T210', 'Floor 2', 'available'),
(25, 1, 25, 'T211', 'Floor 2', 'available'),
(26, 1, 25, 'T212', 'Floor 2', 'available'),
(30, 1, 26, 'ED201', 'Floor 2', 'available'),
(31, 1, 26, 'ED202', 'Floor 2', 'available'),
(32, 1, 26, 'ED203', 'Floor 2', 'available'),
(33, 1, 26, 'ED204', 'Floor 2', 'available'),
(34, 1, 26, 'ED205', 'Floor 2', 'available'),
(35, 1, 26, 'ED206', 'Floor 2', 'available'),
(36, 1, 26, 'ED207', 'Floor 2', 'available'),
(37, 1, 26, 'ED208', 'Floor 2', 'available'),
(38, 1, 26, 'ED209', 'Floor 2', 'available'),
(39, 1, 26, 'ED210', 'Floor 2', 'available'),
(45, 1, 27, 'DD301', 'Floor 3', 'available'),
(46, 1, 27, 'DD302', 'Floor 3', 'available'),
(47, 1, 27, 'DD303', 'Floor 3', 'available'),
(48, 1, 27, 'DD304', 'Floor 3', 'available'),
(49, 1, 27, 'DD305', 'Floor 3', 'available'),
(50, 1, 27, 'DD306', 'Floor 3', 'available'),
(51, 1, 27, 'DD307', 'Floor 3', 'available'),
(52, 1, 27, 'DD308', 'Floor 3', 'available'),
(53, 1, 27, 'DD309', 'Floor 3', 'available'),
(54, 1, 27, 'DD310', 'Floor 3', 'available'),
(55, 1, 27, 'DD311', 'Floor 3', 'available'),
(56, 1, 27, 'DD312', 'Floor 3', 'available'),
(57, 1, 27, 'DD313', 'Floor 3', 'available'),
(58, 1, 27, 'DD314', 'Floor 3', 'available'),
(60, 1, 28, 'TW301', 'Floor 3', 'available'),
(61, 1, 28, 'TW302', 'Floor 3', 'available'),
(62, 1, 28, 'TW303', 'Floor 3', 'available'),
(63, 1, 28, 'TW304', 'Floor 3', 'available'),
(64, 1, 28, 'TW305', 'Floor 3', 'available'),
(65, 1, 28, 'TW306', 'Floor 3', 'available'),
(66, 1, 28, 'TW307', 'Floor 3', 'available'),
(67, 1, 28, 'TW308', 'Floor 3', 'available'),
(68, 1, 28, 'TW309', 'Floor 3', 'available'),
(69, 1, 28, 'TW310', 'Floor 3', 'available'),
(70, 1, 28, 'TW311', 'Floor 3', 'available'),
(71, 1, 28, 'TW312', 'Floor 3', 'available'),
(75, 1, 29, 'SG301', 'Floor 3', 'available'),
(76, 1, 29, 'SG302', 'Floor 3', 'available'),
(77, 1, 29, 'SG303', 'Floor 3', 'available'),
(78, 1, 29, 'SG304', 'Floor 3', 'available'),
(79, 1, 29, 'SG305', 'Floor 3', 'available'),
(80, 1, 29, 'SG306', 'Floor 3', 'available'),
(81, 1, 29, 'SG307', 'Floor 3', 'available'),
(82, 1, 29, 'SG308', 'Floor 3', 'available'),
(103, 1, 15, 'SD303', 'Floor 3', 'available'),
(104, 1, 15, 'SD304', 'Floor 3', 'available'),
(105, 1, 15, 'SD305', 'Floor 3', 'available'),
(106, 1, 15, 'SD306', 'Floor 3', 'available'),
(107, 1, 15, 'SD307', 'Floor 3', 'available'),
(108, 1, 15, 'SD308', 'Floor 3', 'available'),
(109, 1, 15, 'SD309', 'Floor 3', 'available'),
(110, 1, 15, 'SD310', 'Floor 3', 'available'),
(111, 1, 15, 'SD311', 'Floor 3', 'available'),
(112, 1, 15, 'SD312', 'Floor 3', 'available');

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
(15, 1, 'Standard Double', 'A well kept double room with a comfortable bed, in an easy reach of the front desk.', 2, 155000.00, 1),
(16, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(17, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(18, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(19, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(20, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(21, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(22, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1),
(23, 1, 'Suite', 'The most spacious option at the hotel, ideal for a memorable stay.', 3, 248000.00, 1),
(24, 1, 'Family Room', 'A spacious room made for families travelling together.', 4, 314000.00, 1),
(25, 1, 'Triple Room', 'A comfortable setting for three guests.', 3, 213000.00, 1),
(26, 1, 'Executive Deluxe', 'An elevated stay with refined touches for business and leisure.', 2, 202000.00, 1),
(27, 1, 'Deluxe Double', 'Elegant double accommodation with a warm, private atmosphere.', 2, 178000.00, 1),
(28, 1, 'Standard Twin', 'A neatly kept room with two comfortable beds.', 2, 142000.00, 1),
(29, 1, 'Standard Single', 'A simple, well equipped single room.', 1, 128000.00, 1);

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
(20, 1, 'Kampala Paper Mart', 'Paul Mugisha', '+256 775 220 005', 'pm@kpmar.ug', 'Kampala Road, Kampala', 'KM-7789', 1, NULL);

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
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `hotel_id`, `name`, `email`, `phone`, `password_hash`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Reagan Otema (Administrator)', 'admin@hotelparadiseonthenile.info', '0772 514 889', '$2y$10$liAwR45r6zD/Vl8yzASI3ueZfJGKLnt3PSE2PRPjbL0vogo4Db5A2', 'active', NULL, NULL),
(2, 1, 'Hotel Director', 'director@hotelparadiseonthenile.info', '+256 774 000 001', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(3, 1, 'General Manager', 'gm@hotelparadiseonthenile.info', '+256 774 000 002', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(4, 1, 'Finance Officer', 'accounts@hotelparadiseonthenile.info', '+256 774 000 003', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(5, 1, 'Cashier', 'cashier@hotelparadiseonthenile.info', '+256 774 000 004', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(6, 1, 'Front Desk Reception', 'frontdesk@hotelparadiseonthenile.info', '+256 774 000 005', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(7, 1, 'Restaurant Waiter', 'waiter@hotelparadiseonthenile.info', '+256 774 000 006', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(8, 1, 'Bar Staff', 'bar@hotelparadiseonthenile.info', '+256 774 000 007', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(9, 1, 'Kitchen', 'kitchen@hotelparadiseonthenile.info', '+256 774 000 008', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(10, 1, 'Storekeeper', 'store@hotelparadiseonthenile.info', '+256 774 000 009', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(11, 1, 'Procurement Officer', 'procurement@hotelparadiseonthenile.info', '+256 774 000 010', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(12, 1, 'Housekeeping', 'housekeeping@hotelparadiseonthenile.info', '+256 774 000 011', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL),
(13, 1, 'Internal Auditor', 'auditor@hotelparadiseonthenile.info', '+256 774 000 012', '$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2', 'active', NULL, NULL);

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
(13, 16);

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
-- Table structure for table `website_booking_requests`
--

CREATE TABLE `website_booking_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `guest_name` varchar(190) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(60) DEFAULT NULL,
  `room_type` varchar(190) DEFAULT NULL,
  `check_in` date DEFAULT NULL,
  `check_out` date DEFAULT NULL,
  `adults` int(11) NOT NULL DEFAULT 1,
  `children` int(11) NOT NULL DEFAULT 0,
  `status` enum('new','processed','cancelled') NOT NULL DEFAULT 'new',
  `system_reservation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `website_enquiries`
--

CREATE TABLE `website_enquiries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(190) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(60) DEFAULT NULL,
  `subject` varchar(190) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('new','read','replied','closed') NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
(1, 'site_name', 'Hotel Paradise on the Nile', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(2, 'legal_name', 'Hotel Paradise on the Nile Ltd', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(3, 'address', 'Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(4, 'po_box', 'P.O. Box 1139, Jinja, Uganda', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(5, 'phone_primary', '+256 759 504 928', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(6, 'phone_secondary', '+256 773 565 668', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(7, 'email', 'frontdesk@hotelparadiseonthenile.info', '2026-10-05 05:31:26', '2026-10-09 07:17:53'),
(8, 'website', 'www.hotelparadiseonthenile.info', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(9, 'certification', 'UNBS Certified (US 130:2017)', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(10, 'management_system_path', '/system/', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(11, 'designed_by', 'Reagansoft Innovation Limited', '2026-10-05 05:31:26', '2026-10-05 05:31:26'),
(12, 'domain', 'https://hotelparadiseonthenile.info', '2026-10-05 05:31:43', '2026-10-05 05:31:43'),
(13, 'hotel_name', 'Hotel Paradise on the Nile', '2026-10-05 05:31:43', '2026-10-05 05:31:43'),
(14, 'designer', 'Reagansoft Innovation Limited', '2026-10-05 05:31:43', '2026-10-05 05:31:43'),
(15, 'system_path', '/system/', '2026-10-05 05:31:43', '2026-10-05 05:31:43');

--
-- Indexes for dumped tables
--

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
-- Indexes for table `efris_transactions`
--
ALTER TABLE `efris_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `requested_by` (`requested_by`);

--
-- Indexes for table `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `hotel_id` (`hotel_id`);

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
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`);

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
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`);

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
-- Indexes for table `reception_records`
--
ALTER TABLE `reception_records`
  ADD PRIMARY KEY (`id`);

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
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `hotel_id` (`hotel_id`,`room_number`),
  ADD KEY `room_type_id` (`room_type_id`);

--
-- Indexes for table `room_types`
--
ALTER TABLE `room_types`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `shifts`
--
ALTER TABLE `shifts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hotel_id` (`hotel_id`),
  ADD KEY `user_id` (`user_id`);

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
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `hotel_id` (`hotel_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_id`,`role_id`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `voids`
--
ALTER TABLE `voids`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `website_booking_requests`
--
ALTER TABLE `website_booking_requests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `website_enquiries`
--
ALTER TABLE `website_enquiries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_enquiry_status` (`status`),
  ADD KEY `idx_enquiry_created` (`created_at`);

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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT for table `efris_transactions`
--
ALTER TABLE `efris_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guests`
--
ALTER TABLE `guests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `guest_folio_entries`
--
ALTER TABLE `guest_folio_entries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `hotels`
--
ALTER TABLE `hotels`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `inventory_categories`
--
ALTER TABLE `inventory_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `inventory_items`
--
ALTER TABLE `inventory_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `menu_categories`
--
ALTER TABLE `menu_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- AUTO_INCREMENT for table `menu_items`
--
ALTER TABLE `menu_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=743;

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
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
-- AUTO_INCREMENT for table `reception_records`
--
ALTER TABLE `reception_records`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reservations`
--
ALTER TABLE `reservations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `reservation_rooms`
--
ALTER TABLE `reservation_rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `room_types`
--
ALTER TABLE `room_types`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `shifts`
--
ALTER TABLE `shifts`
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
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `stock_movements`
--
ALTER TABLE `stock_movements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `voids`
--
ALTER TABLE `voids`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `website_booking_requests`
--
ALTER TABLE `website_booking_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `website_enquiries`
--
ALTER TABLE `website_enquiries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `website_settings`
--
ALTER TABLE `website_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `beds`
--
ALTER TABLE `beds`
  ADD CONSTRAINT `beds_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  ADD CONSTRAINT `expenses_ibfk_2` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `guests`
--
ALTER TABLE `guests`
  ADD CONSTRAINT `guests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `guests_ibfk_2` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `guest_folio_entries`
--
ALTER TABLE `guest_folio_entries`
  ADD CONSTRAINT `guest_folio_entries_ibfk_1` FOREIGN KEY (`reservation_id`) REFERENCES `reservations` (`id`);

--
-- Constraints for table `inventory_items`
--
ALTER TABLE `inventory_items`
  ADD CONSTRAINT `inventory_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `inventory_categories` (`id`);

--
-- Constraints for table `menu_items`
--
ALTER TABLE `menu_items`
  ADD CONSTRAINT `menu_items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `menu_categories` (`id`);

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
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `rooms_ibfk_2` FOREIGN KEY (`room_type_id`) REFERENCES `room_types` (`id`);

--
-- Constraints for table `room_types`
--
ALTER TABLE `room_types`
  ADD CONSTRAINT `room_types_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `shifts`
--
ALTER TABLE `shifts`
  ADD CONSTRAINT `shifts_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`),
  ADD CONSTRAINT `shifts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

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
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`hotel_id`) REFERENCES `hotels` (`id`);

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
