-- EcoCycle database schema + seed data
-- MariaDB / MySQL. Charset utf8mb4.

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS user_badges;
DROP TABLE IF EXISTS redemptions;
DROP TABLE IF EXISTS recycling_logs;
DROP TABLE IF EXISTS rewards;
DROP TABLE IF EXISTS partners;
DROP TABLE IF EXISTS badges;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------------
-- Users
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(120)  NOT NULL,
    email          VARCHAR(190)  NOT NULL UNIQUE,
    password_hash  VARCHAR(255)  NOT NULL,
    neighborhood   VARCHAR(120)  NOT NULL DEFAULT 'Greendale',
    points_balance INT           NOT NULL DEFAULT 0,
    total_points   INT           NOT NULL DEFAULT 0,
    streak_count   INT           NOT NULL DEFAULT 0,
    last_log_date  DATE          NULL,
    is_admin       TINYINT(1)    NOT NULL DEFAULT 0,
    created_at     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Recycling logs
-- ---------------------------------------------------------------------------
CREATE TABLE recycling_logs (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT           NOT NULL,
    material_type       VARCHAR(30)   NOT NULL,
    quantity            INT           NOT NULL DEFAULT 1,
    weight_kg           DECIMAL(8,2)  NOT NULL DEFAULT 0,
    points_awarded      INT           NOT NULL DEFAULT 0,
    co2_saved_kg        DECIMAL(8,2)  NOT NULL DEFAULT 0,
    verification_status ENUM('verified','pending') NOT NULL DEFAULT 'verified',
    note                VARCHAR(255)  NULL,
    created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Partners (local businesses / causes)
-- ---------------------------------------------------------------------------
CREATE TABLE partners (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    business_name VARCHAR(150) NOT NULL,
    category      VARCHAR(60)  NOT NULL,
    contact_info  VARCHAR(190) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Rewards (marketplace offers)
-- ---------------------------------------------------------------------------
CREATE TABLE rewards (
    id                 INT AUTO_INCREMENT PRIMARY KEY,
    partner_id         INT          NOT NULL,
    title              VARCHAR(150) NOT NULL,
    description        VARCHAR(400) NOT NULL,
    category           VARCHAR(60)  NOT NULL DEFAULT 'discount',
    points_cost        INT          NOT NULL,
    quantity_available INT          NOT NULL DEFAULT 100,
    expiry_date        DATE         NULL,
    icon               VARCHAR(10)  NOT NULL DEFAULT '🎁',
    CONSTRAINT fk_reward_partner FOREIGN KEY (partner_id) REFERENCES partners(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Redemptions
-- ---------------------------------------------------------------------------
CREATE TABLE redemptions (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT          NOT NULL,
    reward_id       INT          NOT NULL,
    redemption_code VARCHAR(20)  NOT NULL UNIQUE,
    points_spent    INT          NOT NULL,
    status          ENUM('active','used','expired') NOT NULL DEFAULT 'active',
    created_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_redeem_user   FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
    CONSTRAINT fk_redeem_reward FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Badges / achievements
-- ---------------------------------------------------------------------------
CREATE TABLE badges (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    code           VARCHAR(40)  NOT NULL UNIQUE,
    name           VARCHAR(80)  NOT NULL,
    description    VARCHAR(200) NOT NULL,
    icon           VARCHAR(10)  NOT NULL DEFAULT '🏅'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_badges (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT      NOT NULL,
    badge_id   INT      NOT NULL,
    awarded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_badge (user_id, badge_id),
    CONSTRAINT fk_ub_user  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
    CONSTRAINT fk_ub_badge FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------------
-- Seed data
-- ---------------------------------------------------------------------------
INSERT INTO partners (business_name, category, contact_info) VALUES
('Bean & Leaf Café',      'Food & Drink', 'hello@beanandleaf.example'),
('Verde Grocery Co-op',   'Grocery',      'support@verdegrocery.example'),
('ReWear Thrift',         'Retail',       'contact@rewear.example'),
('SolarWorks',            'Eco Products', 'info@solarworks.example'),
('City Tree Fund',        'Donation',     'give@citytreefund.example');

INSERT INTO rewards (partner_id, title, description, category, points_cost, quantity_available, expiry_date, icon) VALUES
(1, 'Free Regular Coffee',        'Redeem for one free regular coffee at Bean & Leaf Café.',                'discount', 250,  200, '2027-12-31', '☕'),
(1, '20% Off Any Pastry',         'Enjoy 20% off any freshly baked pastry.',                                'discount', 150,  300, '2027-12-31', '🥐'),
(2, '$5 Off Groceries',           'Take $5 off a grocery order of $30 or more at Verde Grocery Co-op.',     'discount', 400,  150, '2027-12-31', '🛒'),
(2, 'Reusable Produce Bag Set',   'A set of 3 organic-cotton mesh produce bags.',                           'eco-product', 600, 80, '2027-12-31', '🥬'),
(3, '15% Off Second-Hand Finds',  'Save 15% on your next thrift haul at ReWear.',                           'discount', 300,  120, '2027-12-31', '👕'),
(4, 'Solar Phone Charger',        'Compact solar-powered phone charger from SolarWorks.',                   'eco-product', 1500, 40, '2027-12-31', '🔋'),
(5, 'Plant a Tree (Donate)',      'Convert 500 points into a real tree planted by the City Tree Fund.',     'donation', 500, 9999, NULL,          '🌳'),
(5, 'Fund a Community Compost',   'Donate points toward a neighborhood composting station.',                'donation', 800, 9999, NULL,          '♻️');

INSERT INTO badges (code, name, description, icon) VALUES
('first_log',    'First Steps',     'Logged your very first recycling entry.',            '🌱'),
('streak_7',     'Week Warrior',    'Maintained a 7-day recycling streak.',               '🔥'),
('kg_100',       'Century Diverter','Diverted 100 kg of material from landfill.',         '🏆'),
('points_1000',  'Point Collector', 'Earned 1,000 lifetime EcoPoints.',                   '⭐'),
('all_materials','Sorting Master',  'Recycled at least one item of every material type.', '🧭');

-- ---------------------------------------------------------------------------
-- Owner / administrator account (Zyk Granada)
-- Password: passw0rd!  (change it after first login via the profile page)
-- The hash below is a bcrypt hash of 'passw0rd!'.
-- ---------------------------------------------------------------------------
INSERT INTO users (name, email, password_hash, neighborhood, is_admin) VALUES
('Zyk Granada', 'zyk.granada@ecocycle.local', '$2y$10$gO0cRSF62dfb3r72QMQ6DeTHpcq5VIR5R639B0FhlHKhg.fUZ.Fse', 'Greendale', 1);
