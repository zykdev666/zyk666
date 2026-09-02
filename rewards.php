<?php
/**
 * EcoCycle — rewards marketplace + redemption flow.
 * Guests can browse; redeeming requires login and enough points.
 */
require_once __DIR__ . '/includes/functions.php';

$user   = currentUser();
$filter = $_GET['category'] ?? 'all';

// Handle a redemption POST.
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    requireLogin();
    if (!verifyCsrf()) {
        setFlash('error', 'Your session expired. Please try again.');
        header('Location: rewards.php');
        exit;
    }

    $rewardId = (int) ($_POST['reward_id'] ?? 0);
    $pdo = db();
    $pdo->beginTransaction();
    try {
        // Lock the reward row and re-read the user's balance inside the txn.
        $rStmt = $pdo->prepare('SELECT * FROM rewards WHERE id = ? FOR UPDATE');
        $rStmt->execute([$rewardId]);
        $reward = $rStmt->fetch();

        $uStmt = $pdo->prepare('SELECT points_balance FROM users WHERE id = ? FOR UPDATE');
        $uStmt->execute([$user['id']]);
        $balance = (int) $uStmt->fetchColumn();

        if (!$reward) {
            throw new RuntimeException('That reward is no longer available.');
        }
        if ((int) $reward['quantity_available'] <= 0) {
            throw new RuntimeException('Sorry, that reward is out of stock.');
        }
        if ($balance < (int) $reward['points_cost']) {
            throw new RuntimeException('You need ' . num($reward['points_cost']) . ' points to redeem this.');
        }

        // Generate a guaranteed-unique code.
        do {
            $code = generateRedemptionCode();
            $chk = $pdo->prepare('SELECT 1 FROM redemptions WHERE redemption_code = ?');
            $chk->execute([$code]);
        } while ($chk->fetchColumn());

        $pdo->prepare('INSERT INTO redemptions (user_id, reward_id, redemption_code, points_spent) VALUES (?, ?, ?, ?)')
            ->execute([$user['id'], $rewardId, $code, $reward['points_cost']]);
        $pdo->prepare('UPDATE users SET points_balance = points_balance - ? WHERE id = ?')
            ->execute([$reward['points_cost'], $user['id']]);
        $pdo->prepare('UPDATE rewards SET quantity_available = quantity_available - 1 WHERE id = ?')
            ->execute([$rewardId]);

        $pdo->commit();
        setFlash('success', 'Redeemed! Your code is ' . $code . ' — show it at ' . $reward['title'] . '. See it any time on your profile.');
    } catch (Throwable $ex) {
        $pdo->rollBack();
        setFlash('error', $ex->getMessage());
    }
    header('Location: rewards.php');
    exit;
}

// Build the catalogue query with an optional category filter.
$sql = 'SELECT w.*, p.business_name, p.category AS partner_category
          FROM rewards w JOIN partners p ON p.id = w.partner_id';
$params = [];
$categories = ['discount' => 'Discounts', 'eco-product' => 'Eco Products', 'donation' => 'Donations'];
if (isset($categories[$filter])) {
    $sql .= ' WHERE w.category = ?';
    $params[] = $filter;
}
$sql .= ' ORDER BY w.points_cost ASC';
$stmt = db()->prepare($sql);
$stmt->execute($params);
$rewards = $stmt->fetchAll();

$balance = $user ? (int) $user['points_balance'] : 0;

$pageTitle = 'Rewards marketplace';
require __DIR__ . '/includes/header.php';
?>
<section class="max-w-6xl mx-auto px-4 py-10">
    <div class="flex flex-wrap items-end justify-between gap-4">
        <div>
            <h1 class="text-2xl font-extrabold text-slate-900">Rewards marketplace 🎁</h1>
            <p class="mt-1 text-slate-600">Turn your EcoPoints into real local rewards and green donations.</p>
        </div>
        <?php if ($user): ?>
            <div class="bg-white rounded-xl border border-eco-100 px-5 py-3 text-center shadow-sm">
                <div class="text-xs font-semibold text-slate-500">Your balance</div>
                <div class="text-2xl font-extrabold text-eco-700"><?= num($balance) ?> pts</div>
            </div>
        <?php endif; ?>
    </div>

    <!-- Category filter -->
    <div class="mt-6 flex flex-wrap gap-2">
        <?php
        $tabs = ['all' => 'All'] + $categories;
        foreach ($tabs as $key => $label):
            $isActive = $filter === $key; ?>
            <a href="?category=<?= e($key) ?>"
               class="px-4 py-2 rounded-full text-sm font-semibold transition <?= $isActive ? 'bg-eco-600 text-white' : 'bg-white border border-eco-100 text-slate-600 hover:bg-eco-50' ?>">
                <?= e($label) ?>
            </a>
        <?php endforeach; ?>
    </div>

    <!-- Reward cards -->
    <div class="mt-6 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        <?php foreach ($rewards as $reward):
            $affordable = $user && $balance >= (int) $reward['points_cost'];
            $inStock    = (int) $reward['quantity_available'] > 0; ?>
            <div class="eco-card bg-white rounded-2xl shadow-sm border border-eco-100 p-6 flex flex-col">
                <div class="flex items-start justify-between">
                    <span class="w-14 h-14 rounded-2xl bg-eco-50 grid place-items-center text-3xl" aria-hidden="true"><?= e($reward['icon']) ?></span>
                    <span class="text-xs font-bold px-2.5 py-1 rounded-full bg-eco-100 text-eco-800 capitalize"><?= e(str_replace('-', ' ', $reward['category'])) ?></span>
                </div>
                <h2 class="mt-4 font-bold text-slate-900"><?= e($reward['title']) ?></h2>
                <p class="text-xs font-semibold text-slate-400 mt-0.5"><?= e($reward['business_name']) ?></p>
                <p class="mt-2 text-sm text-slate-600 flex-1"><?= e($reward['description']) ?></p>

                <div class="mt-4 flex items-center justify-between">
                    <span class="text-lg font-extrabold text-eco-700"><?= num($reward['points_cost']) ?> <span class="text-xs font-semibold text-slate-400">pts</span></span>
                    <?php if ($reward['expiry_date']): ?>
                        <span class="text-xs text-slate-400">Exp. <?= e(date('M Y', strtotime($reward['expiry_date']))) ?></span>
                    <?php endif; ?>
                </div>

                <?php if (!$user): ?>
                    <a href="login.php" class="mt-4 w-full text-center py-2.5 rounded-xl bg-eco-600 text-white font-bold hover:bg-eco-700 transition">Log in to redeem</a>
                <?php elseif (!$inStock): ?>
                    <button disabled class="mt-4 w-full py-2.5 rounded-xl bg-slate-100 text-slate-400 font-bold cursor-not-allowed">Out of stock</button>
                <?php else: ?>
                    <form method="post" class="mt-4" onsubmit="return confirm('Redeem &quot;<?= e(addslashes($reward['title'])) ?>&quot; for <?= num($reward['points_cost']) ?> points?');">
                        <?= csrfField() ?>
                        <input type="hidden" name="reward_id" value="<?= (int) $reward['id'] ?>">
                        <button type="submit" <?= $affordable ? '' : 'disabled' ?>
                            class="w-full py-2.5 rounded-xl font-bold transition <?= $affordable ? 'bg-eco-600 text-white hover:bg-eco-700' : 'bg-slate-100 text-slate-400 cursor-not-allowed' ?>">
                            <?= $affordable ? 'Redeem' : 'Need ' . num((int) $reward['points_cost'] - $balance) . ' more pts' ?>
                        </button>
                    </form>
                <?php endif; ?>
            </div>
        <?php endforeach; ?>
    </div>

    <?php if (!$rewards): ?>
        <p class="mt-10 text-center text-slate-500">No rewards in this category yet.</p>
    <?php endif; ?>
</section>
<?php require __DIR__ . '/includes/footer.php'; ?>
