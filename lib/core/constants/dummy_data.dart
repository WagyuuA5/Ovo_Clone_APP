import '../../data/models/contact_model.dart';
import '../../data/models/merchant_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/promo_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';

class DummyData {
  DummyData._();

  // ---------------------------------------------------------------------------
  // Current User
  // ---------------------------------------------------------------------------
  static final UserModel currentUser = UserModel(
    id: 'usr_001',
    name: 'Budi Santoso',
    phone: '081234567890',
    email: 'budi.santoso@email.com',
    avatarUrl: '',
    ovoBalance: 850000,
    ovoPoints: 1250,
    pin: '123456',
    isVerified: true,
    lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
  );

  // ---------------------------------------------------------------------------
  // Transactions (20 items)
  // ---------------------------------------------------------------------------
  static final List<TransactionModel> transactions = [
    // ── 5 Transfer Out ────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_001',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke Andi',
      subtitle: 'OVO Transfer • 082111222333',
      amount: 150000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: TransactionStatus.success,
      referenceId: 'REF001234',
      targetPhone: '082111222333',
      targetName: 'Andi Wijaya',
    ),
    TransactionModel(
      id: 'trx_002',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke Siti',
      subtitle: 'OVO Transfer • 085999888777',
      amount: 75000,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: TransactionStatus.success,
      referenceId: 'REF001235',
      targetPhone: '085999888777',
      targetName: 'Siti Rahayu',
    ),
    TransactionModel(
      id: 'trx_003',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke Reza',
      subtitle: 'OVO Transfer • 081333444555',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 5)),
      status: TransactionStatus.success,
      referenceId: 'REF001236',
      targetPhone: '081333444555',
      targetName: 'Reza Firmansyah',
    ),
    TransactionModel(
      id: 'trx_004',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke Maya',
      subtitle: 'OVO Transfer • 087666777888',
      amount: 50000,
      date: DateTime.now().subtract(const Duration(days: 8)),
      status: TransactionStatus.success,
      referenceId: 'REF001237',
      targetPhone: '087666777888',
      targetName: 'Maya Kusuma',
    ),
    TransactionModel(
      id: 'trx_005',
      type: TransactionType.transfer,
      direction: TransactionDirection.debit,
      title: 'Transfer ke Doni',
      subtitle: 'OVO Transfer • 089555666777',
      amount: 300000,
      date: DateTime.now().subtract(const Duration(days: 12)),
      status: TransactionStatus.success,
      referenceId: 'REF001238',
      targetPhone: '089555666777',
      targetName: 'Doni Prasetyo',
    ),

    // ── 3 Transfer In ─────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_006',
      type: TransactionType.transfer,
      direction: TransactionDirection.credit,
      title: 'Transfer dari Budi',
      subtitle: 'OVO Transfer • 082333444555',
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.success,
      referenceId: 'REF001239',
      targetPhone: '082333444555',
      targetName: 'Bimo Aditya',
    ),
    TransactionModel(
      id: 'trx_007',
      type: TransactionType.transfer,
      direction: TransactionDirection.credit,
      title: 'Transfer dari Citra',
      subtitle: 'OVO Transfer • 082777888999',
      amount: 125000,
      date: DateTime.now().subtract(const Duration(days: 6)),
      status: TransactionStatus.success,
      referenceId: 'REF001240',
      targetPhone: '082777888999',
      targetName: 'Citra Dewi',
    ),
    TransactionModel(
      id: 'trx_008',
      type: TransactionType.transfer,
      direction: TransactionDirection.credit,
      title: 'Transfer dari Hendra',
      subtitle: 'OVO Transfer • 085111222333',
      amount: 250000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      status: TransactionStatus.success,
      referenceId: 'REF001241',
      targetPhone: '085111222333',
      targetName: 'Hendra Gunawan',
    ),

    // ── 3 Top Up ──────────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_009',
      type: TransactionType.topup,
      direction: TransactionDirection.credit,
      title: 'Top Up OVO',
      subtitle: 'Via BCA',
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 4)),
      status: TransactionStatus.success,
      referenceId: 'REF001242',
    ),
    TransactionModel(
      id: 'trx_010',
      type: TransactionType.topup,
      direction: TransactionDirection.credit,
      title: 'Top Up OVO',
      subtitle: 'Via Mandiri',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 9)),
      status: TransactionStatus.success,
      referenceId: 'REF001243',
    ),
    TransactionModel(
      id: 'trx_011',
      type: TransactionType.topup,
      direction: TransactionDirection.credit,
      title: 'Top Up OVO',
      subtitle: 'Via BRI',
      amount: 100000,
      date: DateTime.now().subtract(const Duration(days: 14)),
      status: TransactionStatus.success,
      referenceId: 'REF001244',
    ),

    // ── 2 PLN Payments ────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_012',
      type: TransactionType.pln,
      direction: TransactionDirection.debit,
      title: 'PLN Prabayar',
      subtitle: 'No. Meter: 12345678901',
      amount: 100000,
      date: DateTime.now().subtract(const Duration(days: 7)),
      status: TransactionStatus.success,
      referenceId: 'REF001245',
      note: 'Token PLN berhasil dikirim',
    ),
    TransactionModel(
      id: 'trx_013',
      type: TransactionType.pln,
      direction: TransactionDirection.debit,
      title: 'PLN Prabayar',
      subtitle: 'No. Meter: 98765432109',
      amount: 200000,
      date: DateTime.now().subtract(const Duration(days: 22)),
      status: TransactionStatus.success,
      referenceId: 'REF001246',
      note: 'Token PLN berhasil dikirim',
    ),

    // ── 2 Pulsa / Internet Payments ───────────────────────────────────────────
    TransactionModel(
      id: 'trx_014',
      type: TransactionType.pulsa,
      direction: TransactionDirection.debit,
      title: 'Pulsa Telkomsel',
      subtitle: '081234567890 • 50.000',
      amount: 52000,
      date: DateTime.now().subtract(const Duration(days: 11)),
      status: TransactionStatus.success,
      referenceId: 'REF001247',
      targetPhone: '081234567890',
    ),
    TransactionModel(
      id: 'trx_015',
      type: TransactionType.internet,
      direction: TransactionDirection.debit,
      title: 'Paket Internet XL',
      subtitle: '081234567890 • 10GB/30 Hari',
      amount: 85000,
      date: DateTime.now().subtract(const Duration(days: 18)),
      status: TransactionStatus.success,
      referenceId: 'REF001248',
      targetPhone: '081234567890',
    ),

    // ── 2 Merchant Payments ───────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_016',
      type: TransactionType.payment,
      direction: TransactionDirection.debit,
      title: 'Indomaret',
      subtitle: 'OVO Payment • Ritel',
      amount: 87500,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.success,
      referenceId: 'REF001249',
      note: 'Belanja kebutuhan sehari-hari',
    ),
    TransactionModel(
      id: 'trx_017',
      type: TransactionType.payment,
      direction: TransactionDirection.debit,
      title: 'Grab',
      subtitle: 'OVO Payment • Transport',
      amount: 35000,
      date: DateTime.now().subtract(const Duration(days: 15)),
      status: TransactionStatus.success,
      referenceId: 'REF001250',
      note: 'GrabCar perjalanan ke kantor',
    ),

    // ── 2 Cashback ────────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_018',
      type: TransactionType.cashback,
      direction: TransactionDirection.credit,
      title: 'Cashback Indomaret',
      subtitle: 'Cashback 10% • Maks Rp 5.000',
      amount: 5000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.success,
      referenceId: 'REF001251',
    ),
    TransactionModel(
      id: 'trx_019',
      type: TransactionType.cashback,
      direction: TransactionDirection.credit,
      title: 'Cashback Transfer',
      subtitle: 'Double Points Promo',
      amount: 25000,
      date: DateTime.now().subtract(const Duration(days: 6)),
      status: TransactionStatus.success,
      referenceId: 'REF001252',
    ),

    // ── 1 Withdraw ────────────────────────────────────────────────────────────
    TransactionModel(
      id: 'trx_020',
      type: TransactionType.withdraw,
      direction: TransactionDirection.debit,
      title: 'Tarik Tunai',
      subtitle: 'ATM BCA • Rek. 1234567890',
      amount: 500000,
      date: DateTime.now().subtract(const Duration(days: 25)),
      status: TransactionStatus.success,
      referenceId: 'REF001253',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Contacts (10 items)
  // ---------------------------------------------------------------------------
  static final List<ContactModel> contacts = [
    ContactModel(
      id: 'cnt_001',
      name: 'Andi Wijaya',
      phone: '082111222333',
      avatarInitial: 'AW',
      isFavorite: true,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ContactModel(
      id: 'cnt_002',
      name: 'Siti Rahayu',
      phone: '085999888777',
      avatarInitial: 'SR',
      isFavorite: true,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ContactModel(
      id: 'cnt_003',
      name: 'Reza Firmansyah',
      phone: '081333444555',
      avatarInitial: 'RF',
      isFavorite: true,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ContactModel(
      id: 'cnt_004',
      name: 'Maya Kusuma',
      phone: '087666777888',
      avatarInitial: 'MK',
      isFavorite: false,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ContactModel(
      id: 'cnt_005',
      name: 'Doni Prasetyo',
      phone: '089555666777',
      avatarInitial: 'DP',
      isFavorite: false,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 12)),
    ),
    ContactModel(
      id: 'cnt_006',
      name: 'Citra Dewi',
      phone: '082777888999',
      avatarInitial: 'CD',
      isFavorite: true,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 6)),
    ),
    ContactModel(
      id: 'cnt_007',
      name: 'Hendra Gunawan',
      phone: '085111222333',
      avatarInitial: 'HG',
      isFavorite: false,
      lastTransactionDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ContactModel(
      id: 'cnt_008',
      name: 'Lina Agustina',
      phone: '081999000111',
      avatarInitial: 'LA',
      isFavorite: false,
    ),
    ContactModel(
      id: 'cnt_009',
      name: 'Bimo Aditya',
      phone: '082333444555',
      avatarInitial: 'BA',
      isFavorite: false,
    ),
    ContactModel(
      id: 'cnt_010',
      name: 'Putri Handayani',
      phone: '087888999000',
      avatarInitial: 'PH',
      isFavorite: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Promos (5 items)
  // ---------------------------------------------------------------------------
  static final List<PromoModel> promos = [
    PromoModel(
      id: 'prm_001',
      title: 'Cashback 30%',
      subtitle: 'Min. transaksi Rp 50.000',
      description:
          'Dapatkan cashback 30% untuk setiap transaksi pembayaran dengan minimum transaksi Rp 50.000. Cashback maksimal Rp 15.000 per transaksi.',
      colorValue: 0xFF4C3494,
      validUntil: DateTime.now().add(const Duration(days: 15)),
      isActive: true,
    ),
    PromoModel(
      id: 'prm_002',
      title: 'Gratis Pulsa 10rb',
      subtitle: 'Khusus hari ini',
      description:
          'Beli pulsa apa saja senilai minimal Rp 50.000 dan dapatkan gratis pulsa senilai Rp 10.000. Berlaku untuk semua operator.',
      colorValue: 0xFF27AE60,
      validUntil: DateTime.now().add(const Duration(days: 1)),
      isActive: true,
    ),
    PromoModel(
      id: 'prm_003',
      title: 'Diskon PLN',
      subtitle: 'Hemat hingga Rp 10.000',
      description:
          'Bayar tagihan atau beli token PLN lewat OVO dan hemat hingga Rp 10.000. Berlaku setiap hari Senin-Jumat.',
      colorValue: 0xFFEB5757,
      validUntil: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
    ),
    PromoModel(
      id: 'prm_004',
      title: 'Double Points',
      subtitle: 'Setiap transaksi Transfer',
      description:
          'Kumpulkan OVO Points 2x lipat untuk setiap transaksi transfer OVO ke OVO. Poin langsung masuk ke akun kamu.',
      colorValue: 0xFF2F80ED,
      validUntil: DateTime.now().add(const Duration(days: 7)),
      isActive: true,
    ),
    PromoModel(
      id: 'prm_005',
      title: 'Cashback Indomaret',
      subtitle: 'Max. cashback Rp 5.000',
      description:
          'Belanja di Indomaret menggunakan OVO dan dapatkan cashback 10% maksimal Rp 5.000 setiap transaksi.',
      colorValue: 0xFFF2994A,
      validUntil: DateTime.now().add(const Duration(days: 20)),
      isActive: true,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Merchants (5 items)
  // ---------------------------------------------------------------------------
  static const List<MerchantModel> merchants = [
    MerchantModel(
      id: 'mrc_001',
      name: 'Indomaret',
      category: 'Retail',
      description: 'Minimarket terpercaya di seluruh Indonesia',
      minPayment: 5000,
    ),
    MerchantModel(
      id: 'mrc_002',
      name: 'Alfamart',
      category: 'Retail',
      description: 'Belanja mudah dan hemat di Alfamart',
      minPayment: 5000,
    ),
    MerchantModel(
      id: 'mrc_003',
      name: 'KFC',
      category: 'F&B',
      description: 'Ayam goreng crispy favorit keluarga',
      minPayment: 20000,
    ),
    MerchantModel(
      id: 'mrc_004',
      name: 'McDonalds',
      category: 'F&B',
      description: 'I\'m lovin\' it — makanan cepat saji terbaik',
      minPayment: 25000,
    ),
    MerchantModel(
      id: 'mrc_005',
      name: 'Grab',
      category: 'Transport',
      description: 'Transportasi online terpercaya dan nyaman',
      minPayment: 10000,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Notifications (8 items)
  // ---------------------------------------------------------------------------
  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'ntf_001',
      title: 'Transfer Berhasil',
      body: 'Transfer Rp 150.000 ke Andi Wijaya berhasil diproses.',
      type: NotificationType.transaction,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'ntf_002',
      title: 'Top Up Berhasil',
      body: 'Top Up OVO Rp 500.000 via BCA berhasil. Saldo kamu kini Rp 850.000.',
      type: NotificationType.transaction,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationModel(
      id: 'ntf_003',
      title: 'Promo Spesial Untukmu!',
      body: 'Cashback 30% untuk transaksi hari ini. Jangan sampai terlewat!',
      type: NotificationType.promo,
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    NotificationModel(
      id: 'ntf_004',
      title: 'Pembayaran PLN Berhasil',
      body: 'Pembayaran token PLN Rp 100.000 berhasil. Token telah dikirim.',
      type: NotificationType.transaction,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'ntf_005',
      title: 'Cashback Diterima',
      body: 'Selamat! Cashback Rp 5.000 dari belanja di Indomaret telah masuk.',
      type: NotificationType.transaction,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    NotificationModel(
      id: 'ntf_006',
      title: 'Double Points Aktif',
      body: 'Promo Double Points untuk Transfer OVO berlaku hingga 7 hari ke depan.',
      type: NotificationType.promo,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationModel(
      id: 'ntf_007',
      title: 'Pembaruan Aplikasi',
      body: 'Versi terbaru OVO tersedia. Perbarui sekarang untuk pengalaman lebih baik.',
      type: NotificationType.system,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    NotificationModel(
      id: 'ntf_008',
      title: 'Keamanan Akun',
      body: 'Login baru terdeteksi pada akun kamu. Jika bukan kamu, segera ubah PIN.',
      type: NotificationType.security,
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Bank List
  // ---------------------------------------------------------------------------
  static const List<String> bankList = [
    'BCA',
    'Mandiri',
    'BRI',
    'BNI',
    'CIMB Niaga',
    'Danamon',
  ];

  // ---------------------------------------------------------------------------
  // Top Up Amounts
  // ---------------------------------------------------------------------------
  static const List<Map<String, dynamic>> topupAmounts = [
    {'amount': 50000, 'label': 'Rp 50.000'},
    {'amount': 100000, 'label': 'Rp 100.000'},
    {'amount': 200000, 'label': 'Rp 200.000'},
    {'amount': 500000, 'label': 'Rp 500.000'},
    {'amount': 1000000, 'label': 'Rp 1.000.000'},
  ];

  // ---------------------------------------------------------------------------
  // Operators
  // ---------------------------------------------------------------------------
  static const List<String> operators = [
    'Telkomsel',
    'XL',
    'Indosat',
    'Tri',
    'Smartfren',
    'Axis',
  ];

  // ---------------------------------------------------------------------------
  // Pulsa Packages
  // ---------------------------------------------------------------------------
  static const List<Map<String, dynamic>> pulsaPackages = [
    {'quota': '10rb', 'price': 11000, 'label': '10rb • Rp 11.000'},
    {'quota': '20rb', 'price': 21500, 'label': '20rb • Rp 21.500'},
    {'quota': '50rb', 'price': 52000, 'label': '50rb • Rp 52.000'},
    {'quota': '100rb', 'price': 102000, 'label': '100rb • Rp 102.000'},
    {'quota': '150rb', 'price': 152000, 'label': '150rb • Rp 152.000'},
  ];
}
