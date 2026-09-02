<?php
/**
 * EcoCycle — account registration.
 */
require_once __DIR__ . '/includes/functions.php';

if (isLoggedIn()) {
    header('Location: dashboard.php');
    exit;
}

$errors = [];
$old    = ['name' => '', 'email' => '', 'neighborhood' => ''];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verifyCsrf()) {
        $errors[] = 'Your session expired. Please try again.';
    } else {
        $name         = trim($_POST['name'] ?? '');
        $email        = trim($_POST['email'] ?? '');
        $neighborhood = trim($_POST['neighborhood'] ?? '') ?: 'Greendale';
        $password     = $_POST['password'] ?? '';
        $confirm      = $_POST['confirm'] ?? '';
        $old = ['name' => $name, 'email' => $email, 'neighborhood' => $neighborhood];

        if ($name === '' || mb_strlen($name) > 120) {
            $errors[] = 'Please enter your name (up to 120 characters).';
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $errors[] = 'Please enter a valid email address.';
        }
        if (mb_strlen($password) < 8) {
            $errors[] = 'Password must be at least 8 characters.';
        }
        if ($password !== $confirm) {
            $errors[] = 'Passwords do not match.';
        }

        if (!$errors) {
            $exists = db()->prepare('SELECT id FROM users WHERE email = ?');
            $exists->execute([$email]);
            if ($exists->fetch()) {
                $errors[] = 'An account with that email already exists.';
            }
        }

        if (!$errors) {
            $stmt = db()->prepare(
                'INSERT INTO users (name, email, password_hash, neighborhood) VALUES (?, ?, ?, ?)'
            );
            $stmt->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT), $neighborhood]);
            loginUser((int) db()->lastInsertId());
            setFlash('success', 'Welcome to EcoCycle, ' . $name . '! Log your first item to earn a badge.');
            header('Location: dashboard.php');
            exit;
        }
    }
}

$pageTitle = 'Create your account';
require __DIR__ . '/includes/header.php';
?>
<section class="max-w-md mx-auto px-4 py-12">
    <div class="text-center">
        <h1 class="text-3xl font-extrabold text-slate-900">Join EcoCycle 🌱</h1>
        <p class="mt-2 text-slate-600">Start earning rewards for recycling in minutes.</p>
    </div>

    <?php if ($errors): ?>
        <div class="mt-6 bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 text-sm" role="alert">
            <ul class="list-disc list-inside space-y-1">
                <?php foreach ($errors as $err): ?><li><?= e($err) ?></li><?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <form method="post" class="mt-6 bg-white rounded-2xl shadow-sm border border-eco-100 p-6 space-y-4" novalidate>
        <?= csrfField() ?>
        <div>
            <label for="name" class="block text-sm font-semibold text-slate-700">Full name</label>
            <input id="name" name="name" type="text" required value="<?= e($old['name']) ?>"
                   class="mt-1 w-full rounded-xl border border-slate-200 px-4 py-2.5 focus:border-eco-500 focus:ring-eco-500">
        </div>
        <div>
            <label for="email" class="block text-sm font-semibold text-slate-700">Email</label>
            <input id="email" name="email" type="email" required value="<?= e($old['email']) ?>"
                   class="mt-1 w-full rounded-xl border border-slate-200 px-4 py-2.5 focus:border-eco-500 focus:ring-eco-500">
        </div>
        <div>
            <label for="neighborhood" class="block text-sm font-semibold text-slate-700">Neighborhood</label>
            <input id="neighborhood" name="neighborhood" type="text" placeholder="e.g. Greendale" value="<?= e($old['neighborhood']) ?>"
                   class="mt-1 w-full rounded-xl border border-slate-200 px-4 py-2.5 focus:border-eco-500 focus:ring-eco-500">
            <p class="mt-1 text-xs text-slate-400">Used for the community leaderboard.</p>
        </div>
        <div>
            <label for="password" class="block text-sm font-semibold text-slate-700">Password</label>
            <input id="password" name="password" type="password" required minlength="8"
                   class="mt-1 w-full rounded-xl border border-slate-200 px-4 py-2.5 focus:border-eco-500 focus:ring-eco-500">
            <p class="mt-1 text-xs text-slate-400">At least 8 characters.</p>
        </div>
        <div>
            <label for="confirm" class="block text-sm font-semibold text-slate-700">Confirm password</label>
            <input id="confirm" name="confirm" type="password" required minlength="8"
                   class="mt-1 w-full rounded-xl border border-slate-200 px-4 py-2.5 focus:border-eco-500 focus:ring-eco-500">
        </div>
        <button type="submit" class="w-full py-3 rounded-xl bg-eco-600 text-white font-bold hover:bg-eco-700 transition">Create account</button>
    </form>

    <p class="mt-4 text-center text-sm text-slate-600">
        Already a member? <a href="login.php" class="font-semibold text-eco-700 hover:underline">Log in</a>
    </p>
</section>
<?php require __DIR__ . '/includes/footer.php'; ?>
