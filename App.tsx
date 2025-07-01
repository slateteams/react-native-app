/**
 * Slate React Native App - iOS Workspace Integration
 * Integrates with the native iOS Slate editing capabilities
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  StatusBar,
  SafeAreaView,
  Dimensions,
  Alert,
  ActivityIndicator,
} from 'react-native';

// Import our bridge to iOS Slate functionality
import { SlateWorkspaceManager, Draft, type WorkspaceResult } from './src/bridges/SlateWorkspaceBridge';

const { width } = Dimensions.get('window');

// Mock data for recent media (to be replaced with real data later)
const recentMedia = [
  {
    id: 1,
    thumbnail: 'https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1',
  },
  {
    id: 2,
    thumbnail: 'https://via.placeholder.com/120x120/96CEB4/FFFFFF?text=Media+2',
  },
  {
    id: 3,
    thumbnail: 'https://via.placeholder.com/120x120/FECA57/FFFFFF?text=Media+3',
  },
  {
    id: 4,
    thumbnail: 'https://via.placeholder.com/120x120/6C5CE7/FFFFFF?text=Media+4',
  },
];

const App: React.FC = () => {
  const [drafts, setDrafts] = useState<Draft[]>([]);
  const [loading, setLoading] = useState(true);
  const [bridgeConnected, setBridgeConnected] = useState(false);
  const [connectionStatus, setConnectionStatus] = useState('Testing...');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // First test the bridge connection
      console.log('Testing bridge connection...');
      const connectionTest = await SlateWorkspaceManager.testConnection();
      console.log('Bridge connection test result:', connectionTest);
      setBridgeConnected(connectionTest.status === 'connected');
      setConnectionStatus(connectionTest.message);
      
      // Load drafts from iOS Slate app
      console.log('Loading drafts...');
      const loadedDrafts = await SlateWorkspaceManager.getDrafts();
      console.log('Loaded drafts:', loadedDrafts);
      setDrafts(loadedDrafts);
    } catch (error) {
      console.error('Error loading data:', error);
      setBridgeConnected(false);
      setConnectionStatus('Connection failed');
      Alert.alert('Error', 'Failed to connect to iOS Slate app');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateNew = async () => {
    try {
      console.log('Creating new draft...');
      const result = await SlateWorkspaceManager.createNewDraft();
      
      if (result.success) {
        console.log('Created new draft:', result.draftId);
        // Open the workspace with the new draft
        await handleOpenWorkspace(result.draftId);
      }
    } catch (error) {
      console.error('Error creating new draft:', error);
      Alert.alert('Error', 'Failed to create new draft');
    }
  };

  const handleOpenWorkspace = async (draftId?: string) => {
    try {
      console.log('Opening workspace with draft:', draftId || 'new');
      const result: WorkspaceResult = await SlateWorkspaceManager.openWorkspace(draftId);
      
      if (result.success) {
        console.log('Workspace opened successfully');
        // The iOS app should now be showing the Slate editing interface
        Alert.alert('Success', result.message || 'Workspace opened successfully!');
      } else {
        console.log('Failed to open workspace');
        Alert.alert('Error', 'Failed to open workspace');
      }
    } catch (error) {
      console.error('Error opening workspace:', error);
      Alert.alert('Error', 'Failed to open workspace');
    }
  };

  const handleRefresh = () => {
    loadData();
  };

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <StatusBar barStyle="light-content" backgroundColor="#1a1a1a" />
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Connecting to Slate...</Text>
          <Text style={styles.statusText}>{connectionStatus}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1a1a1a" />
      
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Slate</Text>
        <View style={styles.headerActions}>
          <View style={[styles.connectionIndicator, bridgeConnected ? styles.connected : styles.disconnected]} />
          <TouchableOpacity onPress={handleRefresh} style={styles.refreshButton}>
            <Text style={styles.refreshText}>⟳</Text>
          </TouchableOpacity>
        </View>
      </View>

      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        {/* Connection Status */}
        <View style={styles.statusContainer}>
          <Text style={styles.statusLabel}>Bridge Status:</Text>
          <Text style={[styles.statusValue, bridgeConnected ? styles.connectedText : styles.disconnectedText]}>
            {connectionStatus}
          </Text>
        </View>

        {/* Create New Project Button */}
        <TouchableOpacity style={styles.createButton} onPress={handleCreateNew}>
          <View style={styles.createButtonContent}>
            <View style={styles.createIcon}>
              <Text style={styles.createIconText}>+</Text>
            </View>
            <View style={styles.createTextContainer}>
              <Text style={styles.createTitle}>Create New Project</Text>
              <Text style={styles.createSubtitle}>Start a new video editing project</Text>
            </View>
          </View>
        </TouchableOpacity>

        {/* Recent Projects */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Projects</Text>
          
          {drafts.length > 0 ? (
            drafts.map((draft) => (
              <TouchableOpacity
                key={draft.id}
                style={styles.projectCard}
                onPress={() => handleOpenWorkspace(draft.id)}
              >
                <Image source={{ uri: draft.previewUrl }} style={styles.projectThumbnail} />
                <View style={styles.projectDetails}>
                  <Text style={styles.projectTitle}>{draft.title}</Text>
                  <Text style={styles.projectMeta}>
                    {Math.round(draft.duration)}s • {new Date(draft.createdAt).toLocaleDateString()}
                  </Text>
                  <View style={styles.projectStatus}>
                    <View style={[
                      styles.statusBadge,
                      draft.approvalStatus === 0 ? styles.draftStatus :
                      draft.approvalStatus === 1 ? styles.pendingStatus : styles.approvedStatus
                    ]}>
                      <Text style={styles.statusText}>
                        {draft.approvalStatus === 0 ? 'Draft' :
                         draft.approvalStatus === 1 ? 'Pending' : 'Approved'}
                      </Text>
                    </View>
                  </View>
                </View>
              </TouchableOpacity>
            ))
          ) : (
            <View style={styles.emptyState}>
              <Text style={styles.emptyStateText}>No projects yet</Text>
              <Text style={styles.emptyStateSubtext}>Create your first video project to get started</Text>
            </View>
          )}
        </View>

        {/* Recent Media */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Recent Media</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.mediaScroll}>
            {recentMedia.map((media) => (
              <TouchableOpacity key={media.id} style={styles.mediaItem}>
                <Image source={{ uri: media.thumbnail }} style={styles.mediaThumbnail} />
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1a1a1a',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#1a1a1a',
  },
  loadingText: {
    color: '#ffffff',
    fontSize: 18,
    marginTop: 16,
  },
  statusText: {
    color: '#888',
    fontSize: 14,
    marginTop: 8,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#333',
  },
  headerTitle: {
    color: '#ffffff',
    fontSize: 28,
    fontWeight: 'bold',
  },
  headerActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  connectionIndicator: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: 12,
  },
  connected: {
    backgroundColor: '#4CAF50',
  },
  disconnected: {
    backgroundColor: '#F44336',
  },
  refreshButton: {
    padding: 8,
  },
  refreshText: {
    color: '#007AFF',
    fontSize: 18,
  },
  scrollView: {
    flex: 1,
  },
  statusContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#2a2a2a',
    marginHorizontal: 20,
    marginTop: 16,
    borderRadius: 8,
  },
  statusLabel: {
    color: '#888',
    fontSize: 14,
  },
  statusValue: {
    fontSize: 14,
    fontWeight: '500',
  },
  connectedText: {
    color: '#4CAF50',
  },
  disconnectedText: {
    color: '#F44336',
  },
  createButton: {
    margin: 20,
    backgroundColor: '#007AFF',
    borderRadius: 12,
    overflow: 'hidden',
  },
  createButtonContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
  },
  createIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  createIconText: {
    color: '#ffffff',
    fontSize: 32,
    fontWeight: '300',
  },
  createTextContainer: {
    flex: 1,
  },
  createTitle: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 4,
  },
  createSubtitle: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
  },
  section: {
    paddingHorizontal: 20,
    marginBottom: 24,
  },
  sectionTitle: {
    color: '#ffffff',
    fontSize: 20,
    fontWeight: '600',
    marginBottom: 16,
  },
  projectCard: {
    flexDirection: 'row',
    backgroundColor: '#2a2a2a',
    borderRadius: 12,
    marginBottom: 12,
    overflow: 'hidden',
  },
  projectThumbnail: {
    width: 100,
    height: 80,
    backgroundColor: '#333',
  },
  projectDetails: {
    flex: 1,
    padding: 12,
    justifyContent: 'space-between',
  },
  projectTitle: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 4,
  },
  projectMeta: {
    color: '#888',
    fontSize: 12,
    marginBottom: 8,
  },
  projectStatus: {
    flexDirection: 'row',
  },
  statusBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
  },
  draftStatus: {
    backgroundColor: 'rgba(255, 193, 7, 0.2)',
  },
  pendingStatus: {
    backgroundColor: 'rgba(255, 152, 0, 0.2)',
  },
  approvedStatus: {
    backgroundColor: 'rgba(76, 175, 80, 0.2)',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  emptyStateText: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: '500',
    marginBottom: 8,
  },
  emptyStateSubtext: {
    color: '#888',
    fontSize: 14,
    textAlign: 'center',
  },
  mediaScroll: {
    marginHorizontal: -20,
    paddingHorizontal: 20,
  },
  mediaItem: {
    marginRight: 12,
  },
  mediaThumbnail: {
    width: 120,
    height: 120,
    borderRadius: 8,
    backgroundColor: '#333',
  },
});

export default App;
