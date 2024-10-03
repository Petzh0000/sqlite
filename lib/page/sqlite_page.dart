import 'package:flutter/material.dart';
import '/services/database_helper.dart';

class SqlitePage extends StatefulWidget {
  const SqlitePage({super.key});

  @override
  State<SqlitePage> createState() => _SqlitePageState();
}

class _SqlitePageState extends State<SqlitePage> {
  //dbHelper ซึ่งเป็นอินสแตนซ์ของ DatabaseHelper
  //สําหรับจัดการฐานข้อมูล SQLite และสร้างตัวควบคุมสําหรับ TextField ที่จะใช้ในการ
  //กรอกข้อมูลชื่อ (_nameController) และอีเมล (_emailController)
  //users ใช้เก็บรายการข้อมูลที่ดึงมาจากฐานข้อมูล
  //SQLite ในรูปแบบ List ของ Map ซึ่งแต่ละ Map แทนข้อมูลหนึ่งรายการ
  DatabaseHelper dbHelper = DatabaseHelper();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  //สร้างฟังก์ชัน _addUser ที่ทําหน้าที่เพิ่มข้อมูลใหม่ลงในฐานข้อมูล โดยใช้
  //ฟังก์ชัน insertUser ของ DatabaseHelper หลังจากเพิ่มข้อมูลสําเร็จ จะเคลียร์ข้อมูลใน
  //ช่องกรอกเพื่อเตรียมพร้อมสําหรับการกรอกข้อมูลใหม่
  Future<void> _addUser() async {
    await dbHelper.insertUser({
      'name': _nameController.text,
      'nickname': _nicknameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });
    _nameController.clear();
    _nicknameController.clear();
    _emailController.clear();
    _phoneController.clear();
  }

  Future<void> _updateUser(int id) async {
    await dbHelper.updateUser({
      'id': id,
      'name': _nameController.text,
      'nickname': _nicknameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    });
    _nameController.clear();
    _nicknameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _refreshUsers();
  }

  Future<void> _deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    _refreshUsers(); // อัปเดตรายการข้อมูล
  }

  //สร้างฟอร์มเพิ่มข้อมูล โดยทําการสร้างฟังก์ชัน _showForm
  void _showForm(int? id) {
    if (id != null) {
      final existingUser = users.firstWhere((element) => element['id'] == id);
      _nameController.text = existingUser['name'];
      _nicknameController.text = existingUser['nickname'];
      _emailController.text = existingUser['email'];
      _phoneController.text = existingUser['phone'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'ชื่อจริง นามสกุล'),
                ),
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(labelText: 'ชื่อเล่น'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'อีเมล'),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'เบอร์โทร'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (id == null) {
                      _addUser();
                    } else {
                      _updateUser(id);
                    }
                    Navigator.of(context).pop(); // ปิด bottom sheet
                  },
                  child: Text(id == null ? 'เพิ่มข้อมูล' : 'แก้ไขข้อมูล'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  //initState ซึ่งจะถูกเรียกใช้ทันทีเมื่อหน้าจอถูกสร้างขึ้น โดย
  //ภายในเมธอดนี้จะมีการเรียกฟังก์ชัน _refreshUsers เพื่อดึงข้อมูลทั้งหมดจากฐานข้อมูล
  //สร้างฟังก์ชัน _refreshUsers ทํางานโดยใช้เมธอด getUsers ของ DatabaseHelper เพื่อดึง
  //ข้อมูลจากฐานข้อมูล เมื่อดึงข้อมูลเสร็จสิ้น ฟังก์ชันจะอัปเดตสถานะของตัวแปร users ด้วย
  //ข้อมูลที่ดึงมาได้ และใช้ setState เพื่อบอกฟลัตเตอร์ว่าต้องการอัปเดตหน้าจอใหม่ตาม
  //ข้อมูลที่เปลี่ยนแปลง
  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    final data = await dbHelper.getUsers();
    setState(() {
      users = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('รายการข้อมูล'),
      ),
      body: users.isEmpty
          ? Center(
        child: Text(
            'ไม่มีข้อมูล กรุณาเพิ่มข้อมูลใหม่'), // ข้อความแสดงที่กลางหน้าจอเมื่อไม่มีข้อมูล
      )
          : ListView.builder(
        itemCount: users.length, // จํานวนข้อมูลในรายการ
        itemBuilder: (context, index) {
          return ListTile(
              title: Text('ชื่อจริง-นามสกุล: ${users[index]['name']}'),
              subtitle: Text('ชื่อเล่น: ${users[index]['nickname']}\nอีเมล: ${users[index]['email']}\nเบอร์: ${users[index]['phone']}'),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showForm(users[index]['id']),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteUser(users[index]['id']),
                  ),
                ],
              )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }
}