import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import '../search/search_page.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دسته‌بندی‌ها')),
        body: categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('دریافت دسته‌بندی‌ها ناموفق بود.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            ),
          ),
          data: (categories) => RefreshIndicator(
            onRefresh: () => ref.refresh(categoriesProvider.future),
            child: categories.isEmpty
                ? ListView(children: const [SizedBox(height: 240), Center(child: Text('دسته‌بندی‌ای وجود ندارد'))])
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _CategoryTile(category: categories[index]),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.category_outlined),
        title: Text(category.name),
        subtitle: category.children.isEmpty ? null : Text('${category.children.length} زیر‌دسته'),
        children: [
          for (final child in category.children)
            ListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: 32, end: 16),
              leading: const Icon(Icons.chevron_left),
              title: Text(child.name),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SearchPage(categoryId: child.id, title: child.name),
                  ),
                );
              },
            ),
          if (category.children.isNotEmpty)
            ListTile(
              contentPadding: const EdgeInsetsDirectional.only(start: 32, end: 16),
              leading: const Icon(Icons.arrow_back),
              title: const Text('مشاهده همه محصولات این دسته'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SearchPage(categoryId: category.id, title: category.name),
                  ),
                );
              },
            ),
        ],
        onExpansionChanged: (expanded) {
          if (expanded && category.children.isEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchPage(categoryId: category.id, title: category.name),
              ),
            );
          }
        },
      ),
    );
  }
}
