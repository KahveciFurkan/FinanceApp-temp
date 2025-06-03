import 'package:hive/hive.dart';

import 'hive/rejected_suggestion.dart';

class Titless {
  static const List<String> titleSuggestions = [
    // Faturalar
    'Elektrik Faturası Ödemesi',
    'Su Faturası Ödemesi',
    'Doğalgaz Faturası Ödemesi',
    'İnternet Faturası Ödemesi',
    'Mobil Telefon Faturası Ödemesi',
    'Kablolu TV Abonelik Ödemesi',
    'Apartman Aidatı Ödemesi',

    // Kira ve Konut
    'Kira Ödemesi',
    'Konut Kredisi Taksiti',
    'Emlak Vergisi Ödemesi',

    // Market ve Yiyecek
    'Haftalık Market Alışverişi',
    'Bakkal Alışverişi',
    'Meyve-Sebze Alışverişi',
    'Et-Balık Alışverişi',
    'Fırın Alışverişi',
    'Kahvaltı Masrafı',
    'Öğle Yemeği Masrafı',
    'Akşam Yemeği Masrafı',

    // Dışarıda Yemek
    'Restoran Hesabı',
    'Kafe/Kahve Masrafı',
    'Fast Food Hesabı',
    'Yemek Siparişi (Getir/Yemeksepeti)',
    'İş Yemeği Masrafı',

    // Ulaşım
    'Toplu Taşıma Bileti (İstanbulkart)',
    'Taksi Ücreti',
    'Uber/Bolt Ücreti',
    'Araç Yakıtı (Benzin/Motorin)',
    'Araç Bakım Masrafı',
    'Lastik Değişimi',
    'Otopark Ücreti',
    'Trafik Cezası Ödemesi',
    'Vignette Ödemesi',

    // Sağlık
    'Doktor Muayene Ücreti',
    'Diş Tedavi Masrafı',
    'Eczane Alışverişi',
    'Tahlil/Laboratuvar Ücreti',
    'Check-up Masrafı',
    'Sağlık Sigortası Ödemesi',
    'Gözlük/Lens Alışverişi',

    // Eğlence
    'Sinema Bileti',
    'Konser/Etkinlik Bileti',
    'Tiyatro Bileti',
    'Spor Müsabakası Bileti',
    'Netflix/Spotify Aboneliği',
    'Oyun Aboneliği (Steam/PSN)',
    'Kumarhane/Bahis Masrafı',
    'Hobi Malzemeleri',

    // Seyahat
    'Uçak Bileti',
    'Otel Konaklama',
    'Tatil Masrafları',
    'Araç Kiralama Ücreti',
    'Yurtiçi Gezi Masrafları',
    'Yurtdışı Gezi Masrafları',
    'Valiz/Bavul Alışverişi',

    // Giyim
    'Günlük Giyim Alışverişi',
    'Ayakkabı Alışverişi',
    'Aksesuar Alışverişi',
    'Özel Gün Kıyafeti',
    'Spor Kıyafetleri',

    // Kişisel Bakım
    'Kuaför/Berber Ücreti',
    'Cilt Bakımı Masrafı',
    'Makyaj Malzemeleri',
    'Parfüm/Kozmetik Alışverişi',
    'Spa/Masaj Ücreti',

    // Eğitim
    'Okul Harç Ödemesi',
    'Kurs Ücreti',
    'Kitap/Dergi Alışverişi',
    'Kırtasiye Malzemeleri',
    'Online Eğitim Aboneliği',

    // Ev ve Tamirat
    'Mobilya Alışverişi',
    'Ev Aletleri Alışverişi',
    'Temizlik Malzemeleri',
    'Ev Dekorasyon Ürünleri',
    'Tamirat Masrafı',
    'Boya-Badana Masrafı',
    'Elektrikçi/Tesisatçı Ücreti',

    // Teknoloji
    'Elektronik Cihaz Alışverişi',
    'Telefon Yükseltme',
    'Bilgisayar/Yazılım Alışverişi',
    'Kamera/Fotoğraf Ekipmanı',
    'Kulaklık/Hoparlör Alışverişi',

    // Finansal
    'Kredi Kartı Ödemesi',
    'Banka Komisyonu',
    'Vergi Ödemesi (Gelir/Mülk)',
    'Sigorta Primleri',
    'Kasko Ödemesi',
    'Bireysel Emeklilik Katkısı',

    // Sosyal
    'Hediye Alışverişi',
    'Bağış/Yardımlaşma',
    'Düğün/Nişan Masrafı',
    'Doğum Günü Partisi Masrafı',
    'Özel Gün Kutlaması',

    // Diğer
    'Çocuk Bakım Masrafları',
    'Bebek Malzemeleri',
    'Evcil Hayvan Masrafları',
    'Ofis Malzemeleri',
    'Kargo/Posta Ücreti',
    'Nakit Çekme İşlemi',
  ];
}

final defaultSuggestions = [
  'Market Alışverişi',
  'Yemek Siparişi',
  'Kira Ödemesi',
  'Elektrik Faturası',
  'Toplu Taşıma',
];

List<String> getFilteredSuggestions(String input, {int limit = 5}) {
  if (input.isEmpty) {
    return defaultSuggestions.take(limit).toList();
  }

  final filtered =
      Titless.titleSuggestions
          .where((title) => title.toLowerCase().contains(input.toLowerCase()))
          .take(limit)
          .toList();

  return filtered;
}

Map<String, List<String>> keywordCategoryMap = {
  'Fatura': [
    'elektrik',
    'su',
    'doğalgaz',
    'internet',
    'aidat',
    'telefon',
    'tv',
    'kablo',
    'iptv',
    'fiber',
    'cep telefonu',
    'abonelik',
    'fatura',
    'kira',
    'kira ödemesi',
    'doğalgaz faturası',
    'su faturası',
    'elektrik faturası',
    'mobil operatör',
  ],

  'Yiyecek': [
    'market',
    'restoran',
    'yemek',
    'kahve',
    'bakkal',
    'kafe',
    'fast food',
    'yemek siparişi',
    'yemeksepeti',
    'getir',
    'manav',
    'kasap',
    'fırın',
    'pastane',
    'süpermarket',
    'alkol',
    'sigara',
    'şarap',
    'meyve',
    'sebze',
    'kahvaltı',
    'öğle yemeği',
    'akşam yemeği',
    'baklava',
  ],

  'Ulaşım': [
    'metro',
    'otobüs',
    'taksi',
    'uber',
    'yakıt',
    'benzin',
    'motorin',
    'lpg',
    'araba bakım',
    'araba tamir',
    'lastik',
    'otopark',
    'vignette',
    'toll',
    'trafik cezası',
    'servis',
    'arac vergisi',
    'bisiklet',
    'tramvay',
    'vapur',
    'feribot',
    'arama kurtarma',
    'araba yıkama',
  ],

  'Eğlence': [
    'sinema',
    'oyun',
    'müzik',
    'spotify',
    'netflix',
    'konser',
    'tiyatro',
    'müze',
    'sergi',
    'parti',
    'bar',
    'disko',
    'piknik',
    'hobi',
    'alışveriş merkezi',
    'avm',
    'bowling',
    'tema parkı',
    'kumarhane',
    'balık tutma',
    'tatile çıkma',
    'yazılım oyun',
    'playstation',
    'xbox',
    'konsol',
    'dijital oyun',
  ],

  'Sağlık': [
    'eczane',
    'doktor',
    'ilaç',
    'muayene',
    'hastane',
    'dişçi',
    'göz doktoru',
    'tahlil',
    'checkup',
    'sağlık sigortası',
    'vitamin',
    'diyet',
    'psikolog',
    'fizik tedavi',
    'ortopedi',
    'ameliyat',
    'tansiyon',
    'şeker ölçümü',
    'protez',
    'işitme cihazı',
    'maske',
    'dezenfektan',
  ],

  'Giyim': [
    'elbise',
    'pantolon',
    'kıyafet',
    'ayakkabı',
    'giyim',
    'moda',
    'aksesuar',
    'çanta',
    'takı',
    'saat',
    'gözlük',
    'şapka',
    'atkı',
    'eldiven',
    'çorap',
    'iç çamaşırı',
    'mont',
    'ceket',
    'gömlek',
    'kazak',
    'tesettür',
    'mayo',
    'bikini',
    'kravat',
  ],

  'Ev': [
    'mobilya',
    'ev eşyası',
    'beyaz eşya',
    'elektronik eşya',
    'halı',
    'perde',
    'mutfak gereçleri',
    'bahçe',
    'kırtasiye',
    'temizlik malzemesi',
    'dekorasyon',
    'yatak',
    'kanepe',
    'dolap',
    'bulaşık makinesi',
    'çamaşır makinesi',
    'buzdolabı',
    'fırın',
    'süpürge',
    'toz bezi',
    'çiçek',
    'avize',
    'paspas',
    'kilit',
    'hırdavat',
  ],

  'Eğitim': [
    'okul',
    'üniversite',
    'ders',
    'kurs',
    'seminer',
    'konferans',
    'kitap',
    'ders kitabı',
    'kırtasiye',
    'yazılım',
    'online kurs',
    'özel ders',
    'öğrenci kredi',
    'burs',
    'sınav ücreti',
    'matematik',
    'ingilizce',
    'yabancı dil',
    'danışmanlık',
    'eğitim materyali',
    'ödev',
    'proje',
    'yaz kampı',
  ],

  'Seyahat': [
    'otel',
    'tatil',
    'uçak',
    'uçak bileti',
    'tren',
    'tren bileti',
    'gezi',
    'tur',
    'vize',
    'pasaport',
    'valiz',
    'bavul',
    'seyahat sigortası',
    'yurt dışı',
    'plaj',
    'dağ',
    'kayak',
    'pansiyon',
    'hostel',
    'kiralık araba',
    'rehber',
    'gezi rehberi',
    'suitcase',
    'backpack',
    'güneş kremi',
  ],

  'Kişisel Bakım': [
    'kuaför',
    'berber',
    'saç',
    'cilt bakımı',
    'makyaj',
    'parfüm',
    'kozmetik',
    'tırnak',
    'manikür',
    'pedikür',
    'epilasyon',
    'dövme',
    'spa',
    'masaj',
    'sakal tıraşı',
    'cilt maskesi',
    'şampuan',
    'sabun',
    'diş macunu',
    'tıraş köpüğü',
    'losyon',
    'güneş gözlüğü',
  ],

  'Spor': [
    'spor salonu',
    'gym',
    'yoga',
    'fitness',
    'pilates',
    'yüzme',
    'futbol',
    'basketbol',
    'tenis',
    'spor malzemeleri',
    'spor ayakkabı',
    'eşofman',
    'top',
    'dambıl',
    'bisiklet',
    'koşu bandı',
    'kayak',
    'snowboard',
    'paten',
    'fitness app',
    'maç bileti',
    'spor kulübü',
    'protein tozu',
  ],

  'Teknoloji': [
    'bilgisayar',
    'laptop',
    'cep telefonu',
    'tablet',
    'kamera',
    'televizyon',
    'yazıcı',
    'kulaklık',
    'yazılım',
    'oyun konsolu',
    'playstation',
    'xbox',
    'nintendo',
    'akıllı saat',
    'dron',
    'usb',
    'harddisk',
    'monitör',
    'klavye',
    'mouse',
    'router',
    'yazılım lisansı',
    'cloud storage',
    'powerbank',
  ],

  'Vergi & Sigorta': [
    'vergi',
    'sigorta',
    'sağlık sigortası',
    'araba sigortası',
    'ev sigortası',
    'hayat sigortası',
    'kasko',
    'emlak vergisi',
    'gelir vergisi',
    'mtv',
    'kasko',
    'dask',
    'bireysel emeklilik',
    'yatırım fonu',
    'vergi iadesi',
    'noter',
  ],

  'Çocuk & Bebek': [
    'bebek bezi',
    'mama',
    'oyuncak',
    'kreş',
    'okul öncesi',
    'çocuk doktoru',
    'sünnet',
    'bebek arabası',
    'anaokulu',
    'çocuk kıyafeti',
    'emzirme',
    'biberon',
    'oyun parkı',
    'doğum günü partisi',
    'eğitici oyun',
  ],

  'Bağış & Hediye': [
    'hediye',
    'doğum günü',
    'düğün',
    'nişan',
    'bayram',
    'özel gün',
    'bağış',
    'yardım',
    'sadaka',
    'dini bağış',
    'kermes',
    'sosyal sorumluluk',
    'çeyiz',
    'hediye kartı',
    'hediye paketi',
  ],

  'Evcil Hayvan': [
    'veteriner',
    'mama',
    'kuaför',
    'aşı',
    'pet shop',
    'tasma',
    'kafes',
    'akvaryum',
    'kum',
    'oyuncak',
    'pet otel',
    'eğitim',
    'tarama fırçası',
  ],

  'Ofis & İş': [
    'kırtasiye',
    'yazıcı',
    'fotokopi',
    'toplantı',
    'iş yemeği',
    'iş seyahati',
    'meslek kursu',
    'lisans',
    'yazılım aboneliği',
    'web sitesi',
    'reklam',
    'kargo',
    'posta',
    'ofis mobilyası',
    'iş kıyafeti',
    'cv',
  ],

  'Tamir & Bakım': [
    'tamir',
    'tamirci',
    'boya',
    'tadilat',
    'marangoz',
    'elektrikçi',
    'su tesisatı',
    'kilitçi',
    'camcı',
    'çilingir',
    'arıza',
    'bakım',
    'servis',
    'yat servisi',
    'kombi bakımı',
  ],

  'Diğer': [
    'nakit çekme',
    'havale',
    'eft',
    'borç',
    'ceza',
    'kayıp',
    'buluntu',
    'piyango',
    'kumar',
    'bahis',
    'bağışıklık güçlendirici',
    'ikram',
    'zam',
    'indirim',
    'kampanya',
    'promosyon',
  ],
};

class AISuggestionResult {
  final String? category;
  final double confidence;
  final String suggestionText;

  AISuggestionResult({
    required this.category,
    required this.confidence,
    required this.suggestionText,
  });
}

Future<String?> getImprovedAISuggestion(String title) async {
  final lowerTitle = title.toLowerCase();
  final rejectedBox = Hive.box<RejectedSuggestion>('rejectedSuggestions');

  final rejectedWords = <String, int>{};

  for (var suggestion in rejectedBox.values) {
    final words = suggestion.title.toLowerCase().split(RegExp(r'\s+'));
    for (var word in words) {
      rejectedWords[word] = (rejectedWords[word] ?? 0) + 1;
    }
  }

  final inputWords = lowerTitle.split(RegExp(r'\s+'));

  // Eğer başlık reddedilmiş kelimelerden oluşuyorsa uyarı ver
  for (var word in inputWords) {
    if (rejectedWords[word] != null && rejectedWords[word]! >= 2) {
      return 'Bu başlık daha önce AI tarafından yanlış tahmin edilmiş olabilir.';
    }
  }

  return null; // Uyarı yok, standart tahmin yapılabilir
}

AISuggestionResult generateAISuggestion(String title) {
  final lowerTitle = title.toLowerCase();
  MapEntry<String, int>? matchedEntry;
  int maxMatchCount = 0;

  for (var entry in keywordCategoryMap.entries) {
    int matchCount =
        entry.value.where((keyword) => lowerTitle.contains(keyword)).length;

    if (matchCount > maxMatchCount) {
      maxMatchCount = matchCount;
      matchedEntry = MapEntry(entry.key, matchCount);
    }
  }

  if (matchedEntry != null && matchedEntry.value > 0) {
    final confidence = (matchedEntry.value /
            keywordCategoryMap[matchedEntry.key]!.length)
        .clamp(0.3, 1.0);
    final suggestion =
        '${matchedEntry.key} kategorisi öneriliyor. Anahtar kelime eşleşme oranı: %${(confidence * 100).round()}';
    return AISuggestionResult(
      category: matchedEntry.key,
      confidence: confidence,
      suggestionText: suggestion,
    );
  }

  return AISuggestionResult(
    category: null,
    confidence: 0.0,
    suggestionText: 'AI bu başlık için özel bir tahminde bulunamadı.',
  );
}
