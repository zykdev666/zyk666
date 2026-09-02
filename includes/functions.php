<?php
/**
 * EcoCycle — shared helpers: session, auth, points/levels engine, impact math.
 */

declare(strict_types=1);

require_once __DIR__ . '/../config/config.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

/* -------------------------------------------------------------------------
 * Domain configuration
 * ---------------------------------------------------------------------- */

/**
 * Material catalogue: points per kg, CO2 saved per kg (kg CO2e), and an
 * average per-item weight used by the quantity estimator.
 */
function materials(): array
{
    return [
        'plastic' => ['label' => 'Plastic',  'icon' => '🧴', 'points_per_kg' => 10, 'co2_per_kg' => 1.50, 'avg_item_kg' => 0.04],
        'glass'   => ['label' => 'Glass',    'icon' => '🍾', 'points_per_kg' => 6,  'co2_per_kg' => 0.30, 'avg_item_kg' => 0.40],
        'paper'   => ['label' => 'Paper',    'icon' => '📰', 'points_per_kg' => 5,  'co2_per_kg' => 0.90, 'avg_item_kg' => 0.10],
        'metal'   => ['label' => 'Metal',    'icon' => '🥫', 'points_per_kg' => 12, 'co2_per_kg' => 4.00, 'avg_item_kg' => 0.03],
        'ewaste'  => ['label' => 'E-waste',  'icon' => '🔌', 'points_per_kg' => 15, 'co2_per_kg' => 2.00, 'avg_item_kg' => 0.30],
        'organic' => ['label' => 'Organic',  'icon' => '🍎', 'points_per_kg' => 4,  'co2_per_kg' => 0.50, 'avg_item_kg' => 0.25],
    ];
}

/**
 * Level ladder, keyed by the minimum lifetime points required to reach it.
 * Ordered ascending.
 */
function levels(): array
{
    return [
        ['name' => 'Sprout',         'min' => 0,    'icon' => '🌱'],
        ['name' => 'Sapling',        'min' => 250,  'icon' => '🌿'],
        ['name' => 'Green Guardian', 'min' => 1000, 'icon' => '🌳'],
        ['name' => 'Eco Champion',   'min' => 3000, 'icon' => '🏆'],
    ];
}

/** Trees-equivalent factor: a mature tree absorbs ~21 kg CO2 per year. */
const CO2_PER_TREE_KG = 21.0;

/* -------------------------------------------------------------------------
 * Level helpers
 * ---------------------------------------------------------------------- */

/** Resolve the current level for a given lifetime points total. */
function levelForPoints(int $points): array
{
    $current = levels()[0];
    foreach (levels() as $level) {
        if ($points >= $level['min']) {
            $current = $level;
        }
    }
    return $current;
}

/** The next level above the current points, or null if already maxed. */
function nextLevelForPoints(int $points): ?array
{
    foreach (levels() as $level) {
        if ($points < $level['min']) {
            return $level;
        }
    }
    return null;
}

/**
 * Progress (0-100) toward the next level, plus the current/next level meta.
 */
function levelProgress(int $points): array
{
    $current = levelForPoints($points);
    $next    = nextLevelForPoints($points);

    if ($next === null) {
        return ['current' => $current, 'next' => null, 'percent' => 100, 'to_next' => 0];
    }

    $span   = $next['min'] - $current['min'];
    $gained = $points - $current['min'];
    $percent = $span > 0 ? (int) round(($gained / $span) * 100) : 0;

    return [
        'current' => $current,
        'next'    => $next,
        'percent' => max(0, min(100, $percent)),
        'to_next' => max(0, $next['min'] - $points),
    ];
}

/* -------------------------------------------------------------------------
 * Impact math
 * ---------------------------------------------------------------------- */

/** Convert kg of CO2 saved into a tree-year equivalent. */
function treesEquivalent(float $co2Kg): float
{
    return $co2Kg / CO2_PER_TREE_KG;
}

/* -------------------------------------------------------------------------
 * Auth / session helpers
 * ---------------------------------------------------------------------- */

function isLoggedIn(): bool
{
    return isset($_SESSION['user_id']);
}

/** Fetch the currently logged-in user row, or null. */
function currentUser(): ?array
{
    if (!isLoggedIn()) {
        return null;
    }
    static $cached = null;
    if ($cached !== null) {
        return $cached;
    }
    $stmt = db()->prepare('SELECT * FROM users WHERE id = ?');
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch();
    $cached = $user ?: null;
    return $cached;
}

/** Redirect guests to login. */
function requireLogin(): void
{
    if (!isLoggedIn()) {
        header('Location: login.php');
        exit;
    }
}

/** Whether the current user is an administrator/owner. */
function isAdmin(): bool
{
    $user = currentUser();
    return $user !== null && (int) ($user['is_admin'] ?? 0) === 1;
}

/** Guard admin-only pages: guests go to login, non-admins back to dashboard. */
function requireAdmin(): void
{
    requireLogin();
    if (!isAdmin()) {
        setFlash('error', 'That area is for administrators only.');
        header('Location: dashboard.php');
        exit;
    }
}

function loginUser(int $userId): void
{
    session_regenerate_id(true);
    $_SESSION['user_id'] = $userId;
}

function logoutUser(): void
{
    $_SESSION = [];
    session_destroy();
}

/* -------------------------------------------------------------------------
 * CSRF protection
 * ---------------------------------------------------------------------- */

function csrfToken(): string
{
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function csrfField(): string
{
    return '<input type="hidden" name="csrf" value="' . e(csrfToken()) . '">';
}

function verifyCsrf(): bool
{
    return isset($_POST['csrf'], $_SESSION['csrf'])
        && hash_equals($_SESSION['csrf'], $_POST['csrf']);
}

/* -------------------------------------------------------------------------
 * View helpers
 * ---------------------------------------------------------------------- */

/** HTML-escape shortcut. */
function e(?string $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

/** Format a number with thousands separators. */
function num($value, int $decimals = 0): string
{
    return number_format((float) $value, $decimals);
}

/** Flash-message helpers (one-shot session messages). */
function setFlash(string $type, string $message): void
{
    $_SESSION['flash'][] = ['type' => $type, 'message' => $message];
}

function takeFlashes(): array
{
    $flashes = $_SESSION['flash'] ?? [];
    unset($_SESSION['flash']);
    return $flashes;
}

/* -------------------------------------------------------------------------
 * Recycling / points engine
 * ---------------------------------------------------------------------- */

/**
 * Record a recycling entry inside a transaction, updating points, streak,
 * and awarding any newly-earned badges. Returns the created log row id.
 */
function recordRecyclingLog(int $userId, string $material, int $quantity, float $weightKg, ?string $note): array
{
    $catalogue = materials();
    if (!isset($catalogue[$material])) {
        throw new InvalidArgumentException('Unknown material type.');
    }
    $meta = $catalogue[$material];

    $points = (int) round($weightKg * $meta['points_per_kg']);
    $co2    = round($weightKg * $meta['co2_per_kg'], 2);

    $pdo = db();
    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO recycling_logs (user_id, material_type, quantity, weight_kg, points_awarded, co2_saved_kg, note)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([$userId, $material, $quantity, $weightKg, $points, $co2, $note]);
        $logId = (int) $pdo->lastInsertId();

        // Streak: increment if last log was yesterday, reset to 1 if older, keep if today.
        $user = $pdo->query('SELECT streak_count, last_log_date FROM users WHERE id = ' . $userId)->fetch();
        $today = new DateTimeImmutable('today');
        $streak = 1;
        if (!empty($user['last_log_date'])) {
            $last = new DateTimeImmutable($user['last_log_date']);
            $diff = (int) $last->diff($today)->format('%a');
            if ($diff === 0) {
                $streak = (int) $user['streak_count']; // already logged today
            } elseif ($diff === 1) {
                $streak = (int) $user['streak_count'] + 1;
            } else {
                $streak = 1;
            }
        }

        $upd = $pdo->prepare(
            'UPDATE users
                SET points_balance = points_balance + ?,
                    total_points   = total_points + ?,
                    streak_count   = ?,
                    last_log_date  = CURDATE()
              WHERE id = ?'
        );
        $upd->execute([$points, $points, $streak, $userId]);

        $pdo->commit();
    } catch (Throwable $ex) {
        $pdo->rollBack();
        throw $ex;
    }

    $newBadges = evaluateBadges($userId);

    return [
        'log_id'     => $logId,
        'points'     => $points,
        'co2'        => $co2,
        'streak'     => $streak,
        'new_badges' => $newBadges,
    ];
}

/**
 * Check every badge criterion for a user and award any not yet held.
 * Returns the list of newly-awarded badge rows.
 */
function evaluateBadges(int $userId): array
{
    $pdo = db();

    $stats = $pdo->query(
        'SELECT COUNT(*)                         AS log_count,
                COALESCE(SUM(weight_kg), 0)      AS total_kg,
                COUNT(DISTINCT material_type)    AS material_types
           FROM recycling_logs WHERE user_id = ' . $userId
    )->fetch();

    $user = $pdo->query('SELECT total_points, streak_count FROM users WHERE id = ' . $userId)->fetch();

    $earned = [];
    if ((int) $stats['log_count'] >= 1)          $earned[] = 'first_log';
    if ((int) $user['streak_count'] >= 7)        $earned[] = 'streak_7';
    if ((float) $stats['total_kg'] >= 100)       $earned[] = 'kg_100';
    if ((int) $user['total_points'] >= 1000)     $earned[] = 'points_1000';
    if ((int) $stats['material_types'] >= count(materials())) $earned[] = 'all_materials';

    if (!$earned) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($earned), '?'));
    $badgeStmt = $pdo->prepare("SELECT * FROM badges WHERE code IN ($placeholders)");
    $badgeStmt->execute($earned);
    $badges = $badgeStmt->fetchAll();

    $insert = $pdo->prepare('INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, ?)');
    $newly = [];
    foreach ($badges as $badge) {
        $insert->execute([$userId, $badge['id']]);
        if ($insert->rowCount() > 0) {
            $newly[] = $badge;
        }
    }
    return $newly;
}

/** Generate a human-friendly, unique redemption code. */
function generateRedemptionCode(): string
{
    return 'ECO-' . strtoupper(bin2hex(random_bytes(4)));
}
