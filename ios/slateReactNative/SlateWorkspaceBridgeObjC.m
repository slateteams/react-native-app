//
//  SlateWorkspaceBridgeObjC.m
//  slateReactNative
//

#import "SlateWorkspaceBridgeObjC.h"
#import <React/RCTLog.h>

@implementation SlateWorkspaceBridgeObjC

// Export module to React Native
RCT_EXPORT_MODULE(SlateWorkspaceBridge);

// Run on main queue for UI operations
+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

// Test connection method
RCT_EXPORT_METHOD(testConnection:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *result = @{
            @"status": @"connected",
            @"message": @"Slate bridge is working!"
        };
        resolve(result);
    });
}

// Get drafts method
RCT_EXPORT_METHOD(getDrafts:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *mockDrafts = @[
            @{
                @"id": @"draft_1",
                @"title": @"My First Video Project",
                @"previewUrl": @"https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Draft+1",
                @"createdAt": @1640995200000,
                @"updatedAt": @1640995200000,
                @"approvalStatus": @0,
                @"duration": @30.5
            },
            @{
                @"id": @"draft_2",
                @"title": @"Summer Vacation Memories",
                @"previewUrl": @"https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Draft+2",
                @"createdAt": @1641081600000,
                @"updatedAt": @1641081600000,
                @"approvalStatus": @1,
                @"duration": @45.2
            },
            @{
                @"id": @"draft_3",
                @"title": @"Product Demo Video",
                @"previewUrl": @"https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Draft+3",
                @"createdAt": @1641168000000,
                @"updatedAt": @1641168000000,
                @"approvalStatus": @2,
                @"duration": @60.0
            }
        ];
        resolve(mockDrafts);
    });
}

// Open workspace method
RCT_EXPORT_METHOD(openWorkspace:(NSString *)draftId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RCTLogInfo(@"Opening workspace with draft ID: %@", draftId ?: @"new");
        
        // TODO: Integrate with actual Slate ContentEditVC
        // This is where we'll present the iOS Slate editing interface
        
        NSDictionary *result = @{
            @"success": @YES,
            @"message": @"Workspace opened (mock)"
        };
        resolve(result);
    });
}

// Create new draft method
RCT_EXPORT_METHOD(createNewDraft:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *newDraftId = [NSString stringWithFormat:@"draft_%.0f", [[NSDate date] timeIntervalSince1970]];
        RCTLogInfo(@"Creating new draft with ID: %@", newDraftId);
        
        NSDictionary *result = @{
            @"success": @YES,
            @"draftId": newDraftId
        };
        resolve(result);
    });
}

// Get recent media method
RCT_EXPORT_METHOD(getRecentMedia:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *mockMedia = @[
            @{
                @"id": @"media_1",
                @"url": @"https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1",
                @"thumbnail": @"https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1",
                @"type": @"image"
            },
            @{
                @"id": @"media_2",
                @"url": @"https://via.placeholder.com/120x120/96CEB4/FFFFFF?text=Media+2",
                @"thumbnail": @"https://via.placeholder.com/120x120/96CEB4/FFFFFF?text=Media+2",
                @"type": @"video",
                @"duration": @15.5
            },
            @{
                @"id": @"media_3",
                @"url": @"https://via.placeholder.com/120x120/FECA57/FFFFFF?text=Media+3",
                @"thumbnail": @"https://via.placeholder.com/120x120/FECA57/FFFFFF?text=Media+3",
                @"type": @"image"
            }
        ];
        resolve(mockMedia);
    });
}

@end 