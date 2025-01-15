import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// API Anahtarı ve Şehir
const String apiKey =
    'fe2e43a39b4bbb342ea86c77895486e8'; // Buraya kendi API anahtarınızı yazın
const String city = 'Erzurum'; // Buraya istediğiniz şehir adını yazın

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Kişisel Asistan Uygulaması',
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kişisel Asistan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Görevler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.cloud),
              title: Text('Hava Durumu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.alarm),
              title: Text('Hatırlatıcı'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ayarlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .blueAccent, // primary yerine backgroundColor kullanıldı
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Buton tıklandı!')),
                );
              },
              child: Text('Butona Bas'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _weatherInfo;
  bool isLoading = false;

  Future<void> _fetchWeather() async {
    final city = _cityController.text;
    if (city.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      final apiKey = 'e80d78b024334b2a87f135656251101';
      final url =
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=no';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _weatherInfo =
                '${data["location"]["name"]}, ${data["location"]["country"]}: '
                '${data["current"]["temp_c"]}°C, ${data["current"]["condition"]["text"]}';
          });
        } else {
          setState(() {
            _weatherInfo = 'Şehir bulunamadı.';
          });
        }
      } catch (e) {
        setState(() {
          _weatherInfo = 'Hata: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Hava Durumu', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Şehir Adı',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchWeather,
              child: Text('Hava Durumunu Getir'),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : _weatherInfo != null
                    ? Text(
                        _weatherInfo!,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<String> _tasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    setState(() {
      _tasks.add(_controller.text);
    });
    _controller.clear();
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Görevler', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Yeni Görev',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.task_alt),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Görev Ekle'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.check_box_outline_blank),
                  title: Text(_tasks[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late FlutterLocalNotificationsPlugin _localNotifications;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    _localNotifications.initialize(settings);
  }

  void _scheduleNotification() async {
    if (_selectedDateTime == null) return;

    const androidDetails = AndroidNotificationDetails(
      'reminder_id',
      'Hatırlatıcılar',
      channelDescription: 'Hatırlatıcı Bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.zonedSchedule(
      0,
      'Hatırlatma',
      'Bu bir hatırlatma bildirimidir!',
      tz.TZDateTime.from(_selectedDateTime!, tz.local),
      details,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Gerekli parametre eklendi
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDateTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hatırlatıcı')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text('Tarih ve Saat Seç'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scheduleNotification,
              child: Text('Hatırlatıcı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Ayarlar')),
      body: SwitchListTile(
        title: Text('Karanlık Tema'),
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(),
      ),
    );
  }
}
