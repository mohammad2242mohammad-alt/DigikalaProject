import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../product/product_detail_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, this.categoryId, this.title});

  final int? categoryId;
  final String? title;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  String _sort = 'latest';
  double? _minPrice;
  double? _maxPrice;
  Future<List<Product>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final repository = ref.read(productRepositoryProvider);
    _future = repository.getProducts(
      search: _searchController.text,
      categoryId: widget.categoryId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      sort: _sort,
      perPage: 50,
    );
  }

  void _search() {
    setState(_load);
  }

  Future<void> _openFilters() async {
    final minController = TextEditingController(text: _minPrice?.toStringAsFixed(0) ?? '');
    final maxController = TextEditingController(text: _maxPrice?.toStringAsFixed(0) ?? '');
    var selectedSort = _sort;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('فیلتر و مرتب‌سازی', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'حداقل قیمت', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'حداکثر قیمت', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSort,
                decoration: const InputDecoration(labelText: 'مرتب‌سازی', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'latest', child: Text('جدیدترین')),
                  DropdownMenuItem(value: 'price_asc', child: Text('ارزان‌ترین')),
                  DropdownMenuItem(value: 'price_desc', child: Text('گران‌ترین')),
                  DropdownMenuItem(value: 'rating', child: Text('بالاترین امتیاز')),
                  DropdownMenuItem(value: 'popular', child: Text('محبوب‌ترین')),
                ],
                onChanged: (value) {
                  if (value != null) setSheetState(() => selectedSort = value);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final min = double.tryParse(minController.text.trim());
                  final max = double.tryParse(maxController.text.trim());
                  if (min != null && max != null && max < min) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حداکثر قیمت باید بیشتر یا مساوی حداقل قیمت باشد.')));
                    return;
                  }
                  Navigator.pop(context);
                  setState(() {
                    _minPrice = min;
                    _maxPrice = max;
                    _sort = selectedSort;
                    _load();
                  });
                },
                child: const Text('اعمال فیلتر'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title ?? 'جستجوی محصولات')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                      decoration: InputDecoration(
                        hintText: 'نام محصول را جستجو کنید',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _search();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'فیلتر',
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('خطا در دریافت محصولات:\n${snapshot.error}', textAlign: TextAlign.center));
                  }
                  final products = snapshot.data ?? const <Product>[];
                  if (products.isEmpty) {
                    return const Center(child: Text('محصولی مطابق جستجو پیدا نشد.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => setState(_load),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            leading: product.image != null && product.image!.isNotEmpty
                                ? Image.network(product.image!, width: 70, height: 70, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 42))
                                : const Icon(Icons.image_outlined, size: 42),
                            title: Text(product.name),
                            subtitle: Text(product.stock > 0 ? '${PriceFormatter.format(product.effectivePrice)} تومان' : 'ناموجود'),
                            trailing: Text('⭐ ${product.rating}'),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailPage(product: product))),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
