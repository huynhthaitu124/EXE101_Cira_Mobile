import React, { useState, useRef, useEffect } from 'react';
import { 
  Dimensions, 
  TouchableOpacity, 
  Image, 
  FlatList,
  View,
  StatusBar,
  KeyboardAvoidingView,
  Platform,
  Alert,
  ImageBackground,
  TextInput,
  ScrollView,
  Keyboard,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { BlurView } from 'expo-blur';
import { LinearGradient } from 'expo-linear-gradient';
import * as ImageManipulator from 'expo-image-manipulator';
import {
  Box,
  VStack,
  HStack,
  Text,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';
import { CameraView, CameraType, useCameraPermissions } from 'expo-camera';
import * as MediaLibrary from 'expo-media-library';
import * as Haptics from 'expo-haptics';
import AIBubble from '../components/AIBubble';

// Voice recognition disabled - requires native build
// import { ExpoWebSpeechRecognition } from 'expo-speech-recognition';

const { width, height } = Dimensions.get('window');

// Mock data for family photos - Locket style
const familyPhotos = [
  { 
    id: 'camera', // Only camera view
    type: 'camera',
  },
];

export default function HomeScreen({ navigation }: any) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [facing, setFacing] = useState<CameraType>('back');
  const [cameraPermission, requestCameraPermission] = useCameraPermissions();
  const [mediaLibraryPermission, requestMediaLibraryPermission] = MediaLibrary.usePermissions();
  const [capturedPhoto, setCapturedPhoto] = useState<string | null>(null);
  const [dominantColor, setDominantColor] = useState<string>('#000000');
  const [suggestedTags, setSuggestedTags] = useState<string[]>([]);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [photoCaption, setPhotoCaption] = useState('');
  const [isTypingCaption, setIsTypingCaption] = useState(false);
  const [selectedChapter, setSelectedChapter] = useState<string | null>(null);
  const [showChapterDropdown, setShowChapterDropdown] = useState(false);
  const [showNewChapterForm, setShowNewChapterForm] = useState(false);
  const [newChapterName, setNewChapterName] = useState('');
  const [newChapterDescription, setNewChapterDescription] = useState('');
  const cameraRef = useRef<CameraView>(null);
  const scrollViewRef = useRef<ScrollView>(null);

  // Mock chapters data - Replace with API call
  const myChapters = [
    { id: '1', title: 'Summer Vacation 2024', icon: '🏖️' },
    { id: '2', title: 'Birthday Celebration', icon: '🎂' },
    { id: '3', title: 'Mountain Adventure', icon: '⛰️' },
    { id: '4', title: 'Family Gathering', icon: '👨‍👩‍👧‍👦' },
  ];

  useEffect(() => {
    // Request permissions on mount
    (async () => {
      if (!cameraPermission?.granted) {
        await requestCameraPermission();
      }
      if (!mediaLibraryPermission?.granted) {
        await requestMediaLibraryPermission();
      }
      
      // Voice recognition disabled - requires native build
      // To enable: run npx expo run:ios or npx expo run:android
    })();
  }, []);

  const toggleCameraFacing = () => {
    setFacing(current => (current === 'back' ? 'front' : 'back'));
  };

  const takePicture = async () => {
    if (cameraRef.current) {
      try {
        const photo = await cameraRef.current.takePictureAsync({
          quality: 0.8,
        });
        
        if (photo) {
          let finalUri = photo.uri;
          
          // Flip image if using front camera
          if (facing === 'front') {
            const flippedImage = await ImageManipulator.manipulateAsync(
              photo.uri,
              [{ flip: ImageManipulator.FlipType.Horizontal }],
              { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG }
            );
            finalUri = flippedImage.uri;
          }
          
          setCapturedPhoto(finalUri);
          
          // Generate a beautiful color palette for background
          // Based on common photo scenarios: sunset, nature, indoor, etc.
          const colorPalettes = [
            '#FF6B6B', // Warm red/coral - sunset, love
            '#4ECDC4', // Teal - beach, water
            '#95E1D3', // Mint - nature, fresh
            '#F38181', // Pink - celebration, joy
            '#AA96DA', // Purple - evening, calm
            '#FCBAD3', // Light pink - family, warmth
            '#FFD93D', // Yellow - happiness, energy
            '#6BCB77', // Green - nature, outdoor
            '#4D96FF', // Blue - sky, peace
            '#FF8787', // Salmon - warm memories
          ];
          
          // Pick a random color for variety
          const randomColor = colorPalettes[Math.floor(Math.random() * colorPalettes.length)];
          setDominantColor(randomColor);
          
          // Generate AI suggested tags based on image content
          // TODO: Replace with actual AI image recognition API
          generateSuggestedTags();
        }
      } catch (error) {
        console.error('Error taking picture:', error);
      }
    }
  };

  const generateSuggestedTags = () => {
    // Mock AI-generated tags based on image content
    // In production, this would call an AI vision API
    const mockTags = [
      '🌅 Sunset',
      '👨‍👩‍👧‍👦 Family',
      '🏖️ Beach',
      '😊 Happy',
      '🌴 Nature',
      '📸 Memory',
      '❤️ Love',
      '🎉 Celebration',
    ];
    
    // Randomly select 4-6 tags to suggest
    const numTags = Math.floor(Math.random() * 3) + 4; // 4-6 tags
    const shuffled = mockTags.sort(() => 0.5 - Math.random());
    setSuggestedTags(shuffled.slice(0, numTags));
    setSelectedTags([]); // Reset selected tags
  };

  const toggleTag = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter(t => t !== tag));
    } else {
      setSelectedTags([...selectedTags, tag]);
    }
  };

  const handleCreateNewChapter = () => {
    Keyboard.dismiss();
    setShowNewChapterForm(true);
    setShowChapterDropdown(false);
    // Scroll to bottom to show form above keyboard
    setTimeout(() => {
      scrollViewRef.current?.scrollToEnd({ animated: true });
    }, 100);
  };

  const createNewChapterWithPhoto = async () => {
    if (capturedPhoto && newChapterName.trim()) {
      // Save to library
      if (mediaLibraryPermission?.granted) {
        try {
          await MediaLibrary.saveToLibraryAsync(capturedPhoto);
        } catch (error) {
          console.error('Error saving photo:', error);
        }
      }

      // TODO: Create new chapter with this photo
      // photoCaption is used as the photo description
      console.log('Creating new chapter:', {
        name: newChapterName,
        description: newChapterDescription,
        photo: capturedPhoto,
        tags: selectedTags,
        photoDescription: photoCaption, // Caption becomes photo description
      });
      
      // Reset state
      setCapturedPhoto(null);
      setSuggestedTags([]);
      setSelectedTags([]);
      setPhotoCaption('');
      setSelectedChapter(null);
      setShowNewChapterForm(false);
      setNewChapterName('');
      setNewChapterDescription('');
      
      // Show success message
      Alert.alert('Success', `Chapter "${newChapterName}" created with your photo!`);
    }
  };

  const addPhotoToChapter = async (chapterId: string | null) => {
    if (capturedPhoto) {
      // Save to library
      if (mediaLibraryPermission?.granted) {
        try {
          await MediaLibrary.saveToLibraryAsync(capturedPhoto);
        } catch (error) {
          console.error('Error saving photo:', error);
        }
      }

      // TODO: Add photo to existing chapter
      // photoCaption is used as the photo description
      console.log('Adding photo to chapter:', chapterId);
      console.log('Tags:', selectedTags);
      console.log('Photo description:', photoCaption); // Caption becomes photo description
      
      // Reset state
      setCapturedPhoto(null);
      setSuggestedTags([]);
      setSelectedTags([]);
      setPhotoCaption('');
      setSelectedChapter(null);
      setShowChapterDropdown(false);
      
      // Show success message
      Alert.alert('Success', 'Photo added to chapter!');
    }
  };

  const savePhoto = async () => {
    if (capturedPhoto && mediaLibraryPermission?.granted) {
      try {
        await MediaLibrary.saveToLibraryAsync(capturedPhoto);
        setCapturedPhoto(null); // Return to camera view
        setSuggestedTags([]);
        setSelectedTags([]);
        setPhotoCaption('');
      } catch (error) {
        console.error('Error saving photo:', error);
      }
    }
  };

  const retakePhoto = () => {
    Keyboard.dismiss();
    setCapturedPhoto(null);
    setDominantColor('#000000'); // Reset to black
    setSuggestedTags([]);
    setSelectedTags([]);
    setPhotoCaption('');
    setIsTypingCaption(false);
    setSelectedChapter(null);
    setShowChapterDropdown(false);
    setShowNewChapterForm(false);
    setNewChapterName('');
    setNewChapterDescription('');
  };

  const renderItem = ({ item, index }: { item: any; index: number }) => {
    // Camera View (First item)
    if (item.type === 'camera') {
      return (
        <View style={{ width, height }}>
          <View style={{ flex: 1, position: 'relative' }}>
            {/* Background with Gradient Effect After Capture */}
            <View style={{ 
              position: 'absolute', 
              top: 0, 
              left: 0, 
              right: 0, 
              bottom: 0,
              backgroundColor: '#FFFFFF'
            }}>
                {capturedPhoto && (
                  <>
                    {/* Gradient overlay - extends further down */}
                    <View style={{ 
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      right: 0,
                      height: height * 0.65,  // Top 65% of screen (increased from 50%)
                    }}>
                      <LinearGradient
                        colors={[
                          `${dominantColor}35`,      // Top - visible color
                          `${dominantColor}25`,      
                          `${dominantColor}15`,      
                          `${dominantColor}08`,
                          `${dominantColor}00`,      // Fully transparent
                        ]}
                        locations={[0, 0.3, 0.6, 0.85, 1]}
                        start={{ x: 0.5, y: 0 }}
                        end={{ x: 0.5, y: 1 }}
                        style={{ flex: 1 }}
                      />
                    </View>
                    {/* Light blur only at top */}
                    <View style={{ 
                      position: 'absolute',
                      top: 0,
                      left: 0,
                      right: 0,
                      height: height * 0.65,
                    }}>
                      <BlurView 
                        intensity={6} 
                        tint="light"
                        style={{ flex: 1 }} 
                      />
                    </View>
                  </>
                )}
              </View>

              <SafeAreaView style={{ flex: 1 }} edges={['top']}>
                {!capturedPhoto ? (
                  // No scroll when in camera view
                  <Box flex={1} position="relative">
              {/* Top Bar - Inside Safe Area */}
              <Box px={20} py={12}>
                <HStack justifyContent="space-between" alignItems="center">
                  <HStack gap={8}>
                    <TouchableOpacity onPress={() => navigation.navigate('Dashboard')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="arrow-back" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Profile')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="person-circle-outline" size={24} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Notifications')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                        position="relative"
                      >
                        <Ionicons name="notifications-outline" size={20} color="#000000" />
                        {/* Notification Badge */}
                        <Box
                          position="absolute"
                          top={4}
                          right={4}
                          w={8}
                          h={8}
                          borderRadius={4}
                          bg="#E74C3C"
                          borderWidth={1.5}
                          borderColor="#FFFFFF"
                        />
                      </Box>
                    </TouchableOpacity>
                  </HStack>
                  <HStack gap={8}>
                    <TouchableOpacity onPress={() => navigation.navigate('Gallery')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="book-outline" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Messages')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="chatbubble-outline" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                  </HStack>
                </HStack>
              </Box>

              {/* Camera Preview Area - Real Camera */}
              <Box 
                flex={capturedPhoto ? 0 : 1}
                justifyContent="center" 
                alignItems="center" 
                px={16}
                pt={capturedPhoto ? 12 : 0}
                style={{ 
                  minHeight: capturedPhoto ? undefined : height * 0.5, 
                  maxHeight: capturedPhoto ? undefined : height * 0.65 
                }}
              >
                <Box 
                  w={capturedPhoto ? "75%" : "95%"}
                  style={{ maxWidth: capturedPhoto ? 300 : 450 }}
                  aspectRatio={3/4}
                  borderRadius={20}
                  overflow="hidden"
                  borderWidth={1}
                  borderColor="#333333"
                >
                  {capturedPhoto ? (
                    // Show captured photo
                    <Image
                      source={{ uri: capturedPhoto }}
                      style={{ flex: 1, width: '100%', height: '100%' }}
                      resizeMode="cover"
                    />
                  ) : cameraPermission?.granted ? (
                    // Show live camera
                    <CameraView
                      ref={cameraRef}
                      style={{ flex: 1, width: '100%', height: '100%' }}
                      facing={facing}
                    />
                  ) : (
                    // Show permission message
                    <Box 
                      flex={1}
                      bg="#1A1A1A"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="camera" size={64} color="#555555" />
                      <Text fontSize={13} color="#777777" mt={8} textAlign="center" px={20}>
                        {cameraPermission === null ? 'Requesting camera permission...' : 'Camera permission denied'}
                      </Text>
                    </Box>
                  )}
                </Box>
              </Box>

              {/* AI Suggested Tags - Show after photo capture */}
              {capturedPhoto && suggestedTags.length > 0 && (
                <Box px={20} pt={20} pb={12}>
                  <VStack gap={12}>
                    <Text fontSize={13} fontWeight="600" color="rgba(0,0,0,0.6)">
                      Suggested tags:
                    </Text>
                    <ScrollView 
                      horizontal 
                      showsHorizontalScrollIndicator={false}
                      contentContainerStyle={{ gap: 8 }}
                    >
                      {suggestedTags.map((tag, index) => {
                        const isSelected = selectedTags.includes(tag);
                        return (
                          <TouchableOpacity 
                            key={index}
                            onPress={() => toggleTag(tag)}
                          >
                            <Box
                              bg={isSelected ? "#5DADE2" : "rgba(0,0,0,0.08)"}
                              borderRadius={20}
                              px={16}
                              py={8}
                              borderWidth={isSelected ? 0 : 1}
                              borderColor="rgba(0,0,0,0.15)"
                            >
                              <Text 
                                fontSize={13} 
                                fontWeight={isSelected ? "600" : "500"}
                                color={isSelected ? "#FFFFFF" : "#000000"}
                              >
                                {tag}
                              </Text>
                            </Box>
                          </TouchableOpacity>
                        );
                      })}
                    </ScrollView>
                  </VStack>
                </Box>
              )}

              {/* OLD SECTION - REMOVED */}
              {capturedPhoto && false && (
                <Box px={20} pb={12}>
                  <VStack gap={12}>
                    <Text fontSize={15} fontWeight="600" color="#2C3E50">
                      Add to Chapter
                    </Text>
                    
                    {/* Create New Chapter Button */}
                    <TouchableOpacity onPress={() => addPhotoToChapter('new')}>
                      <Box
                        bg="#5DADE2"
                        borderRadius={16}
                        p={16}
                      >
                        <HStack gap={12} alignItems="center">
                          <Box
                            w={40}
                            h={40}
                            borderRadius={12}
                            bg="rgba(255,255,255,0.2)"
                            justifyContent="center"
                            alignItems="center"
                          >
                            <Ionicons name="add" size={24} color="#FFFFFF" />
                          </Box>
                          <VStack flex={1}>
                            <Text fontSize={15} fontWeight="600" color="#FFFFFF">
                              Create New Chapter
                            </Text>
                            <Text fontSize={12} color="rgba(255,255,255,0.8)">
                              Start a new story
                            </Text>
                          </VStack>
                          <Ionicons name="chevron-forward" size={20} color="#FFFFFF" />
                        </HStack>
                      </Box>
                    </TouchableOpacity>

                    {/* Existing Chapters */}
                    <VStack gap={8}>
                      {myChapters.map((chapter) => (
                        <TouchableOpacity 
                          key={chapter.id}
                          onPress={() => addPhotoToChapter(chapter.id)}
                        >
                          <Box
                            bg={selectedChapter === chapter.id ? 'rgba(93,173,226,0.1)' : 'rgba(0,0,0,0.05)'}
                            borderRadius={12}
                            p={14}
                            borderWidth={selectedChapter === chapter.id ? 1 : 0}
                            borderColor="#5DADE2"
                          >
                            <HStack gap={12} alignItems="center">
                              <Text fontSize={24}>
                                {chapter.icon}
                              </Text>
                              <Text fontSize={14} fontWeight="500" color="#2C3E50" flex={1}>
                                {chapter.title}
                              </Text>
                              <Ionicons name="chevron-forward" size={18} color="#95A5A6" />
                            </HStack>
                          </Box>
                        </TouchableOpacity>
                      ))}
                    </VStack>
                  </VStack>
                </Box>
              )}

              {/* Bottom Camera Controls - Functional */}
              <Box pb={12} px={20}>
                <HStack justifyContent="center" alignItems="center" w="100%" gap={35}>
                  <TouchableOpacity>
                    <Box
                      w={42}
                      h={42}
                      borderRadius={12}
                      bg="rgba(0,0,0,0.08)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="images-outline" size={20} color="#000000" />
                    </Box>
                  </TouchableOpacity>

                  {/* Main Button - Capture or Next */}
                  <TouchableOpacity 
                    onPress={capturedPhoto ? savePhoto : takePicture} 
                    disabled={!cameraPermission?.granted && !capturedPhoto}
                  >
                    {/* Outer black border */}
                    <Box
                      w={74}
                      h={74}
                      borderRadius={37}
                      bg="#000000"
                      justifyContent="center"
                      alignItems="center"
                      opacity={(cameraPermission?.granted || capturedPhoto) ? 1 : 0.5}
                    >
                      {/* White gap */}
                      <Box
                        w={66}
                        h={66}
                        borderRadius={33}
                        bg="#FFFFFF"
                        justifyContent="center"
                        alignItems="center"
                      >
                        {/* Inner colored button with gradient */}
                        <LinearGradient
                          colors={capturedPhoto 
                            ? ['#34C759', '#34C759']
                            : ['#4ECDC4', '#5DADE2', '#667EEA']
                          }
                          start={{ x: 0, y: 0 }}
                          end={{ x: 1, y: 1 }}
                          style={{
                            width: 58,
                            height: 58,
                            borderRadius: 29,
                            justifyContent: 'center',
                            alignItems: 'center',
                          }}
                        >
                          {capturedPhoto && (
                            <Ionicons 
                              name="checkmark" 
                              size={32} 
                              color="#FFFFFF" 
                            />
                          )}
                        </LinearGradient>
                      </Box>
                    </Box>
                  </TouchableOpacity>

                  {/* Right Button - Flip Camera or Retake */}
                  
                  {/* Right Button - Flip Camera or Retake */}
                  <TouchableOpacity 
                    onPress={capturedPhoto ? retakePhoto : toggleCameraFacing} 
                    disabled={!cameraPermission?.granted && !capturedPhoto}
                  >
                    <Box
                      w={42}
                      h={42}
                      borderRadius={12}
                      bg="rgba(0,0,0,0.08)"
                      justifyContent="center"
                      alignItems="center"
                      opacity={(cameraPermission?.granted || capturedPhoto) ? 1 : 0.5}
                    >
                      <Ionicons 
                        name={capturedPhoto ? "close" : "camera-reverse-outline"} 
                        size={20} 
                        color="#000000" 
                      />
                    </Box>
                  </TouchableOpacity>
                </HStack>
              </Box>

              {/* Story Chapters Button - Bottom Left - Only show when not captured */}
              <Box position="absolute" bottom={40} left={40} zIndex={999}>
                <TouchableOpacity onPress={() => navigation.navigate('Gallery')}>
                  <Box
                    w={56}
                    h={56}
                    borderRadius={16}
                    bg="rgba(255,255,255,0.95)"
                    justifyContent="center"
                    alignItems="center"
                    shadowColor="#000"
                    shadowOffset={{ width: 0, height: 2 }}
                    shadowOpacity={0.15}
                    shadowRadius={8}
                    borderWidth={1}
                    borderColor="rgba(0,0,0,0.08)"
                  >
                    <Ionicons name="book" size={24} color="#5DADE2" />
                  </Box>
                </TouchableOpacity>
              </Box>

              {/* AI Bubble Component - Fixed Position */}
              <Box position="absolute" bottom={20} right={20} zIndex={999}>
                <AIBubble />
              </Box>
            </Box>
                ) : (
                  // Scrollable when photo captured
                  <ScrollView 
                    ref={scrollViewRef}
                    contentContainerStyle={{ flexGrow: 1 }}
                    keyboardShouldPersistTaps="handled"
                    showsVerticalScrollIndicator={false}
                    scrollEnabled={true}
                    bounces={false}
                  >
                    <Box minHeight={height} position="relative">
              {/* Top Bar - Inside Safe Area */}
              <Box px={20} py={12}>
                <HStack justifyContent="space-between" alignItems="center">
                  <HStack gap={8}>
                    <TouchableOpacity onPress={() => navigation.navigate('Dashboard')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="arrow-back" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Profile')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="person-circle-outline" size={24} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Notifications')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                        position="relative"
                      >
                        <Ionicons name="notifications-outline" size={20} color="#000000" />
                        {/* Notification Badge */}
                        <Box
                          position="absolute"
                          top={4}
                          right={4}
                          w={8}
                          h={8}
                          borderRadius={4}
                          bg="#E74C3C"
                          borderWidth={1.5}
                          borderColor="#FFFFFF"
                        />
                      </Box>
                    </TouchableOpacity>
                  </HStack>
                  <HStack gap={8}>
                    <TouchableOpacity onPress={() => navigation.navigate('Gallery')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="book-outline" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => navigation.navigate('Messages')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(0,0,0,0.08)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="chatbubble-outline" size={20} color="#000000" />
                      </Box>
                    </TouchableOpacity>
                  </HStack>
                </HStack>
              </Box>

              {/* Camera Preview Area - Real Camera */}
              <Box 
                flex={0}
                justifyContent="center" 
                alignItems="center" 
                px={16}
                pt={12}
              >
                <Box 
                  w="60%"
                  style={{ maxWidth: 240 }}
                  aspectRatio={3/4}
                  borderRadius={20}
                  overflow="hidden"
                  borderWidth={1}
                  borderColor="#333333"
                >
                  <Image
                    source={{ uri: capturedPhoto }}
                    style={{ flex: 1, width: '100%', height: '100%' }}
                    resizeMode="cover"
                  />
                </Box>
              </Box>

              {/* AI Suggested Tags - Show after photo capture */}
              {suggestedTags.length > 0 && (
                <Box px={20} pt={20} pb={12}>
                  <VStack gap={12}>
                    <Text fontSize={13} fontWeight="600" color="rgba(0,0,0,0.6)">
                      Suggested tags:
                    </Text>
                    <ScrollView 
                      horizontal 
                      showsHorizontalScrollIndicator={false}
                      contentContainerStyle={{ gap: 8 }}
                    >
                      {suggestedTags.map((tag, index) => {
                        const isSelected = selectedTags.includes(tag);
                        return (
                          <TouchableOpacity 
                            key={index}
                            onPress={() => toggleTag(tag)}
                          >
                            <Box
                              bg={isSelected ? "#5DADE2" : "rgba(0,0,0,0.08)"}
                              borderRadius={20}
                              px={16}
                              py={8}
                              borderWidth={isSelected ? 0 : 1}
                              borderColor="rgba(0,0,0,0.15)"
                            >
                              <Text 
                                fontSize={13} 
                                fontWeight={isSelected ? "600" : "500"}
                                color={isSelected ? "#FFFFFF" : "#000000"}
                              >
                                {tag}
                              </Text>
                            </Box>
                          </TouchableOpacity>
                        );
                      })}
                    </ScrollView>
                  </VStack>
                </Box>
              )}

              {/* Caption Input and Action Buttons - Always show after photo capture */}
              {!showNewChapterForm && !showChapterDropdown && (
                <Box px={20} pb={12}>
                  <VStack gap={16}>
                    <Box
                      bg="rgba(0,0,0,0.05)"
                      borderRadius={16}
                      borderWidth={1}
                      borderColor="rgba(0,0,0,0.1)"
                    >
                      <TextInput
                        value={photoCaption}
                        onChangeText={setPhotoCaption}
                        placeholder="Add a caption... (optional)"
                        placeholderTextColor="rgba(0,0,0,0.4)"
                        multiline
                        onFocus={() => {
                          setIsTypingCaption(true);
                          setTimeout(() => {
                            scrollViewRef.current?.scrollToEnd({ animated: true });
                          }, 100);
                        }}
                        onBlur={() => setIsTypingCaption(false)}
                        style={{
                          paddingHorizontal: 16,
                          paddingVertical: 12,
                          fontSize: 14,
                          color: '#000000',
                          minHeight: 60,
                          maxHeight: 100,
                          textAlignVertical: 'top',
                        }}
                      />
                    </Box>

                    {/* Two Action Buttons */}
                    <VStack gap={12}>
                      {/* Create New Chapter Button */}
                      <TouchableOpacity onPress={handleCreateNewChapter}>
                        <Box
                          bg="#5DADE2"
                          borderRadius={16}
                          p={16}
                        >
                          <HStack gap={12} alignItems="center" justifyContent="center">
                            <Ionicons name="add-circle" size={20} color="#FFFFFF" />
                            <Text fontSize={15} fontWeight="600" color="#FFFFFF">
                              Create New Chapter
                            </Text>
                          </HStack>
                        </Box>
                      </TouchableOpacity>

                      {/* Add to Existing Chapter Button */}
                      <TouchableOpacity onPress={() => setShowChapterDropdown(!showChapterDropdown)}>
                        <Box
                          bg="#FFFFFF"
                          borderRadius={16}
                          p={16}
                          borderWidth={2}
                          borderColor="#5DADE2"
                        >
                          <HStack gap={12} alignItems="center" justifyContent="center">
                            <Ionicons name="folder-open" size={20} color="#5DADE2" />
                            <Text fontSize={15} fontWeight="600" color="#5DADE2">
                              Add to Existing Chapter
                            </Text>
                          </HStack>
                        </Box>
                      </TouchableOpacity>
                    </VStack>
                  </VStack>
                </Box>
              )}

              {/* New Chapter Form - Show when Create New Chapter is clicked */}
              {showNewChapterForm && (
                <Box px={20} pb={12}>
                  <VStack gap={16}>
                    <Text fontSize={15} fontWeight="600" color="#2C3E50">
                      Create New Chapter
                    </Text>
                    
                    {(
                      // New Chapter Form
                      <Box
                        bg="rgba(93,173,226,0.1)"
                        borderRadius={16}
                        p={16}
                        borderWidth={1}
                        borderColor="#5DADE2"
                      >
                        <VStack gap={14}>
                          <HStack justifyContent="space-between" alignItems="center">
                            <Text fontSize={15} fontWeight="600" color="#2C3E50">
                              New Chapter
                            </Text>
                            <TouchableOpacity onPress={() => setShowNewChapterForm(false)}>
                              <Box
                                bg="#E8E8E8"
                                borderRadius={8}
                                px={12}
                                py={6}
                              >
                                <Text fontSize={13} fontWeight="600" color="#5A5A5A">
                                  Cancel
                                </Text>
                              </Box>
                            </TouchableOpacity>
                          </HStack>

                          {/* Chapter Name Input */}
                          <Box>
                            <Text fontSize={13} fontWeight="500" color="#7F8C8D" mb={6}>
                              Chapter Name *
                            </Text>
                            <Box
                              bg="#FFFFFF"
                              borderRadius={12}
                              borderWidth={1}
                              borderColor="rgba(0,0,0,0.1)"
                            >
                              <TextInput
                                value={newChapterName}
                                onChangeText={setNewChapterName}
                                placeholder="e.g. Summer Vacation 2024"
                                placeholderTextColor="rgba(0,0,0,0.4)"
                                style={{
                                  paddingHorizontal: 14,
                                  paddingVertical: 10,
                                  fontSize: 14,
                                  color: '#000000',
                                }}
                              />
                            </Box>
                          </Box>

                          {/* Chapter Description Input */}
                          <Box>
                            <Text fontSize={13} fontWeight="500" color="#7F8C8D" mb={6}>
                              Description (optional)
                            </Text>
                            <Box
                              bg="#FFFFFF"
                              borderRadius={12}
                              borderWidth={1}
                              borderColor="rgba(0,0,0,0.1)"
                            >
                              <TextInput
                                value={newChapterDescription}
                                onChangeText={setNewChapterDescription}
                                placeholder="Describe this chapter..."
                                placeholderTextColor="rgba(0,0,0,0.4)"
                                multiline
                                numberOfLines={3}
                                style={{
                                  paddingHorizontal: 14,
                                  paddingVertical: 10,
                                  fontSize: 14,
                                  color: '#000000',
                                  minHeight: 70,
                                  textAlignVertical: 'top',
                                }}
                              />
                            </Box>
                          </Box>

                          {/* Create Button */}
                          <TouchableOpacity 
                            onPress={createNewChapterWithPhoto}
                            disabled={!newChapterName.trim()}
                          >
                            <Box
                              bg={newChapterName.trim() ? "#5DADE2" : "rgba(0,0,0,0.1)"}
                              borderRadius={12}
                              py={12}
                              alignItems="center"
                            >
                              <Text 
                                fontSize={14} 
                                fontWeight="600" 
                                color={newChapterName.trim() ? "#FFFFFF" : "#95A5A6"}
                              >
                                Create Chapter & Add Photo
                              </Text>
                            </Box>
                          </TouchableOpacity>
                        </VStack>
                      </Box>
                    )}
                  </VStack>
                </Box>
              )}

              {/* Existing Chapters Dropdown - Show when Add to Existing Chapter is clicked */}
              {showChapterDropdown && (
                <Box px={20} pb={12}>
                  <VStack gap={12}>
                    <HStack justifyContent="space-between" alignItems="center">
                      <Text fontSize={15} fontWeight="600" color="#2C3E50">
                        Select Chapter
                      </Text>
                      <TouchableOpacity onPress={() => setShowChapterDropdown(false)}>
                        <Box
                          bg="#E8E8E8"
                          borderRadius={8}
                          px={12}
                          py={6}
                        >
                          <Text fontSize={13} fontWeight="600" color="#5A5A5A">
                            Cancel
                          </Text>
                        </Box>
                      </TouchableOpacity>
                    </HStack>

                    <VStack gap={8}>
                      {myChapters.map((chapter) => (
                        <TouchableOpacity 
                          key={chapter.id}
                          onPress={() => {
                            setSelectedChapter(chapter.id);
                            addPhotoToChapter(chapter.id);
                          }}
                        >
                          <Box
                            bg="rgba(93,173,226,0.05)"
                            borderRadius={12}
                            p={14}
                            borderWidth={1}
                            borderColor={selectedChapter === chapter.id ? "#5DADE2" : "rgba(0,0,0,0.1)"}
                          >
                            <HStack gap={12} alignItems="center">
                              <Text fontSize={24}>
                                {chapter.icon}
                              </Text>
                              <Text fontSize={15} fontWeight="600" color="#2C3E50" flex={1}>
                                {chapter.title}
                              </Text>
                              <Ionicons name="chevron-forward" size={18} color="#5DADE2" />
                            </HStack>
                          </Box>
                        </TouchableOpacity>
                      ))}
                    </VStack>
                  </VStack>
                </Box>
              )}

              {/* Bottom Camera Controls - Functional */}
              <Box pb={12} px={20}>
                <HStack justifyContent="center" alignItems="center" w="100%" gap={35}>
                  <TouchableOpacity>
                    <Box
                      w={42}
                      h={42}
                      borderRadius={12}
                      bg="rgba(0,0,0,0.08)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="share-outline" size={20} color="#000000" />
                    </Box>
                  </TouchableOpacity>

                  {/* Main Button - Save Photo */}
                  <TouchableOpacity 
                    onPress={savePhoto} 
                  >
                    {/* Outer black border */}
                    <Box
                      w={74}
                      h={74}
                      borderRadius={37}
                      bg="#000000"
                      justifyContent="center"
                      alignItems="center"
                    >
                      {/* White gap */}
                      <Box
                        w={66}
                        h={66}
                        borderRadius={33}
                        bg="#FFFFFF"
                        justifyContent="center"
                        alignItems="center"
                      >
                        {/* Inner colored button with gradient */}
                        <LinearGradient
                          colors={['#34C759', '#34C759']}
                          start={{ x: 0, y: 0 }}
                          end={{ x: 1, y: 1 }}
                          style={{
                            width: 58,
                            height: 58,
                            borderRadius: 29,
                            justifyContent: 'center',
                            alignItems: 'center',
                          }}
                        >
                          <Ionicons 
                            name="checkmark" 
                            size={32} 
                            color="#FFFFFF" 
                          />
                        </LinearGradient>
                      </Box>
                    </Box>
                  </TouchableOpacity>

                  {/* Right Button - Retake */}
                  <TouchableOpacity onPress={retakePhoto}>
                    <Box
                      w={42}
                      h={42}
                      borderRadius={12}
                      bg="rgba(0,0,0,0.08)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="close" size={20} color="#000000" />
                    </Box>
                  </TouchableOpacity>
                </HStack>
              </Box>

              {/* AI Bubble Component - Fixed Position */}
              <Box position="absolute" bottom={20} right={20} zIndex={999}>
                <AIBubble />
              </Box>
            </Box>
          </ScrollView>
                )}
          </SafeAreaView>
        </View>
      </View>
    );
  }

    // Photo View (Friend's photo)
    return (
      <View style={{ width, height }}>
        <SafeAreaView style={{ flex: 1 }} edges={['top']}>
          {/* Fullscreen Photo */}
          <Image
            source={{ uri: item.imageUrl }}
            style={{ 
              position: 'absolute',
              width: '100%', 
              height: '100%',
              top: 0,
              left: 0,
            }}
            resizeMode="cover"
          />

          {/* Top Overlay - Inside Safe Area */}
          <Box
            pt={12}
            pb={20}
            px={20}
            bg="rgba(0,0,0,0.5)"
          >
            <HStack justifyContent="space-between" alignItems="center">
              <HStack gap={12} alignItems="center">
                <Box
                  w={32}
                  h={32}
                  borderRadius={16}
                  bg="#FFFFFF"
                  alignItems="center"
                  justifyContent="center"
                >
                  <Text fontSize={14} fontWeight="bold" color="#5DADE2">
                    {item.userInitial}
                  </Text>
                </Box>
                <VStack gap={2}>
                  <Text fontSize={15} fontWeight="600" color="#FFFFFF">
                    {item.user}
                  </Text>
                  <Text fontSize={12} color="rgba(255,255,255,0.8)">
                    {item.time}
                  </Text>
                </VStack>
              </HStack>
              <Text fontSize={15} fontWeight="500" color="#FFFFFF">
                Everyone
              </Text>
            </HStack>
          </Box>

          {/* Bottom Overlay */}
          <Box
            position="absolute"
            bottom={20}
            left={0}
            right={0}
            px={20}
          >
            <VStack gap={16}>
              {/* Caption with background */}
              <Box
                bg="rgba(0,0,0,0.5)"
                px={16}
                py={10}
                borderRadius={16}
              >
                <Text fontSize={14} color="#FFFFFF" lineHeight={20}>
                  {item.caption}
                </Text>
              </Box>

              {/* Message Input with reactions */}
              <HStack
                bg="rgba(40,40,40,0.85)"
                borderRadius={24}
                px={18}
                py={12}
                alignItems="center"
                gap={10}
              >
                <Text fontSize={14} color="rgba(255,255,255,0.5)" flex={1}>
                  Send message...
                </Text>
                <TouchableOpacity>
                  <Ionicons name="flame" size={22} color="#FF6B35" />
                </TouchableOpacity>
                <TouchableOpacity>
                  <Ionicons name="heart" size={22} color="#FF3B8E" />
                </TouchableOpacity>
                <TouchableOpacity>
                  <Ionicons name="happy-outline" size={22} color="#FFFFFF" />
                </TouchableOpacity>
              </HStack>
            </VStack>
          </Box>
        </SafeAreaView>
      </View>
    );
  };

  const onViewRef = useRef((viewableItems: any) => {
    if (viewableItems.viewableItems.length > 0) {
      setCurrentIndex(viewableItems.viewableItems[0].index || 0);
    }
  });

  const viewConfigRef = useRef({ viewAreaCoveragePercentThreshold: 50 });

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={[]}>
      <StatusBar barStyle="dark-content" />
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={{ flex: 1 }}
        keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 20}
      >
        <Box flex={1} bg="#FFFFFF">
          <FlatList
            data={familyPhotos}
            renderItem={renderItem}
            keyExtractor={(item) => item.id.toString()}
            scrollEnabled={false}
            showsVerticalScrollIndicator={false}
            onViewableItemsChanged={onViewRef.current}
            viewabilityConfig={viewConfigRef.current}
          />
        </Box>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
