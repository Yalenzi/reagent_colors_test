import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  String _query = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final _col = FirebaseFirestore.instance.collection('reagents');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            tooltip: 'Add Reagent',
            icon: const Icon(Icons.add),
            onPressed: _showAddReagentDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _col.orderBy('reagentName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No reagents yet. Click + to add'));
          }
          // Filter and sort
          List<QueryDocumentSnapshot<Map<String, dynamic>>> filtered = docs.where((d) {
            final data = d.data();
            final name = (data['reagentName'] ?? '').toString().toLowerCase();
            final category = (data['category'] ?? 'general').toString().toLowerCase();
            final q = _query.toLowerCase();
            return q.isEmpty || name.contains(q) || category.contains(q);
          }).toList();

          int compareBy(int colIndex, Map<String, dynamic> a, Map<String, dynamic> b) {
            switch (colIndex) {
              case 0: // name
                return (a['reagentName'] ?? '').toString().toLowerCase().compareTo((b['reagentName'] ?? '').toString().toLowerCase());
              case 1: // category
                return (a['category'] ?? '').toString().toLowerCase().compareTo((b['category'] ?? '').toString().toLowerCase());
              case 2: // duration
                return ((a['testDuration'] ?? 0) as int).compareTo((b['testDuration'] ?? 0) as int);
              default:
                return 0;
            }
          }

          if (_sortColumnIndex != null) {
            filtered.sort((x, y) {
              final a = x.data();
              final b = y.data();
              final c = compareBy(_sortColumnIndex!, a, b);
              return _sortAscending ? c : -c;
            });
          }

          final source = _ReagentsDataSource(
            rows: filtered,
            onEdit: (id, data) => _showEditReagentDialog(id, data),
            onRefs: (id, data) => _editReferences(id, data),
            onRefsColor: (id, data) => _editReferencesByColor(id, data),
            onDrugResults: (id, data) => _editDrugResults(id, data),
            onDelete: (id, name) => _confirmDelete(id, name),
          );

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search by name or category',
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PaginatedDataTable2(
                    wrapInCard: true,
                    rowsPerPage: 10,
                    columns: [
                      DataColumn2(
                        label: const Text('Name'),
                        onSort: (i, asc) => setState(() {
                          _sortColumnIndex = i;
                          _sortAscending = asc;
                        }),
                      ),
                      DataColumn2(
                        label: const Text('Category'),
                        onSort: (i, asc) => setState(() {
                          _sortColumnIndex = i;
                          _sortAscending = asc;
                        }),
                      ),
                      DataColumn2(
                        label: const Text('Duration'),
                        numeric: true,
                        onSort: (i, asc) => setState(() {
                          _sortColumnIndex = i;
                          _sortAscending = asc;
                        }),
                      ),
                      const DataColumn2(label: Text('Actions')),
                    ],
                    source: source,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReagentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reagent'),
      ),
    );
  }

  Future<void> _showAddReagentDialog() async {
    final nameCtrl = TextEditingController();
    final nameArCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final descArCtrl = TextEditingController();
    final safetyCtrl = TextEditingController(text: 'Medium');
    final safetyArCtrl = TextEditingController(text: 'متوسط');
    final categoryCtrl = TextEditingController(text: 'General');
    int testDuration = 30;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Reagent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (en)')),
                TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'الاسم (ar)')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (en)')),
                TextField(controller: descArCtrl, decoration: const InputDecoration(labelText: 'الوصف (ar)')),
                TextField(controller: safetyCtrl, decoration: const InputDecoration(labelText: 'Safety level (en)')),
                TextField(controller: safetyArCtrl, decoration: const InputDecoration(labelText: 'مستوى الأمان (ar)')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Test duration (min): '),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: testDuration,
                      items: const [15, 30, 45, 60]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (v) => setState(() => testDuration = v ?? 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final data = {
                  'reagentName': nameCtrl.text.trim(),
                  'reagentName_ar': nameArCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'description_ar': descArCtrl.text.trim(),
                  'safetyLevel': safetyCtrl.text.trim(),
                  'safetyLevel_ar': safetyArCtrl.text.trim(),
                  'testDuration': testDuration,
                  'chemicals': <String>[],
                  'drugResults': <Map<String, dynamic>>[],
                  'category': categoryCtrl.text.trim().isEmpty ? 'General' : categoryCtrl.text.trim(),
                  'references': <String>[],
                  // 'referencesByColor': { 'purple': ['https://...'] }
                };
                await _col.doc(nameCtrl.text.trim()).set(data, SetOptions(merge: true));
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditReagentDialog(String id, Map<String, dynamic> existing) async {
    final nameCtrl = TextEditingController(text: existing['reagentName'] ?? '');
    final nameArCtrl = TextEditingController(text: existing['reagentName_ar'] ?? '');
    final descCtrl = TextEditingController(text: existing['description'] ?? '');
    final descArCtrl = TextEditingController(text: existing['description_ar'] ?? '');
    final safetyCtrl = TextEditingController(text: existing['safetyLevel'] ?? '');
    final safetyArCtrl = TextEditingController(text: existing['safetyLevel_ar'] ?? '');
    final categoryCtrl = TextEditingController(text: existing['category'] ?? 'General');
    int testDuration = (existing['testDuration'] ?? 30) as int;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Reagent'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (en)')),
                TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'الاسم (ar)')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description (en)')),
                TextField(controller: descArCtrl, decoration: const InputDecoration(labelText: 'الوصف (ar)')),
                TextField(controller: safetyCtrl, decoration: const InputDecoration(labelText: 'Safety level (en)')),
                TextField(controller: safetyArCtrl, decoration: const InputDecoration(labelText: 'مستوى الأمان (ar)')),
                TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Test duration (min): '),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: testDuration,
                      items: const [15, 30, 45, 60]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (v) => setState(() => testDuration = v ?? testDuration),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'reagentName': nameCtrl.text.trim(),
                  'reagentName_ar': nameArCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'description_ar': descArCtrl.text.trim(),
                  'safetyLevel': safetyCtrl.text.trim(),
                  'safetyLevel_ar': safetyArCtrl.text.trim(),
                  'testDuration': testDuration,
                  'category': categoryCtrl.text.trim().isEmpty ? 'General' : categoryCtrl.text.trim(),
                };
                await _col.doc(id).set(data, SetOptions(merge: true));
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save changes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reagent'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            onPressed: () => Navigator.pop(context, true),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  if (ok == true) {
    await _col.doc(id).delete();
  }
}

  Future<void> _editReferences(String id, Map<String, dynamic> data) async {
    final List<String> refs = (data['references'] as List?)?.cast<String>() ?? <String>[];
    final TextEditingController inputCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit References'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Reference URL',
                            hintText: 'https://example.com',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final v = inputCtrl.text.trim();
                          if (v.isEmpty) return;
                          setState(() {
                            refs.add(v);
                            inputCtrl.clear();
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      itemCount: refs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => ListTile(
                        dense: true,
                        title: Text(refs[i], maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => refs.removeAt(i)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await _col.doc(id).set({'references': refs}, SetOptions(merge: true));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _editReferencesByColor(String id, Map<String, dynamic> data) async {
    final Map<String, List<String>> refsByColor = {
      for (final entry in ((data['referencesByColor'] as Map?) ?? <String, dynamic>{}).entries)
        entry.key.toString(): (entry.value as List?)?.cast<String>() ?? <String>[]
    };

    String? selectedColor = refsByColor.keys.isNotEmpty ? refsByColor.keys.first : null;
    final TextEditingController colorCtrl = TextEditingController();
    final TextEditingController linkCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final currentLinks = selectedColor == null ? <String>[] : (refsByColor[selectedColor] ?? <String>[]);
          return AlertDialog(
            title: const Text('Edit References by Color'),
            content: SizedBox(
              width: 560,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedColor,
                          items: refsByColor.keys
                              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                              .toList(),
                          onChanged: (v) => setState(() => selectedColor = v),
                          decoration: const InputDecoration(labelText: 'Select color key'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 220,
                        child: TextField(
                          controller: colorCtrl,
                          decoration: const InputDecoration(labelText: 'New color key'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final k = colorCtrl.text.trim();
                          if (k.isEmpty) return;
                          if (!refsByColor.containsKey(k)) {
                            setState(() {
                              refsByColor[k] = <String>[];
                              selectedColor = k;
                              colorCtrl.clear();
                            });
                          }
                        },
                        child: const Text('Add color'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: linkCtrl,
                          decoration: const InputDecoration(labelText: 'Reference URL for selected color'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedColor == null
                            ? null
                            : () {
                                final v = linkCtrl.text.trim();
                                if (v.isEmpty) return;
                                setState(() {
                                  refsByColor[selectedColor!]!.add(v);
                                  linkCtrl.clear();
                                });
                              },
                        child: const Text('Add link'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      itemCount: currentLinks.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) => ListTile(
                        dense: true,
                        title: Text(currentLinks[i], maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              currentLinks.removeAt(i);
                              refsByColor[selectedColor!] = currentLinks;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await _col.doc(id).set({'referencesByColor': refsByColor}, SetOptions(merge: true));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _editDrugResults(String id, Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> items = ((data['drugResults'] as List?) ?? const [])
        .map((e) => {
              'drugName': (e as Map)['drugName']?.toString() ?? '',
              'color': (e)['color']?.toString() ?? '',
              'color_ar': (e)['color_ar']?.toString() ?? '',
            })
        .toList();

    final nameCtrl = TextEditingController();
    final colorCtrl = TextEditingController();
    final colorArCtrl = TextEditingController();

    Future<void> editItemDialog(int index) async {
      final ec1 = TextEditingController(text: items[index]['drugName'] ?? '');
      final ec2 = TextEditingController(text: items[index]['color'] ?? '');
      final ec3 = TextEditingController(text: items[index]['color_ar'] ?? '');
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Drug Result'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: ec1, decoration: const InputDecoration(labelText: 'Drug name')),
                TextField(controller: ec2, decoration: const InputDecoration(labelText: 'Color (en)')),
                TextField(controller: ec3, decoration: const InputDecoration(labelText: 'Color (ar)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                items[index] = {
                  'drugName': ec1.text.trim(),
                  'color': ec2.text.trim(),
                  'color_ar': ec3.text.trim(),
                };
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Drug Results'),
            content: SizedBox(
              width: 560,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(labelText: 'Drug name'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: colorCtrl,
                          decoration: const InputDecoration(labelText: 'Color (en)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: colorArCtrl,
                          decoration: const InputDecoration(labelText: 'Color (ar)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final dn = nameCtrl.text.trim();
                          final c = colorCtrl.text.trim();
                          final ca = colorArCtrl.text.trim();
                          if (dn.isEmpty || c.isEmpty || ca.isEmpty) return;
                          setState(() {
                            items.add({'drugName': dn, 'color': c, 'color_ar': ca});
                            nameCtrl.clear();
                            colorCtrl.clear();
                            colorArCtrl.clear();
                          });
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final it = items[i];
                        return ListTile(
                          dense: true,
                          title: Text(it['drugName'] ?? ''),
                          subtitle: Text('EN: ${it['color'] ?? ''} | AR: ${it['color_ar'] ?? ''}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(


                                icon: const Icon(Icons.edit),
                                onPressed: () async {
                                  await editItemDialog(i);
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => items.removeAt(i)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await _col.doc(id).set({'drugResults': items}, SetOptions(merge: true));
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

}





class _ReagentsDataSource extends DataTableSource {
  _ReagentsDataSource({
    required this.rows,
    required this.onEdit,
    required this.onRefs,
    required this.onRefsColor,
    required this.onDrugResults,
    required this.onDelete,
  });

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> rows;
  final void Function(String id, Map<String, dynamic> data) onEdit;
  final void Function(String id, Map<String, dynamic> data) onRefs;
  final void Function(String id, Map<String, dynamic> data) onRefsColor;
  final void Function(String id, Map<String, dynamic> data) onDrugResults;
  final void Function(String id, String name) onDelete;

  @override
  DataRow? getRow(int index) {
    if (index >= rows.length) return null;
    final d = rows[index];
    final data = d.data();
    final name = (data['reagentName'] ?? '').toString();
    final category = (data['category'] ?? 'General').toString();
    final duration = (data['testDuration'] ?? 0) as int;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(name.isEmpty ? d.id : name)),
        DataCell(Text(category)),
        DataCell(Text('$duration')),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit(d.id, data);
                  break;
                case 'refs':
                  onRefs(d.id, data);
                  break;
                case 'refs_color':
                  onRefsColor(d.id, data);
                  break;
                case 'drugResults':
                  onDrugResults(d.id, data);
                  break;
                case 'delete':
                  onDelete(d.id, name);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'refs', child: Text('Edit References')),
              PopupMenuItem(value: 'refs_color', child: Text('Edit Refs by Color')),
              PopupMenuItem(value: 'drugResults', child: Text('Edit Drug Results')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
