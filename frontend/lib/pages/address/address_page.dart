import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';

class AddressPage extends ConsumerWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('آدرس‌های من')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('آدرس جدید'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: addresses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('خطا: $error')),
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Text('هنوز آدرسی ثبت نکرده‌اید.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(addressesProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final address = items[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                address.title?.isNotEmpty == true
                                    ? address.title!
                                    : address.city,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (address.isDefault)
                              const Chip(label: Text('پیش‌فرض')),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${address.recipientName} - ${address.phone}\n'
                            '${address.province}، ${address.city}\n'
                            '${address.address}\nکدپستی: ${address.postalCode}',
                          ),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _openForm(context, address: address);
                            } else if (value == 'delete') {
                              await _delete(context, ref, address);
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                            PopupMenuItem(value: 'delete', child: Text('حذف')),
                          ],
                        ),
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

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AddressModel address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آدرس'),
        content: const Text('آیا از حذف این آدرس مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(addressRepositoryProvider).delete(address.id);
      ref.invalidate(addressesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('آدرس حذف شد.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در حذف آدرس: $e')),
        );
      }
    }
  }

  Future<void> _openForm(
    BuildContext context, {
    AddressModel? address,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddressFormSheet(address: address),
    );
  }
}

class AddressFormSheet extends ConsumerStatefulWidget {
  const AddressFormSheet({super.key, this.address});

  final AddressModel? address;

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _recipient;
  late final TextEditingController _phone;
  late final TextEditingController _province;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _postalCode;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.address;
    _title = TextEditingController(text: item?.title ?? '');
    _recipient = TextEditingController(text: item?.recipientName ?? '');
    _phone = TextEditingController(text: item?.phone ?? '');
    _province = TextEditingController(text: item?.province ?? '');
    _city = TextEditingController(text: item?.city ?? '');
    _address = TextEditingController(text: item?.address ?? '');
    _postalCode = TextEditingController(text: item?.postalCode ?? '');
    _isDefault = item?.isDefault ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _recipient.dispose();
    _phone.dispose();
    _province.dispose();
    _city.dispose();
    _address.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repository = ref.read(addressRepositoryProvider);
      final data = {
        'title': _title.text.trim().isEmpty ? null : _title.text.trim(),
        'recipientName': _recipient.text.trim(),
        'phone': _phone.text.trim(),
        'province': _province.text.trim(),
        'city': _city.text.trim(),
        'address': _address.text.trim(),
        'postalCode': _postalCode.text.trim(),
        'isDefault': _isDefault,
      };

      if (widget.address == null) {
        await repository.create(
          title: data['title'] as String?,
          recipientName: data['recipientName'] as String,
          phone: data['phone'] as String,
          province: data['province'] as String,
          city: data['city'] as String,
          address: data['address'] as String,
          postalCode: data['postalCode'] as String,
          isDefault: data['isDefault'] as bool,
        );
      } else {
        await repository.update(
          id: widget.address!.id,
          title: data['title'] as String?,
          recipientName: data['recipientName'] as String,
          phone: data['phone'] as String,
          province: data['province'] as String,
          city: data['city'] as String,
          address: data['address'] as String,
          postalCode: data['postalCode'] as String,
          isDefault: data['isDefault'] as bool,
        );
      }

      ref.invalidate(addressesProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در ذخیره آدرس: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label را وارد کنید';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.address == null ? 'افزودن آدرس' : 'ویرایش آدرس',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _field(_title, 'عنوان آدرس', required: false),
                _field(_recipient, 'نام گیرنده'),
                _field(_phone, 'شماره تماس', keyboardType: TextInputType.phone),
                _field(_province, 'استان'),
                _field(_city, 'شهر'),
                _field(_address, 'آدرس کامل', maxLines: 3),
                _field(_postalCode, 'کد پستی', keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('آدرس پیش‌فرض'),
                  value: _isDefault,
                  onChanged: _saving ? null : (value) => setState(() => _isDefault = value),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('ذخیره آدرس'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required ? (value) => _required(value, label) : null,
      ),
    );
  }
}
