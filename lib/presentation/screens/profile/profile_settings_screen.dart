import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../viewmodels/theme_viewmodel.dart';
import '../auth/auth_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPassController;
  late TextEditingController _newPassController;

  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _wrongOldPassword = false;
  bool _isLoggingOut = false;
  TimeOfDay? _notificationTime;

  late Box _profileBox;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    initNotifications();
    _initProfile();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  Future<void> _initProfile() async {
    _profileBox = await Hive.openBox('userProfile');
    final prefs = await SharedPreferences.getInstance();

    _nameController = TextEditingController(
      text: _profileBox.get('name') ?? '',
    );
    _emailController = TextEditingController(
      text: _profileBox.get('email') ?? '',
    );
    _oldPassController = TextEditingController();
    _newPassController = TextEditingController();

    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    final hour = prefs.getInt('notifHour');
    final minute = prefs.getInt('notifMinute');
    if (hour != null && minute != null) {
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    await _profileBox.put('name', _nameController.text.trim());
    await _profileBox.put('email', _emailController.text.trim());

    // Password handling with debug prints and cross-check between Hive & SharedPreferences
    if (_oldPassController.text.isNotEmpty &&
        _newPassController.text.isNotEmpty) {
      final storedPassHive = _profileBox.get('password'); // may be null
      final prefs = await SharedPreferences.getInstance();
      final storedPassPrefs = prefs.getString('password'); // may be null

      // DEBUG prints — remove later (insecure)
      // These prints will show in the debug console/logcat
      print('DEBUG: storedPass (Hive)    = $storedPassHive');
      print('DEBUG: storedPass (SharedPrefs) = $storedPassPrefs');
      print('DEBUG: entered old password = ${_oldPassController.text}');

      final entered = _oldPassController.text;

      // Accept if entered matches Hive OR SharedPreferences
      final bool matchesHive =
          (storedPassHive != null && entered == storedPassHive);
      final bool matchesPrefs =
          (storedPassPrefs != null && entered == storedPassPrefs);

      if (matchesHive || matchesPrefs) {
        // Save new password to both storage locations so they stay in sync
        await _profileBox.put('password', _newPassController.text);
        await prefs.setString('password', _newPassController.text);

        setState(() => _wrongOldPassword = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password updated successfully!")),
        );
      } else {
        // Wrong old password — shake + red styling + snackbar
        setState(() => _wrongOldPassword = true);
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Old password incorrect")));
        return;
      }
    }

    // Notifications: store preference + schedule/cancel
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);

    if (_notificationsEnabled && _notificationTime != null) {
      await prefs.setInt('notifHour', _notificationTime!.hour);
      await prefs.setInt('notifMinute', _notificationTime!.minute);
      await _scheduleNotification(_notificationTime!);
    } else {
      await flutterLocalNotificationsPlugin.cancelAll();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully!")),
    );
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    tz.initializeTimeZones();
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_channel',
      'Daily Reminders',
      channelDescription: 'Workout reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder to work out today! 💪',
      'Stay consistent with your goals!',
      scheduledDate,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _pickNotificationTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) setState(() => _notificationTime = time);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About Creator"),
        content: const Text(
          "Name: Noel Ninan Sheri\nPurpose: For Fun 💪",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);

    // Play logout Lottie for its duration (we'll show the Lottie screen and route after)
    // We'll delay here and then navigate — the UI shows the Lottie and waits
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const AuthScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggingOut) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Lottie.asset(
            'assets/animations/logout.json',
            repeat: false,
            onLoaded: (composition) {
              // ensure lottie plays its full duration before navigation
              Future.delayed(composition.duration, () {
                if (mounted) _logout();
              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile Settings",
          style: GoogleFonts.satisfy(color: Colors.blueAccent, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTextField("Name", _nameController),
          _buildTextField("Email", _emailController),
          const SizedBox(height: 16),
          _buildPasswordSection(),
          const Divider(height: 32, color: Colors.grey),
          _buildThemeSelector(isDark),
          const Divider(height: 32, color: Colors.grey),
          _buildNotificationSection(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Save Changes"),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            label: const Text("Logout"),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: _showAboutDialog,
              child: const Text("About Creator"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.blueAccent),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.lightBlueAccent),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Change Password",
          style: GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 18),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset =
                8 * (1 - (_shakeController.value - 0.5).abs() * 2); // shake
            return Transform.translate(
              offset: Offset(_wrongOldPassword ? offset : 0, 0),
              child: child,
            );
          },
          child: TextField(
            controller: _oldPassController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Old Password",
              labelStyle: TextStyle(
                color: _wrongOldPassword ? Colors.red : Colors.blueAccent,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _wrongOldPassword ? Colors.red : Colors.blueAccent,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: _wrongOldPassword
                      ? Colors.redAccent
                      : Colors.lightBlueAccent,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildTextField("New Password", _newPassController),
      ],
    );
  }

  Widget _buildThemeSelector(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Dark Mode",
          style: TextStyle(color: Colors.blueAccent, fontSize: 16),
        ),
        Switch(
          value: isDark,
          onChanged: (val) => ref.read(themeProvider.notifier).toggleTheme(),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Daily Workout Reminder",
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
            Switch(
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                if (val) _pickNotificationTime();
              },
            ),
          ],
        ),
        if (_notificationsEnabled && _notificationTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              "Reminder set for ${_notificationTime!.format(context)}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }
}
