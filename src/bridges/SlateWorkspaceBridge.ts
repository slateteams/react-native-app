import { NativeModules } from 'react-native';

export interface Draft {
  id: string;
  title: string;
  previewUrl: string;
  createdAt: number;
  updatedAt: number;
  approvalStatus: number;
  duration: number;
}

export interface MediaItem {
  id: string;
  url: string;
  thumbnail: string;
  type: 'image' | 'video';
  duration?: number;
}

export interface WorkspaceResult {
  success: boolean;
  message?: string;
}

export interface ConnectionTest {
  status: string;
  message: string;
}

export interface SlateWorkspaceBridgeInterface {
  /**
   * Test the connection to the native bridge
   */
  testConnection(): Promise<ConnectionTest>;
  
  /**
   * Get all drafts/projects from the iOS Slate app
   */
  getDrafts(): Promise<Draft[]>;
  
  /**
   * Open the iOS Slate workspace/editing interface
   * @param draftId Optional draft ID to open, null for new project
   */
  openWorkspace(draftId?: string | null): Promise<WorkspaceResult>;
  
  /**
   * Create a new draft
   */
  createNewDraft(): Promise<{ success: boolean; draftId: string }>;
  
  /**
   * Get recent media items from the photo library/camera roll
   */
  getRecentMedia(): Promise<MediaItem[]>;
  
  /**
   * Open the content editor directly for creating new content
   */
  openContentEditor(): Promise<WorkspaceResult>;
}

// Debug: Log available native modules
console.log('🔍 Available Native Modules:', Object.keys(NativeModules));
console.log('🔍 SlateWorkspaceBridge available:', !!NativeModules.SlateWorkspaceBridge);

const SlateWorkspaceBridgeNative = NativeModules.SlateWorkspaceBridge as SlateWorkspaceBridgeInterface;

// Export a manager class that wraps the native module
export class SlateWorkspaceManager {
  /**
   * Test the connection to the native Slate bridge
   */
  static async testConnection(): Promise<ConnectionTest> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found. Available modules: ' + Object.keys(NativeModules).join(', '));
    }
    return SlateWorkspaceBridgeNative.testConnection();
  }
  
  /**
   * Get all available drafts from the iOS Slate app
   */
  static async getDrafts(): Promise<Draft[]> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridgeNative.getDrafts();
  }
  
  /**
   * Open the iOS Slate workspace for editing
   * @param draftId Optional draft ID to edit, creates new draft if not provided
   */
  static async openWorkspace(draftId?: string): Promise<WorkspaceResult> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridgeNative.openWorkspace(draftId || null);
  }
  
  /**
   * Create a new draft in the iOS Slate app
   */
  static async createNewDraft(): Promise<{ success: boolean; draftId: string }> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridgeNative.createNewDraft();
  }
  
  /**
   * Get recent media items available for editing
   */
  static async getRecentMedia(): Promise<MediaItem[]> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridgeNative.getRecentMedia();
  }
  
  /**
   * Open the content editor directly for creating new content
   */
  static async openContentEditor(): Promise<WorkspaceResult> {
    if (!SlateWorkspaceBridgeNative) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridgeNative.openContentEditor();
  }
}

// Export both the interface and the manager
export { SlateWorkspaceBridgeNative };
export default SlateWorkspaceManager; 