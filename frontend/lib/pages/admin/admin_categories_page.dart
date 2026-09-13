import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import '../../providers/admin_provider.dart';

class AdminCategoriesPage extends ConsumerStatefulWidget {
  const AdminCategoriesPage({super.key});

  @override
  ConsumerState<AdminCategoriesPage> createState() => _AdminCategoriesPageState();
}

class _AdminCategoriesPageState extends ConsumerState<AdminCategoriesPage> {
  late Future<List<CategoryModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminRepositoryProvider).getCategories();
  }

  Future<void> _refresh() async {
    setState(() => _future = ref.read(adminRepositoryProvider).getCategories());
    await _future;
  }

  Future<void> _edit([CategoryModel? category]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _CategoryDialog(category: category),
    );
    if (result == true) await _refresh();
  }

  Future<void> _delete(CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف دسته‌بندی'),
        content: Text('دسته «${category.name}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(adminRepositoryProvider).deleteCategory(category.id);
      await _refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت دسته‌بندی‌ها')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('دسته جدید'),
        ),
        body: FutureBuilder<List<CategoryModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text('خطا: ${snapshot.error}'));
            final categories = snapshot.data ?? const <CategoryModel>[];
            if (categories.isEmpty) return const Center(child: Text('دسته‌بندی‌ای ثبت نشده است.'));
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final category = categories[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: Text(category.name),
                      subtitle: Text('${category.slug} | ${category.parentId == null ? 'اصلی' : 'زیرمجموعه'}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _edit(category);
                          if (value == 'delete') _delete(category);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  const _CategoryDialog({this.category});
  final CategoryModel? category;

  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _slug;
  late final TextEditingController _image;
  late final TextEditingController _description;
  late final TextEditingController _sortOrder;
  int? _parentId;
  bool _active = true;
  bool _saving = false;
  List<CategoryModel> _categories = const [];

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = TextEditingController(text: c?.name ?? '');
    _slug = TextEditingController(text: c?.slug ?? '');
    _image = TextEditingController(text: c?.image ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _sortOrder = TextEditingController(text: '0');
    _parentId = c?.parentId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(adminRepositoryProvider).getCategories();
      if (mounted) setState(() => _categories = categories.where((c) => c.id != widget.category?.id).toList());
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in [_name, _slug, _image, _description, _sortOrder]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'parent_id': _parentId,
        'name': _name.text.trim(),
        'slug': _slug.text.trim(),
        'image': _image.text.trim().isEmpty ? null : _image.text.trim(),
        'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
        'is_active': _active,
        'sort_order': int.tryParse(_sortOrder.text.trim()) ?? 0,
      };
      final repo = ref.read(adminRepositoryProvider);
      if (widget.category == null) {
        await repo.createCategory(data);
      } else {
        await repo.updateCategory(widget.category!.id, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'دسته جدید' : 'ویرایش دسته'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'نام'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'این فیلد الزامی است' : null,
                ),
                TextFormField(
                  controller: _slug,
                  decoration: const InputDecoration(labelText: 'Slug'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'این فیلد الزامی است' : null,
                ),
                DropdownButtonFormField<int?>(
                  initialValue: _parentId,
                  decoration: const InputDecoration(labelText: 'دسته والد'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('بدون والد')),
                    ..._categories.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (value) => setState(() => _parentId = value),
                ),
                TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'توضیحات'), maxLines: 2),
                TextFormField(controller: _image, decoration: const InputDecoration(labelText: 'آدرس تصویر'), keyboardType: TextInputType.url),
                TextFormField(controller: _sortOrder, decoration: const InputDecoration(labelText: 'ترتیب نمایش'), keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('دسته فعال باشد'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('لغو')),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
          label: const Text('ذخیره'),
        ),
      ],
    );
  }
}
