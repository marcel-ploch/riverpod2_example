#
# Makefile for CI/CD Environments and commandline users
#

# Dev Builds
run-dev:
	flutter run
run-stage:
	flutter run
run-prod:
	flutter run

# Profile Builds
run-dev-profile:
	flutter run --profile
run-stage-profile:
	flutter run --profile
run-prod-profile:
	flutter run --profile

# Release Builds
run-dev-release:
	flutter run --release 
run-stage-release:
	flutter run --release
run-prod-release:
	flutter run --release

# Format & Lint
format:
	flutter format . --line-length 120 --set-exit-if-changed
format-fix:
	flutter format . --line-length 120
lint:
	flutter analyze

# Testing
test:
	flutter test
.PHONY: test
test-coverage:
	printf "on macOS you need to `brew install lcov`"
	flutter test --coverage && genhtml coverage/lcov.info --output=coverage

# Build runner
build-runner:
	flutter pub run build_runner build --delete-conflicting-outputs
build-runner-watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

# Clean project
clean:
	flutter clean
	flutter pub get
	make build-runner

# Export Archives .ipa, .aab and .apk
build-ios:
	@echo "Build iOS"
	make clean
	flutter build ipa --obfuscate --split-debug-info=./build-output/debug/ --tree-shake-icons --export-options-plist=ios/ios-export-options.plist --suppress-analytics
	cp build/ios/ipa/app.ipa build-output/app.ipa
build-ios-analyze:
	@echo "Build iOS analyze"
	flutter build ipa --analyze-size --suppress-analytics
build-android:
	@echo "Build Store App Bundle"
	make clean
	flutter build appbundle --obfuscate --split-debug-info=./build-output/debug/
	cp build/app/outputs/bundle/release/app-release.aab build-output/
	mv build-output/app-release.aab build-output/app.aab
build-android-analyze:
	@echo "Build Android analyze"
	flutter build appbundle --analyze-size --suppress-analytics
build-android-apk:
	@echo "Build self-distribution .apk"
	make clean
	flutter build apk --obfuscate --split-debug-info=./build-output/debug/
	cp build/app/outputs/apk/release/app-release.apk build-output/
	mv build-output/app-release.apk build-output/app.apk

# Release Archive to AppStore/PlayStore
release-ios:
	@echo "Release iOS"
	cd ios; bundle exec fastlane deploy
release-android:
	@echo "Release Android"
	cd android; bundle exec fastlane deploy
release:
	@make build-ios && @make release-ios && @make build-android-appbundle && @make release-android

# Additional helpers
packages-outdated:
	flutter pub outdated
packages-upgrade:
	flutter pub upgrade
l10n:
	flutter gen-l10n
appicon:
	flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons.yaml
deeplink:
	@printf "Android:\nadb shell am start -a android.intent.action.VIEW -c andrmoid.intent.category.BROWSABLE -d de.coodoo.counter://settings"
	@printf "\n\n"
	@printf "iOS:\nxcrun simctl openurl booted de.coodoo.counter://settings"
