import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Dimensions,
  StyleSheet,
  SafeAreaView,
  StatusBar,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import AIBubble from '../components/AIBubble';

const { width, height } = Dimensions.get('window');

interface FeatureCard {
  id: string;
  title: string;
  description: string;
  icon: keyof typeof Ionicons.glyphMap;
  color: string;
  gradientColors: [string, string];
  screen: string;
}

const features: FeatureCard[] = [
  {
    id: '1',
    title: 'Camera',
    description: 'Capture moments',
    icon: 'camera',
    color: '#5DADE2',
    gradientColors: ['#5DADE2', '#3498DB'],
    screen: 'Home',
  },
  {
    id: '2',
    title: 'Life Chapters',
    description: 'View photos',
    icon: 'images',
    color: '#9B59B6',
    gradientColors: ['#9B59B6', '#8E44AD'],
    screen: 'Gallery',
  },
  {
    id: '3',
    title: 'Memories',
    description: 'Relive moments',
    icon: 'time',
    color: '#E74C3C',
    gradientColors: ['#E74C3C', '#C0392B'],
    screen: 'Notifications',
  },
  {
    id: '4',
    title: 'Feed',
    description: 'Family updates',
    icon: 'heart',
    color: '#E91E63',
    gradientColors: ['#E91E63', '#C2185B'],
    screen: 'Feed',
  },
];

// Daily Photo Goal with Milestones
const dailyPhotoGoal = {
  title: 'Daily Photo Goal',
  current: 7,
  milestones: [
    { value: 3, icon: 'star', color: '#F39C12', label: '3' },
    { value: 7, icon: 'trophy', color: '#E74C3C', label: '7' },
    { value: 12, icon: 'medal', color: '#9B59B6', label: '12' },
    { value: 15, icon: 'ribbon', color: '#E91E63', label: '15' },
  ],
  maxValue: 15,
  progressColor: '#4CAF50',
};

export default function DashboardScreen() {
  const navigation = useNavigation();

  const handleCardPress = (screen: string) => {
    // @ts-ignore - Navigation type
    navigation.navigate(screen);
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.headerButton}
          onPress={() => {
            // @ts-ignore
            navigation.navigate('Profile');
          }}
        >
          <Ionicons name="person-circle-outline" size={32} color="#2C3E50" />
        </TouchableOpacity>
        
        <View style={styles.headerCenter}>
          <Text style={styles.appName}>Cira</Text>
        </View>
        
        <View style={styles.headerRightButtons}>
          <TouchableOpacity 
            style={styles.headerButton}
            onPress={() => {
              // @ts-ignore
              navigation.navigate('Notifications');
            }}
          >
            <Ionicons name="notifications-outline" size={28} color="#2C3E50" />
          </TouchableOpacity>
        </View>
      </View>

      {/* Subtitle */}
      <View style={styles.subtitleContainer}>
        <Text style={styles.subtitle}>Family Photo Sharing</Text>
        <Text style={styles.description}>
          Capture, share, and cherish moments together
        </Text>
      </View>

      {/* Daily Photo Goal Progress with Milestones */}
      <View style={styles.goalsContainer}>
        <View style={styles.goalItem}>
          <View style={styles.goalHeader}>
            <View style={styles.goalInfo}>
              <Ionicons name="camera" size={20} color="#4CAF50" />
              <Text style={styles.goalTitle}>{dailyPhotoGoal.title}</Text>
            </View>
            <Text style={styles.goalCount}>
              {dailyPhotoGoal.current}/{dailyPhotoGoal.maxValue}
            </Text>
          </View>
          
          {/* Progress Bar with Milestones */}
          <View style={styles.progressTrack}>
            {/* Progress Fill */}
            <View 
              style={[
                styles.progressBarFill, 
                { 
                  width: `${(dailyPhotoGoal.current / dailyPhotoGoal.maxValue) * 100}%`,
                  backgroundColor: dailyPhotoGoal.progressColor,
                }
              ]} 
            />
            
            {/* Milestone Markers */}
            <View style={styles.milestonesContainer}>
              {dailyPhotoGoal.milestones.map((milestone, index) => {
                const position = (milestone.value / dailyPhotoGoal.maxValue) * 100;
                const isAchieved = dailyPhotoGoal.current >= milestone.value;
                
                return (
                  <View 
                    key={index}
                    style={[
                      styles.milestoneMarker,
                      { left: `${position}%` }
                    ]}
                  >
                    {/* Milestone Icon */}
                    <View 
                      style={[
                        styles.milestoneIconContainer,
                        { 
                          borderColor: isAchieved ? milestone.color : '#D0D0D0',
                          backgroundColor: isAchieved ? milestone.color : '#FFFFFF',
                        }
                      ]}
                    >
                      <Ionicons 
                        name={milestone.icon as keyof typeof Ionicons.glyphMap} 
                        size={14} 
                        color={isAchieved ? '#FFFFFF' : '#BDBDBD'} 
                      />
                    </View>
                    
                    {/* Milestone Label */}
                    <Text style={[
                      styles.milestoneLabel,
                      { color: isAchieved ? milestone.color : '#95A5A6' }
                    ]}>
                      {milestone.label}
                    </Text>
                  </View>
                );
              })}
            </View>
          </View>
        </View>
      </View>

      {/* Feature Cards Grid */}
      <View style={styles.gridContainer}>
        {features.map((feature, index) => (
          <TouchableOpacity
            key={feature.id}
            style={[
              styles.cardWrapper,
              index % 2 === 0 ? styles.cardLeft : styles.cardRight,
            ]}
            onPress={() => handleCardPress(feature.screen)}
            activeOpacity={0.8}
          >
            <LinearGradient
              colors={feature.gradientColors}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.card}
            >
              {/* Icon Container */}
              <View style={styles.iconContainer}>
                <Ionicons name={feature.icon} size={32} color="#FFFFFF" />
              </View>

              {/* Card Content - Spacer to push content down */}
              <View style={styles.cardSpacer} />

              {/* Card Text Content */}
              <View style={styles.cardTextContainer}>
                <Text style={styles.cardTitle}>{feature.title}</Text>
                <Text style={styles.cardDescription}>{feature.description}</Text>
              </View>

              {/* Arrow Icon */}
              <View style={styles.arrowContainer}>
                <Ionicons name="arrow-forward" size={20} color="#FFFFFF" />
              </View>
            </LinearGradient>
          </TouchableOpacity>
        ))}
      </View>

      {/* AI Bubble */}
      <AIBubble />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 8,
  },
  headerButton: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#FFFFFF',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  headerRightButtons: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  headerCenter: {
    flex: 1,
    alignItems: 'center',
  },
  appName: {
    fontSize: 28,
    fontWeight: '700',
    color: '#2C3E50',
  },
  swipeHint: {
    fontSize: 11,
    fontWeight: '600',
    color: '#95A5A6',
    marginTop: 2,
  },
  subtitleContainer: {
    paddingHorizontal: 24,
    paddingVertical: 16,
  },
  subtitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#34495E',
    marginBottom: 4,
  },
  description: {
    fontSize: 14,
    color: '#7F8C8D',
    lineHeight: 20,
  },
  goalsContainer: {
    paddingHorizontal: 24,
    paddingVertical: 12,
    marginBottom: 4,
  },
  goalItem: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    paddingBottom: 20,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 2,
    overflow: 'visible',
  },
  goalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  goalInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  goalTitle: {
    fontSize: 15,
    fontWeight: '600',
    color: '#4CAF50',
  },
  goalCount: {
    fontSize: 14,
    fontWeight: '600',
    color: '#4CAF50',
  },
  progressTrack: {
    height: 12,
    backgroundColor: '#E8F5E9',
    borderRadius: 6,
    position: 'relative',
    marginTop: 12,
    marginBottom: 36,
    marginLeft: 0,
    marginRight: 10,
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 6,
    position: 'absolute',
    left: 0,
    top: 0,
  },
  milestonesContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  milestoneMarker: {
    position: 'absolute',
    alignItems: 'center',
    width: 32,
    marginLeft: -16,
  },
  milestoneIconContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    marginTop: -10,
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.15,
    shadowRadius: 4,
    elevation: 4,
  },
  milestoneLabel: {
    fontSize: 10,
    fontWeight: '700',
    marginTop: 8,
  },
  gridContainer: {
    flex: 1,
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: 16,
    paddingTop: 8,
  },
  cardWrapper: {
    width: '50%',
    padding: 8,
  },
  cardLeft: {
    paddingRight: 8,
  },
  cardRight: {
    paddingLeft: 8,
  },
  card: {
    borderRadius: 20,
    padding: 20,
    minHeight: 160,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 5,
  },
  iconContainer: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(255, 255, 255, 0.25)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardSpacer: {
    flex: 1,
    minHeight: 8,
  },
  cardTextContainer: {
    marginBottom: 12,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  cardDescription: {
    fontSize: 13,
    color: 'rgba(255, 255, 255, 0.9)',
    fontWeight: '500',
  },
  arrowContainer: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    alignSelf: 'flex-end',
  },
  footer: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  footerText: {
    fontSize: 13,
    color: '#95A5A6',
    fontWeight: '500',
  },
});
