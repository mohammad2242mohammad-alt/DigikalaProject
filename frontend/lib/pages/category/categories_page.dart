import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/store_app_bar.dart';
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
        appBar: const StoreAppBar(title: 'دسته‌بندی‌ها'),
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
                ? ListView(
                    children: const [
                      SizedBox(height: 240),
                      Center(child: Text('دسته‌بندی‌ای وجود ندارد')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _CategoryTile(
                      category: categories[index],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({required this.category});
  final CategoryModel category;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final hasChildren = category.children.isNotEmpty;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: hasChildren
                ? () => setState(() => expanded = !expanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  if (hasChildren)
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 26,
                    )
                  else
                    const SizedBox(width: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded && hasChildren)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  const Divider(height: 1),
                  _CategoryActionTile(
                    icon: Icons.apps_outlined,
                    title: 'همه محصولات',
                    onTap: () => _openSearch(
                      context,
                      category.id,
                      'همه محصولات ${category.name}',
                    ),
                  ),
                  for (final child in category.children)
                    _CategoryActionTile(
                      icon: Icons.chevron_left,
                      title: child.name,
                      onTap: () => _openSearch(
                        context,
                        child.id,
                        child.name,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, int categoryId, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchPage(categoryId: categoryId, title: title),
      ),
    );
  }
}

class _CategoryActionTile extends StatelessWidget {
  const _CategoryActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 8, right: 12),
        leading: Icon(icon),
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
