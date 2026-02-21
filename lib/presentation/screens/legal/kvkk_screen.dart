import 'package:flutter/material.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// KVKK Aydınlatma Metni — Turkish data protection disclosure.
class KvkkScreen extends StatelessWidget {
  const KvkkScreen({super.key});

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
                    l10n.kvkkNotice,
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
KİŞİSEL VERİLERİN KORUNMASI HAKKINDA AYDINLATMA METNİ
(6698 Sayılı KVKK Kapsamında)

Son güncelleme: Şubat 2026

1. VERİ SORUMLUSU
[Şirket/Kişi adı placeholder]
İletişim: kvkk@kendinapp.com

2. İŞLENEN KİŞİSEL VERİLER

a) Kimlik Verileri
• Anonim kullanıcı kimliği (UUID)
• Kullanıcı adı (isteğe bağlı)

b) İletişim Verileri
• E-posta adresi (yalnızca hesap oluşturulduğunda)

c) İçerik Verileri
• Günlük yazılar
• Haftalık yansımalar
• Arşivlenen yansımalar

d) İşlem Güvenliği Verileri
• Oturum bilgileri
• Giriş zamanları

3. KİŞİSEL VERİLERİN İŞLENME AMAÇLARI
• Uygulama hizmetlerinin sunulması ve iyileştirilmesi
• Kullanıcı kimlik doğrulaması
• Yapay zeka ile haftalık yansıma oluşturulması
• Abonelik ve ödeme işlemlerinin yönetimi
• Yasal yükümlülüklerin yerine getirilmesi

4. KİŞİSEL VERİLERİN İŞLENME HUKUKİ SEBEPLERİ
• KVKK Madde 5/2(c): Sözleşmenin ifası için gerekli olması
• KVKK Madde 5/2(f): Meşru menfaat
• KVKK Madde 5/1: Açık rıza (yapay zeka ile yansıma oluşturma)

5. KİŞİSEL VERİLERİN AKTARILMASI
Kişisel verileriniz aşağıdaki taraflarla paylaşılabilir:
• Supabase Inc. (ABD) — Veri depolama hizmeti
• Yapay zeka hizmet sağlayıcısı — Yansıma oluşturma
• Apple Inc. — Abonelik ve ödeme yönetimi

Yurt dışına veri aktarımı, KVKK Madde 9 kapsamında yeterli koruma sağlayan ülkelere veya açık rızanıza dayanarak gerçekleştirilir.

6. KİŞİSEL VERİLERİN SAKLANMA SÜRESİ
• Aktif hesap verileri: Hesap silinene kadar
• Anonim hesap verileri: Son aktiviteden itibaren 12 ay
• Silinen hesap verileri: Silme talebinden itibaren 30 gün
• Yasal zorunluluk gerektiren veriler: İlgili mevzuatın öngördüğü süre

7. VERİ GÜVENLİĞİ TEDBİRLERİ
• TLS 1.3 ile şifreli veri iletimi
• Row Level Security (RLS) ile veritabanı erişim kontrolü
• Minimum veri toplama prensibi
• Düzenli güvenlik değerlendirmeleri

8. VERİ SAHİBİNİN HAKLARI (KVKK Madde 11)
Kişisel veri sahibi olarak aşağıdaki haklara sahipsiniz:

a) Kişisel verilerinizin işlenip işlenmediğini öğrenme
b) Kişisel verileriniz işlenmişse buna ilişkin bilgi talep etme
c) Kişisel verilerinizin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme
d) Yurt içinde veya yurt dışında kişisel verilerinizin aktarıldığı üçüncü kişileri bilme
e) Kişisel verilerinizin eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme
f) KVKK Madde 7'deki şartlar çerçevesinde kişisel verilerinizin silinmesini veya yok edilmesini isteme
g) (e) ve (f) bentleri uyarınca yapılan işlemlerin, kişisel verilerinizin aktarıldığı üçüncü kişilere bildirilmesini isteme
h) İşlenen verilerin münhasıran otomatik sistemler vasıtasıyla analiz edilmesi suretiyle aleyhinize bir sonuç ortaya çıkmasına itiraz etme
i) Kişisel verilerinizin kanuna aykırı olarak işlenmesi sebebiyle zarara uğramanız halinde zararın giderilmesini talep etme

9. BAŞVURU YÖNTEMİ
Yukarıdaki haklarınızı kullanmak için:
• E-posta: kvkk@kendinapp.com
• Uygulama içi: Ayarlar > Hesap > Veri Talebi

Başvurularınız en geç 30 gün içinde cevaplanacaktır.

10. DEĞİŞİKLİKLER
Bu aydınlatma metni güncellenebilir. Önemli değişikliklerde uygulama içi bildirim yapılır.
''';

  static const _contentEn = '''
PERSONAL DATA PROTECTION DISCLOSURE
(Under Turkish Law No. 6698 — KVKK)

Last updated: February 2026

1. DATA CONTROLLER
[Company/Person name placeholder]
Contact: kvkk@kendinapp.com

2. PERSONAL DATA PROCESSED

a) Identity Data
• Anonymous user ID (UUID)
• Username (optional)

b) Contact Data
• Email address (only when account is created)

c) Content Data
• Daily entries
• Weekly reflections
• Archived reflections

d) Transaction Security Data
• Session information
• Login timestamps

3. PURPOSES OF PROCESSING
• Providing and improving application services
• User authentication
• Generating weekly reflections with AI
• Subscription and payment management
• Fulfilling legal obligations

4. LEGAL BASIS FOR PROCESSING
• KVKK Article 5/2(c): Necessary for contract performance
• KVKK Article 5/2(f): Legitimate interest
• KVKK Article 5/1: Explicit consent (AI reflection generation)

5. DATA TRANSFERS
Your personal data may be shared with:
• Supabase Inc. (USA) — Data storage
• AI service provider — Reflection generation
• Apple Inc. — Subscription and payment management

International transfers are conducted to countries with adequate protection or based on your explicit consent under KVKK Article 9.

6. DATA RETENTION
• Active accounts: Until account deletion
• Anonymous accounts: 12 months from last activity
• Deleted accounts: 30 days from deletion request
• Legally required data: As required by applicable legislation

7. SECURITY MEASURES
• TLS 1.3 encrypted data transmission
• Row Level Security (RLS) for database access control
• Minimum data collection principle
• Regular security assessments

8. DATA SUBJECT RIGHTS (KVKK Article 11)
As a data subject, you have the right to:
a) Learn whether your personal data is being processed
b) Request information about processing if it has been processed
c) Learn the purpose of processing and whether data is used accordingly
d) Know third parties to whom your data is transferred domestically or abroad
e) Request correction of incomplete or incorrectly processed data
f) Request deletion or destruction under KVKK Article 7
g) Request notification of corrections and deletions to third parties
h) Object to outcomes arising solely from automated analysis
i) Claim compensation for damages due to unlawful processing

9. HOW TO APPLY
To exercise your rights:
• Email: kvkk@kendinapp.com
• In-app: Settings > Account > Data Request

Applications will be responded to within 30 days.

10. CHANGES
This disclosure may be updated. In-app notification will be provided for significant changes.
''';
}
