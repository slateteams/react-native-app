#!/bin/bash

# SPM Migration Tools for SlateReactNative
# This script provides utility functions for migrating from CocoaPods to SPM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to analyze current CocoaPods dependencies
analyze_dependencies() {
    log_info "Analyzing current CocoaPods dependencies..."
    
    if [[ ! -f "ios/Podfile.lock" ]]; then
        log_error "Podfile.lock not found. Please run 'pod install' first."
        return 1
    fi
    
    cd ios
    
    # Extract pod names and versions
    log_info "Current CocoaPods dependencies:"
    grep -A 1000000 "PODS:" Podfile.lock | grep -E "^  - " | head -50
    
    # Check for SPM availability
    log_info "Checking SPM availability for major dependencies..."
    
    # List of dependencies we know have SPM support
    SPM_AVAILABLE=(
        "Firebase"
        "SDWebImage" 
        "MBProgressHUD"
        "CocoaLumberjack"
        "Alamofire"
    )
    
    for dep in "${SPM_AVAILABLE[@]}"; do
        if grep -q "$dep" Podfile.lock; then
            log_success "$dep - SPM available"
        fi
    done
    
    cd ..
}

# Function to create initial Package.swift
create_package_swift() {
    log_info "Creating initial Package.swift..."
    
    if [[ -f "ios/Package.swift" ]]; then
        log_warning "Package.swift already exists. Creating backup..."
        cp ios/Package.swift ios/Package.swift.backup
    fi
    
    cat > ios/Package.swift << 'EOF'
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
        // Firebase Suite (SPM Available)
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        
        // Third-party libraries (SPM Available)
        .package(url: "https://github.com/SDWebImage/SDWebImage", from: "5.12.0"),
        .package(url: "https://github.com/jdg/MBProgressHUD", from: "1.2.0"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.6.2"),
        
        // TODO: Add Slate dependencies when available
        // .package(url: "https://github.com/slateteams/ios-fm-lib-spm", from: "1.1.32"),
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
                .product(name: "SDWebImage", package: "SDWebImage"),
                .product(name: "MBProgressHUD", package: "MBProgressHUD"),
                .product(name: "CocoaLumberjack", package: "CocoaLumberjack"),
                // TODO: Add Slate dependencies
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
EOF
    
    log_success "Package.swift created at ios/Package.swift"
}

# Function to create hybrid Podfile (React Native only)
create_hybrid_podfile() {
    log_info "Creating hybrid Podfile (React Native only)..."
    
    if [[ -f "ios/Podfile" ]]; then
        log_warning "Backing up existing Podfile..."
        cp ios/Podfile ios/Podfile.cocoapods.backup
    fi
    
    cat > ios/Podfile << 'EOF'
# Hybrid Podfile - React Native only (other deps via SPM)
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, '16.0'
prepare_react_native_project!

use_frameworks! :linkage => :static

target 'slateReactNative' do
  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    :app_path => "#{Pod::Config.instance.installation_root}/..",
    :hermes_enabled => true,
    :fabric_enabled => true
  )

  # ONLY React Native dependencies - everything else via SPM
  # Removed all Slate and third-party dependencies
  
  post_install do |installer|
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false
    )
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
        config.build_settings['ENABLE_BITCODE'] = 'NO'
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        # Enable SPM compatibility
        config.build_settings['SWIFT_PACKAGE_MANAGER_ENABLED'] = 'YES'
        config.build_settings['PACKAGE_RESOURCE_BUNDLE_FORMAT'] = 'automatic'
      end
    end
  end
end
EOF
    
    log_success "Hybrid Podfile created"
}

# Function to backup current state
backup_current_state() {
    local backup_dir="migration-backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup in $backup_dir..."
    
    mkdir -p "$backup_dir"
    
    # Backup key files
    [[ -f "ios/Podfile" ]] && cp ios/Podfile "$backup_dir/"
    [[ -f "ios/Podfile.lock" ]] && cp ios/Podfile.lock "$backup_dir/"
    [[ -d "ios/Pods" ]] && cp -r ios/Pods "$backup_dir/"
    [[ -f "ios/slateReactNative.xcodeproj/project.pbxproj" ]] && cp ios/slateReactNative.xcodeproj/project.pbxproj "$backup_dir/"
    [[ -f "ios/slateReactNative.xcworkspace/contents.xcworkspacedata" ]] && cp ios/slateReactNative.xcworkspace/contents.xcworkspacedata "$backup_dir/"
    
    log_success "Backup created in $backup_dir"
}

# Function to clean derived data
clean_derived_data() {
    log_info "Cleaning Xcode derived data..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/slateReactNative-*
    log_success "Derived data cleaned"
}

# Function to validate SPM setup
validate_spm_setup() {
    log_info "Validating SPM setup..."
    
    cd ios
    
    if [[ ! -f "Package.swift" ]]; then
        log_error "Package.swift not found"
        return 1
    fi
    
    # Basic syntax check
    if swift package dump-package > /dev/null 2>&1; then
        log_success "Package.swift syntax is valid"
    else
        log_error "Package.swift has syntax errors"
        return 1
    fi
    
    cd ..
}

# Function to generate SPM template for Slate dependency
generate_slate_spm_template() {
    local repo_name="$1"
    local version="$2"
    
    if [[ -z "$repo_name" || -z "$version" ]]; then
        log_error "Usage: generate_slate_spm_template <repo_name> <version>"
        return 1
    fi
    
    local template_dir="spm-templates/$repo_name-spm"
    mkdir -p "$template_dir"
    
    cat > "$template_dir/Package.swift" << EOF
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "${repo_name}",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "${repo_name}",
            targets: ["${repo_name}"]
        ),
    ],
    dependencies: [
        // Add dependencies here based on original podspec
        // Example:
        // .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack", from: "3.6.2"),
    ],
    targets: [
        .target(
            name: "${repo_name}",
            dependencies: [
                // Map dependencies here
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "${repo_name}Tests",
            dependencies: ["${repo_name}"]
        ),
    ]
)
EOF
    
    # Create directory structure
    mkdir -p "$template_dir/Sources/$repo_name"
    mkdir -p "$template_dir/Tests/${repo_name}Tests"
    mkdir -p "$template_dir/Sources/Resources"
    
    cat > "$template_dir/README.md" << EOF
# $repo_name SPM Package

This is the Swift Package Manager version of the original \`$repo_name\` CocoaPods dependency.

## Installation

\`\`\`swift
.package(url: "https://github.com/slateteams/${repo_name}-spm", from: "$version")
\`\`\`

## Usage

\`\`\`swift
import $repo_name
\`\`\`

## Migration Notes

- Original CocoaPods version: $version
- Converted to SPM: $(date +%Y-%m-%d)

## TODO

- [ ] Copy source files from original repository
- [ ] Update dependencies in Package.swift
- [ ] Update import statements if needed
- [ ] Add tests
- [ ] Update documentation
EOF
    
    log_success "SPM template created for $repo_name at $template_dir"
}

# Function to check build after changes
check_build() {
    log_info "Checking build..."
    
    cd ios
    
    # Clean first
    if [[ -f "Podfile" ]]; then
        log_info "Running pod install..."
        bundle exec pod install --repo-update
    fi
    
    log_info "Building project..."
    xcodebuild -workspace slateReactNative.xcworkspace -scheme slateReactNative -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build
    
    if [[ $? -eq 0 ]]; then
        log_success "Build succeeded!"
    else
        log_error "Build failed!"
        return 1
    fi
    
    cd ..
}

# Function to show migration status
show_migration_status() {
    log_info "Migration Status:"
    
    echo "📁 Project Structure:"
    [[ -f "ios/Package.swift" ]] && echo "  ✅ Package.swift exists" || echo "  ❌ Package.swift missing"
    [[ -f "ios/Podfile" ]] && echo "  ✅ Podfile exists" || echo "  ❌ Podfile missing"
    [[ -d "ios/Pods" ]] && echo "  ⚠️  Pods directory exists" || echo "  ✅ Pods directory removed"
    [[ -f "ios/Podfile.lock" ]] && echo "  ⚠️  Podfile.lock exists" || echo "  ✅ Podfile.lock removed"
    
    echo ""
    echo "📦 Dependencies:"
    if [[ -f "ios/Package.swift" ]]; then
        cd ios
        swift package show-dependencies 2>/dev/null || echo "  ❌ Cannot resolve SPM dependencies"
        cd ..
    fi
    
    echo ""
    echo "🔧 Build Status:"
    if [[ -d "ios/Pods" ]]; then
        echo "  ⚠️  Using CocoaPods (hybrid mode)"
    else
        echo "  ✅ Fully migrated to SPM"
    fi
}

# Function to revert to CocoaPods (emergency rollback)
revert_to_cocoapods() {
    log_warning "Reverting to CocoaPods..."
    
    if [[ -f "ios/Podfile.cocoapods.backup" ]]; then
        cp ios/Podfile.cocoapods.backup ios/Podfile
        log_success "Restored original Podfile"
    else
        log_error "No Podfile backup found!"
        return 1
    fi
    
    cd ios
    bundle exec pod install
    cd ..
    
    log_success "Reverted to CocoaPods successfully"
}

# Main command dispatcher
case "${1:-help}" in
    "analyze")
        analyze_dependencies
        ;;
    "backup")
        backup_current_state
        ;;
    "create-package")
        create_package_swift
        ;;
    "create-hybrid")
        create_hybrid_podfile
        ;;
    "clean")
        clean_derived_data
        ;;
    "validate")
        validate_spm_setup
        ;;
    "template")
        generate_slate_spm_template "$2" "$3"
        ;;
    "build")
        check_build
        ;;
    "status")
        show_migration_status
        ;;
    "revert")
        revert_to_cocoapods
        ;;
    "help"|*)
        echo "SPM Migration Tools"
        echo ""
        echo "Usage: $0 <command> [arguments]"
        echo ""
        echo "Commands:"
        echo "  analyze          - Analyze current CocoaPods dependencies"
        echo "  backup           - Create backup of current state"
        echo "  create-package   - Create initial Package.swift"
        echo "  create-hybrid    - Create hybrid Podfile (React Native only)"
        echo "  clean            - Clean Xcode derived data"
        echo "  validate         - Validate SPM setup"
        echo "  template <name> <version> - Generate SPM template for Slate dependency"
        echo "  build            - Check build after changes"
        echo "  status           - Show migration status"
        echo "  revert           - Revert to CocoaPods (emergency rollback)"
        echo "  help             - Show this help"
        echo ""
        echo "Example workflow:"
        echo "  $0 backup"
        echo "  $0 analyze"
        echo "  $0 create-package"
        echo "  $0 create-hybrid"
        echo "  $0 build"
        echo "  $0 status"
        ;;
esac 