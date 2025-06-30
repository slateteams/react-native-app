/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
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
} from 'react-native';

const { width } = Dimensions.get('window');

// Mock data for recent projects
const recentProjects = [
  {
    id: 1,
    title: 'New 02-06-2025',
    duration: '9:16',
    lastEdited: 'Last edited 1w ago',
    thumbnail: 'https://via.placeholder.com/150x200/4A5568/FFFFFF?text=Video+1',
  },
  {
    id: 2,
    title: 'New 02-06-2025',
    duration: '0:32',
    lastEdited: 'Last edited 1w ago', 
    thumbnail: 'https://via.placeholder.com/150x200/2D3748/FFFFFF?text=Video+2',
  },
];

// Mock data for recent media
const recentMedia = [
  {
    id: 1,
    thumbnail: 'https://via.placeholder.com/120x120/E53E3E/FFFFFF?text=Media+1',
  },
  {
    id: 2,
    thumbnail: 'https://via.placeholder.com/120x120/3182CE/FFFFFF?text=Media+2',
  },
  {
    id: 3,
    thumbnail: 'https://via.placeholder.com/120x120/38A169/FFFFFF?text=Media+3',
  },
];

const quickStartOptions = [
  { id: 1, title: 'Template', icon: '📋' },
  { id: 2, title: 'Denoise', icon: '🔊' },
  { id: 3, title: 'Layout', icon: '📱' },
  { id: 4, title: 'Extract Audio', icon: '🎵' },
  { id: 5, title: 'Remove BG', icon: '🖼️' },
  { id: 6, title: 'Add caption', icon: '💬' },
];

const Header = () => (
  <View style={styles.header}>
    <Text style={styles.headerTitle}>Create</Text>
    <View style={styles.headerIcons}>
      <TouchableOpacity style={styles.headerIcon}>
        <Text style={styles.headerIconText}>🔔</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.headerIcon}>
        <View style={styles.profileIcon}>
          <Text style={styles.profileText}>🏀</Text>
        </View>
      </TouchableOpacity>
    </View>
  </View>
);

const StartProjectButton = () => (
  <TouchableOpacity style={styles.startProjectButton}>
    <Text style={styles.startProjectText}>Start new project</Text>
    <Text style={styles.startProjectArrow}>→</Text>
  </TouchableOpacity>
);

const QuickStartGrid = () => (
  <View style={styles.section}>
    <Text style={styles.sectionTitle}>Quick Start</Text>
    <View style={styles.quickStartGrid}>
      {quickStartOptions.map((option) => (
        <TouchableOpacity key={option.id} style={styles.quickStartOption}>
          <Text style={styles.quickStartIcon}>{option.icon}</Text>
          <Text style={styles.quickStartText}>{option.title}</Text>
          <Text style={styles.quickStartArrow}>›</Text>
        </TouchableOpacity>
      ))}
    </View>
  </View>
);

const RecentProjects = () => (
  <View style={styles.section}>
    <View style={styles.sectionHeader}>
      <Text style={styles.sectionTitle}>Recent Projects</Text>
      <TouchableOpacity>
        <Text style={styles.seeAllText}>See all</Text>
      </TouchableOpacity>
    </View>
    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.horizontalScroll}>
      {recentProjects.map((project) => (
        <TouchableOpacity key={project.id} style={styles.projectCard}>
          <View style={styles.projectThumbnail}>
            <Image source={{ uri: project.thumbnail }} style={styles.thumbnailImage} />
            <View style={styles.durationBadge}>
              <Text style={styles.durationText}>{project.duration}</Text>
            </View>
            <View style={styles.recordingIndicator} />
          </View>
          <View style={styles.projectInfo}>
            <Text style={styles.projectTitle}>{project.title}</Text>
            <Text style={styles.projectSubtitle}>{project.lastEdited}</Text>
          </View>
          <TouchableOpacity style={styles.projectMenu}>
            <Text style={styles.menuDots}>⋮</Text>
          </TouchableOpacity>
        </TouchableOpacity>
      ))}
    </ScrollView>
  </View>
);

const RecentMedia = () => (
  <View style={styles.section}>
    <View style={styles.sectionHeader}>
      <Text style={styles.sectionTitle}>Recent Media</Text>
      <TouchableOpacity>
        <Text style={styles.seeAllText}>See all</Text>
      </TouchableOpacity>
    </View>
    <ScrollView horizontal showsHorizontalScrollIndicator={false} style={styles.horizontalScroll}>
      {recentMedia.map((media) => (
        <TouchableOpacity key={media.id} style={styles.mediaCard}>
          <Image source={{ uri: media.thumbnail }} style={styles.mediaImage} />
        </TouchableOpacity>
      ))}
    </ScrollView>
  </View>
);

const BottomNavigation = () => (
  <View style={styles.bottomNav}>
    <TouchableOpacity style={styles.navItem}>
      <Text style={[styles.navIcon, styles.activeNavIcon]}>✨</Text>
    </TouchableOpacity>
    <TouchableOpacity style={styles.navItem}>
      <Text style={styles.navIcon}>📺</Text>
    </TouchableOpacity>
    <TouchableOpacity style={styles.navItem}>
      <Text style={styles.navIcon}>🖼️</Text>
    </TouchableOpacity>
    <TouchableOpacity style={styles.navItem}>
      <Text style={styles.navIcon}>📤</Text>
    </TouchableOpacity>
    <TouchableOpacity style={styles.navItem}>
      <Text style={styles.navIcon}>📋</Text>
    </TouchableOpacity>
  </View>
);

const App = () => {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#1A1A1A" />
      <Header />
      <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
        <View style={styles.content}>
          <StartProjectButton />
          <QuickStartGrid />
          <RecentProjects />
          <RecentMedia />
        </View>
      </ScrollView>
      <BottomNavigation />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#1A1A1A',
  },
  scrollView: {
    flex: 1,
  },
  content: {
    paddingBottom: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
    backgroundColor: '#1A1A1A',
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  headerIcons: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  headerIcon: {
    marginLeft: 15,
  },
  headerIconText: {
    fontSize: 20,
    color: '#FFFFFF',
  },
  profileIcon: {
    width: 35,
    height: 35,
    borderRadius: 20,
    backgroundColor: '#E53E3E',
    justifyContent: 'center',
    alignItems: 'center',
  },
  profileText: {
    fontSize: 16,
  },
  startProjectButton: {
    backgroundColor: '#48BB78',
    marginHorizontal: 20,
    marginVertical: 20,
    paddingVertical: 18,
    paddingHorizontal: 25,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  startProjectText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '600',
  },
  startProjectArrow: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: 'bold',
  },
  section: {
    marginBottom: 30,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    marginBottom: 15,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  seeAllText: {
    fontSize: 16,
    color: '#A0AEC0',
  },
  quickStartGrid: {
    paddingHorizontal: 20,
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  quickStartOption: {
    width: (width - 60) / 2,
    backgroundColor: '#2D3748',
    padding: 15,
    borderRadius: 12,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
  },
  quickStartIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  quickStartText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
    flex: 1,
  },
  quickStartArrow: {
    color: '#A0AEC0',
    fontSize: 18,
  },
  horizontalScroll: {
    paddingLeft: 20,
  },
  projectCard: {
    marginRight: 15,
    width: 200,
  },
  projectThumbnail: {
    position: 'relative',
    borderRadius: 12,
    overflow: 'hidden',
    marginBottom: 10,
  },
  thumbnailImage: {
    width: 200,
    height: 250,
    backgroundColor: '#2D3748',
  },
  durationBadge: {
    position: 'absolute',
    bottom: 10,
    left: 10,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
  },
  durationText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '500',
  },
  recordingIndicator: {
    position: 'absolute',
    top: 10,
    left: 10,
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#E53E3E',
  },
  projectInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
  },
  projectTitle: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '500',
    flex: 1,
  },
  projectSubtitle: {
    color: '#A0AEC0',
    fontSize: 14,
    marginTop: 2,
  },
  projectMenu: {
    padding: 5,
  },
  menuDots: {
    color: '#A0AEC0',
    fontSize: 16,
  },
  mediaCard: {
    marginRight: 15,
  },
  mediaImage: {
    width: 120,
    height: 120,
    borderRadius: 12,
    backgroundColor: '#2D3748',
  },
  bottomNav: {
    flexDirection: 'row',
    backgroundColor: '#2D3748',
    paddingVertical: 15,
    paddingHorizontal: 20,
    justifyContent: 'space-around',
    borderTopWidth: 1,
    borderTopColor: '#4A5568',
  },
  navItem: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  navIcon: {
    fontSize: 22,
    color: '#A0AEC0',
  },
  activeNavIcon: {
    color: '#48BB78',
  },
});

export default App;
