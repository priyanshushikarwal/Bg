// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bg_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BgModelAdapter extends TypeAdapter<BgModel> {
  @override
  final int typeId = 1;

  @override
  BgModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BgModel(
      id: fields[0] as String,
      bgNumber: fields[1] as String,
      issueDate: fields[2] as DateTime,
      amount: fields[3] as double,
      expiryDate: fields[4] as DateTime,
      claimExpiryDate: fields[5] as DateTime,
      bankName: fields[6] as String,
      discom: fields[7] as String,
      tenderNumber: fields[8] as String,
      status: fields[9] as BgStatus,
      extensionHistory: (fields[10] as List).cast<ExtensionModel>(),
      documents: (fields[11] as List).cast<DocumentModel>(),
      fdrDetails: fields[12] as FdrModel?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BgModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bgNumber)
      ..writeByte(2)
      ..write(obj.issueDate)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.claimExpiryDate)
      ..writeByte(6)
      ..write(obj.bankName)
      ..writeByte(7)
      ..write(obj.discom)
      ..writeByte(8)
      ..write(obj.tenderNumber)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.extensionHistory)
      ..writeByte(11)
      ..write(obj.documents)
      ..writeByte(12)
      ..write(obj.fdrDetails)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BgModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FdrModelAdapter extends TypeAdapter<FdrModel> {
  @override
  final int typeId = 2;

  @override
  FdrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FdrModel(
      id: fields[0] as String,
      fdrNumber: fields[1] as String,
      fdrDate: fields[2] as DateTime,
      fdrAmount: fields[3] as double,
      roi: fields[4] as double,
      bankName: fields[5] as String?,
      maturityDate: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FdrModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fdrNumber)
      ..writeByte(2)
      ..write(obj.fdrDate)
      ..writeByte(3)
      ..write(obj.fdrAmount)
      ..writeByte(4)
      ..write(obj.roi)
      ..writeByte(5)
      ..write(obj.bankName)
      ..writeByte(6)
      ..write(obj.maturityDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FdrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExtensionModelAdapter extends TypeAdapter<ExtensionModel> {
  @override
  final int typeId = 3;

  @override
  ExtensionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExtensionModel(
      id: fields[0] as String,
      extensionDate: fields[1] as DateTime,
      newBgExpiryDate: fields[2] as DateTime,
      newClaimExpiryDate: fields[3] as DateTime,
      remarks: fields[4] as String?,
      documentId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExtensionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.extensionDate)
      ..writeByte(2)
      ..write(obj.newBgExpiryDate)
      ..writeByte(3)
      ..write(obj.newClaimExpiryDate)
      ..writeByte(4)
      ..write(obj.remarks)
      ..writeByte(5)
      ..write(obj.documentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtensionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentModelAdapter extends TypeAdapter<DocumentModel> {
  @override
  final int typeId = 5;

  @override
  DocumentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentModel(
      id: fields[0] as String,
      type: fields[1] as DocumentType,
      version: fields[2] as int,
      uploadDate: fields[3] as DateTime,
      filePath: fields[4] as String,
      fileName: fields[5] as String,
      description: fields[6] as String?,
      fileSizeBytes: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(3)
      ..write(obj.uploadDate)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.fileName)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.fileSizeBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BgStatusAdapter extends TypeAdapter<BgStatus> {
  @override
  final int typeId = 0;

  @override
  BgStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BgStatus.active;
      case 1:
        return BgStatus.expired;
      case 2:
        return BgStatus.released;
      default:
        return BgStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, BgStatus obj) {
    switch (obj) {
      case BgStatus.active:
        writer.writeByte(0);
        break;
      case BgStatus.expired:
        writer.writeByte(1);
        break;
      case BgStatus.released:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BgStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 4;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.originalBgCopy;
      case 1:
        return DocumentType.extendedBgCopy;
      case 2:
        return DocumentType.releaseLetter;
      case 3:
        return DocumentType.other;
      default:
        return DocumentType.originalBgCopy;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.originalBgCopy:
        writer.writeByte(0);
        break;
      case DocumentType.extendedBgCopy:
        writer.writeByte(1);
        break;
      case DocumentType.releaseLetter:
        writer.writeByte(2);
        break;
      case DocumentType.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
