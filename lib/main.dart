import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── ICON LOOKUP MAP (const-safe for release builds) ─────
const Map<String, IconData> _iconMap = {
  'wb_sunny_outlined':      Icons.wb_sunny_outlined,
  'fitness_center':         Icons.fitness_center,
  'free_breakfast_outlined':Icons.free_breakfast_outlined,
  'menu_book_outlined':     Icons.menu_book_outlined,
  'self_improvement':       Icons.self_improvement,
  'lunch_dining_outlined':  Icons.lunch_dining_outlined,
  'bedtime_outlined':       Icons.bedtime_outlined,
  'directions_walk':        Icons.directions_walk,
  'dinner_dining_outlined': Icons.dinner_dining_outlined,
  'tv_outlined':            Icons.tv_outlined,
  'auto_stories_outlined':  Icons.auto_stories_outlined,
  'nightlight_round':       Icons.nightlight_round,
  'schedule':               Icons.schedule,
};

IconData _iconFromName(String name) => _iconMap[name] ?? Icons.schedule;

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: MainNavScreen(),
    );
  }
}

// ─── BOTTOM NAV WRAPPER ──────────────────────────────────
class MainNavScreen extends StatefulWidget {
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  bool _loaded = false;

  List<Task> tasks = [];

  // Default routines (used only on first-ever launch)
  final List<RoutineItem> _defaultRoutines = [
    RoutineItem(title: 'Wake up & freshen up', hour: 5, minute: 30, colorHex: 0xFF4FC3F7, iconName: 'wb_sunny_outlined'),
    RoutineItem(title: 'Morning exercise',      hour: 6, minute: 0,  colorHex: 0xFF81C784, iconName: 'fitness_center'),
    RoutineItem(title: 'Breakfast',             hour: 7, minute: 0,  colorHex: 0xFFFFB74D, iconName: 'free_breakfast_outlined'),
    RoutineItem(title: 'Study / Work session 1',hour: 8, minute: 0,  colorHex: 0xFF7986CB, iconName: 'menu_book_outlined'),
    RoutineItem(title: 'Short break',           hour: 10,minute: 30, colorHex: 0xFFA5D6A7, iconName: 'self_improvement'),
    RoutineItem(title: 'Study / Work session 2',hour: 11,minute: 0,  colorHex: 0xFF7986CB, iconName: 'menu_book_outlined'),
    RoutineItem(title: 'Lunch',                 hour: 13,minute: 0,  colorHex: 0xFFFFB74D, iconName: 'lunch_dining_outlined'),
    RoutineItem(title: 'Rest / Nap',            hour: 14,minute: 0,  colorHex: 0xFF80DEEA, iconName: 'bedtime_outlined'),
    RoutineItem(title: 'Study / Work session 3',hour: 15,minute: 0,  colorHex: 0xFF7986CB, iconName: 'menu_book_outlined'),
    RoutineItem(title: 'Evening walk',          hour: 17,minute: 30, colorHex: 0xFF81C784, iconName: 'directions_walk'),
    RoutineItem(title: 'Dinner',                hour: 19,minute: 0,  colorHex: 0xFFFFB74D, iconName: 'dinner_dining_outlined'),
    RoutineItem(title: 'Leisure / Screen time', hour: 20,minute: 0,  colorHex: 0xFFCE93D8, iconName: 'tv_outlined'),
    RoutineItem(title: 'Read / Wind down',      hour: 21,minute: 30, colorHex: 0xFFEF9A9A, iconName: 'auto_stories_outlined'),
    RoutineItem(title: 'Sleep',                 hour: 22,minute: 30, colorHex: 0xFF90CAF9, iconName: 'nightlight_round'),
  ];

  List<RoutineItem> routines = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ── LOAD from SharedPreferences ──
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // --- Tasks ---
    final tasksJson = prefs.getStringList('tasks') ?? [];
    final loadedTasks = tasksJson.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return Task(
        title: m['title'] as String,
        category: m['category'] as String? ?? 'General',
        isDone: m['isDone'] as bool? ?? false,
      );
    }).toList();

    // --- Routines ---
    final routinesJson = prefs.getStringList('routines');
    List<RoutineItem> loadedRoutines;

    if (routinesJson == null || routinesJson.isEmpty) {
      // First launch — use defaults
      loadedRoutines = List.from(_defaultRoutines);
    } else {
      loadedRoutines = routinesJson.map((s) {
        final m = jsonDecode(s) as Map<String, dynamic>;
        return RoutineItem(
          title:    m['title']    as String,
          hour:     m['hour']     as int,
          minute:   m['minute']   as int,
          colorHex: m['colorHex'] as int,
          isDone:   m['isDone']   as bool? ?? false,
          iconName: m['iconName'] as String? ?? 'schedule',
        );
      }).toList();
    }

    setState(() {
      tasks    = loadedTasks;
      routines = loadedRoutines;
      _loaded  = true;
    });
  }

  // ── SAVE Tasks ──
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = tasks.map((t) => jsonEncode({
      'title':    t.title,
      'category': t.category,
      'isDone':   t.isDone,
    })).toList();
    await prefs.setStringList('tasks', list);
  }

  // ── SAVE Routines ──
  Future<void> _saveRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final list = routines.map((r) => jsonEncode({
      'title':    r.title,
      'hour':     r.hour,
      'minute':   r.minute,
      'colorHex': r.colorHex,
      'isDone':   r.isDone,
      'iconName': r.iconName,
    })).toList();
    await prefs.setStringList('routines', list);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      HomeScreen(
        tasks: tasks,
        onTasksChanged: () {
          setState(() {});
          _saveTasks();
        },
      ),
      RoutineScreen(
        routines: routines,
        onRoutinesChanged: () {
          setState(() {});
          _saveRoutines();
        },
      ),
      StatsScreen(tasks: tasks),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: Colors.indigo[50],
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist_rounded),  label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.schedule_rounded),   label: 'Routine'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded),  label: 'Stats'),
        ],
      ),
    );
  }
}

// ─── MODEL: TASK ─────────────────────────────────────────
class Task {
  String title;
  bool isDone;
  String category;
  Task({required this.title, this.isDone = false, this.category = 'General'});
}

// ─── MODEL: ROUTINE ITEM ─────────────────────────────────
class RoutineItem {
  String title;
  int hour;
  int minute;
  int colorHex;
  String iconName;
  bool isDone;

  RoutineItem({
    required this.title,
    required this.hour,
    required this.minute,
    required this.colorHex,
    required this.iconName,
    this.isDone = false,
  });

  IconData get icon => _iconFromName(iconName);

  String get timeLabel {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Color get color => Color(colorHex);
}

// ─── HOME SCREEN ─────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback onTasksChanged;
  const HomeScreen({required this.tasks, required this.onTasksChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = 'All';

  List<Task> get tasks => widget.tasks;
  int get doneCount    => tasks.where((t) => t.isDone).length;
  int get pendingCount => tasks.where((t) => !t.isDone).length;

  List<Task> get filteredTasks {
    if (filter == 'Pending') return tasks.where((t) => !t.isDone).toList();
    if (filter == 'Done')    return tasks.where((t) => t.isDone).toList();
    return tasks;
  }

  void addTask(String title, String category) {
    tasks.add(Task(title: title, category: category));
    widget.onTasksChanged();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    widget.onTasksChanged();
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    widget.onTasksChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('ROUTINE', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Summary bar ──
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryChip(label: 'Total',   count: tasks.length, color: Colors.white),
                _SummaryChip(label: 'Pending', count: pendingCount, color: Colors.amber[200]!),
                _SummaryChip(label: 'Done',    count: doneCount,    color: Colors.greenAccent[200]!),
              ],
            ),
          ),
          // ── Filter tabs ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: ['All', 'Pending', 'Done'].map((f) {
                final selected = filter == f;
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => filter = f),
                    selectedColor: Colors.indigo,
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                  ),
                );
              }).toList(),
            ),
          ),
          // ── Task list ──
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
                        SizedBox(height: 12),
                        Text('No tasks here!', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _TaskCard(
                        task: task,
                        onToggle: () => toggleTask(task),
                        onDelete: () => deleteTask(task),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(
                              task: task,
                              onToggle: () => toggleTask(task),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTaskDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Task'),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter task title...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: ['General', 'Work', 'Personal', 'Shopping', 'Health']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setDialogState(() => selectedCategory = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  addTask(titleController.text.trim(), selectedCategory);
                  Navigator.pop(ctx);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ROUTINE SCREEN (24-HR SCHEDULE) ─────────────────────
class RoutineScreen extends StatefulWidget {
  final List<RoutineItem> routines;
  final VoidCallback onRoutinesChanged;
  const RoutineScreen({required this.routines, required this.onRoutinesChanged});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  List<RoutineItem> get routines => widget.routines;
  int get doneCount => routines.where((r) => r.isDone).length;

  String get currentSlot {
    final now     = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;
    RoutineItem? current;
    for (var r in routines) {
      if (r.hour * 60 + r.minute <= nowMins) current = r;
    }
    return current?.title ?? 'Rest time';
  }

  void _showAddRoutineDialog(BuildContext context) {
    final titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    final iconOptions = {
      'Study':    'menu_book_outlined',
      'Exercise': 'fitness_center',
      'Meal':     'lunch_dining_outlined',
      'Sleep':    'bedtime_outlined',
      'Break':    'self_improvement',
      'Other':    'schedule',
    };

    String selectedIconName = 'schedule';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text('Add Activity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Activity name...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.access_time, color: Colors.indigo),
                  title: Text(selectedTime.format(ctx)),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: ctx, initialTime: selectedTime);
                      if (picked != null) setD(() => selectedTime = picked);
                    },
                    child: Text('Change'),
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: iconOptions.entries.map((e) {
                    final active = selectedIconName == e.value;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_iconFromName(e.value), size: 14),
                          SizedBox(width: 4),
                          Text(e.key, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      selected: active,
                      onSelected: (_) => setD(() => selectedIconName = e.value),
                      selectedColor: Colors.indigo,
                      labelStyle: TextStyle(color: active ? Colors.white : Colors.black87),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  routines.add(RoutineItem(
                    title:    titleController.text.trim(),
                    hour:     selectedTime.hour,
                    minute:   selectedTime.minute,
                    colorHex: 0xFF7986CB,
                    iconName: selectedIconName,
                  ));
                  routines.sort((a, b) =>
                      (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
                  widget.onRoutinesChanged();
                  Navigator.pop(ctx);
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now     = TimeOfDay.now();
    final nowMins = now.hour * 60 + now.minute;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('Daily Routine', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // ── Header: current slot + progress ──
          Container(
            color: Colors.indigo,
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Now: $currentSlot',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: routines.isEmpty ? 0 : doneCount / routines.length,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent[200]!),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '$doneCount of ${routines.length} activities done',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Timeline list ──
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final item     = routines[index];
                final itemMins = item.hour * 60 + item.minute;
                final isPast   = itemMins < nowMins;
                final isCurrent = index < routines.length - 1
                    ? itemMins <= nowMins &&
                          (routines[index + 1].hour * 60 + routines[index + 1].minute) > nowMins
                    : itemMins <= nowMins;

                return _RoutineCard(
                  item:      item,
                  isPast:    isPast,
                  isCurrent: isCurrent,
                  isLast:    index == routines.length - 1,
                  onToggle: () {
                    item.isDone = !item.isDone;
                    widget.onRoutinesChanged();
                  },
                  onDelete: () {
                    routines.removeAt(index);
                    widget.onRoutinesChanged();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () => _showAddRoutineDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Activity'),
      ),
    );
  }
}

// ─── ROUTINE CARD WIDGET ──────────────────────────────────
class _RoutineCard extends StatelessWidget {
  final RoutineItem item;
  final bool isPast, isCurrent, isLast;
  final VoidCallback onToggle, onDelete;

  const _RoutineCard({
    required this.item,
    required this.isPast,
    required this.isCurrent,
    required this.isLast,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label
          SizedBox(
            width: 64,
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                item.timeLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.indigo : Colors.grey[500],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          // Dot + vertical line
          Column(
            children: [
              SizedBox(height: 12),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isDone
                      ? Colors.indigo
                      : isCurrent
                      ? Colors.indigo
                      : Colors.grey[300],
                ),
                child: item.isDone
                    ? Icon(Icons.check, size: 9, color: Colors.white)
                    : isCurrent
                    ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: isPast ? Colors.indigo[100] : Colors.grey[200]),
                ),
            ],
          ),
          SizedBox(width: 10),
          // Activity card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent ? Colors.indigo : Colors.grey[200]!,
                    width: isCurrent ? 1.5 : 0.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      decoration: item.isDone ? TextDecoration.lineThrough : null,
                      color: item.isDone ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                  subtitle: isCurrent
                      ? Text('In progress', style: TextStyle(fontSize: 11, color: Colors.indigo))
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onToggle,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.isDone ? Colors.indigo : Colors.transparent,
                            border: Border.all(
                              color: item.isDone ? Colors.indigo : Colors.grey[400]!,
                              width: 1.5,
                            ),
                          ),
                          child: item.isDone
                              ? Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(width: 6),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TASK CARD WIDGET ─────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle, onDelete, onTap;

  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  Color get categoryColor {
    switch (task.category) {
      case 'Work':     return Colors.blue[100]!;
      case 'Personal': return Colors.purple[100]!;
      case 'Shopping': return Colors.orange[100]!;
      case 'Health':   return Colors.green[100]!;
      default:         return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone ? Colors.indigo : Colors.transparent,
              border: Border.all(
                color: task.isDone ? Colors.indigo : Colors.grey[400]!,
                width: 2,
              ),
            ),
            child: task.isDone ? Icon(Icons.check, size: 16, color: Colors.white) : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 15,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey[400] : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(task.category, style: TextStyle(fontSize: 11, color: Colors.black54)),
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.red[300]),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ─── SUMMARY CHIP ─────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

// ─── TASK DETAIL SCREEN ───────────────────────────────────
class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  const TaskDetailScreen({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('Task Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 4),
            Text(task.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Category', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 4),
            Chip(label: Text(task.category), backgroundColor: Colors.indigo[50]),
            SizedBox(height: 20),
            Text('Status', style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 4),
            Chip(
              label: Text(task.isDone ? 'Completed' : 'Pending'),
              backgroundColor: task.isDone ? Colors.green[50] : Colors.orange[50],
              avatar: Icon(
                task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 16,
                color: task.isDone ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.isDone ? Colors.orange : Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  onToggle();
                  Navigator.pop(context);
                },
                icon: Icon(task.isDone ? Icons.undo : Icons.check),
                label: Text(
                  task.isDone ? 'Mark as Pending' : 'Mark as Done',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STATS SCREEN ─────────────────────────────────────────
class StatsScreen extends StatelessWidget {
  final List<Task> tasks;
  const StatsScreen({required this.tasks});

  int get done    => tasks.where((t) => t.isDone).length;
  int get pending => tasks.where((t) => !t.isDone).length;

  Map<String, int> get categoryBreakdown {
    final map = <String, int>{};
    for (var t in tasks) {
      map[t.category] = (map[t.category] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final total = tasks.length;
    final pct   = total == 0 ? 0.0 : done / total;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('Your Stats'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 16,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
            SizedBox(height: 8),
            Text('${(pct * 100).toStringAsFixed(0)}% completed', style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Total',   value: '$total', color: Colors.indigo[50]!)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Done',    value: '$done',  color: Colors.green[50]!)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Pending', value: '$pending', color: Colors.orange[50]!)),
              ],
            ),
            SizedBox(height: 28),
            Text('By category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ...categoryBreakdown.entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(width: 80, child: Text(e.key, style: TextStyle(fontSize: 14))),
                    SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : e.value / total,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo[300]!),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('${e.value}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
