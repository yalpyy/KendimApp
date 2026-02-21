import 'package:flutter/material.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// Gizlilik Politikası — KVKK compliant privacy policy.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isTr = l10n.locale.languageCode == 'tr';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.screenVertical),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.privacyPolicy,
                    style: theme.textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Text(
                  isTr ? _contentTr : _contentEn,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _contentTr = '''
GİZLİLİK POLİTİKASI

Son güncelleme: Şubat 2026

1. VERİ SORUMLUSU
Kendin uygulaması adına veri sorumlusu:
[Şirket/Kişi adı placeholder]
İletişim: privacy@kendinapp.com

2. TOPLANAN VERİLER
• Kimlik verileri: Anonim kullanıcı kimliği (UUID)
• İletişim verileri: E-posta adresi (yalnızca hesap oluşturulduğunda)
• İçerik verileri: Günlük yazılar, haftalık yansımalar
• Teknik veriler: Cihaz türü, uygulama sürümü, oturum bilgileri

3. VERİ İŞLEME AMAÇLARI
• Uygulama hizmetinin sunulması
• Haftalık yansımaların yapay zeka ile oluşturulması
• Hesap güvenliği ve kimlik doğrulama
• Abonelik yönetimi

4. VERİ DEPOLAMA
Verileriniz Supabase altyapısı üzerinde depolanmaktadır. Supabase, PostgreSQL tabanlı bulut veritabanı hizmeti sunmaktadır. Veriler şifrelenmiş bağlantılar (TLS) üzerinden iletilir.

5. YAPAY ZEKA KULLANIMI
Haftalık yansımalar, yazılarınızın yapay zeka modeline gönderilmesiyle oluşturulur. Bu işlem:
• Yalnızca sizin yazılarınız üzerinde gerçekleşir
• Yazılarınız model eğitimi için kullanılmaz
• Yansıma oluşturulduktan sonra giriş verileri saklanmaz

6. VERİ SAKLAMA SÜRESİ
• Aktif hesaplar: Hesap silinene kadar
• Anonim hesaplar: Son aktiviteden itibaren 12 ay
• Silinen hesaplar: 30 gün içinde tamamen silinir

7. ÜÇÜNCÜ TARAF PAYLAŞIMI
Verileriniz üçüncü taraflarla paylaşılmaz. Yalnızca:
• Supabase (veri depolama)
• Yapay zeka sağlayıcısı (yansıma oluşturma)
• Apple (abonelik yönetimi)
hizmetleri altyapısal olarak kullanılmaktadır.

8. KULLANICI HAKLARI (KVKK Madde 11)
Aşağıdaki haklarınız bulunmaktadır:
• Verilerinizin işlenip işlenmediğini öğrenme
• İşlenmişse buna ilişkin bilgi talep etme
• İşlenme amacını ve amacına uygun kullanılıp kullanılmadığını öğrenme
• Yurt içinde/dışında aktarıldığı üçüncü kişileri bilme
• Eksik/yanlış işlenmişse düzeltilmesini isteme
• KVKK Madde 7 kapsamında silinmesini/yok edilmesini isteme
• Düzeltme ve silme işlemlerinin üçüncü kişilere bildirilmesini isteme
• İşlenen verilerin münhasıran otomatik sistemlerle analiz edilmesi suretiyle aleyhinize bir sonuç ortaya çıkmasına itiraz etme
• Kanuna aykırı işlenmesi sebebiyle zarara uğramanız halinde zararın giderilmesini talep etme

9. VERİ GÜVENLİĞİ
• TLS 1.3 şifreli iletişim
• Row Level Security (RLS) ile veri izolasyonu
• Anonim kimlik doğrulama ile minimum veri toplama

10. İLETİŞİM
Gizlilik ile ilgili sorularınız için:
privacy@kendinapp.com
''';

  static const _contentEn = '''
PRIVACY POLICY

Last updated: February 2026

1. DATA CONTROLLER
Data controller on behalf of the Kendin application:
[Company/Person name placeholder]
Contact: privacy@kendinapp.com

2. DATA COLLECTED
• Identity data: Anonymous user ID (UUID)
• Contact data: Email address (only when an account is created)
• Content data: Daily entries, weekly reflections
• Technical data: Device type, app version, session information

3. PURPOSES OF DATA PROCESSING
• Providing application services
• Generating weekly reflections using AI
• Account security and authentication
• Subscription management

4. DATA STORAGE
Your data is stored on Supabase infrastructure. Supabase provides a PostgreSQL-based cloud database service. Data is transmitted over encrypted connections (TLS).

5. AI USAGE
Weekly reflections are generated by sending your entries to an AI model. This process:
• Only operates on your own entries
• Your entries are not used for model training
• Input data is not retained after reflection generation

6. DATA RETENTION PERIOD
• Active accounts: Until account deletion
• Anonymous accounts: 12 months from last activity
• Deleted accounts: Completely removed within 30 days

7. THIRD-PARTY SHARING
Your data is not shared with third parties. Only:
• Supabase (data storage)
• AI provider (reflection generation)
• Apple (subscription management)
are used as infrastructure services.

8. USER RIGHTS
You have the following rights:
• Learn whether your data is being processed
• Request information about processing
• Learn the purpose and whether it is used in accordance with its purpose
• Know third parties to whom data is transferred
• Request correction of incomplete/incorrect data
• Request deletion/destruction of data
• Object to outcomes arising solely from automated analysis

9. DATA SECURITY
• TLS 1.3 encrypted communication
• Row Level Security (RLS) for data isolation
• Minimum data collection with anonymous authentication

10. CONTACT
For privacy-related questions:
privacy@kendinapp.com
''';
}
