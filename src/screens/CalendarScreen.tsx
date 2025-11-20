import React, { useState, useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
  Image,
  Dimensions,
  StatusBar,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { LinearGradient } from 'expo-linear-gradient';
import SubscriptionModal from '../components/SubscriptionModal';

const { width } = Dimensions.get('window');

interface PhotoData {
  date: string; // YYYY-MM-DD
  photos: string[]; // Array of photo URIs
  hasPhotos: boolean;
}

interface MonthData {
  year: number;
  month: number; // 0-11
  days: PhotoData[];
}

// Mock data generator
const generateMockData = (): MonthData[] => {
  const months: MonthData[] = [];
  const currentDate = new Date();
  
  // Generate data for 6 months (current month and 5 previous months)
  for (let i = 5; i >= 0; i--) {
    const targetDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - i, 1);
    const year = targetDate.getFullYear();
    const month = targetDate.getMonth();
    
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const days: PhotoData[] = [];
    
    // Mock photo URLs (using placeholder images)
    const mockPhotos = [
      'https://picsum.photos/200/200?random=1',
      'https://picsum.photos/200/200?random=2',
      'https://picsum.photos/200/200?random=3',
      'https://picsum.photos/200/200?random=4',
      'https://picsum.photos/200/200?random=5',
      'https://picsum.photos/200/200?random=6',
      'https://picsum.photos/200/200?random=7',
      'https://picsum.photos/200/200?random=8',
      'https://picsum.photos/200/200?random=9',
      'https://picsum.photos/200/200?random=10',
    ];
    
    for (let day = 1; day <= daysInMonth; day++) {
      const date = new Date(year, month, day);
      // Format date string properly to avoid timezone issues
      const dateString = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
      
      // Randomly decide if there are photos for this day (70% chance)
      const hasPhotos = Math.random() > 0.3 && date <= currentDate;
      
      // Random number of photos (1-3)
      const photoCount = hasPhotos ? Math.floor(Math.random() * 3) + 1 : 0;
      const photos = hasPhotos 
        ? Array.from({ length: photoCount }, (_, idx) => 
            mockPhotos[Math.floor(Math.random() * mockPhotos.length)]
          )
        : [];
      
      days.push({
        date: dateString,
        photos,
        hasPhotos,
      });
    }
    
    months.push({ year, month, days });
  }
  
  return months;
};

// Calculate streak
const calculateStreak = (monthsData: MonthData[]): number => {
  let streak = 0;
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  // Flatten all days and sort by date descending
  const allDays = monthsData
    .flatMap(m => m.days)
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  
  for (let i = 0; i < allDays.length; i++) {
    const dayDate = new Date(allDays[i].date);
    dayDate.setHours(0, 0, 0, 0);
    
    const expectedDate = new Date(today);
    expectedDate.setDate(today.getDate() - i);
    expectedDate.setHours(0, 0, 0, 0);
    
    if (dayDate.getTime() === expectedDate.getTime() && allDays[i].hasPhotos) {
      streak++;
    } else if (dayDate.getTime() < expectedDate.getTime()) {
      break;
    }
  }
  
  return streak;
};

// Calculate total photos
const calculateTotalPhotos = (monthsData: MonthData[]): number => {
  return monthsData.reduce((total, month) => {
    return total + month.days.reduce((monthTotal, day) => {
      return monthTotal + day.photos.length;
    }, 0);
  }, 0);
};

const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

export default function CalendarScreen() {
  const navigation = useNavigation();
  const scrollViewRef = useRef<ScrollView>(null);
  const [monthsData] = useState<MonthData[]>(generateMockData());
  const [currentMonthY, setCurrentMonthY] = useState(0);
  const [subscriptionModalVisible, setSubscriptionModalVisible] = useState(false);
  const streak = calculateStreak(monthsData);
  const totalPhotos = calculateTotalPhotos(monthsData);

  // Mock user data
  const userData = {
    name: 'John Doe',
    username: '@johndoe',
    avatar: 'https://picsum.photos/200/200?random=user',
    hasSubscription: false,
  };

  // Scroll to current month on mount
  useEffect(() => {
    if (currentMonthY > 0) {
      setTimeout(() => {
        scrollViewRef.current?.scrollTo({
          y: currentMonthY,
          animated: true,
        });
      }, 100);
    }
  }, [currentMonthY]);

  const renderMonthCalendar = (monthData: MonthData, index: number) => {
    const { year, month, days } = monthData;
    const currentDate = new Date();
    const isCurrentMonth = year === currentDate.getFullYear() && month === currentDate.getMonth();
    const firstDay = new Date(year, month, 1).getDay();
    const daysInMonth = days.length;
    
    // Create calendar grid - fill to complete weeks (always 7 cells per row)
    const calendarDays: (PhotoData | null)[] = [
      ...Array(firstDay).fill(null),
      ...days
    ];
    
    // Fill remaining cells to complete the last week
    const remainingCells = 7 - (calendarDays.length % 7);
    if (remainingCells < 7) {
      calendarDays.push(...Array(remainingCells).fill(null));
    }
    
    // Split into weeks of exactly 7 days each
    const weeks: (PhotoData | null)[][] = [];
    for (let i = 0; i < calendarDays.length; i += 7) {
      weeks.push(calendarDays.slice(i, i + 7));
    }
    
    return (
      <View 
        key={`${year}-${month}`} 
        style={styles.monthContainer}
        onLayout={(event) => {
          if (isCurrentMonth) {
            const { y } = event.nativeEvent.layout;
            setCurrentMonthY(y - 20); // Offset for better positioning
          }
        }}
      >
        {/* Month Header */}
        <Text style={styles.monthTitle}>
          {MONTHS[month]} {year}
        </Text>
        
        {/* Weekday Headers */}
        <View style={styles.weekdayRow}>
          {WEEKDAYS.map((day) => (
            <View key={day} style={styles.weekdayCell}>
              <Text style={styles.weekdayText}>{day}</Text>
            </View>
          ))}
        </View>
        
        {/* Calendar Grid */}
        {weeks.map((week, weekIndex) => (
          <View key={`week-${weekIndex}`} style={styles.weekRow}>
            {Array.from({ length: 7 }, (_, dayIndex) => {
              const day = week[dayIndex];
              
              if (!day) {
                // Empty cell with same structure to maintain consistent sizing
                return (
                  <View key={`empty-${weekIndex}-${dayIndex}`} style={styles.dayCell}>
                    <View style={styles.emptyCellContent} />
                  </View>
                );
              }
              
              // Extract day number directly from date string to avoid timezone issues
              const dayNumber = parseInt(day.date.split('-')[2], 10);
              const today = new Date();
              const todayString = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
              const isToday = day.date === todayString;
              
              return (
                <TouchableOpacity
                  key={day.date}
                  style={styles.dayCell}
                  activeOpacity={0.7}
                  onPress={() => {
                    // Handle day press - could show photos for this day
                    console.log('Day pressed:', day.date);
                  }}
                >
                  <View style={[styles.dayCellContent, isToday && styles.todayCellContent]}>
                    {/* Day Number */}
                    <View style={styles.dayNumberContainer}>
                      <Text style={[styles.dayNumber, isToday && styles.todayText]}>
                        {dayNumber}
                      </Text>
                    </View>
                    
                    {/* Photo Thumbnail or Placeholder */}
                    {day.hasPhotos && day.photos.length > 0 ? (
                      <View style={styles.photoContainer}>
                        <Image
                          source={{ uri: day.photos[0] }}
                          style={styles.photoThumbnail}
                        />
                        {day.photos.length > 1 && (
                          <View style={styles.photoBadge}>
                            <Text style={styles.photoBadgeText}>+{day.photos.length - 1}</Text>
                          </View>
                        )}
                      </View>
                    ) : (
                      <View style={styles.emptyPhotoContainer}>
                        <View style={styles.emptyPhotoPlaceholder} />
                      </View>
                    )}
                  </View>
                </TouchableOpacity>
              );
            })}
          </View>
        ))}
      </View>
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      
      {/* Header - Fixed */}
      <View style={styles.header}>
        <View style={styles.headerContent}>
          {/* Left Side - Avatar and User Info */}
          <View style={styles.userSection}>
            <Image
              source={{ uri: userData.avatar }}
              style={styles.avatar}
            />
            
            <View style={styles.userInfo}>
              <Text style={styles.userName}>{userData.name}</Text>
              <Text style={styles.userHandle}>
                {userData.username}
              </Text>
            </View>
          </View>

          {/* Right Side - Icons and Subscription Badge */}
          <View style={styles.headerRight}>
            <TouchableOpacity 
              style={styles.subscriptionBadge}
              onPress={() => {
                setSubscriptionModalVisible(true);
              }}
            >
              <LinearGradient
                colors={['#F39C12', '#E67E22']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.subscriptionGradient}
              >
                <Ionicons name="star" size={14} color="#FFFFFF" />
                <Text style={styles.subscriptionText}>Cira Gold</Text>
              </LinearGradient>
            </TouchableOpacity>

            <View style={styles.headerIcons}>
                <TouchableOpacity 
                  style={styles.iconButton}
                  onPress={() => {
                    // @ts-ignore
                    navigation.navigate('Messages');
                  }}
                >
                  <Ionicons name="people" size={24} color="#2C3E50" />
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={styles.iconButton}
                  onPress={() => {
                    // @ts-ignore
                    navigation.navigate('Profile');
                  }}
                >
                  <Ionicons name="settings" size={24} color="#2C3E50" />
                </TouchableOpacity>
                
                <TouchableOpacity 
                  style={styles.iconButton}
                  onPress={() => {
                    console.log('More options');
                  }}
                >
                  <Ionicons name="chevron-forward" size={24} color="#2C3E50" />
                </TouchableOpacity>
              </View>
          </View>
        </View>
      </View>

      {/* Calendar ScrollView */}
      <ScrollView
        ref={scrollViewRef}
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {monthsData.map((monthData, index) => renderMonthCalendar(monthData, index))}
        
        {/* Bottom Padding */}
        <View style={styles.bottomPadding} />
      </ScrollView>

      {/* Stats Cards - Fixed at bottom */}
      <View style={styles.statsContainer}>
        {/* Streak Card */}
        <LinearGradient
          colors={['#E74C3C', '#C0392B']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.statCard}
        >
          <Ionicons name="flame" size={28} color="#FFFFFF" />
          <View style={styles.statInfo}>
            <Text style={styles.statValue}>{streak}</Text>
            <Text style={styles.statLabel}>Day Streak</Text>
          </View>
        </LinearGradient>

        {/* Total Photos Card */}
        <LinearGradient
          colors={['#5DADE2', '#3498DB']}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.statCard}
        >
          <Ionicons name="images" size={28} color="#FFFFFF" />
          <View style={styles.statInfo}>
            <Text style={styles.statValue}>{totalPhotos}</Text>
            <Text style={styles.statLabel}>Photos</Text>
          </View>
        </LinearGradient>
      </View>

      {/* Subscription Modal */}
      <SubscriptionModal
        visible={subscriptionModalVisible}
        onClose={() => setSubscriptionModalVisible(false)}
        onSelectPlan={(planId) => {
          console.log('Selected plan:', planId);
          // TODO: Handle plan selection (navigate to payment, etc.)
        }}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8F9FA',
  },
  header: {
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E8E8E8',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 8,
    elevation: 4,
    overflow: 'hidden',
  },
  headerContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 16,
    minHeight: 80,
  },
  collapsedContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    position: 'absolute',
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
  },
  expandedContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    flex: 1,
  },
  userSection: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    gap: 12,
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    borderWidth: 2,
    borderColor: '#F39C12',
  },
  userInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  userName: {
    fontSize: 17,
    fontWeight: '700',
    color: '#2C3E50',
    lineHeight: 22,
  },
  userHandle: {
    fontSize: 14,
    color: '#7F8C8D',
    marginTop: 2,
    lineHeight: 18,
  },
  headerRight: {
    alignItems: 'flex-end',
    gap: 10,
  },
  subscriptionBadge: {
    borderRadius: 20,
    overflow: 'hidden',
    shadowColor: '#F39C12',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 3,
    minHeight: 28,
  },
  subscriptionGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    paddingVertical: 7,
    gap: 6,
    borderWidth: 1.5,
    borderColor: 'rgba(255, 255, 255, 0.3)',
    minHeight: 28,
  },
  subscriptionText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#FFFFFF',
    lineHeight: 16,
  },
  headerIcons: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#F8F9FA',
    justifyContent: 'center',
    alignItems: 'center',
  },
  statsContainer: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    paddingVertical: 12,
    paddingBottom: 16,
    gap: 12,
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#E8E8E8',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 8,
  },
  statCard: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    padding: 14,
    borderRadius: 16,
    gap: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
    elevation: 3,
  },
  statInfo: {
    flex: 1,
  },
  statValue: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  statLabel: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.9)',
    fontWeight: '600',
    marginTop: 2,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: 16,
    paddingTop: 12,
    paddingBottom: 20,
  },
  monthContainer: {
    marginBottom: 28,
  },
  monthTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#2C3E50',
    marginBottom: 12,
    paddingLeft: 2,
  },
  weekdayRow: {
    flexDirection: 'row',
    marginBottom: 6,
  },
  weekdayCell: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: 6,
  },
  weekdayText: {
    fontSize: 11,
    fontWeight: '600',
    color: '#95A5A6',
  },
  weekRow: {
    flexDirection: 'row',
    marginBottom: 4,
  },
  dayCell: {
    flex: 1,
    aspectRatio: 0.7, // Make cells taller to fit content better (number + photo)
    padding: 2,
  },
  emptyCellContent: {
    flex: 1,
    backgroundColor: 'transparent',
  },
  dayCellContent: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderRadius: 10,
    padding: 5,
    borderWidth: 1,
    borderColor: '#ECECEC',
    justifyContent: 'space-between',
  },
  todayCellContent: {
    borderWidth: 2,
    borderColor: '#5DADE2',
  },
  dayNumberContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    height: 16,
  },
  dayNumber: {
    fontSize: 10,
    fontWeight: '700',
    color: '#34495E',
  },
  todayText: {
    color: '#5DADE2',
    fontWeight: '800',
  },
  photoContainer: {
    flex: 1,
    borderRadius: 8,
    overflow: 'hidden',
    backgroundColor: '#F8F9FA',
  },
  photoThumbnail: {
    width: '100%',
    height: '100%',
    resizeMode: 'cover',
  },
  photoBadge: {
    position: 'absolute',
    bottom: 1,
    right: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    borderRadius: 6,
    paddingHorizontal: 3,
    paddingVertical: 1,
    minWidth: 16,
    alignItems: 'center',
  },
  photoBadgeText: {
    fontSize: 7,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  emptyPhotoContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    borderRadius: 8,
  },
  emptyPhotoPlaceholder: {
    width: '60%',
    height: '60%',
    borderRadius: 6,
    backgroundColor: '#FFFFFF',
    borderWidth: 1.5,
    borderColor: '#DFE4E8',
    borderStyle: 'dashed',
  },
  bottomPadding: {
    height: 40,
  },
});
