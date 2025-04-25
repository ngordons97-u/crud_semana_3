import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'db_helper.dart';

void main() {
  runApp(MyApp());
}

class Computadora {
  String id;
  String tipo;
  String marca;
  String cpu;
  String ram;
  String hdd;

  Computadora({
    required this.id,
    required this.tipo,
    required this.marca,
    required this.cpu,
    required this.ram,
    required this.hdd,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(backgroundColor: Colors.cyanAccent),
        primarySwatch: Colors.green,
      ),
      title: 'Gestión de Inventario Hardware PC',
      home: ComputerListScreen(),
    );
  }
}

class ComputerListScreen extends StatefulWidget {
  const ComputerListScreen({super.key});
  @override
  _ComputerListScreenState createState() => _ComputerListScreenState();
}

class _ComputerListScreenState extends State<ComputerListScreen> {
  List<Computadora> computadoras = [];

  @override
  void initState() {
    super.initState();
    _loadComputadoras();
  }

  Future<void> _loadComputadoras() async {
    final data = await DBHelper().getComputadoras();
    setState(() {
      computadoras = data;
    });
  }

  void addOrUpdateComputer(Computadora comp, {bool isUpdate = false}) async {
    if (isUpdate) {
      await DBHelper().updateComputadora(comp);
    } else {
      await DBHelper().insertComputadora(comp);
    }
    _loadComputadoras(); // recarga los datos
  }

  void deleteComputer(String id) async {
    await DBHelper().deleteComputadora(id);
    _loadComputadoras(); // recarga los datos
  }

  void openForm({Computadora? comp}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ComputerFormScreen(
              onSave: addOrUpdateComputer,
              computadora: comp,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Equipos Registrados'), centerTitle: true),
      body: ListView.builder(
        itemCount: computadoras.length,
        itemBuilder: (context, index) {
          final comp = computadoras[index];
          return ListTile(
            title: Text('${comp.tipo} - ${comp.marca}'),
            subtitle: Text(
              'CPU: ${comp.cpu}, RAM: ${comp.ram}, HDD: ${comp.hdd}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_document),
                  onPressed: () => openForm(comp: comp),
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () => deleteComputer(comp.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: Icon(Icons.add_box),
      ),
    );
  }
}

class ComputerFormScreen extends StatefulWidget {
  final Function(Computadora comp, {bool isUpdate}) onSave;
  final Computadora? computadora;

  ComputerFormScreen({required this.onSave, this.computadora});

  @override
  _ComputerFormScreenState createState() => _ComputerFormScreenState();
}

class _ComputerFormScreenState extends State<ComputerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = Uuid();

  late String tipo;
  late String marca;
  late String cpu;
  late String ram;
  late String hdd;

  @override
  void initState() {
    super.initState();
    final c = widget.computadora;
    tipo = c?.tipo ?? '';
    marca = c?.marca ?? '';
    cpu = c?.cpu ?? '';
    ram = c?.ram ?? '';
    hdd = c?.hdd ?? '';
  }

  void saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final id = widget.computadora?.id ?? _uuid.v4();
      final computadora = Computadora(
        id: id,
        tipo: tipo,
        marca: marca,
        cpu: cpu,
        ram: ram,
        hdd: hdd,
      );

      widget.onSave(computadora, isUpdate: widget.computadora != null);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.computadora == null ? 'Crear Registro' : 'Editar Registro',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField('Tipo', (value) => tipo = value!),
              buildField('Marca', (value) => marca = value!),
              buildField('CPU', (value) => cpu = value!),
              buildField('RAM', (value) => ram = value!),
              buildField('HDD', (value) => hdd = value!),
              SizedBox(height: 20),
              ElevatedButton(onPressed: saveForm, child: Text('Guardar')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField(String label, Function(String?) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue:
          label == 'Tipo'
              ? tipo
              : label == 'Marca'
              ? marca
              : label == 'CPU'
              ? cpu
              : label == 'RAM'
              ? ram
              : hdd,
      validator:
          (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
      onSaved: onSaved,
    );
  }
}
