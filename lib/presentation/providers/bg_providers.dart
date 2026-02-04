import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bg_model.dart';
import '../../data/repositories/bg_repository.dart';
import '../../data/datasources/hive_service.dart';

// Repository Provider
final bgRepositoryProvider = Provider<BgRepository>((ref) {
  return BgRepository();
});

// Filter State
enum BgFilterType { all, active, expired, released, expiringWithin50Days }

class BgFilterState {
  final BgFilterType filterType;
  final String? bankFilter;
  final String? discomFilter;
  final String searchQuery;

  const BgFilterState({
    this.filterType = BgFilterType.all,
    this.bankFilter,
    this.discomFilter,
    this.searchQuery = '',
  });

  BgFilterState copyWith({
    BgFilterType? filterType,
    String? bankFilter,
    String? discomFilter,
    String? searchQuery,
    bool clearBankFilter = false,
    bool clearDiscomFilter = false,
  }) {
    return BgFilterState(
      filterType: filterType ?? this.filterType,
      bankFilter: clearBankFilter ? null : (bankFilter ?? this.bankFilter),
      discomFilter: clearDiscomFilter
          ? null
          : (discomFilter ?? this.discomFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      filterType != BgFilterType.all ||
      bankFilter != null ||
      discomFilter != null ||
      searchQuery.isNotEmpty;
}

// Filter State Provider
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

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearFilters() {
    state = const BgFilterState();
  }
}

// All BGs Provider
final allBgsProvider = FutureProvider<List<BgModel>>((ref) async {
  final repository = ref.watch(bgRepositoryProvider);
  return repository.getAllBgs();
});

// Filtered BGs Provider
final filteredBgsProvider = Provider<AsyncValue<List<BgModel>>>((ref) {
  final allBgsAsync = ref.watch(allBgsProvider);
  final filterState = ref.watch(bgFilterProvider);

  return allBgsAsync.whenData((allBgs) {
    List<BgModel> filtered = allBgs;

    // Apply status filter
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

    // Apply bank filter
    if (filterState.bankFilter != null) {
      filtered = filtered
          .where((bg) => bg.bankName == filterState.bankFilter)
          .toList();
    }

    // Apply discom filter
    if (filterState.discomFilter != null) {
      filtered = filtered
          .where((bg) => bg.discom == filterState.discomFilter)
          .toList();
    }

    // Apply search query
    if (filterState.searchQuery.isNotEmpty) {
      final query = filterState.searchQuery.toLowerCase();
      filtered = filtered.where((bg) {
        return bg.bgNumber.toLowerCase().contains(query) ||
            bg.bankName.toLowerCase().contains(query) ||
            bg.discom.toLowerCase().contains(query) ||
            bg.tenderNumber.toLowerCase().contains(query);
      }).toList();
    }

    // Sort by expiry date
    filtered.sort((a, b) => a.currentExpiryDate.compareTo(b.currentExpiryDate));

    return filtered;
  });
});

// Dashboard Statistics Providers
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final allBgs = HiveService.getAllBgs();

  final activeBgs = allBgs
      .where((bg) => bg.status == BgStatus.active && !bg.isExpired)
      .toList();
  final expiringBgs = allBgs
      .where((bg) => bg.isExpiringWithinDays(50))
      .toList();
  final releasedBgs = allBgs
      .where((bg) => bg.status == BgStatus.released)
      .toList();

  final totalBgAmount = activeBgs.fold<double>(0, (sum, bg) => sum + bg.amount);
  final totalFdrAmount = allBgs
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

// Bank Names Provider
final bankNamesProvider = FutureProvider<Set<String>>((ref) async {
  return HiveService.getAllBankNames();
});

// Discom Names Provider
final discomNamesProvider = FutureProvider<Set<String>>((ref) async {
  return HiveService.getAllDiscoms();
});

// Selected BG Provider (for detail view)
final selectedBgIdProvider = StateProvider<String?>((ref) => null);

final selectedBgProvider = Provider<BgModel?>((ref) {
  final selectedId = ref.watch(selectedBgIdProvider);
  if (selectedId == null) return null;
  return HiveService.getBg(selectedId);
});

// Expanded BG Row Provider
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

// Navigation Provider
enum AppScreen { dashboard, bgManagement, fdrManagement, documents, reports }

final currentScreenProvider = StateProvider<AppScreen>(
  (ref) => AppScreen.dashboard,
);

// BG Mutation Provider
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
