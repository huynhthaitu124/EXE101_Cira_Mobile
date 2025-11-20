import React, { useState } from 'react';
import { 
  ScrollView, 
  TouchableOpacity, 
  Image,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  Box,
  VStack,
  HStack,
  Text,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import AIBubble from '../components/AIBubble';

const { width } = Dimensions.get('window');

interface StoryChapter {
  id: string;
  title: string;
  description: string;
  photoCount: number;
  coverImageUrl?: string; // Optional: URL from API
  coverColor: string; // Placeholder gradient color
  photos: { 
    url?: string; 
    color: string;
    timestamp: string;
    caption: string;
  }[];
  date: string;
  isFavorite: boolean;
  author?: string; // For family chapters
  authorInitial?: string; // For family chapters avatar
}

export default function GalleryScreen({ navigation }: any) {
  const [selectedChapter, setSelectedChapter] = useState<StoryChapter | null>(null);
  const [chapters, setChapters] = useState<StoryChapter[]>([]);
  const [activeTab, setActiveTab] = useState<'my' | 'family'>('my');

  // Mock data - My Chapters
  const initialChapters: StoryChapter[] = [
    {
      id: '1',
      title: 'Summer Vacation 2024',
      description: 'Amazing beach days with family, building sandcastles and watching beautiful sunsets together.',
      photoCount: 24,
      coverImageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80',
      coverColor: '#FFD93D',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&q=80', 
          color: '#FFD93D',
          timestamp: '10:30 AM, July 15',
          caption: 'Perfect beach weather! The water is so clear and warm 🌊☀️'
        },
        { 
          url: 'https://images.unsplash.com/photo-1519046904884-53103b34b206?w=800&q=80', 
          color: '#4ECDC4',
          timestamp: '6:45 PM, July 16',
          caption: 'Most beautiful sunset I\'ve ever seen with my favorite people ❤️'
        },
        { 
          url: 'https://images.unsplash.com/photo-1473496169904-658ba7c44d8a?w=800&q=80', 
          color: '#95E1D3',
          timestamp: '2:15 PM, July 17',
          caption: 'Building sandcastles with the kids. Their imagination is endless! 🏰'
        },
      ],
      date: 'July 2024',
      isFavorite: true,
    },
    {
      id: '2',
      title: 'Birthday Celebration',
      description: 'Emma\'s 5th birthday party filled with laughter, cake, and unforgettable moments with friends.',
      photoCount: 18,
      coverImageUrl: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80',
      coverColor: '#FF6B6B',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80', 
          color: '#FF6B6B',
          timestamp: '3:00 PM, June 8',
          caption: 'Happy 5th birthday Emma! 🎂 She couldn\'t stop smiling today'
        },
        { 
          url: 'https://images.unsplash.com/photo-1464349095431-e9a21285b5f3?w=800&q=80', 
          color: '#F38181',
          timestamp: '4:30 PM, June 8',
          caption: 'All her friends came! Best party ever 🎈🎉'
        },
        { 
          url: 'https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=800&q=80', 
          color: '#FCBAD3',
          timestamp: '5:45 PM, June 8',
          caption: 'Opening presents - her face lights up with each one! 🎁'
        },
      ],
      date: 'June 2024',
      isFavorite: false,
    },
    {
      id: '3',
      title: 'Mountain Adventure',
      description: 'Hiking through scenic trails, discovering nature, and creating memories in the great outdoors.',
      photoCount: 32,
      coverImageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      coverColor: '#6BCB77',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', 
          color: '#6BCB77',
          timestamp: '7:15 AM, May 20',
          caption: 'Early morning start, the view is already breathtaking! ⛰️'
        },
        { 
          url: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&q=80', 
          color: '#4D96FF',
          timestamp: '12:30 PM, May 20',
          caption: 'Reached the summit! Feeling on top of the world 🏔️'
        },
        { 
          url: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', 
          color: '#95E1D3',
          timestamp: '3:45 PM, May 20',
          caption: 'Found a hidden waterfall on our way down. Nature never ceases to amaze!'
        },
        { 
          url: 'https://images.unsplash.com/photo-1454496522488-7a8e488e8606?w=800&q=80', 
          color: '#AA96DA',
          timestamp: '6:00 PM, May 20',
          caption: 'Perfect ending to an adventure-filled day 🌄'
        },
      ],
      date: 'May 2024',
      isFavorite: true,
    },
    {
      id: '4',
      title: 'Family Gathering',
      description: 'Thanksgiving dinner with the whole family, sharing stories and delicious food together.',
      photoCount: 15,
      coverImageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80',
      coverColor: '#FCBAD3',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80', 
          color: '#FCBAD3',
          timestamp: '5:00 PM, Nov 23',
          caption: 'The whole family together for Thanksgiving! Grateful for these moments 🦃'
        },
        { 
          url: 'https://images.unsplash.com/photo-1543007631-283050bb3e8c?w=800&q=80', 
          color: '#FF8787',
          timestamp: '6:30 PM, Nov 23',
          caption: 'Mom outdid herself with the turkey this year! 🍽️'
        },
        { 
          url: 'https://images.unsplash.com/photo-1606787366850-de6330128bfc?w=800&q=80', 
          color: '#FCBAD3',
          timestamp: '8:00 PM, Nov 23',
          caption: 'Four generations in one photo. These are the memories that matter most ❤️'
        },
      ],
      date: 'November 2023',
      isFavorite: false,
    },
  ];

  // Mock data - Family Chapters
  const familyChapters: StoryChapter[] = [
    {
      id: 'f1',
      title: 'Mom\'s Garden Journey',
      description: 'Mom\'s beautiful flower garden through the seasons. From spring blooms to autumn harvest.',
      photoCount: 18,
      coverImageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80',
      coverColor: '#95E1D3',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800&q=80', 
          color: '#95E1D3',
          timestamp: '8:00 AM, Apr 5',
          caption: 'First roses of spring are blooming! 🌹'
        },
        { 
          url: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&q=80', 
          color: '#6BCB77',
          timestamp: '6:30 PM, Apr 12',
          caption: 'My garden is my happy place 🌺'
        },
      ],
      date: 'April 2024',
      isFavorite: true,
      author: 'Mom',
      authorInitial: 'M',
    },
    {
      id: 'f2',
      title: 'Dad\'s Fishing Adventures',
      description: 'Weekend fishing trips and the big catches. Quality time by the lake with nature.',
      photoCount: 12,
      coverImageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80',
      coverColor: '#4D96FF',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80', 
          color: '#4D96FF',
          timestamp: '6:00 AM, Mar 10',
          caption: 'Perfect morning for fishing! 🎣'
        },
        { 
          url: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=80', 
          color: '#4ECDC4',
          timestamp: '3:30 PM, Mar 10',
          caption: 'Biggest catch of the season! 🐟'
        },
      ],
      date: 'March 2024',
      isFavorite: false,
      author: 'Dad',
      authorInitial: 'D',
    },
    {
      id: 'f3',
      title: 'Sarah\'s Art Projects',
      description: 'My sister\'s creative artwork and craft projects. From watercolor paintings to DIY crafts.',
      photoCount: 20,
      coverImageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800&q=80',
      coverColor: '#AA96DA',
      photos: [
        { 
          url: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=800&q=80', 
          color: '#AA96DA',
          timestamp: '2:00 PM, Feb 14',
          caption: 'Finished my new watercolor series! 🎨'
        },
        { 
          url: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800&q=80', 
          color: '#F38181',
          timestamp: '5:00 PM, Feb 20',
          caption: 'Art is my therapy ✨'
        },
      ],
      date: 'February 2024',
      isFavorite: true,
      author: 'Sarah',
      authorInitial: 'S',
    },
  ];

  // Initialize chapters state
  React.useEffect(() => {
    setChapters(initialChapters);
  }, []);

  // Update chapters when tab changes
  React.useEffect(() => {
    if (activeTab === 'my') {
      setChapters(initialChapters);
    } else {
      setChapters(familyChapters);
    }
  }, [activeTab]);

  // Toggle favorite status
  const toggleFavorite = (chapterId: string) => {
    setChapters(prevChapters =>
      prevChapters.map(chapter =>
        chapter.id === chapterId
          ? { ...chapter, isFavorite: !chapter.isFavorite }
          : chapter
      )
    );
    
    // Update selected chapter if it's the one being toggled
    if (selectedChapter && selectedChapter.id === chapterId) {
      setSelectedChapter(prev => prev ? { ...prev, isFavorite: !prev.isFavorite } : null);
    }
  };

  // Render Chapter Detail View
  if (selectedChapter) {
    return (
      <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={['top']}>
        <Box flex={1} bg="#FFFFFF">
          {/* Header */}
          <Box px={16} py={12} borderBottomWidth={1} borderBottomColor="#F0F0F0">
            <HStack justifyContent="space-between" alignItems="center">
              <TouchableOpacity onPress={() => setSelectedChapter(null)}>
                <Ionicons name="arrow-back" size={24} color="#2C3E50" />
              </TouchableOpacity>
              <Text fontSize={18} fontWeight="600" color="#2C3E50">
                Story Chapter
              </Text>
              <HStack gap={12} alignItems="center">
                <TouchableOpacity onPress={() => toggleFavorite(selectedChapter.id)}>
                  <Ionicons 
                    name={selectedChapter.isFavorite ? "heart" : "heart-outline"} 
                    size={24} 
                    color={selectedChapter.isFavorite ? "#E74C3C" : "#2C3E50"} 
                  />
                </TouchableOpacity>
                <TouchableOpacity>
                  <Ionicons name="ellipsis-horizontal" size={24} color="#2C3E50" />
                </TouchableOpacity>
              </HStack>
            </HStack>
          </Box>

          <ScrollView showsVerticalScrollIndicator={false}>
            <VStack gap={20} px={16} py={20} pb={100}>
              {/* Chapter Header */}
              <VStack gap={8}>
                <HStack justifyContent="space-between" alignItems="flex-start">
                  <VStack gap={6} flex={1}>
                    <Text fontSize={24} fontWeight="700" color="#2C3E50">
                      {selectedChapter.title}
                    </Text>
                    
                    {/* Author Info - Only for Family Chapters */}
                    {selectedChapter.author && (
                      <HStack gap={8} alignItems="center">
                        <Box
                          w={24}
                          h={24}
                          borderRadius={12}
                          bg="#5DADE2"
                          justifyContent="center"
                          alignItems="center"
                        >
                          <Text fontSize={11} fontWeight="700" color="#FFFFFF">
                            {selectedChapter.authorInitial}
                          </Text>
                        </Box>
                        <Text fontSize={14} color="#2C3E50" fontWeight="600">
                          by {selectedChapter.author}
                        </Text>
                      </HStack>
                    )}
                    
                    <HStack gap={8} alignItems="center">
                      <Ionicons name="calendar-outline" size={14} color="#95A5A6" />
                      <Text fontSize={13} color="#95A5A6">
                        {selectedChapter.date}
                      </Text>
                      <Text fontSize={13} color="#95A5A6">
                        •
                      </Text>
                      <Text fontSize={13} color="#95A5A6">
                        {selectedChapter.photoCount} photos
                      </Text>
                    </HStack>
                  </VStack>
                  <TouchableOpacity>
                    <Box
                      bg="#5DADE2"
                      px={16}
                      py={10}
                      borderRadius={20}
                    >
                      <HStack gap={8} alignItems="center">
                        <Ionicons name="volume-high" size={16} color="#FFFFFF" />
                        <Text fontSize={13} fontWeight="600" color="#FFFFFF">
                          Play Story
                        </Text>
                      </HStack>
                    </Box>
                  </TouchableOpacity>
                </HStack>
              </VStack>

              {/* Chapter Description */}
              <Box bg="#F8F9FA" px={16} py={14} borderRadius={16}>
                <HStack gap={10} alignItems="flex-start">
                  <Ionicons name="sparkles" size={18} color="#5DADE2" style={{ marginTop: 2 }} />
                  <Text fontSize={14} color="#2C3E50" flex={1} lineHeight={22}>
                    {selectedChapter.description}
                  </Text>
                </HStack>
              </Box>

              {/* Photos Grid */}
              <VStack gap={20}>
                <Text fontSize={16} fontWeight="600" color="#2C3E50">
                  Photos
                </Text>
                <VStack gap={24}>
                  {selectedChapter.photos.map((photo, index) => (
                    <VStack key={index} gap={12}>
                      <TouchableOpacity>
                        <Box
                          borderRadius={16}
                          overflow="hidden"
                          bg={photo.color}
                          w="100%"
                          h={width * 0.75}
                          justifyContent="center"
                          alignItems="center"
                        >
                          {photo.url ? (
                            <Image
                              source={{ uri: photo.url }}
                              style={{ 
                                width: '100%', 
                                height: '100%',
                              }}
                              resizeMode="cover"
                            />
                          ) : (
                            <VStack gap={8} alignItems="center">
                              <Ionicons name="image-outline" size={48} color="rgba(255,255,255,0.5)" />
                              <Text fontSize={12} color="rgba(255,255,255,0.7)">
                                Photo {index + 1}
                              </Text>
                            </VStack>
                          )}
                        </Box>
                      </TouchableOpacity>
                      
                      {/* Photo Info */}
                      <VStack gap={8}>
                        {/* Timestamp */}
                        <HStack gap={6} alignItems="center">
                          <Ionicons name="time-outline" size={14} color="#95A5A6" />
                          <Text fontSize={13} color="#95A5A6" fontWeight="500">
                            {photo.timestamp}
                          </Text>
                        </HStack>
                        
                        {/* Caption */}
                        <Box bg="#F8F9FA" px={14} py={10} borderRadius={12}>
                          <Text fontSize={14} color="#2C3E50" lineHeight={20}>
                            {photo.caption}
                          </Text>
                        </Box>
                      </VStack>
                    </VStack>
                  ))}
                </VStack>
              </VStack>
            </VStack>
          </ScrollView>

          {/* AI Bubble */}
          <AIBubble />
        </Box>
      </SafeAreaView>
    );
  }

  // Render Chapters List
  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={['top']}>
      <Box flex={1} bg="#FFFFFF">
        {/* Header */}
        <Box borderBottomWidth={1} borderBottomColor="#F0F0F0">
          <Box px={16} py={12}>
            <HStack justifyContent="space-between" alignItems="center">
              <TouchableOpacity onPress={() => navigation.goBack()}>
                <Ionicons name="arrow-back" size={24} color="#2C3E50" />
              </TouchableOpacity>
              <Text fontSize={18} fontWeight="600" color="#2C3E50">
                Story Chapters
              </Text>
              <TouchableOpacity>
                <Ionicons name="add-circle-outline" size={24} color="#5DADE2" />
              </TouchableOpacity>
            </HStack>
          </Box>

          {/* Tab Navigation */}
          <HStack px={16} pb={12}>
            <HStack flex={1} bg="#F5F5F5" borderRadius={12} p={2}>
              <TouchableOpacity 
                onPress={() => setActiveTab('my')}
                style={{ flex: 1 }}
              >
                <Box
                  bg={activeTab === 'my' ? '#FFFFFF' : 'transparent'}
                  py={10}
                  borderRadius={10}
                  alignItems="center"
                >
                  <Text 
                    fontSize={14} 
                    fontWeight={activeTab === 'my' ? '600' : '500'}
                    color={activeTab === 'my' ? '#5DADE2' : '#95A5A6'}
                  >
                    My Chapters
                  </Text>
                </Box>
              </TouchableOpacity>
              <TouchableOpacity 
                onPress={() => setActiveTab('family')}
                style={{ flex: 1 }}
              >
                <Box
                  bg={activeTab === 'family' ? '#FFFFFF' : 'transparent'}
                  py={10}
                  borderRadius={10}
                  alignItems="center"
                >
                  <Text 
                    fontSize={14} 
                    fontWeight={activeTab === 'family' ? '600' : '500'}
                    color={activeTab === 'family' ? '#5DADE2' : '#95A5A6'}
                  >
                    Family Chapters
                  </Text>
                </Box>
              </TouchableOpacity>
            </HStack>
          </HStack>
        </Box>

        {/* Chapters List */}
        <ScrollView showsVerticalScrollIndicator={false}>
          <VStack gap={16} px={16} py={20} pb={100}>
            {chapters.map((chapter) => (
              <TouchableOpacity 
                key={chapter.id}
                onPress={() => setSelectedChapter(chapter)}
              >
                <Box
                  borderRadius={20}
                  overflow="hidden"
                  bg="#FFFFFF"
                  borderWidth={1}
                  borderColor="#E8E8E8"
                >
                  {/* Cover Image with Gradient Overlay */}
                  <Box position="relative" h={140}>
                    {chapter.coverImageUrl ? (
                      <Image
                        source={{ uri: chapter.coverImageUrl }}
                        style={{ width: '100%', height: '100%' }}
                        resizeMode="cover"
                      />
                    ) : (
                      <Box bg={chapter.coverColor} w="100%" h="100%" justifyContent="center" alignItems="center">
                        <Ionicons name="images" size={48} color="rgba(255,255,255,0.5)" />
                      </Box>
                    )}
                    <LinearGradient
                      colors={['transparent', 'rgba(0,0,0,0.6)']}
                      style={{
                        position: 'absolute',
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 100,
                      }}
                    />
                    {/* Date Badge - Left */}
                    <Box
                      position="absolute"
                      top={12}
                      left={12}
                      bg="rgba(0,0,0,0.6)"
                      px={12}
                      py={6}
                      borderRadius={12}
                    >
                      <Text fontSize={11} fontWeight="600" color="#FFFFFF">
                        {chapter.date}
                      </Text>
                    </Box>

                    {/* Favorite Icon - Right */}
                    <TouchableOpacity 
                      onPress={(e) => {
                        e.stopPropagation();
                        toggleFavorite(chapter.id);
                      }}
                      style={{
                        position: 'absolute',
                        top: 12,
                        right: 12,
                        backgroundColor: 'rgba(0,0,0,0.6)',
                        borderRadius: 20,
                        width: 36,
                        height: 36,
                        justifyContent: 'center',
                        alignItems: 'center',
                      }}
                    >
                      <Ionicons 
                        name={chapter.isFavorite ? "heart" : "heart-outline"} 
                        size={18} 
                        color={chapter.isFavorite ? "#E74C3C" : "#FFFFFF"} 
                      />
                    </TouchableOpacity>
                  </Box>

                  {/* Chapter Info */}
                  <VStack gap={12} p={16}>
                    <VStack gap={6}>
                      <HStack justifyContent="space-between" alignItems="flex-start">
                        <VStack gap={4} flex={1}>
                          <Text fontSize={18} fontWeight="700" color="#2C3E50">
                            {chapter.title}
                          </Text>
                          {/* Author Badge - Only for Family Chapters */}
                          {chapter.author && (
                            <HStack gap={6} alignItems="center">
                              <Box
                                w={20}
                                h={20}
                                borderRadius={10}
                                bg="#5DADE2"
                                justifyContent="center"
                                alignItems="center"
                              >
                                <Text fontSize={10} fontWeight="700" color="#FFFFFF">
                                  {chapter.authorInitial}
                                </Text>
                              </Box>
                              <Text fontSize={13} color="#7F8C8D" fontWeight="500">
                                by {chapter.author}
                              </Text>
                            </HStack>
                          )}
                        </VStack>
                        <HStack gap={6} alignItems="center" ml={8}>
                          <Ionicons name="images" size={16} color="#95A5A6" />
                          <Text fontSize={14} fontWeight="600" color="#95A5A6">
                            {chapter.photoCount}
                          </Text>
                        </HStack>
                      </HStack>
                      <Text fontSize={14} color="#7F8C8D" lineHeight={20} numberOfLines={2}>
                        {chapter.description}
                      </Text>
                    </VStack>

                    {/* Action Button */}
                    <HStack justifyContent="space-between" alignItems="center">
                      <TouchableOpacity style={{ flex: 1 }}>
                        <Box
                          bg="#5DADE2"
                          py={12}
                          borderRadius={12}
                          alignItems="center"
                        >
                          <HStack gap={8} alignItems="center">
                            <Ionicons name="book-outline" size={18} color="#FFFFFF" />
                            <Text fontSize={14} fontWeight="600" color="#FFFFFF">
                              View Chapter
                            </Text>
                          </HStack>
                        </Box>
                      </TouchableOpacity>
                    </HStack>
                  </VStack>
                </Box>
              </TouchableOpacity>
            ))}
          </VStack>
        </ScrollView>

        {/* AI Bubble */}
        <AIBubble />
      </Box>
    </SafeAreaView>
  );
}
