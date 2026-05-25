import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/crop_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/crop_card.dart';
import '../profile/profile_screen.dart';
import 'crop_detail_screen.dart';
import '../../utils/language_provider.dart';

class EdiblesListScreen extends StatefulWidget {
  static const String routeName = '/edibles-list';

  const EdiblesListScreen({super.key});

  @override
  State<EdiblesListScreen> createState() => _EdiblesListScreenState();
}

class _EdiblesListScreenState extends State<EdiblesListScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _filters = const [
    'All',
    'Vegetables',
    'Fruits',
    'Meat',
  ];

  late TabController _tabController;
  String _searchQuery = '';
  String _activeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeFilter = _filters[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<CropModel> _applyFilters(List<CropModel> crops) {
    return crops.where((crop) {
      final String lowerName = crop.name.toLowerCase();
      final bool matchesSearch =
          _searchQuery.isEmpty || lowerName.contains(_searchQuery.toLowerCase());

      if (!matchesSearch) {
        return false;
      }

      if (_activeFilter == 'All') {
        final cat = crop.category.toLowerCase();
        return cat.contains('vegetable') || cat.contains('fruit') || cat.contains('meat');
      }

      if (_activeFilter == 'Vegetables') {
        return crop.category.toLowerCase().contains('vegetable');
      }

      if (_activeFilter == 'Fruits') {
        return crop.category.toLowerCase().contains('fruit');
      }

      if (_activeFilter == 'Meat') {
        return crop.category.toLowerCase().contains('meat');
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.watchCrops(),
      builder: (context, snapshot) {
        final List<Map<String, dynamic>> source =
            snapshot.data != null && snapshot.data!.isNotEmpty
                ? snapshot.data!
                : DummyData.crops;

        final List<CropModel> crops = _applyFilters(
          source.map((crop) => CropModel.fromMap(crop)).toList(),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(isUrdu ? 'خوراک کی قیمتیں' : 'Edibles Prices'),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Profile',
                onPressed: () {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName);
                },
                icon: const Icon(Icons.person_outline),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: kHighlightColor,
              indicatorWeight: 3,
              tabs: _filters.map((filter) {
                String displayFilter = filter;
                if (isUrdu) {
                  if (filter == 'All') displayFilter = 'سب';
                  if (filter == 'Vegetables') displayFilter = 'سبزیاں';
                  if (filter == 'Fruits') displayFilter = 'پھل';
                  if (filter == 'Meat') displayFilter = 'گوشت';
                }
                return Tab(text: displayFilter);
              }).toList(),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding,
                  14,
                  kDefaultPadding,
                  10,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: isUrdu ? 'فصلیں تلاش کریں...' : 'Search crops...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: crops.isEmpty
                    ? Center(
                        child: Text(
                          isUrdu ? 'آپ کی تلاش سے کوئی فصل میل نہیں کھاتی۔' : 'No crops match your search.',
                          style: const TextStyle(color: kTextLight),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          kDefaultPadding,
                          0,
                          kDefaultPadding,
                          18,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.76,
                        ),
                        itemCount: crops.length,
                        itemBuilder: (context, index) {
                          final CropModel crop = crops[index];
                          return CropCard(
                            crop: crop,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                CropDetailScreen.routeName,
                                arguments: crop,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
