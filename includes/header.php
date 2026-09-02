<?php
/**
 * Shared page header: <head>, Tailwind config, and top navigation.
 * Expects an optional $pageTitle variable to be set before inclusion.
 */
require_once __DIR__ . '/functions.php';

$user   = currentUser();
$title  = isset($pageTitle) ? $pageTitle . ' · ' . APP_NAME : APP_NAME;
$active = basename($_SERVER['PHP_SELF']);

/** Nav link helper with active-state styling. */
function navLink(string $href, string $label, string $active): string
{
    $isActive = $active === $href;
    $classes  = $isActive
        ? 'text-emerald-700 bg-emerald-50 font-semibold'
        : 'text-slate-600 hover:text-emerald-700 hover:bg-emerald-50';
    return '<a href="' . $href . '" class="px-3 py-2 rounded-lg text-sm transition ' . $classes . '">' . e($label) . '</a>';
}
?>
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="EcoCycle — a community recycling rewards platform advancing UN SDG 12.">
    <title><?= e($title) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        eco: {
                            50: '#f0fdf4', 100: '#dcfce7', 200: '#bbf7d0', 300: '#86efac',
                            400: '#4ade80', 500: '#22c55e', 600: '#16a34a', 700: '#15803d',
                            800: '#166534', 900: '#14532d'
                        },
                        earth: { 100: '#f5f0e6', 300: '#d8c7a8', 500: '#a9855f', 700: '#7c5c3b' }
                    },
                    fontFamily: {
                        sans: ['Nunito', 'ui-sans-serif', 'system-ui', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>♻️</text></svg>">
    <link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="min-h-screen bg-eco-50 text-slate-800 font-sans antialiased flex flex-col">

<!-- Skip link for accessibility -->
<a href="#main" class="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-50 focus:bg-white focus:px-4 focus:py-2 focus:rounded-lg focus:shadow">Skip to content</a>

<header class="sticky top-0 z-40 bg-white/90 backdrop-blur border-b border-eco-100">
    <nav class="max-w-6xl mx-auto px-4 h-16 flex items-center justify-between" aria-label="Main navigation">
        <a href="index.php" class="flex items-center gap-2 font-extrabold text-lg text-eco-700">
            <span class="text-2xl" aria-hidden="true">♻️</span> <?= e(APP_NAME) ?>
        </a>

        <button id="navToggle" class="md:hidden p-2 rounded-lg text-slate-600 hover:bg-eco-50" aria-label="Toggle navigation" aria-expanded="false">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"/></svg>
        </button>

        <div id="navMenu" class="hidden md:flex items-center gap-1 absolute md:static top-16 left-0 right-0 bg-white md:bg-transparent border-b md:border-0 border-eco-100 px-4 md:px-0 py-3 md:py-0 flex-col md:flex-row shadow md:shadow-none">
            <?php if ($user): ?>
                <?= navLink('dashboard.php', 'Dashboard', $active) ?>
                <?= navLink('log.php', 'Log Recycling', $active) ?>
                <?= navLink('rewards.php', 'Rewards', $active) ?>
                <?= navLink('leaderboard.php', 'Leaderboard', $active) ?>
                <?= navLink('learn.php', 'Learn', $active) ?>
                <?php if (isAdmin()): ?>
                    <?= navLink('admin.php', 'Admin', $active) ?>
                <?php endif; ?>
                <div class="flex items-center gap-3 md:ml-3 mt-2 md:mt-0 md:pl-3 md:border-l border-eco-100">
                    <a href="profile.php" class="flex items-center gap-2 text-sm text-slate-600 hover:text-eco-700">
                        <span class="w-8 h-8 rounded-full bg-eco-100 text-eco-700 grid place-items-center font-bold" aria-hidden="true"><?= e(strtoupper(substr($user['name'], 0, 1))) ?></span>
                        <span class="font-semibold"><?= num($user['points_balance']) ?> pts</span>
                    </a>
                    <a href="logout.php" class="text-sm text-slate-500 hover:text-red-600">Log out</a>
                </div>
            <?php else: ?>
                <?= navLink('index.php', 'Home', $active) ?>
                <?= navLink('leaderboard.php', 'Leaderboard', $active) ?>
                <?= navLink('learn.php', 'Learn', $active) ?>
                <a href="login.php" class="px-3 py-2 rounded-lg text-sm text-slate-600 hover:text-eco-700">Log in</a>
                <a href="register.php" class="ml-1 px-4 py-2 rounded-lg text-sm font-semibold bg-eco-600 text-white hover:bg-eco-700 transition">Sign up</a>
            <?php endif; ?>
        </div>
    </nav>
</header>

<main id="main" class="flex-1 w-full">
<?php foreach (takeFlashes() as $flash):
    $palette = [
        'success' => 'bg-eco-100 text-eco-800 border-eco-300',
        'error'   => 'bg-red-50 text-red-700 border-red-200',
        'info'    => 'bg-sky-50 text-sky-700 border-sky-200',
    ][$flash['type']] ?? 'bg-slate-50 text-slate-700 border-slate-200';
?>
    <div class="max-w-6xl mx-auto px-4 pt-4">
        <div class="border <?= $palette ?> rounded-xl px-4 py-3 text-sm font-semibold" role="status"><?= e($flash['message']) ?></div>
    </div>
<?php endforeach; ?>
