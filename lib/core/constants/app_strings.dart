class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'BG Manager';
  static const String appFullName = 'Bank Guarantee Management System';
  static const String appVersion = '1.0.0';

  // Navigation
  static const String dashboard = 'Dashboard';
  static const String bgManagement = 'BG Management';
  static const String fdrManagement = 'FDR Management';
  static const String documents = 'Documents';
  static const String reports = 'Reports';
  static const String settings = 'Settings';

  // Dashboard Cards
  static const String totalBgNumbers = 'Total BG Numbers';
  static const String expiryDue = 'Expiry Due';
  static const String totalBgReleased = 'Total BG Released';
  static const String totalBgAmount = 'Total BG Amount';
  static const String totalFdrAmount = 'Total FDR Amount';
  static const String activeBgs = 'Active BGs';
  static const String next50Days = 'Next 50 Days';
  static const String releasedBgs = 'Released BGs';

  // BG Table Headers
  static const String srNo = 'Sr. No.';
  static const String bgNumber = 'BG Number';
  static const String bgIssueDate = 'BG Issue Date';
  static const String bgAmount = 'BG Amount';
  static const String bgExpiryDate = 'BG Expiry Date';
  static const String bgClaimExpiryDate = 'Claim Expiry Date';
  static const String discom = 'Discom';
  static const String tenderNo = 'TN / Tender No.';
  static const String bankName = 'Bank Name';

  // BG Status
  static const String active = 'Active';
  static const String expired = 'Expired';
  static const String released = 'Released';

  // BG Details Sections
  static const String bgDetails = 'BG Details';
  static const String fdrDetails = 'FDR Details';
  static const String extensionHistory = 'Extension History';
  static const String documentsSection = 'Documents';

  // FDR Fields
  static const String fdrNumber = 'FDR Number';
  static const String fdrDate = 'FDR Date';
  static const String fdrAmount = 'FDR Amount';
  static const String fdrRoi = 'FDR ROI (%)';

  // Extension Fields
  static const String extensionDate = 'Extension Date';
  static const String newBgExpiryDate = 'New BG Expiry Date';
  static const String newClaimExpiryDate = 'New Claim Expiry Date';
  static const String extendedTimes = 'Extended Times';

  // Document Types
  static const String originalBgCopy = 'Original BG Copy';
  static const String extendedBgCopy = 'Extended BG Copy';
  static const String releaseLetter = 'Release Letter';

  // Actions
  static const String add = 'Add';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String extend = 'Extend';
  static const String release = 'Release';
  static const String upload = 'Upload';
  static const String download = 'Download';
  static const String preview = 'Preview';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clearFilters = 'Clear Filters';
  static const String export = 'Export';
  static const String refresh = 'Refresh';

  // Filters
  static const String expiredBg = 'Expired BG';
  static const String expiryDueBg = 'Expiry Due BG';
  static const String releasedBg = 'Released BG';
  static const String bankWise = 'Bank-wise';
  static const String discomWise = 'Discom-wise';

  // Messages
  static const String noDataFound = 'No data found';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String confirmDelete =
      'Are you sure you want to delete this item?';
  static const String bgAddedSuccess = 'BG added successfully';
  static const String bgUpdatedSuccess = 'BG updated successfully';
  static const String bgDeletedSuccess = 'BG deleted successfully';
  static const String bgExtendedSuccess = 'BG extended successfully';
  static const String bgReleasedSuccess = 'BG released successfully';
  static const String documentUploadedSuccess =
      'Document uploaded successfully';

  // Validation
  static const String required = 'This field is required';
  static const String invalidAmount = 'Please enter a valid amount';
  static const String invalidDate = 'Please enter a valid date';
  static const String invalidNumber = 'Please enter a valid number';

  // Empty States
  static const String noBgsFound = 'No Bank Guarantees Found';
  static const String noBgsFoundDesc = 'Add your first BG to get started';
  static const String noFdrsFound = 'No FDRs Found';
  static const String noDocumentsFound = 'No Documents Found';
  static const String noExtensionsFound = 'No Extensions Found';

  // Search Placeholders
  static const String searchBg =
      'Search by BG Number, Bank, Discom, or Tender No...';
  static const String searchDocuments = 'Search documents...';
}
