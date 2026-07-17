import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bg_model.dart';
import '../../data/repositories/bg_repository.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/supabase_service.dart';

final bgRepositoryProvider = Provider<BgRepository>((ref) {
  return BgRepository();
});

enum BgFilterType { all, active, expired, released, expiringWithin50Days }

List<String> get availableFirms => SettingsService.firms;

class BgFilterState {
  final BgFilterType filterType;
  final String? bankFilter;
  final String? discomFilter;
  final String searchQuery;
  final String? firmFilter;

  const BgFilterState({
    this.filterType = BgFilterType.all,
    this.bankFilter,
    this.discomFilter,
    this.searchQuery = '',
    this.firmFilter,
  });

  BgFilterState copyWith({
    BgFilterType? filterType,
    String? bankFilter,
    String? discomFilter,
    String? searchQuery,
    String? firmFilter,
    bool clearBankFilter = false,
    bool clearDiscomFilter = false,
    bool clearFirmFilter = false,
  }) {
    return BgFilterState(
      filterType: filterType ?? this.filterType,
      bankFilter: clearBankFilter ? null : (bankFilter ?? this.bankFilter),
      discomFilter: clearDiscomFilter
          ? null
          : (discomFilter ?? this.discomFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      firmFilter: clearFirmFilter ? null : (firmFilter ?? this.firmFilter),
    );
  }

  bool get hasActiveFilters =>
      filterType != BgFilterType.all ||
      bankFilter != null ||
      discomFilter != null ||
      searchQuery.isNotEmpty ||
      firmFilter != null;
}

final bgFilterProvider = StateNotifierProvider<BgFilterNotifier, BgFilterState>(
  (ref) {
    return BgFilterNotifier();
  },
);

class BgFilterNotifier extends StateNotifier<BgFilterState> {
  BgFilterNotifier() : super(const BgFilterState());

  void setFilterType(BgFilterType type) {
    state = state.copyWith(filterType: type);
  }

  void setBankFilter(String? bank) {
    if (bank == null) {
      state = state.copyWith(clearBankFilter: true);
    } else {
      state = state.copyWith(bankFilter: bank);
    }
  }

  void setDiscomFilter(String? discom) {
    if (discom == null) {
      state = state.copyWith(clearDiscomFilter: true);
    } else {
      state = state.copyWith(discomFilter: discom);
    }
  }

  void setFirmFilter(String? firm) {
    if (firm == null) {
      state = state.copyWith(clearFirmFilter: true);
    } else {
      state = state.copyWith(firmFilter: firm);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const BgFilterState();
  }
}

final allBgsProvider = FutureProvider<List<BgModel>>((ref) async {
  final repository = ref.watch(bgRepositoryProvider);
  return repository.getAllBgs();
});

final filteredBgsProvider = Provider<AsyncValue<List<BgModel>>>((ref) {
  final allBgsAsync = ref.watch(allBgsProvider);
  final filterState = ref.watch(bgFilterProvider);

  return allBgsAsync.whenData((allBgs) {
    List<BgModel> filtered = allBgs;

    if (filterState.firmFilter != null) {
      filtered = filtered
          .where((bg) => bg.firmName == filterState.firmFilter)
          .toList();
    }

    switch (filterState.filterType) {
      case BgFilterType.active:
        filtered = filtered
            .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
            .toList();
        break;
      case BgFilterType.expired:
        filtered = filtered
            .where((bg) => bg.isExpired || bg.status == BgStatus.expired)
            .toList();
        break;
      case BgFilterType.released:
        filtered = filtered
            .where((bg) => bg.status == BgStatus.released)
            .toList();
        break;
      case BgFilterType.expiringWithin50Days:
        filtered = filtered.where((bg) => bg.isExpiringWithinDays(50)).toList();
        break;
      case BgFilterType.all:
        break;
    }

    if (filterState.bankFilter != null) {
      filtered = filtered
          .where((bg) =>
              bg.bankName.trim().toLowerCase() ==
              filterState.bankFilter!.trim().toLowerCase())
          .toList();
    }

    if (filterState.discomFilter != null) {
      filtered = filtered
          .where((bg) =>
              bg.discom.trim().toLowerCase() ==
              filterState.discomFilter!.trim().toLowerCase())
          .toList();
    }

    if (filterState.searchQuery.isNotEmpty) {
      final query = filterState.searchQuery.toLowerCase();
      filtered = filtered.where((bg) {
        return bg.bgNumber.toLowerCase().contains(query) ||
            bg.bankName.toLowerCase().contains(query) ||
            bg.discom.toLowerCase().contains(query) ||
            bg.tenderNumber.toLowerCase().contains(query) ||
            bg.firmName.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => a.currentExpiryDate.compareTo(b.currentExpiryDate));

    return filtered;
  });
});

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final allBgsAsync = ref.watch(allBgsProvider);
  final filterState = ref.watch(bgFilterProvider);

  return allBgsAsync.whenData((allBgs) {
    var bgs = allBgs;

    if (filterState.firmFilter != null) {
      bgs = bgs.where((bg) => bg.firmName == filterState.firmFilter).toList();
    }

    if (filterState.bankFilter != null) {
      bgs = bgs
          .where((bg) =>
              bg.bankName.trim().toLowerCase() ==
              filterState.bankFilter!.trim().toLowerCase())
          .toList();
    }

    if (filterState.discomFilter != null) {
      bgs = bgs
          .where((bg) =>
              bg.discom.trim().toLowerCase() ==
              filterState.discomFilter!.trim().toLowerCase())
          .toList();
    }

    if (filterState.searchQuery.isNotEmpty) {
      final query = filterState.searchQuery.toLowerCase();
      bgs = bgs.where((bg) {
        return bg.bgNumber.toLowerCase().contains(query) ||
            bg.bankName.toLowerCase().contains(query) ||
            bg.discom.toLowerCase().contains(query) ||
            bg.tenderNumber.toLowerCase().contains(query) ||
            bg.firmName.toLowerCase().contains(query);
      }).toList();
    }

    final activeBgs = bgs
        .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
        .toList();
    final expiringBgs = bgs.where((bg) => bg.isExpiringWithinDays(50)).toList();
    final releasedBgs = bgs
        .where((bg) => bg.status == BgStatus.released)
        .toList();

    final totalBgAmount = activeBgs.fold<double>(
      0,
      (sum, bg) => sum + bg.amount,
    );
    final totalFdrAmount = bgs
        .where((bg) => bg.fdrDetails != null)
        .fold<double>(0, (sum, bg) => sum + (bg.fdrDetails?.fdrAmount ?? 0));

    return DashboardStats(
      totalBgCount: activeBgs.length,
      expiringBgCount: expiringBgs.length,
      releasedBgCount: releasedBgs.length,
      totalBgAmount: totalBgAmount,
      totalFdrAmount: totalFdrAmount,
    );
  });
});

class DashboardStats {
  final int totalBgCount;
  final int expiringBgCount;
  final int releasedBgCount;
  final double totalBgAmount;
  final double totalFdrAmount;

  const DashboardStats({
    required this.totalBgCount,
    required this.expiringBgCount,
    required this.releasedBgCount,
    required this.totalBgAmount,
    required this.totalFdrAmount,
  });
}

final bankNamesProvider = Provider<AsyncValue<Set<String>>>((ref) {
  final allBgsAsync = ref.watch(allBgsProvider);
  final filterState = ref.watch(bgFilterProvider);

  return allBgsAsync.whenData((allBgs) {
    final uniqueBanks = <String>{};
    final lowercaseSeen = <String>{};
    for (final bg in allBgs) {
      if (filterState.firmFilter != null &&
          bg.firmName != filterState.firmFilter) {
        continue;
      }
      final name = bg.bankName.trim();
      if (name.isNotEmpty && lowercaseSeen.add(name.toLowerCase())) {
        uniqueBanks.add(name);
      }
    }
    return uniqueBanks;
  });
});

final discomNamesProvider = Provider<AsyncValue<Set<String>>>((ref) {
  final allBgsAsync = ref.watch(allBgsProvider);
  final filterState = ref.watch(bgFilterProvider);

  return allBgsAsync.whenData((allBgs) {
    final uniqueDiscoms = <String>{};
    final lowercaseSeen = <String>{};
    for (final bg in allBgs) {
      if (filterState.firmFilter != null &&
          bg.firmName != filterState.firmFilter) {
        continue;
      }
      final name = bg.discom.trim();
      if (name.isNotEmpty && lowercaseSeen.add(name.toLowerCase())) {
        uniqueDiscoms.add(name);
      }
    }
    return uniqueDiscoms;
  });
});

final firmNamesProvider = StateNotifierProvider<FirmNamesNotifier, List<String>>((ref) {
  final notifier = FirmNamesNotifier();
  notifier.loadFromSupabase(); // Auto-sync on startup
  return notifier;
});

class FirmNamesNotifier extends StateNotifier<List<String>> {
  FirmNamesNotifier() : super(SettingsService.firms);

  void refresh() {
    state = SettingsService.firms;
  }

  /// Fetch firms from Supabase and merge with local.
  Future<void> loadFromSupabase() async {
    try {
      final remoteFirms = await SupabaseService.fetchFirms();
      if (remoteFirms.isNotEmpty) {
        final localFirms = SettingsService.firms;
        final mergedNames = <String>{...localFirms};

        for (final rf in remoteFirms) {
          final name = rf['name'] as String? ?? '';
          if (name.isEmpty) continue;
          mergedNames.add(name);

          // Also save details locally from Supabase
          await SettingsService.saveFirmDetails(
            FirmDetails(
              name: name,
              address: rf['address'] as String? ?? '',
              email: rf['email'] as String? ?? '',
              mobile: rf['mobile'] as String? ?? '',
            ),
          );
        }

        // Save merged list locally
        for (final name in mergedNames) {
          await SettingsService.addFirm(name);
        }
        state = SettingsService.firms;
      } else {
        // No remote firms — push local firms to Supabase
        final localFirms = SettingsService.firms;
        for (final name in localFirms) {
          final details = SettingsService.getFirmDetails(name);
          await SupabaseService.upsertFirm(
            name: name,
            address: details.address,
            email: details.email,
            mobile: details.mobile,
          );
        }
      }
    } catch (e) {
      // Silently fail — local data still works
      debugPrint('⚠️ Firm sync failed: $e');
    }
  }

  Future<void> addFirm(String name) async {
    await SettingsService.addFirm(name);
    state = SettingsService.firms;
    // Sync to Supabase
    final details = SettingsService.getFirmDetails(name);
    await SupabaseService.upsertFirm(
      name: name,
      address: details.address,
      email: details.email,
      mobile: details.mobile,
    );
  }

  Future<void> removeFirm(String name) async {
    await SettingsService.removeFirm(name);
    state = SettingsService.firms;
    // Sync to Supabase
    await SupabaseService.deleteFirm(name);
  }

  /// Save firm details and sync to Supabase.
  Future<void> saveFirmDetails(FirmDetails details) async {
    await SettingsService.saveFirmDetails(details);
    state = SettingsService.firms;
    // Sync to Supabase
    await SupabaseService.upsertFirm(
      name: details.name,
      address: details.address,
      email: details.email,
      mobile: details.mobile,
    );
  }
}

final selectedBgIdProvider = StateProvider<String?>((ref) => null);

final selectedBgProvider = FutureProvider<BgModel?>((ref) async {
  final selectedId = ref.watch(selectedBgIdProvider);
  if (selectedId == null) return null;
  final repository = ref.watch(bgRepositoryProvider);
  return repository.getBgById(selectedId);
});

final expandedBgIdsProvider =
    StateNotifierProvider<ExpandedBgIdsNotifier, Set<String>>((ref) {
      return ExpandedBgIdsNotifier();
    });

class ExpandedBgIdsNotifier extends StateNotifier<Set<String>> {
  ExpandedBgIdsNotifier() : super({});

  void toggle(String id) {
    if (state.contains(id)) {
      state = Set.from(state)..remove(id);
    } else {
      state = Set.from(state)..add(id);
    }
  }

  void expand(String id) {
    state = Set.from(state)..add(id);
  }

  void collapse(String id) {
    state = Set.from(state)..remove(id);
  }

  void collapseAll() {
    state = {};
  }
}

enum AppScreen { dashboard, bgManagement, fdrManagement, documents, reports, settings }

final currentScreenProvider = StateProvider<AppScreen>(
  (ref) => AppScreen.dashboard,
);

class BgMutationNotifier extends StateNotifier<AsyncValue<void>> {
  final BgRepository _repository;
  final Ref _ref;

  BgMutationNotifier(this._repository, this._ref)
    : super(const AsyncData(null));

  Future<bool> addBg(BgModel bg) async {
    state = const AsyncLoading();
    try {
      await _repository.addBg(bg);
      _ref.invalidate(allBgsProvider);
      _ref.invalidate(dashboardStatsProvider);
      _ref.invalidate(bankNamesProvider);
      _ref.invalidate(discomNamesProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateBg(BgModel bg) async {
    state = const AsyncLoading();
    try {
      await _repository.updateBg(bg);
      _ref.invalidate(allBgsProvider);
      _ref.invalidate(dashboardStatsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteBg(String id) async {
    state = const AsyncLoading();
    try {
      await _repository.deleteBg(id);
      _ref.invalidate(allBgsProvider);
      _ref.invalidate(dashboardStatsProvider);
      _ref.invalidate(bankNamesProvider);
      _ref.invalidate(discomNamesProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> extendBg(String bgId, ExtensionModel extension) async {
    state = const AsyncLoading();
    try {
      await _repository.extendBg(bgId, extension);
      _ref.invalidate(allBgsProvider);
      _ref.invalidate(dashboardStatsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> releaseBg(String bgId) async {
    state = const AsyncLoading();
    try {
      await _repository.releaseBg(bgId);
      _ref.invalidate(allBgsProvider);
      _ref.invalidate(dashboardStatsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> addDocument(String bgId, DocumentModel document) async {
    state = const AsyncLoading();
    try {
      await _repository.addDocument(bgId, document);
      _ref.invalidate(allBgsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final bgMutationProvider =
    StateNotifierProvider<BgMutationNotifier, AsyncValue<void>>((ref) {
      return BgMutationNotifier(ref.watch(bgRepositoryProvider), ref);
    });
