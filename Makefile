run:
	flutter run --flavor staging -t lib/main.dart

build:
	flutter clean && flutter pub get && flutter build apk --release --flavor staging -t lib/main.dart

run-easy-pay:
	flutter run --flavor easyPay -t lib/main_easy_pay.dart

build-easy-pay:
	flutter clean && flutter pub get && flutter build apk --release --flavor easyPay -t lib/main_easy_pay.dart

run-360:
	flutter run --flavor threeSixty -t lib/main_360.dart

build-360:
	flutter clean && flutter pub get && flutter build apk --release --flavor threeSixty -t lib/main_360.dart

build-appbundle-staging:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor staging -t lib/main.dart

build-appbundle-easy-pay:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor easyPay -t lib/main_easy_pay.dart

build-appbundle-360:
	flutter clean && flutter pub get && flutter build appbundle --release --flavor threeSixty -t lib/main_360.dart