import 'package:flutter/material.dart';

void main() {
  runApp(const TaskSaverApp());
}

class TaskSaverApp extends StatelessWidget {
  const TaskSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'สมุดบันทึกนักผจญภัย',
      theme: ThemeData(
        fontFamily: 'PermanentMarker', // อย่าลืมเพิ่มฟอนต์ใน pubspec.yaml
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          primary: Colors.brown,
          secondary: Colors.amber,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5ECD6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD2B48C),
          elevation: 6,
          titleTextStyle: TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 22,
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          iconTheme: IconThemeData(color: Colors.brown),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'PermanentMarker',
            color: Colors.brown,
            fontSize: 16,
          ),
        ),
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tasks = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      CustomSnackBar.show(context, 'กรุณากรอกชื่องานก่อนบันทึก');
      return;
    }
    setState(() {
      _tasks.add(text);
      _controller.clear();
      _listKey.currentState?.insertItem(_tasks.length - 1);
    });
    CustomSnackBar.show(context, 'บันทึกงานแล้ว');
  }

  void _clearAllTasks() {
    if (_tasks.isEmpty) return;
    for (int i = _tasks.length - 1; i >= 0; i--) {
      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            TaskListItem(task: _tasks[i], animation: animation),
        duration: const Duration(milliseconds: 400),
      );
    }
    setState(() {
      _tasks.clear();
    });
    CustomSnackBar.show(context, 'ลบงานทั้งหมดแล้ว');
  }

  void _removeTask(int index) {
    final removedTask = _tasks[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          TaskListItem(task: removedTask, animation: animation),
      duration: const Duration(milliseconds: 400),
    );
    setState(() {
      _tasks.removeAt(index);
    });
    CustomSnackBar.show(context, 'ลบรายการแล้ว');
  }

  void _openTaskList() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskListPage(tasks: _tasks, onRemove: _removeTask),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final recentTasks = _tasks.length > 2
        ? _tasks.sublist(_tasks.length - 2)
        : List.from(_tasks);
    return Scaffold(
      appBar: CustomAppBar(
        title: 'สมุดบันทึกนักผจญภัย',
        badgeCount: _tasks.length,
        onBadgeTap: _openTaskList,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/adventure_bg.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0xFFF5ECD6),
              BlendMode.softLight,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECD6).withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.brown.shade300, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomSectionTitle(
                      title: 'บันทึกการผจญภัย',
                      bold: true,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _controller,
                      onSubmitted: (_) => _addTask(),
                    ),
                    const SizedBox(height: 12),
                    CustomSaveButton(onPressed: _addTask),
                    const SizedBox(height: 20),
                    TaskStats(taskCount: _tasks.length),
                    const SizedBox(height: 10),
                    MotivationBanner(),
                    const SizedBox(height: 10),
                    if (recentTasks.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomSectionTitle(title: 'ล่าสุด', bold: true),
                          ...recentTasks.reversed.map(
                            (task) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFE7D7B9),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.explore,
                                    color: Colors.brown,
                                  ),
                                  title: Text(
                                    task,
                                    style: const TextStyle(
                                      fontFamily: 'PermanentMarker',
                                      fontSize: 17,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (_tasks.length > 2)
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.menu_book,
                            color: Colors.brown,
                          ),
                          label: const Text(
                            'ดูบันทึกทั้งหมด',
                            style: TextStyle(
                              fontFamily: 'PermanentMarker',
                              color: Colors.brown,
                            ),
                          ),
                          onPressed: _openTaskList,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ Custom Widgets ------------------

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int badgeCount;
  final VoidCallback onBadgeTap;
  const CustomAppBar({
    required this.title,
    required this.badgeCount,
    required this.onBadgeTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 6,
      backgroundColor: const Color(0xFFD2B48C),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: onBadgeTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.menu_book, size: 28, color: Colors.brown),
                Positioned(right: -2, top: 6, child: Badge(count: badgeCount)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class Badge extends StatelessWidget {
  final int count;
  const Badge({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    final String display = count > 99 ? '99+' : '$count';
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.brown,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          display,
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'PermanentMarker',
          ),
        ),
      ),
    );
  }
}

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final bool bold;
  const CustomSectionTitle({required this.title, this.bold = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'PermanentMarker',
        fontSize: 22,
        fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        color: Colors.brown.shade700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  const CustomTextField({
    required this.controller,
    this.onSubmitted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFE7D7B9),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'เขียนบันทึกการผจญภัย...',
          hintStyle: const TextStyle(
            fontFamily: 'PermanentMarker',
            color: Colors.brown,
            fontSize: 16,
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        style: const TextStyle(
          fontFamily: 'PermanentMarker',
          color: Colors.brown,
          fontSize: 16,
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}

class CustomSaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomSaveButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save_alt, color: Colors.brown),
        label: const Text(
          'บันทึก',
          style: TextStyle(
            fontFamily: 'PermanentMarker',
            color: Colors.brown,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD2B48C),
          foregroundColor: Colors.brown,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

class CustomSnackBar {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontSize: 16,
            color: Colors.amber,
          ),
        ),
        backgroundColor: Colors.brown.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ------------------ Task Widgets ------------------

class TaskListItem extends StatelessWidget {
  final String task;
  final Animation<double> animation;
  final VoidCallback? onRemove;
  const TaskListItem({
    required this.task,
    required this.animation,
    this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      axisAlignment: 0.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFFE7D7B9),
          child: ListTile(
            leading: const Icon(Icons.explore, color: Colors.brown),
            title: Text(
              task,
              style: const TextStyle(
                fontFamily: 'PermanentMarker',
                fontSize: 17,
                color: Colors.brown,
              ),
            ),
            trailing: onRemove != null
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: onRemove,
                    tooltip: 'ลบ',
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

// ------------------ Task List Page ------------------

class TaskListPage extends StatefulWidget {
  final List<String> tasks;
  final Function(int)? onRemove;

  const TaskListPage({super.key, required this.tasks, this.onRemove});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  void _removeAt(int index) {
    setState(() {
      widget.tasks.removeAt(index);
    });
    CustomSnackBar.show(context, 'ลบรายการแล้ว');
    if (widget.onRemove != null) {
      widget.onRemove!(index);
    }
  }

  void _clearAllTasks() {
    setState(() {
      widget.tasks.clear();
    });
    CustomSnackBar.show(context, 'ลบงานทั้งหมดแล้ว');
  }

  @override
  Widget build(BuildContext context) {
    // แสดงเฉพาะรายการที่ไม่ใช่ 2 ล่าสุด
    final showTasks = widget.tasks.length > 2
        ? widget.tasks.sublist(0, widget.tasks.length - 2)
        : [];
    return Scaffold(
      appBar: CustomAppBar(
        title: 'รายการบันทึก',
        badgeCount: showTasks.length,
        onBadgeTap: () => Navigator.of(context).pop(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/parchment_texture.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0xFFF5ECD6),
              BlendMode.softLight,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: const Color(0xFFF5ECD6).withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.brown.shade300, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    ClearAllButton(onPressed: _clearAllTasks),
                    const SizedBox(height: 10),
                    showTasks.isEmpty
                        ? const Center(
                            child: Text(
                              'ยังไม่มีรายการ',
                              style: TextStyle(
                                fontFamily: 'PermanentMarker',
                                fontSize: 18,
                                color: Colors.brown,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ...List.generate(showTasks.length, (index) {
                                final task = showTasks[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFFE7D7B9),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.explore,
                                        color: Colors.brown,
                                      ),
                                      title: Text(
                                        task,
                                        style: const TextStyle(
                                          fontFamily: 'PermanentMarker',
                                          fontSize: 17,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _removeAt(index),
                                        tooltip: 'ลบ',
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDismissBackground extends StatelessWidget {
  final bool left;
  const CustomDismissBackground({required this.left, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

class TaskStats extends StatelessWidget {
  final int taskCount;
  const TaskStats({required this.taskCount, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics, color: Colors.brown),
        const SizedBox(width: 8),
        Text(
          'จำนวนบันทึก: $taskCount',
          style: const TextStyle(
            fontFamily: 'PermanentMarker',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}

class MotivationBanner extends StatelessWidget {
  const MotivationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD2B48C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade300, width: 1.5),
      ),
      child: const Text(
        '“ทุกวันคือการผจญภัยใหม่ จงบันทึกทุกความทรงจำ!”',
        style: TextStyle(
          fontFamily: 'PermanentMarker',
          color: Colors.brown,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ClearAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ClearAllButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
        label: const Text(
          'ลบทั้งหมด',
          style: TextStyle(
            fontFamily: 'PermanentMarker',
            color: Colors.redAccent,
          ),
        ),
        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
      ),
    );
  }
}
