#!/usr/bin/php -q
<?php

error_reporting(E_ALL);
ini_set('display_errors', '0');
ini_set('log_errors', '1');
ini_set('error_log', '/tmp/agi_tiquetes_php_error.log');

require_once '/opt/agi-tiquetes/definiciones.inc';

define('SOUND_DIR', '/var/lib/asterisk/sounds/agi-tiquetes');
define('SOUND_PREFIX', 'agi-tiquetes');

function log_msg($message)
{
    file_put_contents(
        '/tmp/agi_tiquetes.log',
        date('c') . ' ' . $message . PHP_EOL,
        FILE_APPEND
    );
}

function db()
{
    $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';

    return new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}

if (getenv('AGI_TEST') === '1') {
    $pdo = db();
    $count = $pdo->query('SELECT COUNT(*) AS total FROM trayectos')->fetch();
    echo "Conexion correcta. Trayectos encontrados: " . $count['total'] . PHP_EOL;
    exit;
}

$agiEnv = [];

while (($line = fgets(STDIN)) !== false) {
    $line = trim($line);

    if ($line === '') {
        break;
    }

    if (strpos($line, ':') !== false) {
        [$key, $value] = explode(':', $line, 2);
        $agiEnv[trim($key)] = trim($value);
    }
}

function agi_cmd($command)
{
    log_msg('>> ' . $command);

    echo $command . "\n";
    fflush(STDOUT);

    $response = trim(fgets(STDIN) ?: '');

    log_msg('<< ' . $response);

    return $response;
}

function agi_result($response)
{
    if (preg_match('/result=(-?\d+)/', $response, $matches)) {
        return (int) $matches[1];
    }

    return 0;
}

function answer_call()
{
    agi_cmd('ANSWER');
}

function hangup_call()
{
    agi_cmd('HANGUP');
    exit;
}


function tts_audio($text)
{
    if (!is_dir(SOUND_DIR)) {
        mkdir(SOUND_DIR, 0775, true);
    }

    $cleanText = trim(str_replace(["\n", "\r"], ' ', $text));
    $hash = 'tts_' . substr(sha1($cleanText), 0, 24);

    $finalWav = SOUND_DIR . '/' . $hash . '.wav';
    $tmpMp3 = '/tmp/' . $hash . '.mp3';

    if (!file_exists($finalWav)) {
        $voice = 'es-CO-SalomeNeural';

        $cmd1 = '/opt/tts-venv/bin/edge-tts '
            . '--voice ' . escapeshellarg($voice) . ' '
            . '--rate=-15% '
            . '--text ' . escapeshellarg($cleanText) . ' '
            . '--write-media ' . escapeshellarg($tmpMp3)
            . ' 2>>/tmp/agi_tiquetes_tts_error.log';

        shell_exec($cmd1);

        $cmd2 = 'ffmpeg -y '
            . '-i ' . escapeshellarg($tmpMp3) . ' '
            . '-ar 8000 '
            . '-ac 1 '
            . '-sample_fmt s16 '
            . escapeshellarg($finalWav)
            . ' 2>>/tmp/agi_tiquetes_tts_error.log';

        shell_exec($cmd2);

        @unlink($tmpMp3);
        @chmod($finalWav, 0664);
    }

    return SOUND_PREFIX . '/' . $hash;
}


function play_text($text, $escapeDigits = '')
{
    $file = tts_audio($text);
    $response = agi_cmd('STREAM FILE ' . $file . ' "' . $escapeDigits . '"');
    $result = agi_result($response);

    if ($result > 0) {
        return chr($result);
    }

    return '';
}

function wait_digit($timeoutMs = 8000)
{
    $response = agi_cmd('WAIT FOR DIGIT ' . $timeoutMs);
    $result = agi_result($response);

    if ($result > 0) {
        return chr($result);
    }

    return '';
}

function say_text($text)
{
    play_text($text, '');
}

function say_digits($digits)
{
    agi_cmd('SAY DIGITS ' . $digits . ' ""');
}

function ask_digit($prompt, array $validDigits)
{
    $allowed = implode('', $validDigits);

    for ($attempt = 1; $attempt <= 3; $attempt++) {
        $digit = play_text($prompt, $allowed);

        if ($digit === '') {
            $digit = wait_digit(8000);
        }

        if (in_array($digit, $validDigits, true)) {
            return $digit;
        }

        say_text('No te entendi. Por favor intenta de nuevo.');
    }

    say_text('No recibimos una opcion valida. La llamada finalizara. Gracias por comunicarte con nosotros.');
    hangup_call();
}

function fecha_humana($date)
{
    $dt = new DateTime($date);

    $months = [
        1 => 'enero',
        2 => 'febrero',
        3 => 'marzo',
        4 => 'abril',
        5 => 'mayo',
        6 => 'junio',
        7 => 'julio',
        8 => 'agosto',
        9 => 'septiembre',
        10 => 'octubre',
        11 => 'noviembre',
        12 => 'diciembre',
    ];

    $day = (int) $dt->format('j');
    $month = $months[(int) $dt->format('n')];

    return $day . ' de ' . $month;
}

function hora_humana($time)
{
    [$hour, $minute] = explode(':', $time);

    $hour = (int) $hour;
    $minute = (int) $minute;

    if ($hour < 12) {
        $period = 'de la manana';
    } elseif ($hour < 18) {
        $period = 'de la tarde';
    } else {
        $period = 'de la noche';
    }

    $hour12 = $hour % 12;

    if ($hour12 === 0) {
        $hour12 = 12;
    }

    if ($minute === 0) {
        return $hour12 . ' ' . $period;
    }

    if ($minute === 30) {
        return $hour12 . ' y treinta ' . $period;
    }

    return $hour12 . ' y ' . $minute . ' ' . $period;
}

function precio_humano($price)
{
    $price = (int) $price;

    if ($price % 1000 === 0) {
        return ($price / 1000) . ' mil pesos';
    }

    return $price . ' pesos';
}

function get_routes(PDO $pdo)
{
    $stmt = $pdo->query(
        'SELECT id, opcion_menu, origen, destino, descripcion
         FROM trayectos
         WHERE activo = 1
         ORDER BY opcion_menu ASC'
    );

    return $stmt->fetchAll();
}

function get_route_by_option(array $routes, $option)
{
    foreach ($routes as $route) {
        if ((string) $route['opcion_menu'] === (string) $option) {
            return $route;
        }
    }

    return null;
}

function get_schedules(PDO $pdo, $routeId)
{
    $stmt = $pdo->prepare(
        'SELECT id, trayecto_id, fecha, hora, precio, cupos_disponibles
         FROM horarios
         WHERE trayecto_id = ?
           AND activo = 1
           AND cupos_disponibles > 0
         ORDER BY fecha ASC, hora ASC
         LIMIT 9'
    );

    $stmt->execute([$routeId]);

    return $stmt->fetchAll();
}

try {
    answer_call();

    $pdo = db();
    $caller = $agiEnv['agi_callerid'] ?? 'desconocido';

    say_text(
        'Hola mor. Bienvenido a Viajes encantadores Express. ' .
        'Soy Greiz, tu asistente virtual de reservas. ' .
        'Te ayudare a encontrar un tiquete disponible de forma rapida y sencilla.'
    );

    while (true) {
        $routes = get_routes($pdo);

        if (count($routes) === 0) {
            say_text('En este momento no tenemos trayectos disponibles. Por favor intenta mas tarde.');
            hangup_call();
        }

        $routePrompt = 'Tenemos estos destinos disponibles. ';
        $validRouteOptions = [];

        foreach ($routes as $route) {
            $option = (string) $route['opcion_menu'];
            $validRouteOptions[] = $option;

            $routePrompt .= 'Para viajar de '
                . $route['origen']
                . ' a '
                . $route['destino']
                . ', marca '
                . $option
                . '. ';
        }

        $routePrompt .= 'Despues de escuchar las opciones, marca el numero del destino que prefieras.';

        $selectedRouteOption = ask_digit($routePrompt, $validRouteOptions);
        $selectedRoute = get_route_by_option($routes, $selectedRouteOption);

        if (!$selectedRoute) {
            say_text('No encontramos ese destino. Intenta de nuevo.');
            continue;
        }

        $schedules = get_schedules($pdo, $selectedRoute['id']);

        if (count($schedules) === 0) {
            say_text(
                'Por ahora no tenemos horarios con cupos disponibles para '
                . $selectedRoute['destino']
                . '. Vamos a elegir otro destino.'
            );
            continue;
        }

        $schedulePrompt = 'Excelente eleccion. Para viajar de '
            . $selectedRoute['origen']
            . ' a '
            . $selectedRoute['destino']
            . ', tenemos estas opciones. ';

        $validScheduleOptions = [];

        foreach ($schedules as $index => $schedule) {
            $option = (string) ($index + 1);
            $validScheduleOptions[] = $option;

            $schedulePrompt .= 'Opcion '
                . $option
                . ', el '
                . fecha_humana($schedule['fecha'])
                . ', a las '
                . hora_humana($schedule['hora'])
                . ', por '
                . precio_humano($schedule['precio'])
                . '. ';
        }

        $schedulePrompt .= 'Marca el numero del horario que prefieras.';

        $selectedScheduleOption = ask_digit($schedulePrompt, $validScheduleOptions);
        $selectedSchedule = $schedules[((int) $selectedScheduleOption) - 1];

        $summaryPrompt = 'Perfecto. Tu reserva seria para el trayecto de '
            . $selectedRoute['origen']
            . ' a '
            . $selectedRoute['destino']
            . ', el '
            . fecha_humana($selectedSchedule['fecha'])
            . ', a las '
            . hora_humana($selectedSchedule['hora'])
            . ', con un precio de '
            . precio_humano($selectedSchedule['precio'])
            . '. Para confirmar la reserva, marca 1. Para corregir la seleccion, marca 2.';

        $confirmation = ask_digit($summaryPrompt, ['1', '2']);

        if ($confirmation === '2') {
            say_text('Claro que si. Vamos a corregir la seleccion desde el inicio.');
            continue;
        }

        $pdo->beginTransaction();

        $lockStmt = $pdo->prepare(
            'SELECT cupos_disponibles
             FROM horarios
             WHERE id = ?
             FOR UPDATE'
        );

        $lockStmt->execute([$selectedSchedule['id']]);
        $currentSchedule = $lockStmt->fetch();

        if (!$currentSchedule || (int) $currentSchedule['cupos_disponibles'] <= 0) {
            $pdo->rollBack();

            say_text(
                'Lo sentimos. Ese horario se acaba de quedar sin cupos. ' .
                'Vamos a buscar otra opcion disponible.'
            );

            continue;
        }

        $reservationCode = (string) random_int(100000, 999999);

        $insertStmt = $pdo->prepare(
            'INSERT INTO reservas
             (codigo_reserva, trayecto_id, horario_id, telefono, estado)
             VALUES (?, ?, ?, ?, ?)'
        );

        $insertStmt->execute([
            $reservationCode,
            $selectedRoute['id'],
            $selectedSchedule['id'],
            $caller,
            'confirmada',
        ]);

        $updateStmt = $pdo->prepare(
            'UPDATE horarios
             SET cupos_disponibles = cupos_disponibles - 1
             WHERE id = ?'
        );

        $updateStmt->execute([$selectedSchedule['id']]);

        $pdo->commit();

        say_text('Listo. Tu reserva fue confirmada correctamente. Tu codigo de reserva es.');
        say_digits($reservationCode);

        say_text(
            'Gracias por llamar a Viajes encantadores Express. ' .
            'Te esperamos en tu viaje. Que tengas un excelente dia.'
        );

        hangup_call();
    }
} catch (Throwable $e) {
    log_msg('ERROR: ' . $e->getMessage());

    try {
        say_text(
            'Lo sentimos. Ocurrio un problema tecnico procesando tu reserva. ' .
            'Por favor intenta nuevamente mas tarde.'
        );
    } catch (Throwable $ignored) {
    }

    hangup_call();
}
