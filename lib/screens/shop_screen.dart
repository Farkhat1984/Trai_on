import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) return;

    // TODO: Здесь будет поиск товаров
    // Пока просто показываем, что поиск работает
    print('Поиск: $query');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазины'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Строка поиска
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск товаров...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value);
              },
            ),

            const SizedBox(height: 40),

            // Описание функционала
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Функция в разработке',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 32),
                        _buildFeatureText(
                          'Здесь будет поиск одежды из различных интернет-магазинов. '
                          'Вы сможете искать товары по описанию или по фото.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureText(
                          'Планируется добавить фильтры по цене, размеру, бренду и цвету.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureText(
                          'Также будет возможность сохранять понравившиеся товары '
                          'в избранное и сразу примерять их виртуально.',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureText(
                          'Интеграция с популярными маркетплейсами позволит '
                          'сравнивать цены и находить лучшие предложения.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureText(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    );
  }
}
