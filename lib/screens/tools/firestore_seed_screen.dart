import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';

class FirestoreSeedScreen extends StatefulWidget {
  static const String routeName = '/seed-firestore';

  const FirestoreSeedScreen({super.key});

  @override
  State<FirestoreSeedScreen> createState() => _FirestoreSeedScreenState();
}

class _FirestoreSeedScreenState extends State<FirestoreSeedScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _clearBeforeSeed = false;

  int get _cropCount => DummyData.crops.length;
  int get _mandiCount => DummyData.mandis.length;
  int get _newsCount => DummyData.news.length;
  int get _historyCount => DummyData.crops
      .map((crop) => DummyData.historyForCrop(
            crop['name'] as String,
            fallbackPrice: (crop['price'] as num).toDouble(),
          ).length)
      .fold(0, (total, length) => total + length);

  Future<void> _seedFirestore() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Seeding Firestore collections...';
    });

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      if (_clearBeforeSeed) {
        setState(() {
          _statusMessage = 'Clearing existing data...';
        });
        await _clearCollections(firestore, const [
          'crops',
          'mandis',
          'news',
          'price_history',
        ]);
      }

      final WriteBatch batch = firestore.batch();

      for (final crop in DummyData.crops) {
        final String docId = (crop['id'] as int).toString();
        batch.set(firestore.collection('crops').doc(docId), crop);
      }

      for (final mandi in DummyData.mandis) {
        final String docId = (mandi['id'] as int).toString();
        batch.set(firestore.collection('mandis').doc(docId), mandi);
      }

      for (final news in DummyData.news) {
        final String docId = (news['id'] as int).toString();
        batch.set(firestore.collection('news').doc(docId), news);
      }

      for (final crop in DummyData.crops) {
        final String cropName = crop['name'] as String;
        final double price = (crop['price'] as num).toDouble();
        final List<Map<String, dynamic>> history = DummyData.historyForCrop(
          cropName,
          fallbackPrice: price,
        );

        for (final day in history) {
          final String date = day['date'] as String;
          final String docId =
              '${cropName.toLowerCase().replaceAll(' ', '_')}-$date';
          batch.set(firestore.collection('price_history').doc(docId), {
            'cropName': cropName,
            'date': date,
            'price': day['price'],
          });
        }
      }

      await batch.commit();
      if (mounted) {
        setState(() {
          _statusMessage = _clearBeforeSeed
              ? 'Cleared and seeded successfully.'
              : 'Seed completed successfully.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Seed failed: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _clearCollections(
    FirebaseFirestore firestore,
    List<String> collections,
  ) async {
    for (final collection in collections) {
      final QuerySnapshot snapshot =
          await firestore.collection(collection).get();
      if (snapshot.docs.isEmpty) {
        continue;
      }
      final WriteBatch batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Firestore'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kAccentColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'This will upload the current dummy data into Firestore. '
                'Use this once for development seeds.',
                style: TextStyle(color: kTextDark, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Crops', _cropCount),
            _buildStatRow('Mandis', _mandiCount),
            _buildStatRow('News', _newsCount),
            _buildStatRow('Price History', _historyCount),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              value: _clearBeforeSeed,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _clearBeforeSeed = value;
                      });
                    },
              title: const Text(
                'Clear existing data before seeding',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Use this if you want a clean, fresh seed.',
              ),
              activeThumbColor: kPrimaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusMessage!.startsWith('Seed failed')
                      ? Colors.red
                      : kTextDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _seedFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _clearBeforeSeed
                            ? 'Clear & Seed Firestore Data'
                            : 'Seed Firestore Data',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: kTextDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

