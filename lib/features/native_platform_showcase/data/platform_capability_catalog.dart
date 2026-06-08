import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_platform_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';

/// Static per-platform detail strings for each native capability kind.
const Map<AppPlatformKind, Map<NativeCapabilityKind, String>>
platformCapabilityCatalog =
    <AppPlatformKind, Map<NativeCapabilityKind, String>>{
      AppPlatformKind.android: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding:
            'Hybrid Composition / Texture Layer; HCPP-ready',
        NativeCapabilityKind.platformPackageManager: 'Gradle + Play packaging',
        NativeCapabilityKind.nativeCodeInterop: 'JNI + Kotlin/Java',
        NativeCapabilityKind.lowLevelGraphics: 'Vulkan / Skia backend',
        NativeCapabilityKind.adaptiveGestures:
            'Predictive back, Material motion',
      },
      AppPlatformKind.ios: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding: 'UiKitView / PlatformView',
        NativeCapabilityKind.platformPackageManager: 'Swift Package Manager',
        NativeCapabilityKind.nativeCodeInterop: 'Swift / Objective-C bridge',
        NativeCapabilityKind.lowLevelGraphics: 'Metal',
        NativeCapabilityKind.adaptiveGestures: 'Edge swipe, haptics cues',
      },
      AppPlatformKind.macos: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding: 'AppKit embedding',
        NativeCapabilityKind.platformPackageManager: 'Swift Package Manager',
        NativeCapabilityKind.nativeCodeInterop: 'Swift / Objective-C bridge',
        NativeCapabilityKind.lowLevelGraphics: 'Metal',
        NativeCapabilityKind.adaptiveGestures: 'Trackpad + context menus',
      },
      AppPlatformKind.windows: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding: 'HWND hosting',
        NativeCapabilityKind.platformPackageManager: 'WinGet / MSIX concept',
        NativeCapabilityKind.nativeCodeInterop: 'C++/Win32 via FFI',
        NativeCapabilityKind.lowLevelGraphics: 'DirectX / Vulkan',
        NativeCapabilityKind.adaptiveGestures: 'Pointer hover, keyboard nav',
      },
      AppPlatformKind.linux: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding: 'GTK/Qt embedding',
        NativeCapabilityKind.platformPackageManager: 'apt/dnf/flatpak concept',
        NativeCapabilityKind.nativeCodeInterop: 'C/C++ via FFI',
        NativeCapabilityKind.lowLevelGraphics: 'Vulkan / OpenGL',
        NativeCapabilityKind.adaptiveGestures: 'Middle-click, shortcuts',
      },
      AppPlatformKind.web: <NativeCapabilityKind, String>{
        NativeCapabilityKind.nativeViewEmbedding: 'HtmlElementView / Wasm host',
        NativeCapabilityKind.platformPackageManager: 'npm / pnpm ecosystem',
        NativeCapabilityKind.nativeCodeInterop: 'JS interop + Wasm',
        NativeCapabilityKind.lowLevelGraphics: 'WebGL / WebGPU',
        NativeCapabilityKind.adaptiveGestures: 'Pointer + scroll chaining',
      },
    };
