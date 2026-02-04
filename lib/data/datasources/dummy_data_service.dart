import 'package:uuid/uuid.dart';
import '../models/bg_model.dart';
import '../datasources/hive_service.dart';

class DummyDataService {
  static const _uuid = Uuid();

  static final List<String> _banks = [
    'State Bank of India',
    'HDFC Bank',
    'ICICI Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
  ];

  static final List<String> _discoms = [
    'UPPCL',
    'PVVNL',
    'DVVNL',
    'MVVNL',
    'PUVVNL',
    'KESCO',
    'TORRENT POWER',
    'TATA POWER',
  ];

  static Future<void> loadDummyData() async {
    // Check if data already exists
    if (HiveService.getAllBgs().isNotEmpty) {
      return;
    }

    final now = DateTime.now();

    // Create diverse set of dummy BGs
    final dummyBgs = [
      // Active BGs with various expiry dates
      _createBg(
        bgNumber: 'BG/2024/001',
        issueDate: now.subtract(const Duration(days: 180)),
        amount: 2500000,
        expiryDate: now.add(const Duration(days: 120)),
        claimExpiryDate: now.add(const Duration(days: 150)),
        bankName: _banks[0],
        discom: _discoms[0],
        tenderNumber: 'TN/2024/UPPCL/001',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2024/001',
          fdrDate: now.subtract(const Duration(days: 180)),
          fdrAmount: 2600000,
          roi: 6.5,
        ),
        status: BgStatus.active,
      ),
      _createBg(
        bgNumber: 'BG/2024/002',
        issueDate: now.subtract(const Duration(days: 150)),
        amount: 5000000,
        expiryDate: now.add(const Duration(days: 30)),
        claimExpiryDate: now.add(const Duration(days: 60)),
        bankName: _banks[1],
        discom: _discoms[1],
        tenderNumber: 'TN/2024/PVVNL/002',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2024/002',
          fdrDate: now.subtract(const Duration(days: 150)),
          fdrAmount: 5200000,
          roi: 7.0,
        ),
        status: BgStatus.active,
      ),
      _createBg(
        bgNumber: 'BG/2024/003',
        issueDate: now.subtract(const Duration(days: 200)),
        amount: 1500000,
        expiryDate: now.add(const Duration(days: 15)),
        claimExpiryDate: now.add(const Duration(days: 45)),
        bankName: _banks[2],
        discom: _discoms[2],
        tenderNumber: 'TN/2024/DVVNL/003',
        status: BgStatus.active,
      ),
      _createBg(
        bgNumber: 'BG/2024/004',
        issueDate: now.subtract(const Duration(days: 90)),
        amount: 3500000,
        expiryDate: now.add(const Duration(days: 45)),
        claimExpiryDate: now.add(const Duration(days: 75)),
        bankName: _banks[3],
        discom: _discoms[3],
        tenderNumber: 'TN/2024/MVVNL/004',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2024/004',
          fdrDate: now.subtract(const Duration(days: 90)),
          fdrAmount: 3600000,
          roi: 6.8,
        ),
        status: BgStatus.active,
        extensionHistory: [
          _createExtension(
            extensionDate: now.subtract(const Duration(days: 30)),
            newBgExpiryDate: now.add(const Duration(days: 45)),
            newClaimExpiryDate: now.add(const Duration(days: 75)),
            remarks: 'First extension',
          ),
        ],
      ),
      _createBg(
        bgNumber: 'BG/2024/005',
        issueDate: now.subtract(const Duration(days: 365)),
        amount: 8000000,
        expiryDate: now.add(const Duration(days: 200)),
        claimExpiryDate: now.add(const Duration(days: 230)),
        bankName: _banks[4],
        discom: _discoms[4],
        tenderNumber: 'TN/2023/PUVVNL/005',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2023/005',
          fdrDate: now.subtract(const Duration(days: 365)),
          fdrAmount: 8500000,
          roi: 7.2,
        ),
        status: BgStatus.active,
        extensionHistory: [
          _createExtension(
            extensionDate: now.subtract(const Duration(days: 180)),
            newBgExpiryDate: now.subtract(const Duration(days: 30)),
            newClaimExpiryDate: now,
            remarks: 'First extension',
          ),
          _createExtension(
            extensionDate: now.subtract(const Duration(days: 30)),
            newBgExpiryDate: now.add(const Duration(days: 200)),
            newClaimExpiryDate: now.add(const Duration(days: 230)),
            remarks: 'Second extension',
          ),
        ],
      ),
      _createBg(
        bgNumber: 'BG/2024/006',
        issueDate: now.subtract(const Duration(days: 60)),
        amount: 1200000,
        expiryDate: now.add(const Duration(days: 300)),
        claimExpiryDate: now.add(const Duration(days: 330)),
        bankName: _banks[5],
        discom: _discoms[5],
        tenderNumber: 'TN/2024/KESCO/006',
        status: BgStatus.active,
      ),
      _createBg(
        bgNumber: 'BG/2024/007',
        issueDate: now.subtract(const Duration(days: 120)),
        amount: 4500000,
        expiryDate: now.add(const Duration(days: 5)),
        claimExpiryDate: now.add(const Duration(days: 35)),
        bankName: _banks[6],
        discom: _discoms[6],
        tenderNumber: 'TN/2024/TORRENT/007',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2024/007',
          fdrDate: now.subtract(const Duration(days: 120)),
          fdrAmount: 4700000,
          roi: 6.5,
        ),
        status: BgStatus.active,
      ),
      // Released BGs
      _createBg(
        bgNumber: 'BG/2023/008',
        issueDate: now.subtract(const Duration(days: 400)),
        amount: 2000000,
        expiryDate: now.subtract(const Duration(days: 30)),
        claimExpiryDate: now,
        bankName: _banks[7],
        discom: _discoms[7],
        tenderNumber: 'TN/2023/TATA/008',
        status: BgStatus.released,
      ),
      _createBg(
        bgNumber: 'BG/2023/009',
        issueDate: now.subtract(const Duration(days: 500)),
        amount: 3000000,
        expiryDate: now.subtract(const Duration(days: 100)),
        claimExpiryDate: now.subtract(const Duration(days: 70)),
        bankName: _banks[0],
        discom: _discoms[1],
        tenderNumber: 'TN/2023/PVVNL/009',
        status: BgStatus.released,
      ),
      _createBg(
        bgNumber: 'BG/2023/010',
        issueDate: now.subtract(const Duration(days: 450)),
        amount: 1800000,
        expiryDate: now.subtract(const Duration(days: 60)),
        claimExpiryDate: now.subtract(const Duration(days: 30)),
        bankName: _banks[1],
        discom: _discoms[2],
        tenderNumber: 'TN/2023/DVVNL/010',
        status: BgStatus.released,
      ),
      // More active BGs for filtering demo
      _createBg(
        bgNumber: 'BG/2024/011',
        issueDate: now.subtract(const Duration(days: 45)),
        amount: 6500000,
        expiryDate: now.add(const Duration(days: 40)),
        claimExpiryDate: now.add(const Duration(days: 70)),
        bankName: _banks[2],
        discom: _discoms[0],
        tenderNumber: 'TN/2024/UPPCL/011',
        fdrDetails: _createFdr(
          fdrNumber: 'FDR/2024/011',
          fdrDate: now.subtract(const Duration(days: 45)),
          fdrAmount: 6800000,
          roi: 7.0,
        ),
        status: BgStatus.active,
      ),
      _createBg(
        bgNumber: 'BG/2024/012',
        issueDate: now.subtract(const Duration(days: 30)),
        amount: 2200000,
        expiryDate: now.add(const Duration(days: 180)),
        claimExpiryDate: now.add(const Duration(days: 210)),
        bankName: _banks[3],
        discom: _discoms[0],
        tenderNumber: 'TN/2024/UPPCL/012',
        status: BgStatus.active,
      ),
    ];

    // Save all dummy BGs
    for (final bg in dummyBgs) {
      await HiveService.addBg(bg);
    }
  }

  static BgModel _createBg({
    required String bgNumber,
    required DateTime issueDate,
    required double amount,
    required DateTime expiryDate,
    required DateTime claimExpiryDate,
    required String bankName,
    required String discom,
    required String tenderNumber,
    FdrModel? fdrDetails,
    BgStatus status = BgStatus.active,
    List<ExtensionModel>? extensionHistory,
    List<DocumentModel>? documents,
  }) {
    return BgModel(
      id: _uuid.v4(),
      bgNumber: bgNumber,
      issueDate: issueDate,
      amount: amount,
      expiryDate: expiryDate,
      claimExpiryDate: claimExpiryDate,
      bankName: bankName,
      discom: discom,
      tenderNumber: tenderNumber,
      status: status,
      extensionHistory: extensionHistory ?? [],
      documents: documents ?? [],
      fdrDetails: fdrDetails,
      createdAt: issueDate,
      updatedAt: DateTime.now(),
    );
  }

  static FdrModel _createFdr({
    required String fdrNumber,
    required DateTime fdrDate,
    required double fdrAmount,
    required double roi,
  }) {
    return FdrModel(
      id: _uuid.v4(),
      fdrNumber: fdrNumber,
      fdrDate: fdrDate,
      fdrAmount: fdrAmount,
      roi: roi,
    );
  }

  static ExtensionModel _createExtension({
    required DateTime extensionDate,
    required DateTime newBgExpiryDate,
    required DateTime newClaimExpiryDate,
    String? remarks,
  }) {
    return ExtensionModel(
      id: _uuid.v4(),
      extensionDate: extensionDate,
      newBgExpiryDate: newBgExpiryDate,
      newClaimExpiryDate: newClaimExpiryDate,
      remarks: remarks,
    );
  }
}
