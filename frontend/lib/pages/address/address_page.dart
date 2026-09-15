import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import 'location_picker_page.dart';
import '../../core/widgets/store_app_bar.dart';

const Map<String, List<String>> _iranProvincesAndCities = {
  'آذربایجان شرقی': ['تبریز','مراغه','مرند','میانه','اهر','بناب','سراب','شبستر','اسکو','هریس'],
  'آذربایجان غربی': ['ارومیه','خوی','مهاباد','میاندوآب','بوکان','سلماس','نقده','پیرانشهر','ماکو','شاهین‌دژ'],
  'اردبیل': ['اردبیل','مشگین‌شهر','پارس‌آباد','خلخال','گرمی','نمین','نیر','بیله‌سوار'],
  'اصفهان': ['اصفهان','کاشان','خمینی‌شهر','نجف‌آباد','شاهین‌شهر','فلاورجان','شهرضا','مبارکه','گلپایگان','آران و بیدگل'],
  'البرز': ['کرج','فردیس','نظرآباد','هشتگرد','طالقان','اشتهارد'],
  'ایلام': ['ایلام','دهلران','آبدانان','ایوان','دره‌شهر','مهران','سرابله'],
  'بوشهر': ['بوشهر','برازجان','گناوه','کنگان','جم','دیر','دشتی','عسلویه'],
  'تهران': ['تهران','شهریار','اسلامشهر','قدس','ملارد','ری','ورامین','پاکدشت','دماوند','رودهن'],
  'چهارمحال و بختیاری': ['شهرکرد','بروجن','فارسان','لردگان','اردل','سامان','بن','کوهرنگ'],
  'خراسان جنوبی': ['بیرجند','قائن','طبس','فردوس','نهبندان','سرایان','درمیان'],
  'خراسان رضوی': ['مشهد','نیشابور','سبزوار','تربت حیدریه','قوچان','تربت جام','کاشمر','چناران','گناباد','تایباد'],
  'خراسان شمالی': ['بجنورد','شیروان','اسفراین','جاجرم','آشخانه','گرمه','فاروج'],
  'خوزستان': ['اهواز','دزفول','آبادان','خرمشهر','بندر ماهشهر','اندیمشک','شوش','بهبهان','ایذه','مسجدسلیمان'],
  'زنجان': ['زنجان','ابهر','خرمدره','قیدار','ماه‌نشان','طارم','سلطانیه'],
  'سمنان': ['سمنان','شاهرود','دامغان','گرمسار','مهدی‌شهر','سرخه','میامی'],
  'سیستان و بلوچستان': ['زاهدان','چابهار','زابل','ایرانشهر','سراوان','خاش','کنارک','نیک‌شهر'],
  'فارس': ['شیراز','مرودشت','جهرم','فسا','کازرون','لار','داراب','آباده','اقلید','فیروزآباد'],
  'قزوین': ['قزوین','تاکستان','آبیک','الوند','بوئین‌زهرا','آوج'],
  'قم': ['قم','کهک'],
  'کردستان': ['سنندج','سقز','مریوان','بانه','قروه','بیجار','کامیاران','دیواندره'],
  'کرمان': ['کرمان','رفسنجان','سیرجان','جیرفت','بم','زرند','راور','شهربابک','کهنوج'],
  'کرمانشاه': ['کرمانشاه','اسلام‌آباد غرب','سنقر','کنگاور','هرسین','صحنه','پاوه','جوانرود'],
  'کهگیلویه و بویراحمد': ['یاسوج','دهدشت','گچساران','لیکک','سی‌سخت'],
  'گلستان': ['گرگان','گنبد کاووس','علی‌آباد کتول','آق‌قلا','بندر ترکمن','کردکوی','مینودشت','کلاله'],
  'گیلان': ['رشت','انزلی','لاهیجان','لنگرود','رودسر','آستانه اشرفیه','تالش','رودبار','فومن'],
  'لرستان': ['خرم‌آباد','بروجرد','دورود','الیگودرز','کوهدشت','نورآباد','الشتر','پلدختر'],
  'مازندران': ['ساری','بابل','آمل','قائم‌شهر','نوشهر','چالوس','تنکابن','بابلسر','بهشهر','رامسر'],
  'مرکزی': ['اراک','ساوه','خمین','محلات','دلیجان','تفرش','آشتیان','شازند'],
  'هرمزگان': ['بندرعباس','میناب','بندر لنگه','قشم','کیش','رودان','حاجی‌آباد','پارسیان'],
  'همدان': ['همدان','ملایر','نهاوند','کبودرآهنگ','رزن','اسدآباد','تویسرکان'],
  'یزد': ['یزد','میبد','اردکان','بافق','مهریز','اشکذر','ابرکوه','تفت'],
};

class AddressPage extends ConsumerWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(
      appBar: const StoreAppBar(title: 'آدرس‌های من'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('آدرس جدید'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: addresses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطا: $e')),
          data: (items) {
            if (items.isEmpty) return const Center(child: Text('هنوز آدرسی ثبت نکرده‌اید.'));
            return RefreshIndicator(
              onRefresh: () => ref.refresh(addressesProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final a = items[index];
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.title?.isNotEmpty == true ? a.title! : a.city,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (a.isDefault) const Chip(label: Text('پیش‌فرض')),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${a.recipientName} - ${a.phone}\n'
                          '${a.province}، ${a.city}\n'
                          '${a.address}\n'
                          'کدپستی: ${a.postalCode}\n'
                          '${a.latitude != null && a.longitude != null ? 'موقعیت روی نقشه ثبت شده' : 'موقعیت روی نقشه ثبت نشده'}',
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _openForm(context, address: a);
                          } else {
                            await _delete(context, ref, a);
                          }
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

  Future<void> _delete(BuildContext context, WidgetRef ref, AddressModel address) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف آدرس'),
        content: const Text('آیا از حذف این آدرس مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok != true) return;
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
  double? _latitude;
  double? _longitude;
  bool _saving = false;

  List<String> get _cities => _province == null ? const [] : (_iranProvincesAndCities[_province] ?? const []);

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _title = TextEditingController(text: a?.title ?? '');
    _recipient = TextEditingController(text: a?.recipientName ?? '');
    final phone = a?.phone ?? '';
    _phone = TextEditingController(text: RegExp(r'^09\d{9}$').hasMatch(phone) ? phone : '09');
    _address = TextEditingController(text: a?.address ?? '');
    _postalCode = TextEditingController(text: a?.postalCode ?? '');
    _isDefault = a?.isDefault ?? false;
    _latitude = a?.latitude;
    _longitude = a?.longitude;
    _province = _iranProvincesAndCities.containsKey(a?.province) ? a?.province : null;
    final cities = _province == null ? const <String>[] : (_iranProvincesAndCities[_province] ?? const <String>[]);
    _city = cities.contains(a?.city) ? a?.city : null;
  }

  @override
  void dispose() {
    for (final controller in [_title, _recipient, _phone, _address, _postalCode]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final location = await Navigator.of(context).push<({double latitude, double longitude})>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(initialLatitude: _latitude, initialLongitude: _longitude),
      ),
    );
    if (location == null || !mounted) return;
    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفاً موقعیت آدرس را روی نقشه انتخاب کنید.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final notifier = ref.read(addressesProvider.notifier);
      final args = {
        'title': _title.text.trim(),
        'recipientName': _recipient.text.trim(),
        'phone': _phone.text.trim(),
        'province': _province!,
        'city': _city!,
        'address': _address.text.trim(),
        'postalCode': _postalCode.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'isDefault': _isDefault,
      };
      if (widget.address == null) {
        await notifier.create(
          title: args['title'] as String,
          recipientName: args['recipientName'] as String,
          phone: args['phone'] as String,
          province: args['province'] as String,
          city: args['city'] as String,
          address: args['address'] as String,
          postalCode: args['postalCode'] as String,
          latitude: args['latitude'] as double?,
          longitude: args['longitude'] as double?,
          isDefault: args['isDefault'] as bool,
        );
      } else {
        await notifier.saveAddress(
          id: widget.address!.id,
          title: args['title'] as String,
          recipientName: args['recipientName'] as String,
          phone: args['phone'] as String,
          province: args['province'] as String,
          city: args['city'] as String,
          address: args['address'] as String,
          postalCode: args['postalCode'] as String,
          latitude: args['latitude'] as double?,
          longitude: args['longitude'] as double?,
          isDefault: args['isDefault'] as bool,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا در ذخیره آدرس: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _phoneValidator(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'شماره تماس را وارد کنید';
    if (!RegExp(r'^09\d{9}$').hasMatch(phone)) return 'شماره تماس باید ۱۱ رقمی و با 09 شروع شود';
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
                Text(widget.address == null ? 'افزودن آدرس' : 'ویرایش آدرس', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _field(_title, 'عنوان آدرس'),
                _field(_recipient, 'نام گیرنده'),
                _field(
                  _phone,
                  'شماره تماس',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return RegExp(r'^09\d{0,9}$').hasMatch(newValue.text)
                          ? newValue.copyWith(selection: TextSelection.collapsed(offset: newValue.text.length))
                          : oldValue;
                    }),
                  ],
                  validator: _phoneValidator,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _province,
                  decoration: const InputDecoration(labelText: 'استان', border: OutlineInputBorder()),
                  items: _iranProvincesAndCities.keys.map((province) => DropdownMenuItem(value: province, child: Text(province))).toList(),
                  validator: (value) => value == null ? 'استان را انتخاب کنید' : null,
                  onChanged: _saving ? null : (value) => setState(() { _province = value; _city = null; }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _city,
                  decoration: InputDecoration(
                    labelText: 'شهر',
                    border: const OutlineInputBorder(),
                    helperText: _province == null ? 'ابتدا استان را انتخاب کنید' : null,
                  ),
                  items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                  validator: (value) => value == null ? 'شهر را انتخاب کنید' : null,
                  onChanged: _saving || _province == null ? null : (value) => setState(() => _city = value),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickLocation,
                  icon: Icon(_latitude == null ? Icons.location_on_outlined : Icons.location_on),
                  label: Text(_latitude == null ? 'انتخاب موقعیت روی نقشه' : 'ویرایش موقعیت روی نقشه'),
                ),
                if (_latitude != null && _longitude != null)
                  Text('موقعیت: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('آدرس پیش‌فرض'),
                  value: _isDefault,
                  onChanged: _saving ? null : (value) => setState(() => _isDefault = value),
                ),
                _field(_address, 'آدرس', maxLines: 3, validator: (value) => value?.trim().isEmpty == true ? 'آدرس را وارد کنید' : null),
                _field(_postalCode, 'کدپستی', keyboardType: TextInputType.number, validator: (value) => value?.trim().isEmpty == true ? 'کدپستی را وارد کنید' : null),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'در حال ذخیره...' : 'ذخیره آدرس'),
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
}
