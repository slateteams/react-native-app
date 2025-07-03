# SPM Migration Checklist for SlateReactNative

## Pre-Migration Setup

### 📋 Planning & Coordination
- [ ] Schedule kick-off meeting with iOS team
- [ ] Assign team member responsibilities
- [ ] Create Slack channel for migration updates
- [ ] Set up weekly progress reviews
- [ ] Document current baseline metrics (build times, etc.)

### 🔍 Analysis & Assessment
- [ ] Run dependency analysis: `./scripts/spm-migration-tools.sh analyze`
- [ ] Document all current dependencies with versions
- [ ] Identify which dependencies have SPM support
- [ ] Catalog Slate-specific dependencies that need conversion
- [ ] Review React Native 0.80.0 SPM compatibility

### 🛠️ Environment Setup
- [ ] Verify Xcode version (15.0+ recommended for SPM)
- [ ] Update Command Line Tools
- [ ] Ensure Swift 5.9+ availability
- [ ] Set up clean development environment
- [ ] Install/update Bundler for CocoaPods management

## Phase 1: Infrastructure Setup (Weeks 1-2)

### 🔄 Version Control
- [ ] Create migration branch: `git checkout -b feature/spm-migration`
- [ ] Create backup: `./scripts/spm-migration-tools.sh backup`
- [ ] Tag current state: `git tag spm-migration-start`
- [ ] Push branch to remote for team visibility

### 📦 Initial SPM Structure
- [ ] Create Package.swift: `./scripts/spm-migration-tools.sh create-package`
- [ ] Validate Package.swift syntax: `./scripts/spm-migration-tools.sh validate`
- [ ] Create Sources directory structure
- [ ] Set up resource handling for SPM
- [ ] Configure basic target dependencies

### 🧪 Testing Infrastructure
- [ ] Set up parallel build environments
- [ ] Configure CI/CD for both CocoaPods and SPM builds
- [ ] Create automated testing pipeline
- [ ] Set up performance monitoring for build times
- [ ] Document rollback procedures

## Phase 2: Dependency Conversion (Weeks 3-8)

### 🔥 Firebase Migration
- [ ] Add Firebase SPM dependency to Package.swift
- [ ] Update FirebaseCore configuration
- [ ] Migrate FirebaseAuth integration
- [ ] Convert FirebaseAnalytics setup
- [ ] Update FirebaseCrashlytics configuration
- [ ] Migrate FirebaseStorage usage
- [ ] Convert FirebaseRemoteConfig
- [ ] Update FirebasePerformance setup
- [ ] Test all Firebase functionality
- [ ] Remove Firebase from Podfile

### 📱 Third-Party Libraries
- [ ] **SDWebImage**
  - [ ] Add to Package.swift
  - [ ] Test image loading functionality
  - [ ] Remove from Podfile
- [ ] **MBProgressHUD**
  - [ ] Add to Package.swift
  - [ ] Test progress indicator functionality
  - [ ] Remove from Podfile
- [ ] **CocoaLumberjack**
  - [ ] Add to Package.swift
  - [ ] Test logging functionality
  - [ ] Remove from Podfile
- [ ] **Alamofire** (if used directly)
  - [ ] Add to Package.swift
  - [ ] Test networking functionality
  - [ ] Remove from Podfile

### 🏢 Slate Dependencies Conversion
Priority order based on dependency tree:

#### 1. Foundation Library (ios-fm-lib)
- [ ] Create SPM repository: `ios-fm-lib-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template FMLib 1.1.32`
- [ ] Convert FMCore module
- [ ] Convert FMResponsiveUI module
- [ ] Convert FMUserActions module
- [ ] Update dependencies: CocoaLumberjack, DatadogSDK, ReachabilitySwift
- [ ] Test all FMLib functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift to use SPM version

#### 2. Rendering Library (ios-fm-rendering)
- [ ] Create SPM repository: `ios-fm-rendering-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template FMRendering 1.2.5`
- [ ] Convert source files
- [ ] Update FMLib dependency to SPM version
- [ ] Test rendering functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 3. Server Data Library (ios-server-data)
- [ ] Create SPM repository: `ios-server-data-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test data handling functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 4. Sharing Library (ios-fm-sharing)
- [ ] Create SPM repository: `ios-fm-sharing-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template FMSharing 1.1.10`
- [ ] Convert source files
- [ ] Update dependencies (FBSDKCoreKit, FBSDKShareKit)
- [ ] Test sharing functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 5. Text View Library (ios-fm-textview)
- [ ] Create SPM repository: `ios-fm-textview-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template FMTextView 1.2.4`
- [ ] Convert source files
- [ ] Update dependencies (MenuItemKit)
- [ ] Test text editing functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 6. NFL Sharing Library (ios-nfl-sharing)
- [ ] Create SPM repository: `ios-nfl-sharing-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template NFLSharing 1.0.5`
- [ ] Convert source files
- [ ] Update complex dependencies (Firebase, CryptoSwift, etc.)
- [ ] Test NFL-specific functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 7. NFL Football API (ios-nfl-football-api)
- [ ] Create SPM repository: `ios-nfl-football-api-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template NFLFootballApi 1.4.4`
- [ ] Convert source files
- [ ] Update Alamofire dependency
- [ ] Test API functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 8. NFL ID API (ios-nfl-id-api)
- [ ] Create SPM repository: `ios-nfl-id-api-spm`
- [ ] Generate template: `./scripts/spm-migration-tools.sh template NFLIDApi 1.0.0`
- [ ] Convert source files
- [ ] Update Alamofire dependency
- [ ] Test ID API functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 9. App Data Library (ios-app-data)
- [ ] Create SPM repository: `ios-app-data-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test data functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 10. API Library (ios-api)
- [ ] Create SPM repository: `ios-api-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test API functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 11. PhotoShelter Integration (ios-integration-photoshelter)
- [ ] Create SPM repository: `ios-integration-photoshelter-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test PhotoShelter integration
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 12. Slack Integration (ios-integration-slack)
- [ ] Create SPM repository: `ios-integration-slack-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test Slack integration
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 13. Getty Integration (ios-integration-getty)
- [ ] Create SPM repository: `ios-integration-getty-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test Getty integration
- [ ] Publish SPM package
- [ ] Update main Package.swift

#### 14. Effects Library (ios-effects)
- [ ] Create SPM repository: `ios-effects-spm`
- [ ] Convert source files
- [ ] Update dependencies
- [ ] Test effects functionality
- [ ] Publish SPM package
- [ ] Update main Package.swift

## Phase 3: Hybrid Mode Setup (Weeks 9-10)

### 🔄 Hybrid Configuration
- [ ] Create hybrid Podfile: `./scripts/smp-migration-tools.sh create-hybrid`
- [ ] Remove all non-React Native dependencies from Podfile
- [ ] Update Xcode project to include SPM packages
- [ ] Configure build settings for SPM compatibility
- [ ] Test hybrid build: `./scripts/spm-migration-tools.sh build`

### 📱 Xcode Project Updates
- [ ] Add SPM packages via File → Add Package Dependencies
- [ ] Remove old CocoaPods framework references
- [ ] Update target dependencies
- [ ] Configure build settings:
  - [ ] `SWIFT_PACKAGE_MANAGER_ENABLED = YES`
  - [ ] `PACKAGE_RESOURCE_BUNDLE_FORMAT = automatic`
- [ ] Update scheme configurations
- [ ] Test all build configurations (Debug/Release)

### 🧪 Functionality Testing
- [ ] Test app launch and basic functionality
- [ ] Verify all Slate features work correctly
- [ ] Test Firebase integration
- [ ] Test third-party library functionality
- [ ] Run full test suite
- [ ] Performance testing (build times, app startup)

## Phase 4: React Native SPM Integration (Weeks 11-16)

### 🔍 React Native SPM Progress Monitoring
- [ ] Monitor React Native SPM support development
- [ ] Test React Native 0.81+ for SPM compatibility
- [ ] Evaluate React Native community SPM solutions
- [ ] Consider React Native upgrade if beneficial

### 🌉 Custom SPM Bridge (If Needed)
- [ ] Create ReactNativeBridge SPM package
- [ ] Configure binary framework distribution
- [ ] Update project to use React Native SPM bridge
- [ ] Test React Native functionality with SPM bridge
- [ ] Document custom bridge approach

### 📦 Complete SPM Migration
- [ ] Update Package.swift with all dependencies
- [ ] Remove CocoaPods completely:
  - [ ] Delete Podfile
  - [ ] Delete Podfile.lock
  - [ ] Remove Pods directory
  - [ ] Clean Xcode project of CocoaPods references
  - [ ] Remove workspace file (if using project directly)
- [ ] Final build and test: `./scripts/spm-migration-tools.sh build`

## Phase 5: Finalization & Cleanup (Weeks 17-20)

### 🧹 Project Cleanup
- [ ] Remove all CocoaPods-related files
- [ ] Clean up Xcode project build phases
- [ ] Remove unused build settings
- [ ] Update .gitignore for SPM
- [ ] Remove CocoaPods from CI/CD scripts

### 📖 Documentation Updates
- [ ] Update README with SPM instructions
- [ ] Document new build process
- [ ] Create SPM troubleshooting guide
- [ ] Update team onboarding documentation
- [ ] Document performance improvements

### 🧪 Final Validation
- [ ] Complete regression testing
- [ ] Performance benchmarking
- [ ] CI/CD pipeline validation
- [ ] Team testing and sign-off
- [ ] Staging environment deployment

### 🎉 Launch & Communication
- [ ] Merge SPM migration branch to main
- [ ] Deploy to production
- [ ] Communicate success to stakeholders
- [ ] Share performance metrics
- [ ] Archive migration documentation

## Post-Migration Tasks

### 📊 Performance Monitoring
- [ ] Monitor build time improvements
- [ ] Track dependency resolution speed
- [ ] Monitor app performance metrics
- [ ] Collect team feedback

### 🛠️ Maintenance Setup
- [ ] Set up SPM dependency update process
- [ ] Configure automated security scanning
- [ ] Establish SPM best practices
- [ ] Plan regular dependency audits

### 📚 Knowledge Sharing
- [ ] Conduct SPM training sessions
- [ ] Create troubleshooting documentation
- [ ] Share lessons learned with other teams
- [ ] Update development guidelines

## Emergency Procedures

### 🚨 Rollback Plan
- [ ] Document rollback procedures
- [ ] Test rollback process: `./scripts/spm-migration-tools.sh revert`
- [ ] Maintain CocoaPods backup until migration is stable
- [ ] Establish communication protocols for issues

### 🔧 Common Issues Resolution
- [ ] Build failures
- [ ] Dependency conflicts
- [ ] Performance regressions
- [ ] Integration test failures

## Success Metrics

### 📈 Performance Improvements
- [ ] Build time: Target 20-30% improvement
- [ ] Dependency resolution: Target 50% improvement
- [ ] Project size reduction
- [ ] Developer experience improvements

### ✅ Quality Metrics
- [ ] Zero functionality regression
- [ ] All tests passing
- [ ] No new crashes or issues
- [ ] Team productivity maintained or improved

---

## Migration Status

**Current Phase**: Planning
**Progress**: 0%
**Next Milestone**: Phase 1 Infrastructure Setup
**ETA**: TBD

**Last Updated**: $(date +%Y-%m-%d)
**Updated By**: Migration Team 