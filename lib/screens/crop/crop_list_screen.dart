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

class CropListScreen extends StatefulWidget {
  static const String routeName = '/crop-list';

  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _filters = const [
    'All',
    'Grains',
    'Vegetables',
    'Cash Crops',
  ];

  String _searchQuery = '';
  String _activeFilter = 'All';

  List<CropModel> _applyFilters(List<CropModel> crops) {
    return crops.where((crop) {
      final String lowerName = crop.name.toLowerCase();
      final bool matchesSearch =
          _searchQuery.isEmpty || lowerName.contains(_searchQuery.toLowerCase());

      if (!matchesSearch) {
        return false;
      }

      if (_activeFilter == 'All') {
        return true;
      }

      if (_activeFilter == 'Grains') {
        return crop.category.toLowerCase().contains('grain');
      }

      if (_activeFilter == 'Vegetables') {
        return crop.category.toLowerCase().contains('vegetable');
      }

      if (_activeFilter == 'Cash Crops') {
        return crop.category.toLowerCase().contains('cash');
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
            title: Text(isUrdu ? 'فصلوں کی قیمتیں' : 'Crop Prices'),
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
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final String filter = _filters[index];
                    final bool isSelected = _activeFilter == filter;

                    String displayFilter = filter;
                    if (isUrdu) {
                      if (filter == 'All') displayFilter = 'سب';
                      if (filter == 'Grains') displayFilter = 'اناج';
                      if (filter == 'Vegetables') displayFilter = 'سبزیاں';
                      if (filter == 'Cash Crops') displayFilter = 'نقد آور فصلیں';
                    }

                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(displayFilter),
                      onSelected: (_) {
                        setState(() {
                          _activeFilter = filter;
                        });
                      },
                      selectedColor: kSecondaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? kSecondaryColor
                            : kTextLight.withValues(alpha: 0.25),
                      ),
                      backgroundColor: Colors.white,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: _filters.length,
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
