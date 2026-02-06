import 'package:hive/hive.dart';

part 'bg_model.g.dart';

@HiveType(typeId: 0)
enum BgStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  expired,
  @HiveField(2)
  released,
}

@HiveType(typeId: 1)
class BgModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bgNumber;

  @HiveField(2)
  final DateTime issueDate;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime expiryDate;

  @HiveField(5)
  final DateTime claimExpiryDate;

  @HiveField(6)
  final String bankName;

  @HiveField(7)
  final String discom;

  @HiveField(8)
  final String tenderNumber;

  @HiveField(9)
  final BgStatus status;

  @HiveField(10)
  final List<ExtensionModel> extensionHistory;

  @HiveField(11)
  final List<DocumentModel> documents;

  @HiveField(12)
  final FdrModel? fdrDetails;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final String firmName;

  BgModel({
    required this.id,
    required this.bgNumber,
    required this.issueDate,
    required this.amount,
    required this.expiryDate,
    required this.claimExpiryDate,
    required this.bankName,
    required this.discom,
    required this.tenderNumber,
    this.status = BgStatus.active,
    this.extensionHistory = const [],
    this.documents = const [],
    this.fdrDetails,
    required this.createdAt,
    required this.updatedAt,
    this.firmName = 'DoonInfra',
  });

  BgModel copyWith({
    String? id,
    String? bgNumber,
    DateTime? issueDate,
    double? amount,
    DateTime? expiryDate,
    DateTime? claimExpiryDate,
    String? bankName,
    String? discom,
    String? tenderNumber,
    BgStatus? status,
    List<ExtensionModel>? extensionHistory,
    List<DocumentModel>? documents,
    FdrModel? fdrDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firmName,
  }) {
    return BgModel(
      id: id ?? this.id,
      bgNumber: bgNumber ?? this.bgNumber,
      issueDate: issueDate ?? this.issueDate,
      amount: amount ?? this.amount,
      expiryDate: expiryDate ?? this.expiryDate,
      claimExpiryDate: claimExpiryDate ?? this.claimExpiryDate,
      bankName: bankName ?? this.bankName,
      discom: discom ?? this.discom,
      tenderNumber: tenderNumber ?? this.tenderNumber,
      status: status ?? this.status,
      extensionHistory: extensionHistory ?? this.extensionHistory,
      documents: documents ?? this.documents,
      fdrDetails: fdrDetails ?? this.fdrDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firmName: firmName ?? this.firmName,
    );
  }

  // Check if BG is expiring within given days
  bool isExpiringWithinDays(int days) {
    if (status != BgStatus.active) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return daysUntilExpiry >= 0 && daysUntilExpiry <= days;
  }

  // Check if BG is expired
  bool get isExpired {
    if (status == BgStatus.released) return false;
    return DateTime.now().isAfter(expiryDate);
  }

  // Get current expiry date (considering extensions)
  DateTime get currentExpiryDate {
    if (extensionHistory.isEmpty) return expiryDate;
    return extensionHistory.last.newBgExpiryDate;
  }

  // Get current claim expiry date (considering extensions)
  DateTime get currentClaimExpiryDate {
    if (extensionHistory.isEmpty) return claimExpiryDate;
    return extensionHistory.last.newClaimExpiryDate;
  }

  // Get number of extensions
  int get extensionCount => extensionHistory.length;

  // Get days until expiry
  int get daysUntilExpiry {
    final now = DateTime.now();
    return currentExpiryDate.difference(now).inDays;
  }
}

@HiveType(typeId: 2)
class FdrModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fdrNumber;

  @HiveField(2)
  final DateTime fdrDate;

  @HiveField(3)
  final double fdrAmount;

  @HiveField(4)
  final double roi; // Rate of Interest in percentage

  @HiveField(5)
  final String? bankName;

  @HiveField(6)
  final DateTime? maturityDate;

  FdrModel({
    required this.id,
    required this.fdrNumber,
    required this.fdrDate,
    required this.fdrAmount,
    required this.roi,
    this.bankName,
    this.maturityDate,
  });

  FdrModel copyWith({
    String? id,
    String? fdrNumber,
    DateTime? fdrDate,
    double? fdrAmount,
    double? roi,
    String? bankName,
    DateTime? maturityDate,
  }) {
    return FdrModel(
      id: id ?? this.id,
      fdrNumber: fdrNumber ?? this.fdrNumber,
      fdrDate: fdrDate ?? this.fdrDate,
      fdrAmount: fdrAmount ?? this.fdrAmount,
      roi: roi ?? this.roi,
      bankName: bankName ?? this.bankName,
      maturityDate: maturityDate ?? this.maturityDate,
    );
  }
}

@HiveType(typeId: 3)
class ExtensionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime extensionDate;

  @HiveField(2)
  final DateTime newBgExpiryDate;

  @HiveField(3)
  final DateTime newClaimExpiryDate;

  @HiveField(4)
  final String? remarks;

  @HiveField(5)
  final String? documentId; // Reference to the extended BG copy document

  ExtensionModel({
    required this.id,
    required this.extensionDate,
    required this.newBgExpiryDate,
    required this.newClaimExpiryDate,
    this.remarks,
    this.documentId,
  });

  ExtensionModel copyWith({
    String? id,
    DateTime? extensionDate,
    DateTime? newBgExpiryDate,
    DateTime? newClaimExpiryDate,
    String? remarks,
    String? documentId,
  }) {
    return ExtensionModel(
      id: id ?? this.id,
      extensionDate: extensionDate ?? this.extensionDate,
      newBgExpiryDate: newBgExpiryDate ?? this.newBgExpiryDate,
      newClaimExpiryDate: newClaimExpiryDate ?? this.newClaimExpiryDate,
      remarks: remarks ?? this.remarks,
      documentId: documentId ?? this.documentId,
    );
  }
}

@HiveType(typeId: 4)
enum DocumentType {
  @HiveField(0)
  originalBgCopy,
  @HiveField(1)
  extendedBgCopy,
  @HiveField(2)
  releaseLetter,
  @HiveField(3)
  other,
}

@HiveType(typeId: 5)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DocumentType type;

  @HiveField(2)
  final int version;

  @HiveField(3)
  final DateTime uploadDate;

  @HiveField(4)
  final String filePath;

  @HiveField(5)
  final String fileName;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final int? fileSizeBytes;

  DocumentModel({
    required this.id,
    required this.type,
    this.version = 1,
    required this.uploadDate,
    required this.filePath,
    required this.fileName,
    this.description,
    this.fileSizeBytes,
  });

  DocumentModel copyWith({
    String? id,
    DocumentType? type,
    int? version,
    DateTime? uploadDate,
    String? filePath,
    String? fileName,
    String? description,
    int? fileSizeBytes,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      version: version ?? this.version,
      uploadDate: uploadDate ?? this.uploadDate,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      description: description ?? this.description,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case DocumentType.originalBgCopy:
        return 'Original BG Copy';
      case DocumentType.extendedBgCopy:
        return 'Extended BG Copy';
      case DocumentType.releaseLetter:
        return 'Release Letter';
      case DocumentType.other:
        return 'Other';
    }
  }
}
