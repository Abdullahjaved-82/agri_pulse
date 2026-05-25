import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/mandi_model.dart';
import '../profile/profile_screen.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/mandi_card.dart';
import 'mandi_detail_screen.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/language_provider.dart';

class MandiListScreen extends StatefulWidget {
  static const String routeName = '/mandi-list';

  const MandiListScreen({super.key});

  @override
  State<MandiListScreen> createState() => _MandiListScreenState();
}

class _MandiListScreenState extends State<MandiListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locSvc = LocationService();
  Position? _currentPosition;

  String _searchQuery = '';
  String _activeStatusFilter = 'All';
  String _activeProvinceFilter = 'All';

  final List<String> _provinces = [
    'All',
    'Punjab',
    'Sindh',
    'KPK',
    'Balochistan',
    'GB',
    'AJK',
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final pos = await _locSvc.getCurrentLocation();
    if (mounted && pos != null) {
      setState(() => _currentPosition = pos);
    }
  }

  static const List<String> _statusFilters = ['All', 'Open', 'Closed'];

  List<MandiModel> _applyFilters(List<MandiModel> mandis) {
    return mandis.where((mandi) {
      final bool matchesStatus =
          _activeStatusFilter == 'All' ||
          (_activeStatusFilter == 'Open' && mandi.isOpen) ||
          (_activeStatusFilter == 'Closed' && !mandi.isOpen);

      if (!matchesStatus) {
        return false;
      }
      
      if (_activeProvinceFilter != 'All' && mandi.province != _activeProvinceFilter) {
        return false;
      }

      if (_searchQuery.isEmpty) {
        return true;
      }

      final String query = _searchQuery.toLowerCase();
      return mandi.name.toLowerCase().contains(query) ||
          mandi.city.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = LanguageScope.of(context).isUrdu;
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.watchMandis(),
      builder: (context, snapshot) {
        final List<Map<String, dynamic>> source =
            snapshot.data != null && snapshot.data!.isNotEmpty
                ? snapshot.data!
                : DummyData.mandis;

        List<MandiModel> allMandis =
            source.map((mandi) => MandiModel.fromMap(mandi)).toList();
        
        if (_currentPosition != null) {
          allMandis = _locSvc.sortMandisByDistance(allMandis, _currentPosition!);
        }

        final List<MandiModel> mandis = _applyFilters(allMandis);
        final int openCount = allMandis.where((m) => m.isOpen).length;

        return Scaffold(
          appBar: AppBar(
            title: Text(isUrdu ? 'قریبی منڈیاں' : 'Nearby Mandis'),
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
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: kAccentColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kSecondaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    isUrdu ? '${allMandis.length} منڈیاں ملیں · $openCount آج کھلی ہیں' : '${allMandis.length} Mandis Found · $openCount Open Today',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding,
                  0,
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
                    hintText: isUrdu ? 'منڈی کے نام یا شہر سے تلاش کریں...' : 'Search by mandi name or city...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _activeProvinceFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: kPrimaryColor),
                            items: _provinces.map((prov) {
                              return DropdownMenuItem(
                                value: prov,
                                child: Text(prov == 'All' ? (isUrdu ? 'تمام صوبے' : 'All Provinces') : prov),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _activeProvinceFilter = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final String filter = _statusFilters[index];
                            final bool isSelected = _activeStatusFilter == filter;
                            String displayFilter = filter;
                            if (isUrdu) {
                              if (filter == 'All') displayFilter = 'سب';
                              if (filter == 'Open') displayFilter = 'کھلی';
                              if (filter == 'Closed') displayFilter = 'بند';
                            }
        
                            return ChoiceChip(
                              label: Text(displayFilter),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _activeStatusFilter = filter;
                                });
                              },
                              selectedColor: kSecondaryColor,
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? kSecondaryColor
                                    : kTextLight.withValues(alpha: 0.25),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : kTextDark,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(width: 8),
                          itemCount: _statusFilters.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: mandis.isEmpty
                    ? Center(
                        child: Text(
                          isUrdu ? 'اس تلاش کے لیے کوئی منڈیاں نہیں ملیں۔' : 'No mandis found for this search.',
                          style: const TextStyle(color: kTextLight),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          kDefaultPadding,
                          0,
                          kDefaultPadding,
                          16,
                        ),
                        itemCount: mandis.length,
                        itemBuilder: (context, index) {
                          final MandiModel mandi = mandis[index];
                          final bool isNearest = _currentPosition != null && 
                                                 allMandis.isNotEmpty && 
                                                 mandi.id == allMandis.first.id;
                          return MandiCard(
                            name: mandi.name,
                            city: mandi.city,
                            province: mandi.province,
                            distance: mandi.distance,
                            isOpen: mandi.isOpen,
                            totalCrops: mandi.totalCrops,
                            isNearest: isNearest,
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                MandiDetailScreen.routeName,
                                arguments: mandi,
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

