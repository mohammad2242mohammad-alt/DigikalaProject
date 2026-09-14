import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';

const Map<String, List<String>> _iranProvincesAndCities = {
  'آذربایجان شرقی': ['تبریز', 'مراغه', 'مرند', 'میانه', 'اهر', 'بناب', 'سراب', 'شبستر', 'اسکو', 'هریس'],
  'آذربایجان غربی': ['ارومیه', 'خوی', 'مهاباد', 'میاندوآب', 'بوکان', 'سلماس', 'نقده', 'پیرانشهر', 'ماکو', 'شاهین‌دژ'],
  'اردبیل': ['اردبیل', 'مشگین‌شهر', 'پارس‌آباد', 'خلخال', 'گرمی', 'نمین', 'نیر', 'بیله‌سوار'],
  'اصفهان': ['اصفهان', 'کاشان', 'خمینی‌شهر', 'نجف‌آباد', 'شاهین‌شهر', 'فلاورجان', 'شهرضا', 'مبارکه', 'گلپایگان', 'آران و بیدگل'],
  'البرز': ['کرج', 'فردیس', 'نظرآباد', 'هشتگرد', 'طالقان', 'اشتهارد'],
  'ایلام': ['ایلام', 'دهلران', 'آبدانان', 'ایوان', 'دره‌شهر', 'مهران', 'سرابله'],
  'بوشهر': ['بوشهر', 'برازجان', 'گناوه', 'کنگان', 'جم', 'دیر', 'دشتی', 'عسلویه'],
  'تهران': ['تهران', 'شهریار', 'اسلامشهر', 'قدس', 'ملارد', 'ری', 'ورامین', 'پاکدشت', 'دماوند', 'رودهن'],
  'چهارمحال و بختیاری': ['شهرکرد', 'بروجن', 'فارسان', 'لردگان', 'اردل', 'سامان', 'بن', 'کوهرنگ'],
  'خراسان جنوبی': ['بیرجند', 'قائن', 'طبس', 'فردوس', 'نهبندان', 'سرایان', 'درمیان'],
  'خراسان رضوی': ['مشهد', 'نیشابور', 'سبزوار', 'تربت حیدریه', 'قوچان', 'تربت جام', 'کاشمر', 'چناران', 'گناباد', 'تایباد'],
  'خراسان شمالی': ['بجنورد', 'شیروان', 'اسفراین', 'جاجرم', 'آشخانه', 'گرمه', 'فاروج'],
  'خوزستان': ['اهواز', 'دزفول', 'آبادان', 'خرمشهر', 'بندر ماهشهر', 'اندیمشک', 'شوش', 'بهبهان', 'ایذه', 'مسجدسلیمان'],
  'زنجان': ['زنجان', 'ابهر', 'خرمدره', 'قیدار', 'ماه‌نشان', 'طارم', 'سلطانیه'],
  'سمنان': ['سمنان', 'شاهرود', 'دامغان', 'گرمسار', 'مهدی‌شهر', 'سرخه', 'میامی'],
  'سیستان و بلوچستان': ['زاهدان', 'چابهار', 'زابل', 'ایرانشهر', 'سراوان', 'خاش', 'کنارک', 'نیک‌شهر'],
  'فارس': ['شیراز', 'مرودشت', 'جهرم', 'فسا', 'کازرون', 'لار', 'داراب', 'آباده', 'اقلید', 'فیروزآباد'],
  'قزوین': ['قزوین', 'تاکستان', 'آبیک', 'الوند', 'بوئین‌زهرا', 'آوج'],
  'قم': ['قم', 'کهک'],
  'کردستان': ['سنندج', 'سقز', 'مریوان', 'بانه', 'قروه', 'بیجار', 'کامیاران', 'دیواندره'],
  'کرمان': ['کرمان', 'رفسنجان', 'سیرجان', 'جیرفت', 'بم', 'زرند', 'راور', 'شهربابک', 'کهنوج'],
  'کرمانشاه': ['کرمانشاه', 'اسلام‌آباد غرب', 'سنقر', 'کنگاور', 'هرسین', 'صحنه', 'پاوه', 'جوانرود'],
  'کهگیلویه و بویراحمد': ['یاسوج', 'دهدشت', 'گچساران', 'لیکک', 'سی‌سخت'],
  'گلستان': ['گرگان', 'گنبد کاووس', 'علی‌آباد کتول', 'آق‌قلا', 'بندر ترکمن', 'کردکوی', 'مینودشت', 'کلاله'],
  'گیلان': ['رشت', 'انزلی', 'لاهیجان', 'لنگرود', 'رودسر', 'آستانه اشرفیه', 'تالش', 'رودبار', 'فومن'],
  'لرستان': ['خرم‌آباد', 'بروجرد', 'دورود', 'الیگودرز', 'کوهدشت', 'نورآباد', 'الشتر', 'پلدختر'],
  'مازندران': ['ساری', 'بابل', 'آمل', 'قائم‌شهر', 'نوشهر', 'چالوس', 'تنکابن', 'بابلسر', 'بهشهر', 'رامسر'],
  'مرکزی': ['اراک', 'ساوه', 'خمین', 'محلات', 'دلیجان', 'تفرش', 'آشتیان', 'شازند'],
  'هرمزگان': ['بندرعباس', 'میناب', 'بندر لنگه', 'قشم', 'کیش', 'رودان', 'حاجی‌آباد', 'پارسیان'],
  'همدان': ['همدان', 'ملایر', 'نهاوند', 'کبودرآهنگ', 'رزن', 'اسدآباد', 'تویسرکان'],
  'یزد': ['یزد', 'میبد', 'اردکان', 'بافق', 'مهریز', 'اشکذر', 'ابرکوه', 'تفت'],
};

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
              return const Center(child: Text('هنوز آدرسی ثبت نکرده‌اید.'));
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
                                address.title?.isNotEmpty == true ? address.title! : address.city,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (address.isDefault) const Chip(label: Text('پیش‌فرض')),
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

  Future<void> _delete(BuildContext context, WidgetRef ref, AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف آدرس'),
        content: const Text('آیا از حذف این آدرس مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(addressesProvider.notifier).delete(address.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('آدرس حذف شد.')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در حذف آدرس: $e')));
      }
    }
  }

  Future<void> _openForm(BuildContext context, {AddressModel? address}) async {
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
  late final TextEditingController _address;
  late final TextEditingController _postalCode;
  late bool _isDefault;
  String? _province;
  String? _city;
  bool _saving = false;

  List<String> get _cities => _province == null ? const [] : (_iranProvincesAndCities[_province] ?? const []);

  @override
  void initState() {
    super.initState();
    final item = widget.address;
    _title = TextEditingController(text: item?.title ?? '');
    _recipient = TextEditingController(text: item?.recipientName ?? '');
    _phone = TextEditingController(text: item?.phone ?? '');
    _address = TextEditingController(text: item?.address ?? '');
    _postalCode = TextEditingController(text: item?.postalCode ?? '');
    _isDefault = item?.isDefault ?? false;
    _province = _iranProvincesAndCities.containsKey(item?.province) ? item?.province : null;
    final cities = _province == null ? const <String>[] : (_iranProvincesAndCities[_province] ?? const <String>[]);
    _city = cities.contains(item?.city) ? item?.city : null;
  }

  @override
  void dispose() {
    _title.dispose();
    _recipient.dispose();
    _phone.dispose();
    _address.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final title = _title.text.trim();
      final notifier = ref.read(addressesProvider.notifier);
      if (widget.address == null) {
        await notifier.create(
          title: title,
          recipientName: _recipient.text.trim(),
          phone: _phone.text.trim(),
          province: _province!,
          city: _city!,
          address: _address.text.trim(),
          postalCode: _postalCode.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        await notifier.saveAddress(
          id: widget.address!.id,
          title: title,
          recipientName: _recipient.text.trim(),
          phone: _phone.text.trim(),
          province: _province!,
          city: _city!,
          address: _address.text.trim(),
          postalCode: _postalCode.text.trim(),
          isDefault: _isDefault,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در ذخیره آدرس: $e')));
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
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
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
                _field(_title, 'عنوان آدرس'),
                _field(_recipient, 'نام گیرنده'),
                _field(_phone, 'شماره تماس', keyboardType: TextInputType.phone),
                _provinceDropdown(),
                const SizedBox(height: 12),
                _cityDropdown(),
                const SizedBox(height: 12),
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
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
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

  Widget _provinceDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _province,
      decoration: const InputDecoration(labelText: 'استان', border: OutlineInputBorder()),
      items: _iranProvincesAndCities.keys
          .map((province) => DropdownMenuItem(value: province, child: Text(province)))
          .toList(),
      validator: (value) => value == null ? 'استان را انتخاب کنید' : null,
      onChanged: _saving
          ? null
          : (value) {
              setState(() {
                _province = value;
                _city = null;
              });
            },
    );
  }

  Widget _cityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _city,
      decoration: InputDecoration(
        labelText: 'شهر',
        border: const OutlineInputBorder(),
        helperText: _province == null ? 'ابتدا استان را انتخاب کنید' : null,
      ),
      items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      validator: (value) => value == null ? 'شهر را انتخاب کنید' : null,
      onChanged: _saving || _province == null ? null : (value) => setState(() => _city = value),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => _required(value, label),
      ),
    );
  }
}
