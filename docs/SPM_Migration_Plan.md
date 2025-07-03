# SPM Migration Plan for SlateReactNative iOS Project

## Executive Summary

This document outlines the complete migration strategy from CocoaPods to Swift Package Manager (SPM) for the SlateReactNative iOS project. The migration addresses the upcoming CocoaPods deprecation (December 2026) and aligns with industry best practices.

## Current State Analysis

### Dependencies Overview
- **React Native Version**: 0.80.0
- **iOS Deployment Target**: 16.0
- **Total CocoaPods Dependencies**: 100+ (including transitive)
- **Custom Slate Dependencies**: 14 private repositories
- **Major Third-Party Libraries**: Firebase suite, AWS SDK components, MBProgressHUD, SDWebImage

### Key Challenges Identified
1. **React Native SPM Support**: React Native 0.80.0 has limited SPM support
2. **Custom Slate Dependencies**: 14 private pod repositories need SPM conversion
3. **Complex Dependency Tree**: Deep transitive dependencies through Firebase and AWS
4. **Build System Integration**: CocoaPods deeply integrated with Xcode project

## Migration Strategy

### Phase 1: Preparation and Assessment (Weeks 1-2)

#### 1.1 Audit Current Dependencies
```bash
# Generate dependency report
cd ios
pod dependency-graph --format dot | dot -T png -o dependencies.png
```

#### 1.2 Check SPM Availability
- ✅ **Already Available via SPM**: 
  - Firebase (official Apple support)
  - SDWebImage
  - MBProgressHUD
  - Most standard libraries

- ⚠️ **Requires Custom SPM Support**:
  - All Slate private repositories (14 total)
  - React Native (partial support)

- ❌ **No SPM Support**:
  - Some legacy dependencies may need alternatives

#### 1.3 Create Migration Branch
```bash
git checkout -b feature/spm-migration
```

### Phase 2: Infrastructure Setup (Weeks 3-4)

#### 2.1 Create Package.swift Structure
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlateReactNative",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SlateReactNative",
            targets: ["SlateReactNative"]
        ),
    ],
    dependencies: [
        // Firebase Suite
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        
        // Third-party libraries
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.12.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD", from: "1.2.0"),
        
        // Slate Dependencies (to be created)
        .package(url: "https://github.com/slateteams/ios-fm-lib-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-fm-rendering-spm", from: "1.0.0"),
        // ... other Slate SPM packages
        
        // React Native (when available)
        // .package(url: "https://github.com/facebook/react-native", from: "0.80.0"),
    ],
    targets: [
        .target(
            name: "SlateReactNative",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),
                // Slate dependencies
                "FMLib",
                "FMRendering",
                "FMSharing",
                "FMTextView",
                // React Native modules will be added later
            ],
            path: "Sources"
        ),
    ]
)
```

#### 2.2 Coordinate with iOS Team for Slate Dependencies
Create SPM versions of all Slate private repositories:

**Priority Order for Conversion:**
1. `ios-fm-lib` (Foundation library - others depend on this)
2. `ios-fm-rendering` 
3. `ios-server-data`
4. `ios-fm-sharing`
5. `ios-fm-textview`
6. `ios-nfl-sharing`
7. ... remaining libraries

### Phase 3: Hybrid Migration Approach (Weeks 5-8)

Since React Native doesn't fully support SPM yet, we'll use a hybrid approach:

#### 3.1 Create Hybrid Podfile
```ruby
# ios/Podfile
platform :ios, '16.0'
prepare_react_native_project!

# Keep React Native on CocoaPods for now
target 'slateReactNative' do
  config = use_native_modules!
  
  use_react_native!(
    :path => config[:reactNativePath],
    :hermes_enabled => true,
    :fabric_enabled => true
  )
  
  # Minimal CocoaPods dependencies (only React Native)
  # All other dependencies moved to SPM
  
  post_install do |installer|
    react_native_post_install(installer, config[:reactNativePath])
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
        # Enable SPM compatibility
        config.build_settings['SWIFT_PACKAGE_MANAGER_ENABLED'] = 'YES'
      end
    end
  end
end
```

#### 3.2 Xcode Project Configuration
Update `slateReactNative.xcodeproj` to include SPM:

1. **Add Package Dependencies in Xcode**:
   - File → Add Package Dependencies
   - Add Firebase, SDWebImage, MBProgressHUD
   - Add Slate SPM packages (as they become available)

2. **Update Build Settings**:
   ```
   SWIFT_PACKAGE_MANAGER_ENABLED = YES
   PACKAGE_RESOURCE_BUNDLE_FORMAT = automatic
   ```

3. **Link SPM Frameworks**:
   - Remove old CocoaPods framework references
   - Add SPM framework references to target

### Phase 4: Slate Dependencies Migration (Weeks 9-12)

#### 4.1 Convert Slate Repositories to SPM
For each Slate repository, create SPM equivalent:

**Example: ios-fm-lib → ios-fm-lib-spm**
```swift
// Package.swift for FMLib
let package = Package(
    name: "FMLib",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "FMCore", targets: ["FMCore"]),
        .library(name: "FMResponsiveUI", targets: ["FMResponsiveUI"]),
        .library(name: "FMUserActions", targets: ["FMUserActions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.6.2"),
        .package(url: "https://github.com/DataDog/dd-sdk-ios", from: "1.23.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", exact: "5.0.0"),
    ],
    targets: [
        .target(
            name: "FMCore",
            dependencies: [
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                .product(name: "DatadogSDK", package: "dd-sdk-ios"),
                .product(name: "Reachability", package: "Reachability.swift"),
            ]
        ),
        .target(
            name: "FMResponsiveUI",
            dependencies: ["FMCore"]
        ),
        .target(
            name: "FMUserActions", 
            dependencies: ["FMCore"]
        ),
    ]
)
```

#### 4.2 Update Main Package.swift
As Slate SPM packages become available, update the main Package.swift:

```swift
dependencies: [
    // Replace pod sources with SPM packages
    .package(url: "https://github.com/slateteams/ios-fm-lib-spm", from: "1.1.32"),
    .package(url: "https://github.com/slateteams/ios-fm-rendering-spm", from: "1.2.5"),
    .package(url: "https://github.com/slateteams/ios-fm-sharing-spm", from: "1.1.10"),
    .package(url: "https://github.com/slateteams/ios-fm-textview-spm", from: "1.2.4"),
    // ... other Slate packages
],
```

### Phase 5: React Native SPM Integration (Weeks 13-16)

#### 5.1 Monitor React Native SPM Progress
React Native team is working on SPM support. Monitor these resources:
- [React Native SPM RFC](https://github.com/react-native-community/discussions-and-proposals)
- [Facebook React Native Issues](https://github.com/facebook/react-native/issues)

#### 5.2 Custom React Native SPM Bridge (If Needed)
If official SPM support is delayed, create a bridge:

```swift
// ReactNativeBridge/Package.swift
let package = Package(
    name: "ReactNativeBridge",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "ReactNativeBridge", targets: ["ReactNativeBridge"]),
    ],
    dependencies: [
        // Binary framework approach
        .binaryTarget(
            name: "React",
            path: "Frameworks/React.xcframework"
        ),
    ],
    targets: [
        .target(
            name: "ReactNativeBridge",
            dependencies: ["React"]
        ),
    ]
)
```

### Phase 6: Full SPM Migration (Weeks 17-20)

#### 6.1 Remove CocoaPods Completely
```bash
# Remove CocoaPods files
rm -rf ios/Pods
rm ios/Podfile
rm ios/Podfile.lock
rm -rf ios/*.xcworkspace

# Clean Xcode project of CocoaPods references
# Update project.pbxproj to remove all CocoaPods build phases
```

#### 6.2 Final Package.swift
```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SlateReactNative",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SlateReactNative", targets: ["SlateReactNative"]),
    ],
    dependencies: [
        // All dependencies now via SPM
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        .package(url: "https://github.com/facebook/react-native", from: "0.81.0"), // When available
        .package(url: "https://github.com/slateteams/ios-fm-lib-spm", from: "1.1.32"),
        .package(url: "https://github.com/slateteams/ios-fm-rendering-spm", from: "1.2.5"),
        .package(url: "https://github.com/slateteams/ios-fm-sharing-spm", from: "1.1.10"),
        .package(url: "https://github.com/slateteams/ios-fm-textview-spm", from: "1.2.4"),
        .package(url: "https://github.com/slateteams/ios-nfl-sharing-spm", from: "1.0.5"),
        .package(url: "https://github.com/slateteams/ios-nfl-football-api-spm", from: "1.4.4"),
        .package(url: "https://github.com/slateteams/ios-nfl-id-api-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-app-data-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-api-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-integration-photoshelter-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-integration-slack-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-integration-getty-spm", from: "1.0.0"),
        .package(url: "https://github.com/slateteams/ios-effects-spm", from: "1.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.12.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "SlateReactNative",
            dependencies: [
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                .product(name: "FMCore", package: "ios-fm-lib-spm"),
                .product(name: "FMResponsiveUI", package: "ios-fm-lib-spm"),
                .product(name: "FMUserActions", package: "ios-fm-lib-spm"),
                .product(name: "FMRendering", package: "ios-fm-rendering-spm"),
                .product(name: "FMSharing", package: "ios-fm-sharing-spm"),
                .product(name: "FMTextView", package: "ios-fm-textview-spm"),
                .product(name: "NFLSharing", package: "ios-nfl-sharing-spm"),
                .product(name: "NFLFootballApi", package: "ios-nfl-football-api-spm"),
                .product(name: "NFLIDApi", package: "ios-nfl-id-api-spm"),
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),
                // React Native dependencies when available
                // .product(name: "React", package: "react-native"),
                // .product(name: "ReactCore", package: "react-native"),
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
```

## Implementation Timeline

### Weeks 1-4: Foundation
- [ ] Complete dependency audit
- [ ] Create SPM infrastructure
- [ ] Set up hybrid CocoaPods/SPM approach
- [ ] Begin Slate dependency conversion

### Weeks 5-12: Core Migration
- [ ] Convert all Slate dependencies to SPM
- [ ] Migrate Firebase and third-party libraries
- [ ] Update Xcode project configuration
- [ ] Extensive testing and validation

### Weeks 13-20: Completion
- [ ] Integrate React Native SPM support
- [ ] Remove CocoaPods completely
- [ ] Final testing and optimization
- [ ] Documentation and team training

## Risk Mitigation

### High Risk Items
1. **React Native SPM Support Delay**
   - **Mitigation**: Use hybrid approach with binary frameworks
   - **Fallback**: Custom React Native SPM bridge

2. **Slate Dependency Conversion Complexity**
   - **Mitigation**: Prioritize by dependency order
   - **Fallback**: Temporary binary framework approach

3. **Build System Breakage**
   - **Mitigation**: Maintain parallel builds during migration
   - **Fallback**: Quick rollback to CocoaPods

### Medium Risk Items
1. **Version Compatibility Issues**
   - **Mitigation**: Careful version pinning and testing
2. **CI/CD Pipeline Updates**
   - **Mitigation**: Update build scripts incrementally

## Success Metrics

- [ ] Build time improvement (target: 20-30% faster)
- [ ] Dependency resolution speed (target: 50% faster)
- [ ] Reduced project complexity (no more Podfile.lock conflicts)
- [ ] Future-proof architecture (aligned with Apple's direction)
- [ ] Zero functionality regression

## Team Coordination

### iOS Team Responsibilities
- Convert private Slate repositories to SPM
- Provide SPM Package.swift templates
- Coordinate release timing

### React Native Team Responsibilities
- Execute migration phases
- Update build scripts and CI/CD
- Validate functionality after each phase
- Document new SPM workflow

## Post-Migration Benefits

1. **Performance**: Faster builds and dependency resolution
2. **Maintenance**: No more Podfile.lock merge conflicts
3. **Future-Proof**: Aligned with Apple's recommended approach
4. **Simplicity**: Native Xcode integration, no external tools required
5. **Reliability**: Better dependency version resolution

## Next Steps

1. **Immediate (Week 1)**:
   - Schedule coordination meeting with iOS team
   - Begin dependency audit
   - Create migration branch

2. **Short-term (Weeks 2-4)**:
   - Set up hybrid approach
   - Start Slate dependency conversion
   - Update CI/CD for parallel builds

3. **Long-term (Weeks 5-20)**:
   - Execute full migration plan
   - Monitor React Native SPM progress
   - Complete transition and cleanup 