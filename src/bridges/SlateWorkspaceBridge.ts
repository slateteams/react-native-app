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
  draftId?: string;
}

export interface ConnectionTest {
  status: string;
  message: string;
}

interface SlateWorkspaceBridgeInterface {
  testConnection(): Promise<ConnectionTest>;
  getDrafts(): Promise<Draft[]>;
  openWorkspace(draftId?: string): Promise<WorkspaceResult>;
  openContentEditor(): Promise<WorkspaceResult>;
  createNewDraft(): Promise<{ success: boolean; draftId: string }>;
  getRecentMedia(): Promise<MediaItem[]>;
}

export const SlateWorkspaceBridge: SlateWorkspaceBridgeInterface = NativeModules.SlateWorkspaceBridge;

// Helper functions for easier usage
export class SlateWorkspace {
  static async testConnection(): Promise<boolean> {
    try {
      const result = await SlateWorkspaceBridge.testConnection();
      console.log('🎬 Slate Connection Test:', result);
      return result.status === 'connected';
    } catch (error) {
      console.error('❌ Slate Connection Failed:', error);
      return false;
    }
  }

  static async openEditor(draftId?: string): Promise<boolean> {
    try {
      if (draftId) {
        const result = await SlateWorkspaceBridge.openWorkspace(draftId);
        console.log('🎬 Opened workspace:', result);
        return result.success;
      } else {
        const result = await SlateWorkspaceBridge.openContentEditor();
        console.log('🎬 Opened content editor:', result);
        return result.success;
      }
    } catch (error) {
      console.error('❌ Failed to open editor:', error);
      return false;
    }
  }

  static async createNewProject(): Promise<string | null> {
    try {
      const result = await SlateWorkspaceBridge.createNewDraft();
      if (result.success) {
        console.log('🎬 Created new draft:', result.draftId);
        return result.draftId;
      }
      return null;
    } catch (error) {
      console.error('❌ Failed to create new draft:', error);
      return null;
    }
  }

  static async getDrafts(): Promise<Draft[]> {
    try {
      const drafts = await SlateWorkspaceBridge.getDrafts();
      console.log('🎬 Retrieved drafts:', drafts.length);
      return drafts;
    } catch (error) {
      console.error('❌ Failed to get drafts:', error);
      return [];
    }
  }

  static async getRecentMedia(): Promise<MediaItem[]> {
    try {
      const media = await SlateWorkspaceBridge.getRecentMedia();
      console.log('🎬 Retrieved media:', media.length);
      return media;
    } catch (error) {
      console.error('❌ Failed to get recent media:', error);
      return [];
    }
  }
}

// Debug: Log available native modules
console.log('🔍 Available Native Modules:', Object.keys(NativeModules));
console.log('🔍 SlateWorkspaceBridge available:', !!NativeModules.SlateWorkspaceBridge);

// Export a manager class that wraps the native module  
export class SlateWorkspaceManager {
  /**
   * Test the connection to the native Slate bridge
   */
  static async testConnection(): Promise<ConnectionTest> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found. Available modules: ' + Object.keys(NativeModules).join(', '));
    }
    return SlateWorkspaceBridge.testConnection();
  }
  
  /**
   * Get all available drafts from the iOS Slate app
   */
  static async getDrafts(): Promise<Draft[]> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridge.getDrafts();
  }
  
  /**
   * Open the iOS Slate workspace for editing
   * @param draftId Optional draft ID to edit, creates new draft if not provided
   */
  static async openWorkspace(draftId?: string): Promise<WorkspaceResult> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridge.openWorkspace(draftId);
  }
  
  /**
   * Create a new draft in the iOS Slate app
   */
  static async createNewDraft(): Promise<{ success: boolean; draftId: string }> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridge.createNewDraft();
  }
  
  /**
   * Get recent media items available for editing
   */
  static async getRecentMedia(): Promise<MediaItem[]> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridge.getRecentMedia();
  }
  
  /**
   * Open the content editor directly for creating new content
   */
  static async openContentEditor(): Promise<WorkspaceResult> {
    if (!SlateWorkspaceBridge) {
      throw new Error('SlateWorkspaceBridge native module not found');
    }
    return SlateWorkspaceBridge.openContentEditor();
  }
}

export default SlateWorkspaceManager; 