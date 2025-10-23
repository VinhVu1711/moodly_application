# File Tree: moodlyy_application

**Generated:** 10/22/2025, 7:50:15 PM
**Root Path:** `f:\FlutterEngineer\DoAnChuyenNganh\moodlyy_application`

```
├── ai
│   ├── data
│   │   ├── aggerate_period_data.py
│   │   ├── fetch_data_from_supabase.py
│   │   ├── generate_period_column.py
│   │   ├── instuction.md
│   │   ├── moodly_export.csv
│   │   ├── moodly_with_period.csv
│   │   ├── prepare_train_dataset.py
│   │   ├── train_dataset.csv
│   │   └── week_period_dataset.csv
│   ├── logs
│   ├── model
│   └── notebooks
├── android
│   ├── .kotlin
│   │   ├── errors
│   │   └── sessions
│   ├── app
│   │   ├── src
│   │   │   ├── debug
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── main
│   │   │   │   ├── java
│   │   │   │   │   └── io
│   │   │   │   │       └── flutter
│   │   │   │   │           └── plugins
│   │   │   │   │               └── GeneratedPluginRegistrant.java
│   │   │   │   ├── kotlin
│   │   │   │   │   └── com
│   │   │   │   │       └── example
│   │   │   │   │           └── moodlyy_application
│   │   │   │   │               └── MainActivity.kt
│   │   │   │   ├── res
│   │   │   │   │   ├── drawable
│   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   ├── drawable-v21
│   │   │   │   │   │   └── launch_background.xml
│   │   │   │   │   ├── mipmap-hdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-mdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xxhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── mipmap-xxxhdpi
│   │   │   │   │   │   └── ic_launcher.png
│   │   │   │   │   ├── values
│   │   │   │   │   │   └── styles.xml
│   │   │   │   │   └── values-night
│   │   │   │   │       └── styles.xml
│   │   │   │   └── AndroidManifest.xml
│   │   │   └── profile
│   │   │       └── AndroidManifest.xml
│   │   └── build.gradle.kts
│   ├── gradle
│   │   └── wrapper
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── .gitignore
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   └── settings.gradle.kts
├── assets
│   ├── anotheremotion
│   │   ├── angry.png
│   │   ├── annoyed.png
│   │   ├── anxious.png
│   │   ├── depressed.png
│   │   ├── enthusiastic.png
│   │   ├── excited.png
│   │   ├── happy.png
│   │   ├── hopeful.png
│   │   ├── lonely.png
│   │   ├── pit-a-part.png
│   │   ├── pressured.png
│   │   ├── proud.png
│   │   ├── refreshed.png
│   │   ├── relaxed.png
│   │   ├── sad.png
│   │   └── tired.png
│   ├── emotion
│   │   ├── happy.png
│   │   ├── neutral.png
│   │   ├── sad-face.png
│   │   ├── veryhappy.png
│   │   └── verysad.png
│   ├── images
│   │   └── moodly_logo.png
│   └── people
│       ├── family.png
│       ├── friends.png
│       ├── lover.png
│       ├── partner.png
│       ├── stranger.png
│       └── yourself.png
├── ios
│   ├── Flutter
│   │   ├── ephemeral
│   │   │   ├── flutter_lldb_helper.py
│   │   │   └── flutter_lldbinit
│   │   ├── AppFrameworkInfo.plist
│   │   ├── Debug.xcconfig
│   │   ├── Generated.xcconfig
│   │   └── Release.xcconfig
│   ├── Runner
│   │   ├── Assets.xcassets
│   │   │   ├── AppIcon.appiconset
│   │   │   │   ├── Contents.json
│   │   │   │   ├── Icon-App-1024x1024@1x.png
│   │   │   │   ├── Icon-App-20x20@1x.png
│   │   │   │   ├── Icon-App-20x20@2x.png
│   │   │   │   ├── Icon-App-20x20@3x.png
│   │   │   │   ├── Icon-App-29x29@1x.png
│   │   │   │   ├── Icon-App-29x29@2x.png
│   │   │   │   ├── Icon-App-29x29@3x.png
│   │   │   │   ├── Icon-App-40x40@1x.png
│   │   │   │   ├── Icon-App-40x40@2x.png
│   │   │   │   ├── Icon-App-40x40@3x.png
│   │   │   │   ├── Icon-App-60x60@2x.png
│   │   │   │   ├── Icon-App-60x60@3x.png
│   │   │   │   ├── Icon-App-76x76@1x.png
│   │   │   │   ├── Icon-App-76x76@2x.png
│   │   │   │   └── Icon-App-83.5x83.5@2x.png
│   │   │   └── LaunchImage.imageset
│   │   │       ├── Contents.json
│   │   │       ├── LaunchImage.png
│   │   │       ├── LaunchImage@2x.png
│   │   │       ├── LaunchImage@3x.png
│   │   │       └── README.md
│   │   ├── Base.lproj
│   │   │   ├── LaunchScreen.storyboard
│   │   │   └── Main.storyboard
│   │   ├── AppDelegate.swift
│   │   ├── GeneratedPluginRegistrant.h
│   │   ├── GeneratedPluginRegistrant.m
│   │   ├── Info.plist
│   │   └── Runner-Bridging-Header.h
│   ├── Runner.xcodeproj
│   │   ├── xcshareddata
│   │   │   └── xcschemes
│   │   │       └── Runner.xcscheme
│   │   └── project.pbxproj
│   ├── RunnerTests
│   │   └── RunnerTests.swift
│   └── .gitignore
├── lib
│   ├── app
│   │   ├── app.dart
│   │   ├── di.dart
│   │   └── root_router.dart
│   ├── common
│   │   └── l10n_etx.dart
│   ├── features
│   │   ├── ai
│   │   │   └── presentation
│   │   │       └── ai_page.dart
│   │   ├── app
│   │   │   ├── notification
│   │   │   │   └── local_notifications_port.dart
│   │   │   └── vm
│   │   │       ├── locale_vm.dart
│   │   │       ├── notification_vm.dart
│   │   │       └── theme_vm.dart
│   │   ├── auth
│   │   │   ├── data
│   │   │   │   └── auth_service.dart
│   │   │   ├── presentation
│   │   │   │   └── pages
│   │   │   │       └── login_page.dart
│   │   │   └── vm
│   │   │       └── auth_vm.dart
│   │   ├── calendar
│   │   │   ├── data
│   │   │   │   ├── calendar_service.dart
│   │   │   │   └── quote_service.dart
│   │   │   ├── presentation
│   │   │   │   └── calendar_page.dart
│   │   │   └── vm
│   │   │       └── calendar_vm.dart
│   │   ├── main_shell
│   │   │   └── presentation
│   │   │       └── app_shell.dart
│   │   ├── mood
│   │   │   ├── domain
│   │   │   │   └── mood.dart
│   │   │   ├── presentation
│   │   │   │   ├── mood_edit_page.dart
│   │   │   │   └── mood_l10n.dart
│   │   │   └── vm
│   │   │       └── mood_vm.dart
│   │   ├── onboarding
│   │   │   └── presentation
│   │   │       └── intro_splash_page.dart
│   │   ├── settings
│   │   │   ├── data
│   │   │   │   └── user_settings_services.dart
│   │   │   └── domain
│   │   │       └── user_settings.dart
│   │   ├── stats
│   │   │   ├── presentation
│   │   │   │   ├── widgets
│   │   │   │   │   ├── another_chart.dart
│   │   │   │   │   ├── mood_bar_chart.dart
│   │   │   │   │   ├── mood_flow_chart.dart
│   │   │   │   │   └── total_mood_tile.dart
│   │   │   │   └── stats_page.dart
│   │   │   └── vm
│   │   │       └── stats_vm.dart
│   │   └── user
│   │       ├── data
│   │       │   └── user_privacy_service.dart
│   │       ├── presentation
│   │       │   ├── privacy_page.dart
│   │       │   └── user_page.dart
│   │       └── vm
│   │           └── user_privacy_vm.dart
│   ├── l10n
│   │   ├── app_en.arb
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_vi.dart
│   │   └── app_vi.arb
│   └── main.dart
├── linux
│   ├── flutter
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── runner
│   │   ├── CMakeLists.txt
│   │   ├── main.cc
│   │   ├── my_application.cc
│   │   └── my_application.h
│   ├── .gitignore
│   └── CMakeLists.txt
├── macos
│   ├── Flutter
│   │   ├── ephemeral
│   │   │   └── Flutter-Generated.xcconfig
│   │   ├── Flutter-Debug.xcconfig
│   │   ├── Flutter-Release.xcconfig
│   │   └── GeneratedPluginRegistrant.swift
│   ├── Runner
│   │   ├── Assets.xcassets
│   │   │   └── AppIcon.appiconset
│   │   │       ├── Contents.json
│   │   │       ├── app_icon_1024.png
│   │   │       ├── app_icon_128.png
│   │   │       ├── app_icon_16.png
│   │   │       ├── app_icon_256.png
│   │   │       ├── app_icon_32.png
│   │   │       ├── app_icon_512.png
│   │   │       └── app_icon_64.png
│   │   ├── Base.lproj
│   │   │   └── MainMenu.xib
│   │   ├── Configs
│   │   │   ├── AppInfo.xcconfig
│   │   │   ├── Debug.xcconfig
│   │   │   ├── Release.xcconfig
│   │   │   └── Warnings.xcconfig
│   │   ├── AppDelegate.swift
│   │   ├── DebugProfile.entitlements
│   │   ├── Info.plist
│   │   ├── MainFlutterWindow.swift
│   │   └── Release.entitlements
│   ├── Runner.xcodeproj
│   │   ├── xcshareddata
│   │   │   └── xcschemes
│   │   │       └── Runner.xcscheme
│   │   └── project.pbxproj
│   ├── RunnerTests
│   │   └── RunnerTests.swift
│   └── .gitignore
├── test
│   └── widget_test.dart
├── web
│   ├── icons
│   │   ├── Icon-192.png
│   │   ├── Icon-512.png
│   │   ├── Icon-maskable-192.png
│   │   └── Icon-maskable-512.png
│   ├── favicon.png
│   ├── index.html
│   └── manifest.json
├── windows
│   ├── flutter
│   │   ├── ephemeral
│   │   │   └── .plugin_symlinks
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   └── generated_plugins.cmake
│   ├── runner
│   │   ├── resources
│   │   │   └── app_icon.ico
│   │   ├── CMakeLists.txt
│   │   ├── Runner.rc
│   │   ├── flutter_window.cpp
│   │   ├── flutter_window.h
│   │   ├── main.cpp
│   │   ├── resource.h
│   │   ├── runner.exe.manifest
│   │   ├── utils.cpp
│   │   ├── utils.h
│   │   ├── win32_window.cpp
│   │   └── win32_window.h
│   ├── .gitignore
│   └── CMakeLists.txt
├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml
├── devtools_options.yaml
├── pubspec.lock
└── pubspec.yaml
```

---

_Generated by FileTree Pro Extension_
