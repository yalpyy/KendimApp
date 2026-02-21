import 'package:flutter/material.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// Kullanım Koşulları — Terms of Service.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    l10n.termsOfService,
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
KULLANIM KOŞULLARI

Son güncelleme: Şubat 2026

1. HİZMET TANIMI
Kendin, kullanıcıların günlük farkındalık yazıları yazmalarını ve haftalık yapay zeka destekli yansımalar almalarını sağlayan bir uygulamadır.

2. HESAP VE KULLANIM
• Uygulamayı anonim olarak kullanabilirsiniz
• Hesap oluşturarak verilerinizi güvence altına alabilirsiniz
• 13 yaşından küçük kullanıcılar uygulamayı kullanamaz
• Hesabınızın güvenliğinden siz sorumlusunuz

3. İÇERİK
• Yazdığınız tüm içerikler size aittir
• Kendin, içeriklerinizi yalnızca yansıma oluşturmak için kullanır
• Yasadışı, tehditkar veya zararlı içerik paylaşmak yasaktır
• İçerikleriniz üçüncü taraflarla paylaşılmaz

4. ABONELİK VE ÖDEME
• Ücretsiz kullanım: Temel yazma ve haftalık yansıma
• Premium (Derinlik): Eksik gün tamamlama, arşiv, geçmiş haftalar
• Ödeme Apple üzerinden gerçekleşir
• Abonelik otomatik olarak yenilenir
• İptal: Abonelik dönemi sonuna kadar geçerlidir
• İade: Apple'ın iade politikası geçerlidir

5. YAPAY ZEKA
• Yansımalar yapay zeka tarafından oluşturulur
• Yapay zeka çıktıları bilgilendirme amaçlıdır
• Kendin bir terapi veya danışmanlık hizmeti değildir
• Yapay zeka önerilerine dayanarak alınan kararlardan Kendin sorumlu değildir

6. HİZMET SÜREKLİLİĞİ
• Hizmeti kesintisiz sunmayı hedefleriz
• Bakım ve güncelleme nedeniyle kesintiler olabilir
• Hizmeti önceden bildirmeksizin değiştirme hakkımız saklıdır

7. HESAP SİLME
• Hesabınızı istediğiniz zaman silebilirsiniz
• Silme işlemi tüm verilerinizi 30 gün içinde kalıcı olarak kaldırır
• Anonim hesaplar 12 ay hareketsizlik sonrası otomatik silinir

8. SORUMLULUK SINIRI
• Kendin, "olduğu gibi" sunulmaktadır
• Veri kaybı, kesinti veya yapay zeka çıktılarından kaynaklanan zararlardan sorumluluk kabul edilmez
• Maksimum sorumluluk, son 12 ayda ödenen abonelik tutarı ile sınırlıdır

9. DEĞİŞİKLİKLER
Bu koşulları güncelleyebiliriz. Önemli değişikliklerde uygulama içi bildirim yapılır.

10. İLETİŞİM
info@kendinapp.com
''';

  static const _contentEn = '''
TERMS OF SERVICE

Last updated: February 2026

1. SERVICE DESCRIPTION
Kendin is an application that allows users to write daily awareness entries and receive weekly AI-powered reflections.

2. ACCOUNT AND USAGE
• You can use the app anonymously
• You can secure your data by creating an account
• Users under 13 years of age cannot use the application
• You are responsible for the security of your account

3. CONTENT
• All content you write belongs to you
• Kendin uses your content solely for generating reflections
• Sharing illegal, threatening, or harmful content is prohibited
• Your content is not shared with third parties

4. SUBSCRIPTION AND PAYMENT
• Free usage: Basic writing and weekly reflection
• Premium (Depth): Complete missed days, archive, past weeks
• Payment is processed through Apple
• Subscriptions renew automatically
• Cancellation: Valid until end of current billing period
• Refunds: Apple's refund policy applies

5. ARTIFICIAL INTELLIGENCE
• Reflections are generated by AI
• AI outputs are for informational purposes only
• Kendin is not a therapy or counseling service
• Kendin is not responsible for decisions made based on AI suggestions

6. SERVICE CONTINUITY
• We aim to provide uninterrupted service
• Interruptions may occur due to maintenance and updates
• We reserve the right to modify the service without prior notice

7. ACCOUNT DELETION
• You can delete your account at any time
• Deletion permanently removes all your data within 30 days
• Anonymous accounts are automatically deleted after 12 months of inactivity

8. LIMITATION OF LIABILITY
• Kendin is provided "as is"
• No liability is accepted for data loss, interruptions, or damages arising from AI outputs
• Maximum liability is limited to the subscription amount paid in the last 12 months

9. CHANGES
We may update these terms. In-app notification will be provided for significant changes.

10. CONTACT
info@kendinapp.com
''';
}
