import UIKit
import React

// Import SlateSDK modules if available
#if canImport(SlateCore)
import SlateCore
#endif

@objc(SlateWorkspaceBridge)
class SlateWorkspaceBridge: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String {
        return "SlateWorkspaceBridge"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    // MARK: - Basic Test Methods
    
    @objc func testConnection(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            resolve(["status": "connected", "message": "Slate bridge is working!"])
        }
    }
    
    @objc func getDrafts(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            // Mock data for now - will be replaced with real Slate data later
            let mockDrafts = [
                [
                    "id": "draft_1",
                    "title": "My First Video Project",
                    "previewUrl": "https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Draft+1",
                    "createdAt": 1640995200000, // Jan 1, 2022
                    "updatedAt": 1640995200000,
                    "approvalStatus": 0,
                    "duration": 30.5
                ],
                [
                    "id": "draft_2", 
                    "title": "Summer Vacation Memories",
                    "previewUrl": "https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Draft+2",
                    "createdAt": 1641081600000, // Jan 2, 2022
                    "updatedAt": 1641081600000,
                    "approvalStatus": 1,
                    "duration": 45.2
                ],
                [
                    "id": "draft_3",
                    "title": "Product Demo Video", 
                    "previewUrl": "https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Draft+3",
                    "createdAt": 1641168000000, // Jan 3, 2022
                    "updatedAt": 1641168000000,
                    "approvalStatus": 2,
                    "duration": 60.0
                ]
            ]
            resolve(mockDrafts)
        }
    }
    
    // MARK: - Content Editor Integration
    
    @objc func openWorkspace(
        _ draftId: String?,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            NSLog("🎬 Opening workspace with draft ID: \(draftId ?? "new")")
            
            // Get the root view controller
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                reject("NO_ROOT_VC", "No root view controller found", nil)
                return
            }
            
            // Create ContentEditVC using the updated SPM-compatible approach
            let contentEditVC = self.createContentEditVC(draftId: draftId)
            
            // Present the view controller
            let navigationController = UINavigationController(rootViewController: contentEditVC)
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController.present(navigationController, animated: true) {
                resolve(["success": true, "message": "Workspace opened successfully", "draftId": draftId ?? "new"])
            }
        }
    }
    
    @objc func openContentEditor(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            NSLog("🎬 Opening content editor for new project...")
            
            // Get the root view controller
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                reject("NO_ROOT_VC", "No root view controller found", nil)
                return
            }
            
            // Create ContentEditVC for new project
            let contentEditVC = self.createContentEditVC(draftId: nil)
            
            // Present the view controller
            let navigationController = UINavigationController(rootViewController: contentEditVC)
            navigationController.modalPresentationStyle = .fullScreen
            
            rootViewController.present(navigationController, animated: true) {
                resolve(["success": true, "message": "Content editor opened successfully"])
            }
        }
    }
    
    @objc func createNewDraft(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            let newDraftId = "draft_\(Date().timeIntervalSince1970)"
            NSLog("Creating new draft with ID: \(newDraftId)")
            
            resolve(["success": true, "draftId": newDraftId])
        }
    }
    
    @objc func getRecentMedia(
        _ resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            // Mock media data for now
            let mockMedia = [
                [
                    "id": "media_1",
                    "url": "https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1",
                    "thumbnail": "https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1",
                    "type": "image"
                ],
                [
                    "id": "media_2",
                    "url": "https://via.placeholder.com/120x120/96CEB4/FFFFFF?text=Media+2", 
                    "thumbnail": "https://via.placeholder.com/120x120/96CEB4/FFFFFF?text=Media+2",
                    "type": "video",
                    "duration": 15.5
                ],
                [
                    "id": "media_3",
                    "url": "https://via.placeholder.com/120x120/FECA57/FFFFFF?text=Media+3",
                    "thumbnail": "https://via.placeholder.com/120x120/FECA57/FFFFFF?text=Media+3", 
                    "type": "image"
                ]
            ]
            resolve(mockMedia)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createContentEditVC(draftId: String?) -> UIViewController {
        NSLog("📱 Creating ContentEditVC with SPM integration...")
        
        // Strategy 1: Try to use real ContentEditVC from SlateSDK (when fully integrated)
        #if canImport(SlateCore) 
        if let slateContentEditVC = createSlateSDKContentEditVC(draftId: draftId) {
            NSLog("✅ Using real ContentEditVC from SlateSDK")
            return slateContentEditVC
        }
        #endif
        
        // Strategy 2: Try to load from storyboard (legacy compatibility)
        if let storyboardVC = createContentEditVCFromStoryboard(draftId: draftId) {
            NSLog("✅ Using ContentEditVC from storyboard")
            return storyboardVC
        }
        
        // Strategy 3: Fallback to SimpleContentEditVC (always works)
        NSLog("⚠️ Using SimpleContentEditVC fallback")
        return createSimpleContentEditVC(draftId: draftId)
    }
    
    private func createSlateSDKContentEditVC(draftId: String?) -> UIViewController? {
        // This will be implemented when SlateSDK integration is complete
        // For now, return nil to fall back to other strategies
        return nil
    }
    
    private func createContentEditVCFromStoryboard(draftId: String?) -> UIViewController? {
        do {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let contentEditVC = storyboard.instantiateViewController(withIdentifier: "ContentEditVC")
            
            // Try to set draft ID if the VC supports it
            if let draftId = draftId {
                // Use reflection to safely set draftId property if it exists
                if contentEditVC.responds(to: Selector("setDraftId:")) {
                    contentEditVC.setValue(draftId, forKey: "draftId")
                }
            }
            
            return contentEditVC
        } catch {
            NSLog("❌ Failed to load ContentEditVC from storyboard: \(error)")
            return nil
        }
    }
    
    private func createSimpleContentEditVC(draftId: String?) -> UIViewController {
        let simpleVC = SimpleContentEditVC()
        simpleVC.draftId = draftId
        
        // Set up completion handler
        simpleVC.setOnComplete { [weak self] resultDraftId in
            NSLog("✅ SimpleContentEditVC completed with draft: \(resultDraftId ?? "none")")
            // Post notification for React Native to handle
            NotificationCenter.default.post(
                name: Notification.Name("SlateWorkspaceCompleted"),
                object: nil,
                userInfo: ["draftId": resultDraftId ?? ""]
            )
        }
        
        return simpleVC
    }
} 