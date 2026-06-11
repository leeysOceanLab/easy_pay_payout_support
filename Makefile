# ── Run (staging URL) ─────────────────────────────────────────────────────
run:
	flutter run --flavor ffPayBubble -t lib/main_ff_pay_bubble.dart

run-details:
	flutter run --flavor ffPayDetails -t lib/main_ff_pay_details.dart

# ── Run (FF Pay / production URL) ─────────────────────────────────────────
run-ff:
	flutter run --flavor ffPayBubble -t lib/main_ff_bubble.dart

run-ff-details:
	flutter run --flavor ffPayDetails -t lib/main_ff_details.dart

# ── Build APK ─────────────────────────────────────────────────────────────
build-staging:
	flutter clean && flutter pub get && flutter build apk --release --flavor staging -t lib/main.dart

build-ff-staging:
	flutter clean && flutter pub get && flutter build apk --release --flavor ffPayBubble -t lib/main_ff_pay_bubble.dart

build-ff-details-staging:
	flutter clean && flutter pub get && flutter build apk --release --flavor ffPayDetails -t lib/main_ff_pay_details.dart

build-ff:
	flutter clean && flutter pub get && flutter build apk --release --flavor ffPayBubble -t lib/main_ff_bubble.dart

build-ff-details:
	flutter clean && flutter pub get && flutter build apk --release --flavor ffPayDetails -t lib/main_ff_details.dart

# ── Build App Bundle ──────────────────────────────────────────────────────
build-appbundle-staging:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor staging -t lib/main.dart

build-appbundle-ff-staging:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor ffPayBubble -t lib/main_ff_pay_bubble.dart

build-appbundle-ff-details-staging:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor ffPayDetails -t lib/main_ff_pay_details.dart

build-appbundle-ff:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor ffPayBubble -t lib/main_ff_bubble.dart

build-appbundle-ff-details:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor ffPayDetails -t lib/main_ff_details.dart

# ── Utils ─────────────────────────────────────────────────────────────────
build-icon:
	dart run flutter_launcher_icons

build-fix:
	dart fix --apply
