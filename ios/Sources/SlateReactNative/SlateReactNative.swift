import Foundation
import UIKit
import Firebase
import SDWebImage
import MBProgressHUD

// MARK: - SPM Slate React Native Module
// This module bridges SPM dependencies to React Native

@objc public class SlateReactNativeSPM: NSObject {
    
    @objc public static let shared = SlateReactNativeSPM()
    
    private override init() {
        super.init()
    }
    
    @objc public func configure() {
        // Configure Firebase and other SPM dependencies
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    @objc public func getVersion() -> String {
        return "1.0.0-SPM"
    }
}

// MARK: - SPM Integration Helper Extensions
extension SlateReactNativeSPM {
    
    @objc public func showProgressHUD(in view: UIView, with text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = text
    }
    
    @objc public func hideProgressHUD(in view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

// MARK: - Firebase Integration
extension SlateReactNativeSPM {
    
    @objc public func configureFirebase() {
        FirebaseApp.configure()
    }
    
    @objc public func isFirebaseConfigured() -> Bool {
        return FirebaseApp.app() != nil
    }
} 