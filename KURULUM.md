# Kendin — Kurulum Rehberi

## 1. Supabase Kurulumu

### Gerekli Secrets (Edge Functions)
```bash
supabase secrets set OPENAI_API_KEY=sk-xxxxx
supabase secrets set RESEND_API_KEY=re_xxxxx
supabase secrets set FCM_SERVER_KEY=AAAA_xxxxx   # Push bildirim icin
```

### Migration'lari calistir
```bash
supabase db push
```

### Edge Function'lari deploy et
```bash
supabase functions deploy generate-reflection
supabase functions deploy send-email
supabase functions deploy send-push
supabase functions deploy migrate-user-data
```

---

## 2. Resend SMTP (Auth E-postalari)

Supabase Dashboard > Authentication > SMTP Settings:

| Alan | Deger |
|------|-------|
| Sender email | `noreply@kendin.app` |
| Sender name | `Kendin` |
| Host | `smtp.resend.com` |
| Port | `465` |
| Username | `resend` |
| Password | Resend API Key (`re_xxxxx`) |

E-posta sablonlari: `supabase/email-templates/` dizininde.
Dashboard > Authentication > Email Templates'e kopyala.

---

## 3. Push Bildirim Kurulumu (iOS + Android)

### Adim 1: Firebase Projesi Olustur
1. [Firebase Console](https://console.firebase.google.com) > Yeni Proje Olustur
2. Proje adi: `kendin-app`

### Adim 2: iOS Uygulamasi Ekle
1. Firebase Console > iOS uygulamasi ekle
2. Bundle ID: `com.kendin.app` (veya kendi bundle ID'n)
3. `GoogleService-Info.plist` dosyasini indir
4. Dosyayi su yola koy:

```
ios/Runner/GoogleService-Info.plist
```

### Adim 3: Android Uygulamasi Ekle
1. Firebase Console > Android uygulamasi ekle
2. Package name: `com.kendin.app`
3. `google-services.json` dosyasini indir
4. Dosyayi su yola koy:

```
android/app/google-services.json
```

### Adim 4: APNs Key (iOS Push icin ZORUNLU)

<!-- ============================================= -->
<!-- APNS KEY BURAYA YAZILACAK                     -->
<!-- ============================================= -->

1. [Apple Developer Console](https://developer.apple.com/account/resources/authkeys/list) > Keys > "+" ile yeni key olustur
2. "Apple Push Notifications service (APNs)" secenegini isaretle
3. Key'i indir (`.p8` dosyasi) — **BU DOSYA SADECE 1 KEZ INDIRILEBILIR!**
4. Su bilgileri not et:
   - **Key ID**: `__BURAYA_KEY_ID_YAZ__`
   - **Team ID**: `__BURAYA_TEAM_ID_YAZ__`
   - **Bundle ID**: `__BURAYA_BUNDLE_ID_YAZ__`

5. Firebase Console > Project Settings > Cloud Messaging > iOS > APNs Authentication Key:
   - `.p8` dosyasini yukle
   - Key ID ve Team ID'yi gir

### Adim 5: FCM Server Key'i Al
1. Firebase Console > Project Settings > Cloud Messaging
2. "Cloud Messaging API (Legacy)" bolumunden **Server Key**'i kopyala
3. Supabase'e kaydet:

```bash
supabase secrets set FCM_SERVER_KEY=AAAA_xxxxx
```

### Adim 6: iOS Projesi Yapilandirma

iOS dizini yoksa olustur:
```bash
flutter create .
```

`ios/Runner/Info.plist` dosyasina ekle:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

Xcode'da:
1. Runner > Signing & Capabilities > "+ Capability" > "Push Notifications" ekle
2. Runner > Signing & Capabilities > "+ Capability" > "Background Modes" ekle > "Remote notifications" isaretle

### Adim 7: Firebase Options (FlutterFire CLI)

```bash
# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Firebase yapilandirmasini olustur
flutterfire configure --project=kendin-app
```

Bu komut `lib/firebase_options.dart` dosyasini olusturur.

Ardindan `push_notification_service.dart` dosyasindaki `Firebase.initializeApp()` satirini guncelle:
```dart
import 'package:kendin/firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## 4. Flutter Build

### Web
```bash
flutter build web --release --base-href "/KendimApp/" \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJxxxxx
```

### iOS
```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://xxxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJxxxxx
```

---

## 5. Kontrol Listesi

- [ ] Supabase projesi olusturuldu
- [ ] Migration'lar calistirildi (`supabase db push`)
- [ ] Edge function'lar deploy edildi
- [ ] OPENAI_API_KEY secret ayarlandi
- [ ] RESEND_API_KEY secret ayarlandi
- [ ] Resend'de `kendin.app` domain dogrulandi (SPF, DKIM, DMARC)
- [ ] Supabase SMTP ayarlari yapildi (Resend)
- [ ] E-posta sablonlari Dashboard'a kopyalandi
- [ ] Firebase projesi olusturuldu
- [ ] `GoogleService-Info.plist` iOS'a eklendi
- [ ] `google-services.json` Android'e eklendi
- [ ] APNs key olusturuldu ve Firebase'e yuklendi
- [ ] FCM_SERVER_KEY secret ayarlandi
- [ ] `flutterfire configure` calistirildi
- [ ] Xcode'da Push Notifications capability eklendi
- [ ] Xcode'da Background Modes > Remote notifications eklendi
