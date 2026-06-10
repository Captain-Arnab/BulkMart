import 'package:flutter/material.dart';
import 'package:urban_roots/core/ui/sweet_alert_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:urban_roots/core/ui/ui_state.dart';
import 'package:urban_roots/data/vendor_mock_data.dart';
import 'package:urban_roots/features/vendor/categories/category_view_model.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late final CategoryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = CategoryViewModel();
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _showCategorySheet({VendorCategory? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              existing == null ? 'Add Category' : 'Edit Category',
              style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text('Icon picker (API later)', style: GoogleFonts.rubik(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await SweetAlert.success(
                  context,
                  message: existing == null ? 'Category added (mock)' : 'Category updated (mock)',
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLongPress(VendorCategory category) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.shade400),
              title: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      _showCategorySheet(existing: category);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete category?'),
          content: Text('Remove "${category.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        await SweetAlert.success(context, message: 'Category deleted (mock)');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF019934),
        onPressed: () => _showCategorySheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    final state = _vm.state;
    if (state is UiLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF019934)));
    }
    if (state is UiError<List<VendorCategory>>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message),
            ElevatedButton(onPressed: _vm.load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final categories = (state as UiSuccess<List<VendorCategory>>).data;
    if (categories.isEmpty) {
      return Center(child: Text('No categories', style: GoogleFonts.rubik()));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final c = categories[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onLongPress: () => _onLongPress(c),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(c.iconAsset, width: 48, height: 48, fit: BoxFit.cover),
            ),
            title: Text(c.name, style: GoogleFonts.rubik(fontWeight: FontWeight.w600)),
            subtitle: Text('Long press to edit or delete', style: GoogleFonts.rubik(fontSize: 11, color: Colors.grey)),
          ),
        );
      },
    );
  }
}
