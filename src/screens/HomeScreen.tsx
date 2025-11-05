import React, { useState, useRef, useEffect } from 'react';
import { 
  Dimensions, 
  TouchableOpacity, 
  Image, 
  FlatList,
  View,
  StatusBar,
  Animated,
  Pressable,
  TextInput,
  Keyboard,
  KeyboardAvoidingView,
  Platform,
  Modal,
  ScrollView,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
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
import { ExpoWebSpeechRecognition } from 'expo-speech-recognition';

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
  const [suggestedTags, setSuggestedTags] = useState<string[]>([]);
  const [selectedTags, setSelectedTags] = useState<string[]>([]);
  const [photoCaption, setPhotoCaption] = useState('');
  const [isRecording, setIsRecording] = useState(false);
  const [isPressing, setIsPressing] = useState(false);
  const [recognizedText, setRecognizedText] = useState('');
  const [isChatModalVisible, setIsChatModalVisible] = useState(false);
  const [chatMessage, setChatMessage] = useState('');
  const [chatHistory, setChatHistory] = useState<Array<{role: 'user' | 'ai', message: string}>>([]);
  const cameraRef = useRef<CameraView>(null);
  const holdTimerRef = useRef<NodeJS.Timeout | null>(null);
  const recognitionRef = useRef<ExpoWebSpeechRecognition | null>(null);
  
  // Animation values for voice wave
  const waveAnimation1 = useRef(new Animated.Value(1)).current;
  const waveAnimation2 = useRef(new Animated.Value(1)).current;
  const waveAnimation3 = useRef(new Animated.Value(1)).current;
  const waveAnimation4 = useRef(new Animated.Value(1)).current;
  const waveAnimation5 = useRef(new Animated.Value(1)).current;
  const pressAnimation = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Request permissions on mount
    (async () => {
      if (!cameraPermission?.granted) {
        await requestCameraPermission();
      }
      if (!mediaLibraryPermission?.granted) {
        await requestMediaLibraryPermission();
      }
      
      // Initialize speech recognition
      recognitionRef.current = new ExpoWebSpeechRecognition();
      recognitionRef.current.lang = 'vi-VN';
      recognitionRef.current.continuous = true;
      recognitionRef.current.interimResults = true;
      recognitionRef.current.maxAlternatives = 1;
      
      // Set up event listeners
      recognitionRef.current.onresult = (event) => {
        const results = event.results;
        if (results && results.length > 0) {
          const transcript = Array.from(results)
            .map((result) => result[0]?.transcript || '')
            .join('');
          setRecognizedText(transcript);
        }
      };
      
      recognitionRef.current.onerror = (event) => {
        console.error('Speech recognition error:', event.error);
        Alert.alert('Lỗi nhận diện giọng nói', event.error || 'Có lỗi xảy ra');
        setIsRecording(false);
      };
      
      recognitionRef.current.onend = () => {
        console.log('Speech recognition ended');
        setIsRecording(false);
      };
    })();
    
    // Cleanup
    return () => {
      if (recognitionRef.current) {
        try {
          recognitionRef.current.stop();
        } catch (e) {
          // Ignore errors during cleanup
        }
      }
    };
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
          setCapturedPhoto(photo.uri);
          
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

  const postPhotoToFeed = async () => {
    if (capturedPhoto && selectedTags.length > 0) {
      // TODO: Upload photo and tags to backend/feed
      console.log('Posting photo with tags:', selectedTags);
      
      // Save to library
      if (mediaLibraryPermission?.granted) {
        try {
          await MediaLibrary.saveToLibraryAsync(capturedPhoto);
        } catch (error) {
          console.error('Error saving photo:', error);
        }
      }
      
      // Reset state
      setCapturedPhoto(null);
      setSuggestedTags([]);
      setSelectedTags([]);
      setPhotoCaption('');
      
      // Show success message
      // TODO: Add toast/alert notification
      console.log('Photo posted successfully!');
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
    setCapturedPhoto(null);
    setSuggestedTags([]);
    setSelectedTags([]);
    setPhotoCaption('');
  };

  const handlePressIn = () => {
    setIsPressing(true);
    
    // Start progress animation
    Animated.timing(pressAnimation, {
      toValue: 1,
      duration: 2000,
      useNativeDriver: false,
    }).start();

    // Set timer for 2 seconds
    holdTimerRef.current = setTimeout(() => {
      startVoiceRecording();
    }, 2000);
  };

  const handlePressOut = () => {
    setIsPressing(false);
    
    // Clear timer if released before 2 seconds
    if (holdTimerRef.current) {
      clearTimeout(holdTimerRef.current);
      holdTimerRef.current = null;
    }

    // Stop and reset progress animation immediately
    pressAnimation.stopAnimation(() => {
      pressAnimation.setValue(0);
    });

    // Stop recording if it was started
    if (isRecording) {
      stopVoiceRecording();
    }
  };

  const startVoiceRecording = async () => {
    try {
      if (!recognitionRef.current) {
        throw new Error('Speech recognition not initialized');
      }
      
      // Haptic feedback when starting
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      setIsRecording(true);
      setRecognizedText('');
      
      // Start speech recognition
      recognitionRef.current.start();
      console.log('Speech recognition started');
      
      // Start wave animations
      const createWaveAnimation = (animValue: Animated.Value, delay: number) => {
        return Animated.loop(
          Animated.sequence([
            Animated.timing(animValue, {
              toValue: 1.5,
              duration: 400,
              delay,
              useNativeDriver: true,
            }),
            Animated.timing(animValue, {
              toValue: 1,
              duration: 400,
              useNativeDriver: true,
            }),
          ])
        );
      };

    Animated.parallel([
      createWaveAnimation(waveAnimation1, 0),
      createWaveAnimation(waveAnimation2, 100),
      createWaveAnimation(waveAnimation3, 200),
      createWaveAnimation(waveAnimation4, 300),
      createWaveAnimation(waveAnimation5, 400),
    ]).start();
    } catch (error) {
      console.error('Error starting speech recognition:', error);
      Alert.alert('Lỗi', 'Không thể bắt đầu nhận diện giọng nói. Vui lòng thử lại.');
      setIsRecording(false);
    }
  };

  const stopVoiceRecording = async () => {
    try {
      if (recognitionRef.current) {
        // Stop speech recognition
        recognitionRef.current.stop();
      }
      
      // Haptic feedback when stopping
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setIsRecording(false);
      
      // Stop all animations
      waveAnimation1.stopAnimation();
      waveAnimation2.stopAnimation();
      waveAnimation3.stopAnimation();
      waveAnimation4.stopAnimation();
      waveAnimation5.stopAnimation();
      
      // Reset to original values
      waveAnimation1.setValue(1);
      waveAnimation2.setValue(1);
      waveAnimation3.setValue(1);
      waveAnimation4.setValue(1);
      waveAnimation5.setValue(1);
      
      // Show recognized text
      if (recognizedText) {
        console.log('Recognized text:', recognizedText);
      }
    } catch (error) {
      console.error('Error stopping speech recognition:', error);
      setIsRecording(false);
    }
  };

  const expandChat = () => {
    setIsChatModalVisible(true);
  };

  const closeChat = () => {
    setIsChatModalVisible(false);
    Keyboard.dismiss();
  };

  const sendMessage = () => {
    if (chatMessage.trim()) {
      // Add user message to history
      setChatHistory([...chatHistory, { role: 'user', message: chatMessage.trim() }]);
      
      // TODO: Call AI API and add response
      // Mock AI response for now
      setTimeout(() => {
        setChatHistory(prev => [...prev, { 
          role: 'ai', 
          message: 'This is a mock AI response. Integration with actual AI API coming soon!' 
        }]);
      }, 1000);
      
      setChatMessage('');
    }
  };

  const renderItem = ({ item, index }: { item: any; index: number }) => {
    // Camera View (First item)
    if (item.type === 'camera') {
      return (
        <View style={{ width, height }}>
          <KeyboardAvoidingView 
            behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
            style={{ flex: 1 }}
          >
            <SafeAreaView style={{ flex: 1, backgroundColor: '#000000' }} edges={['top']}>
              <Box flex={1} bg="#000000">
              {/* Top Bar - Inside Safe Area */}
              <Box px={20} py={12} position="relative">
                <HStack justifyContent="space-between" alignItems="center">
                  <TouchableOpacity>
                    <Box
                      w={36}
                      h={36}
                      borderRadius={18}
                      bg="rgba(255,255,255,0.15)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="person-circle-outline" size={24} color="#FFFFFF" />
                    </Box>
                  </TouchableOpacity>
                  <HStack gap={8}>
                    <TouchableOpacity onPress={() => navigation.navigate('Gallery')}>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(255,255,255,0.15)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="images-outline" size={20} color="#FFFFFF" />
                      </Box>
                    </TouchableOpacity>
                    <TouchableOpacity>
                      <Box
                        w={36}
                        h={36}
                        borderRadius={18}
                        bg="rgba(255,255,255,0.15)"
                        justifyContent="center"
                        alignItems="center"
                      >
                        <Ionicons name="chatbubble-outline" size={20} color="#FFFFFF" />
                      </Box>
                    </TouchableOpacity>
                  </HStack>
                </HStack>
                
                {/* Everyone Button - Centered Absolutely */}
                <Box
                  position="absolute"
                  left={0}
                  right={0}
                  top={12}
                  alignItems="center"
                  pointerEvents="box-none"
                >
                  <TouchableOpacity onPress={() => navigation.navigate('Feed')}>
                    <Box
                      bg="rgba(255,255,255,0.2)"
                      borderRadius={20}
                      px={16}
                      py={8}
                    >
                      <HStack alignItems="center" gap={8}>
                        {/* Notification Badge */}
                        <Box
                          bg="#2A2A2A"
                          borderRadius={10}
                          minWidth={20}
                          h={20}
                          justifyContent="center"
                          alignItems="center"
                          px={6}
                        >
                          <Text fontSize={11} fontWeight="700" color="#FFFFFF">
                            3
                          </Text>
                        </Box>
                        <Text fontSize={15} fontWeight="600" color="#FFFFFF">
                          Everyone
                        </Text>
                      </HStack>
                    </Box>
                  </TouchableOpacity>
                </Box>
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
                    <Text fontSize={13} fontWeight="600" color="rgba(255,255,255,0.8)">
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
                              bg={isSelected ? "#5DADE2" : "rgba(255,255,255,0.15)"}
                              borderRadius={20}
                              px={16}
                              py={8}
                              borderWidth={isSelected ? 0 : 1}
                              borderColor="rgba(255,255,255,0.3)"
                            >
                              <Text 
                                fontSize={13} 
                                fontWeight={isSelected ? "600" : "500"}
                                color="#FFFFFF"
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

              {/* Caption Input - Show after photo capture */}
              {capturedPhoto && (
                <Box px={20} pb={12}>
                  <Box
                    bg="rgba(255,255,255,0.1)"
                    borderRadius={16}
                    borderWidth={1}
                    borderColor="rgba(255,255,255,0.2)"
                  >
                    <TextInput
                      value={photoCaption}
                      onChangeText={setPhotoCaption}
                      placeholder="Add a caption... (optional)"
                      placeholderTextColor="rgba(255,255,255,0.4)"
                      multiline
                      style={{
                        paddingHorizontal: 16,
                        paddingVertical: 12,
                        fontSize: 14,
                        color: '#FFFFFF',
                        minHeight: 60,
                        maxHeight: 100,
                        textAlignVertical: 'top',
                      }}
                    />
                  </Box>
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
                      bg="rgba(255,255,255,0.15)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="images-outline" size={20} color="#FFFFFF" />
                    </Box>
                  </TouchableOpacity>

                  {/* Main Button - Capture or Post */}
                  <TouchableOpacity 
                    onPress={capturedPhoto ? (selectedTags.length > 0 ? postPhotoToFeed : savePhoto) : takePicture} 
                    disabled={!cameraPermission?.granted}
                  >
                    <Box
                      w={62}
                      h={62}
                      borderRadius={31}
                      bg={capturedPhoto ? (selectedTags.length > 0 ? "#5DADE2" : "#34C759") : "#FFFFFF"}
                      borderWidth={4}
                      borderColor={capturedPhoto ? (selectedTags.length > 0 ? "rgba(93,173,226,0.3)" : "rgba(52,199,89,0.3)") : "rgba(255,255,255,0.3)"}
                      opacity={cameraPermission?.granted ? 1 : 0.5}
                      justifyContent="center"
                      alignItems="center"
                    >
                      {capturedPhoto && (
                        <Ionicons 
                          name={selectedTags.length > 0 ? "paper-plane" : "checkmark"} 
                          size={selectedTags.length > 0 ? 24 : 32} 
                          color="#FFFFFF" 
                        />
                      )}
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
                      bg="rgba(255,255,255,0.15)"
                      justifyContent="center"
                      alignItems="center"
                      opacity={(cameraPermission?.granted || capturedPhoto) ? 1 : 0.5}
                    >
                      <Ionicons 
                        name={capturedPhoto ? "close" : "camera-reverse-outline"} 
                        size={20} 
                        color="#FFFFFF" 
                      />
                    </Box>
                  </TouchableOpacity>
                </HStack>
              </Box>

              {/* AI Chat Button & Voice Chat Button */}
              <Box pb={20} px={20}>
                <VStack gap={10}>
                  {/* AI Chat Button - Opens Modal */}
                  <TouchableOpacity 
                    onPress={expandChat}
                    activeOpacity={0.8}
                  >
                    <Box
                      bg="rgba(40,40,40,0.9)"
                      borderRadius={24}
                      px={16}
                      py={12}
                    >
                      <HStack alignItems="center" gap={10}>
                        <Ionicons name="sparkles" size={20} color="#5DADE2" />
                        <Text fontSize={14} color="rgba(255,255,255,0.7)" flex={1}>
                          Ask AI anything...
                        </Text>
                        <Ionicons name="chevron-forward" size={20} color="rgba(255,255,255,0.3)" />
                      </HStack>
                    </Box>
                  </TouchableOpacity>

                  {/* Voice Chat Button */}
                  <Pressable
                    onPressIn={handlePressIn}
                    onPressOut={handlePressOut}
                  >
                    <Box
                      bg={isRecording ? "rgba(93,173,226,0.3)" : "rgba(93,173,226,0.15)"}
                      borderRadius={24}
                      borderWidth={1}
                      borderColor={isRecording ? "#5DADE2" : "rgba(93,173,226,0.3)"}
                      py={12}
                      px={16}
                      position="relative"
                      overflow="hidden"
                    >
                      {/* Progress bar background */}
                      {isPressing && !isRecording && (
                        <Animated.View
                          style={{
                            position: 'absolute',
                            left: 0,
                            top: 0,
                            bottom: 0,
                            backgroundColor: 'rgba(93,173,226,0.2)',
                            width: pressAnimation.interpolate({
                              inputRange: [0, 1],
                              outputRange: ['0%', '100%'],
                            }),
                          }}
                        />
                      )}

                      {isRecording ? (
                        // Recording UI with Wave Animation
                        <VStack gap={8} alignItems="center">
                          <HStack gap={4} alignItems="center" h={24}>
                            <Animated.View style={{ transform: [{ scaleY: waveAnimation1 }] }}>
                              <Box w={3} h={12} bg="#5DADE2" borderRadius={2} />
                            </Animated.View>
                            <Animated.View style={{ transform: [{ scaleY: waveAnimation2 }] }}>
                              <Box w={3} h={16} bg="#5DADE2" borderRadius={2} />
                            </Animated.View>
                            <Animated.View style={{ transform: [{ scaleY: waveAnimation3 }] }}>
                              <Box w={3} h={20} bg="#5DADE2" borderRadius={2} />
                            </Animated.View>
                            <Animated.View style={{ transform: [{ scaleY: waveAnimation4 }] }}>
                              <Box w={3} h={16} bg="#5DADE2" borderRadius={2} />
                            </Animated.View>
                            <Animated.View style={{ transform: [{ scaleY: waveAnimation5 }] }}>
                              <Box w={3} h={12} bg="#5DADE2" borderRadius={2} />
                            </Animated.View>
                          </HStack>
                          <Text fontSize={12} fontWeight="600" color="#5DADE2">
                            Đang nghe...
                          </Text>
                          {recognizedText ? (
                            <Text fontSize={13} color="#FFFFFF" textAlign="center" px={8}>
                              {recognizedText}
                            </Text>
                          ) : null}
                        </VStack>
                      ) : (
                        // Default UI
                        <HStack justifyContent="center" alignItems="center" gap={8} zIndex={1}>
                          <Ionicons name="mic" size={20} color="#5DADE2" />
                          <Text fontSize={13} fontWeight="600" color="#5DADE2">
                            {isPressing ? 'Giữ lại...' : 'Giữ để nói chuyện'}
                          </Text>
                        </HStack>
                      )}
                    </Box>
                  </Pressable>
                  
                  {/* Display recognized text after recording */}
                  {!isRecording && recognizedText && (
                    <Box
                      bg="rgba(40,40,40,0.9)"
                      borderRadius={16}
                      px={16}
                      py={12}
                      borderWidth={1}
                      borderColor="rgba(93,173,226,0.3)"
                    >
                      <VStack gap={8}>
                        <HStack justifyContent="space-between" alignItems="center">
                          <Text fontSize={12} fontWeight="600" color="#5DADE2">
                            Văn bản nhận diện:
                          </Text>
                          <TouchableOpacity onPress={() => setRecognizedText('')}>
                            <Ionicons name="close-circle" size={20} color="rgba(255,255,255,0.5)" />
                          </TouchableOpacity>
                        </HStack>
                        <Text fontSize={14} color="#FFFFFF">
                          {recognizedText}
                        </Text>
                      </VStack>
                    </Box>
                  )}
                </VStack>
              </Box>
            </Box>
          </SafeAreaView>
          </KeyboardAvoidingView>
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
    <SafeAreaView style={{ flex: 1, backgroundColor: '#000000' }} edges={[]}>
      <StatusBar barStyle="light-content" />
      <Box flex={1} bg="#000000">
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

      {/* AI Chat Modal */}
      <Modal
        visible={isChatModalVisible}
        animationType="slide"
        presentationStyle="fullScreen"
        onRequestClose={closeChat}
      >
        <StatusBar barStyle="light-content" />
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={{ flex: 1, backgroundColor: '#1A1A1A' }}
          keyboardVerticalOffset={0}
        >
          <Box flex={1} bg="#1A1A1A">
            {/* Header */}
            <HStack 
              justifyContent="space-between" 
              alignItems="center" 
              px={20} 
              py={16}
              pt={Platform.OS === 'ios' ? 60 : 16}
              borderBottomWidth={1}
              borderBottomColor="rgba(255,255,255,0.1)"
            >
                  <HStack alignItems="center" gap={10}>
                    <Ionicons name="sparkles" size={24} color="#5DADE2" />
                    <Text fontSize={18} fontWeight="600" color="#FFFFFF">
                      AI Assistant
                    </Text>
                  </HStack>
                  <TouchableOpacity onPress={closeChat}>
                    <Box
                      w={32}
                      h={32}
                      borderRadius={16}
                      bg="rgba(255,255,255,0.1)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="close" size={20} color="#FFFFFF" />
                    </Box>
                  </TouchableOpacity>
                </HStack>

                {/* Chat History */}
                <ScrollView
                style={{ flex: 1 }}
                contentContainerStyle={{ padding: 20 }}
              >
                {chatHistory.length === 0 ? (
                  <VStack gap={20} alignItems="center" mt={60}>
                    <Box
                      w={80}
                      h={80}
                      borderRadius={40}
                      bg="rgba(93,173,226,0.15)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="sparkles" size={40} color="#5DADE2" />
                    </Box>
                    <VStack gap={8} alignItems="center">
                      <Text fontSize={20} fontWeight="600" color="#FFFFFF">
                        Start a Conversation
                      </Text>
                      <Text fontSize={14} color="rgba(255,255,255,0.5)" textAlign="center" px={40}>
                        Ask me anything about your memories, photos, or get creative ideas!
                      </Text>
                    </VStack>
                  </VStack>
                ) : (
                  <VStack gap={16}>
                    {chatHistory.map((chat, index) => (
                      <Box
                        key={index}
                        alignSelf={chat.role === 'user' ? 'flex-end' : 'flex-start'}
                        maxWidth="80%"
                      >
                        <Box
                          bg={chat.role === 'user' ? '#5DADE2' : 'rgba(255,255,255,0.1)'}
                          borderRadius={16}
                          px={16}
                          py={12}
                        >
                          <Text fontSize={14} color="#FFFFFF">
                            {chat.message}
                          </Text>
                        </Box>
                      </Box>
                    ))}
                  </VStack>
                )}
              </ScrollView>

              {/* Input Area */}
              <Box
                px={20}
                py={16}
                borderTopWidth={1}
                borderTopColor="rgba(255,255,255,0.1)"
              >
                <HStack gap={12} alignItems="flex-end">
                  <Box flex={1}>
                    <TextInput
                      value={chatMessage}
                      onChangeText={setChatMessage}
                      placeholder="Type your message..."
                      placeholderTextColor="rgba(255,255,255,0.4)"
                      multiline
                      style={{
                        backgroundColor: 'rgba(255,255,255,0.1)',
                        borderRadius: 20,
                        paddingHorizontal: 16,
                        paddingVertical: 12,
                        fontSize: 15,
                        color: '#FFFFFF',
                        maxHeight: 100,
                      }}
                    />
                  </Box>
                  <TouchableOpacity 
                    onPress={sendMessage}
                    disabled={!chatMessage.trim()}
                  >
                    <Box
                      w={44}
                      h={44}
                      borderRadius={22}
                      bg={chatMessage.trim() ? '#5DADE2' : 'rgba(255,255,255,0.1)'}
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons 
                        name="send" 
                        size={20} 
                        color={chatMessage.trim() ? '#FFFFFF' : 'rgba(255,255,255,0.3)'}
                      />
                    </Box>
                  </TouchableOpacity>
                </HStack>
              </Box>
            </Box>
        </KeyboardAvoidingView>
      </Modal>
    </SafeAreaView>
  );
}
