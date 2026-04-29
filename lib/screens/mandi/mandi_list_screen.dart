import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/mandi_model.dart';
import '../profile/profile_screen.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/mandi_card.dart';
import 'mandi_detail_screen.dart';

class MandiListScreen extends StatefulWidget {
  static const String routeName = '/mandi-list';

  const MandiListScreen({super.key});

  @override
  State<MandiListScreen> createState() => _MandiListScreenState();
}

class _MandiListScreenState extends State<MandiListScreen> {
  final List<MandiModel> _allMandis = DummyData.mandis
      .map((mandi) => MandiModel.fromMap(mandi))
      .toList();

  String _searchQuery = '';
  String _activeStatusFilter = 'All';

  static const List<String> _statusFilters = ['All', 'Open', 'Closed'];

  List<MandiModel> get _filteredMandis {
    return _allMandis.where((mandi) {
      final bool matchesStatus =
          _activeStatusFilter == 'All' ||
          (_activeStatusFilter == 'Open' && mandi.isOpen) ||
          (_activeStatusFilter == 'Closed' && !mandi.isOpen);

      if (!matchesStatus) {
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
    final List<MandiModel> mandis = _filteredMandis;
    final int openCount = _allMandis.where((m) => m.isOpen).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Mandis'),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: kAccentColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: kSecondaryColor.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '${_allMandis.length} Mandis Found · $openCount Open Today',
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
                hintText: 'Search by mandi name or city...',
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
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final String filter = _statusFilters[index];
                final bool isSelected = _activeStatusFilter == filter;

                return ChoiceChip(
                  label: Text(filter),
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
          const SizedBox(height: 8),
          Expanded(
            child: mandis.isEmpty
                ? const Center(
                    child: Text(
                      'No mandis found for this search.',
                      style: TextStyle(color: kTextLight),
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
                      return MandiCard(
                        name: mandi.name,
                        city: mandi.city,
                        province: mandi.province,
                        distance: mandi.distance,
                        isOpen: mandi.isOpen,
                        totalCrops: mandi.totalCrops,
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
  }
}

