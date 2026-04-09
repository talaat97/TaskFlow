import 'dart:io';

/// Connection mode:
/// - USB (adb reverse)  → phone's localhost:3000 maps to PC's localhost:3000
/// - Wi-Fi only         → change [kDevMachineIp] and set [kUseAdbReverse] = false
const bool kUseAdbReverse = true; // ← set false if using Wi-Fi instead of USB
const String kDevMachineIp = '192.168.1.2';

final String kBaseUrl = Platform.isAndroid
    ? (kUseAdbReverse
        ? 'http://127.0.0.1:3000' // USB tunnel via `adb reverse tcp:3000 tcp:3000`
        : 'http://$kDevMachineIp:3000') // Wi-Fi — needs firewall rule
    : 'http://localhost:3000'; // iOS simulator

const String kTokenKey = 'auth_token';
const String kUserEmailKey = 'user_email';
const String kUserNameKey = 'user_name';
