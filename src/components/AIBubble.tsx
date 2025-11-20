import React, { useRef, useState, useEffect } from 'react';
import {
  Animated,
  PanResponder,
  Pressable,
  Dimensions,
  Modal,
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
  ScrollView,
  TextInput,
  StatusBar,
  Vibration,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Box, HStack, VStack, Text } from '@gluestack-ui/themed';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Svg, { Circle } from 'react-native-svg';

const { width, height } = Dimensions.get('window');

// Create animated Circle component
const AnimatedCircle = Animated.createAnimatedComponent(Circle);

const BUBBLE_POSITION_KEY = '@bubble_position';

interface ChatMessage {
  role: 'user' | 'assistant';
  message: string;
}

interface BubblePosition {
  x: number;
  y: number;
}

export default function AIBubble() {
  // Position and drag state
  const [initialPosition, setInitialPosition] = useState<BubblePosition>({ 
    x: width - 90, 
    y: height - 250 
  });
  const pan = useRef(new Animated.ValueXY(initialPosition)).current;
  const currentPanPosition = useRef(initialPosition);
  const [isAIExpanded, setIsAIExpanded] = useState(false);
  const [isOnLeftSide, setIsOnLeftSide] = useState(false); // Track bubble side

  // Voice recording state
  const [isRecording, setIsRecording] = useState(false);
  const [isPressing, setIsPressing] = useState(false);
  const [recognizedText, setRecognizedText] = useState('');
  const holdTimerRef = useRef<NodeJS.Timeout | null>(null);
  const pressAnimation = useRef(new Animated.Value(0)).current;
  const isDragging = useRef(false); // Track if user is dragging
  const dragCooldownRef = useRef<NodeJS.Timeout | null>(null); // Cooldown after drag
  const pressStartTime = useRef<number>(0); // Track press start time
  const hasMovedSignificantly = useRef(false); // Track if moved during press
  const progressInterval = useRef<NodeJS.Timeout | null>(null); // For updating progress

  // Chat state
  const [chatMessage, setChatMessage] = useState('');
  const [chatHistory, setChatHistory] = useState<ChatMessage[]>([]);

  // Wave animations for recording indicator
  const waveAnimation1 = useRef(new Animated.Value(1)).current;
  const waveAnimation2 = useRef(new Animated.Value(1)).current;
  const waveAnimation3 = useRef(new Animated.Value(1)).current;
  const waveAnimation4 = useRef(new Animated.Value(1)).current;
  const waveAnimation5 = useRef(new Animated.Value(1)).current;

  // Load saved position on mount
  useEffect(() => {
    loadSavedPosition();
    
    // Cleanup timers on unmount
    return () => {
      if (holdTimerRef.current) {
        clearTimeout(holdTimerRef.current);
      }
      if (dragCooldownRef.current) {
        clearTimeout(dragCooldownRef.current);
      }
      if (progressInterval.current) {
        clearInterval(progressInterval.current);
      }
    };
  }, []);

  // Set initial side based on initialPosition
  useEffect(() => {
    setIsOnLeftSide(initialPosition.x < width / 2);
  }, [initialPosition]);

  const loadSavedPosition = async () => {
    try {
      const savedPosition = await AsyncStorage.getItem(BUBBLE_POSITION_KEY);
      if (savedPosition) {
        const position: BubblePosition = JSON.parse(savedPosition);
        setInitialPosition(position);
        pan.setValue(position);
        currentPanPosition.current = position;
        
        // Update side state based on loaded position
        setIsOnLeftSide(position.x < width / 2);
      }
    } catch (error) {
      console.error('Error loading bubble position:', error);
    }
  };

  const savePosition = async (position: BubblePosition) => {
    try {
      await AsyncStorage.setItem(BUBBLE_POSITION_KEY, JSON.stringify(position));
    } catch (error) {
      console.error('Error saving bubble position:', error);
    }
  };

  // Pan responder for dragging AND press handling
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => !isAIExpanded,
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        // Check if user is moving (dragging)
        const moveThreshold = 5;
        return Math.abs(gestureState.dx) > moveThreshold || Math.abs(gestureState.dy) > moveThreshold;
      },
      onPanResponderGrant: (evt, gestureState) => {
        // Record press start time
        pressStartTime.current = Date.now();
        hasMovedSignificantly.current = false;
        
        // Start showing press feedback
        setIsPressing(true);
        pressAnimation.setValue(0);
        Vibration.vibrate(20);
        
        // Start progress animation for visual feedback
        progressInterval.current = setInterval(() => {
          const elapsed = Date.now() - pressStartTime.current;
          const progress = Math.min(elapsed / 1500, 1);
          pressAnimation.setValue(progress);
          
          if (progress >= 1 || hasMovedSignificantly.current) {
            if (progressInterval.current) {
              clearInterval(progressInterval.current);
              progressInterval.current = null;
            }
          }
        }, 16); // ~60fps
        
        // Prepare for potential drag
        pan.setOffset({
          // @ts-ignore
          x: pan.x._value,
          // @ts-ignore
          y: pan.y._value,
        });
        pan.setValue({ x: 0, y: 0 });
      },
      onPanResponderMove: (evt, gestureState) => {
        const moveThreshold = 8; // pixels
        const hasMoved = Math.abs(gestureState.dx) > moveThreshold || Math.abs(gestureState.dy) > moveThreshold;
        
        if (hasMoved && !isDragging.current) {
          // User is dragging, not just pressing
          hasMovedSignificantly.current = true;
          isDragging.current = true;
          
          // Cancel press/hold actions
          if (holdTimerRef.current) {
            clearTimeout(holdTimerRef.current);
            holdTimerRef.current = null;
          }
          if (progressInterval.current) {
            clearInterval(progressInterval.current);
            progressInterval.current = null;
          }
          
          setIsPressing(false);
          pressAnimation.setValue(0);
          
          if (isRecording) {
            setIsRecording(false);
          }
        }
        
        // Update position when dragging
        if (isDragging.current) {
          pan.setValue({ x: gestureState.dx, y: gestureState.dy });
        }
      },
      onPanResponderRelease: (evt, gestureState) => {
        const pressDuration = Date.now() - pressStartTime.current;
        const moveDistance = Math.sqrt(gestureState.dx * gestureState.dx + gestureState.dy * gestureState.dy);
        const isTap = pressDuration < 300 && moveDistance < 10;
        const isLongPress = pressDuration >= 1500 && moveDistance < 10;
        
        // Clear timers
        if (holdTimerRef.current) {
          clearTimeout(holdTimerRef.current);
          holdTimerRef.current = null;
        }
        if (progressInterval.current) {
          clearInterval(progressInterval.current);
          progressInterval.current = null;
        }
        
        // Handle based on gesture type
        if (isDragging.current) {
          // This was a drag - snap to edge
          pan.flattenOffset();
          
          // @ts-ignore
          const currentX = pan.x._value;
          // @ts-ignore
          const currentY = pan.y._value;
          const screenCenter = width / 2;
          
          const snapToLeft = currentX < screenCenter;
          const targetX = snapToLeft ? 10 : width - 74;
          
          setIsOnLeftSide(snapToLeft);
          
          const minY = 80;
          const maxY = height - 200;
          const boundedY = Math.max(minY, Math.min(maxY, currentY));
          
          const newPosition = { x: targetX, y: boundedY };
          currentPanPosition.current = newPosition;
          
          savePosition(newPosition);
          
          Animated.spring(pan, {
            toValue: newPosition,
            useNativeDriver: false,
            tension: 100,
            friction: 10,
          }).start(() => {
            setTimeout(() => {
              isDragging.current = false;
              hasMovedSignificantly.current = false;
            }, 200);
          });
        } else if (isLongPress) {
          // Long press - start voice recording
          pan.flattenOffset();
          if (!isRecording) {
            startRecording();
          }
        } else if (isTap) {
          // Quick tap - open chat
          pan.flattenOffset();
          setIsPressing(false);
          pressAnimation.setValue(0);
          
          if (!isRecording) {
            expandChat();
          }
        } else {
          // Released too early or moved slightly
          pan.flattenOffset();
          setIsPressing(false);
          pressAnimation.setValue(0);
        }
      },
      onPanResponderTerminate: () => {
        pan.flattenOffset();
        isDragging.current = false;
        hasMovedSignificantly.current = false;
        setIsPressing(false);
        pressAnimation.setValue(0);
        
        if (holdTimerRef.current) {
          clearTimeout(holdTimerRef.current);
          holdTimerRef.current = null;
        }
        if (dragCooldownRef.current) {
          clearTimeout(dragCooldownRef.current);
          dragCooldownRef.current = null;
        }
        if (progressInterval.current) {
          clearInterval(progressInterval.current);
          progressInterval.current = null;
        }
      },
    })
  ).current;

  // Wave animation loop
  useEffect(() => {
    if (isRecording) {
      const createWaveAnimation = (animValue: Animated.Value, delay: number) => {
        return Animated.loop(
          Animated.sequence([
            Animated.delay(delay),
            Animated.timing(animValue, {
              toValue: 1.8,
              duration: 400,
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

      const animations = [
        createWaveAnimation(waveAnimation1, 0),
        createWaveAnimation(waveAnimation2, 100),
        createWaveAnimation(waveAnimation3, 200),
        createWaveAnimation(waveAnimation4, 300),
        createWaveAnimation(waveAnimation5, 400),
      ];

      animations.forEach(anim => anim.start());

      return () => {
        animations.forEach(anim => anim.stop());
      };
    }
  }, [isRecording]);

  // Handle press in for modal voice button
  const handleModalPressIn = () => {
    if (isRecording) return;
    
    setIsPressing(true);
    pressAnimation.setValue(0);
    Vibration.vibrate(20);
    
    Animated.timing(pressAnimation, {
      toValue: 1,
      duration: 1500,
      useNativeDriver: false,
    }).start();
    
    holdTimerRef.current = setTimeout(() => {
      startRecording();
    }, 1500);
  };

  // Handle press out for modal voice button
  const handleModalPressOut = () => {
    if (holdTimerRef.current) {
      clearTimeout(holdTimerRef.current);
      holdTimerRef.current = null;
    }
    
    if (!isRecording) {
      setIsPressing(false);
      pressAnimation.stopAnimation();
      pressAnimation.setValue(0);
    }
  };

  // Start voice recording
  const startRecording = () => {
    setIsPressing(false);
    setIsRecording(true);
    pressAnimation.setValue(0);

    // Vibrate on recording start (light 30ms)
    Vibration.vibrate(30);

    // Simulate recording for 3 seconds
    setTimeout(() => {
      stopRecording();
    }, 3000);
  };

  // Stop voice recording
  const stopRecording = () => {
    setIsRecording(false);
    
    // Vibrate on recording stop (very light 15ms)
    Vibration.vibrate(15);
    
    const demoText = 'This is a demo text from voice recognition';
    setRecognizedText(demoText);
    
    // Add to chat history
    if (isAIExpanded) {
      setChatHistory(prev => [...prev, 
        { role: 'user', message: demoText },
        { role: 'assistant', message: 'I heard: "' + demoText + '". How can I help you?' }
      ]);
    }
    
    // Clear text after 3 seconds
    setTimeout(() => {
      setRecognizedText('');
    }, 3000);
  };

  // Send text message
  const sendMessage = () => {
    if (chatMessage.trim()) {
      setChatHistory(prev => [...prev, 
        { role: 'user', message: chatMessage },
        { role: 'assistant', message: 'Thanks for your message: "' + chatMessage + '". This is a demo response.' }
      ]);
      setChatMessage('');
    }
  };

  // Expand chat modal
  const expandChat = () => {
    // Only expand if not in middle of other actions
    if (!isPressing && !isRecording && !isDragging.current) {
      setIsAIExpanded(true);
    }
  };

  // Close chat modal
  const closeChat = () => {
    setIsAIExpanded(false);
  };

  return (
    <>
      {/* Circular Progress - appears around bubble when pressing */}
      {isPressing && (
        <Animated.View
          style={{
            position: 'absolute',
            transform: [
              { translateX: pan.x }, 
              { translateY: pan.y }
            ],
            zIndex: 999,
          }}
        >
          <Box
            style={{
              width: 80,
              height: 80,
              marginLeft: -8,
              marginTop: -8,
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            <Svg width="80" height="80" style={{ position: 'absolute' }}>
              {/* Background circle */}
              <Circle
                cx="40"
                cy="40"
                r="38"
                stroke="rgba(93,173,226,0.3)"
                strokeWidth="3"
                fill="none"
              />
              {/* Progress circle */}
              <AnimatedCircle
                cx="40"
                cy="40"
                r="38"
                stroke="#5DADE2"
                strokeWidth="3"
                fill="none"
                strokeDasharray={238.76}
                strokeDashoffset={pressAnimation.interpolate({
                  inputRange: [0, 1],
                  outputRange: [238.76, 0],
                })}
                strokeLinecap="round"
                transform="rotate(-90 40 40)"
              />
            </Svg>
          </Box>
        </Animated.View>
      )}

      {/* Wave animation - appears around bubble when recording */}
      {isRecording && (
        <Animated.View
          style={{
            position: 'absolute',
            transform: [
              { translateX: pan.x }, 
              { translateY: pan.y }
            ],
            zIndex: 999,
          }}
        >
          <Box
            style={{
              width: 80,
              height: 80,
              marginLeft: -8,
              marginTop: -8,
              justifyContent: 'center',
              alignItems: 'center',
            }}
          >
            {/* Pulsing wave circles */}
            <Animated.View
              style={{
                position: 'absolute',
                width: 80,
                height: 80,
                borderRadius: 40,
                borderWidth: 2,
                borderColor: '#5DADE2',
                opacity: waveAnimation1.interpolate({
                  inputRange: [1, 1.8],
                  outputRange: [0.8, 0],
                }),
                transform: [
                  {
                    scale: waveAnimation1,
                  },
                ],
              }}
            />
            <Animated.View
              style={{
                position: 'absolute',
                width: 80,
                height: 80,
                borderRadius: 40,
                borderWidth: 2,
                borderColor: '#5DADE2',
                opacity: waveAnimation2.interpolate({
                  inputRange: [1, 1.8],
                  outputRange: [0.6, 0],
                }),
                transform: [
                  {
                    scale: waveAnimation2,
                  },
                ],
              }}
            />
          </Box>
        </Animated.View>
      )}

      {/* Draggable AI Bubble - always same size */}
      <Animated.View
        {...panResponder.panHandlers}
        style={{
          position: 'absolute',
          transform: [{ translateX: pan.x }, { translateY: pan.y }],
          zIndex: 1000,
        }}
      >
        <Box
          w={64}
          h={64}
          borderRadius={32}
          bg="#5DADE2"
          justifyContent="center"
          alignItems="center"
          shadowColor="#000"
          shadowOffset={{ width: 0, height: 4 }}
          shadowOpacity={0.3}
          shadowRadius={8}
        >
          <Ionicons name="sparkles" size={28} color="#FFFFFF" />
        </Box>
      </Animated.View>

      {/* Display recognized text after recording */}
      {!isRecording && recognizedText && (
        <Box
          position="absolute"
          bottom={100}
          left={20}
          right={20}
          bg="rgba(40,40,40,0.9)"
          borderRadius={16}
          px={16}
          py={12}
          borderWidth={1}
          borderColor="rgba(255,255,255,0.1)"
          zIndex={999}
        >
          <Text fontSize={14} color="#FFFFFF" lineHeight={20}>
            {recognizedText}
          </Text>
        </Box>
      )}

      {/* AI Chat Modal */}
      <Modal
        visible={isAIExpanded}
        animationType="slide"
        transparent={false}
        onRequestClose={closeChat}
      >
        <StatusBar barStyle="light-content" />
        <KeyboardAvoidingView
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          style={{ flex: 1 }}
        >
          <Box flex={1} bg="#1A1A1A">
            {/* Modal Header */}
            <HStack
              justifyContent="space-between"
              alignItems="center"
              px={20}
              py={16}
              pt={Platform.OS === 'ios' ? 60 : 16}
              borderBottomWidth={1}
              borderBottomColor="rgba(255,255,255,0.1)"
            >
              <HStack alignItems="center" space="md">
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
                <VStack space="lg" alignItems="center" mt={60}>
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
                  <VStack space="sm" alignItems="center">
                    <Text fontSize={20} fontWeight="600" color="#FFFFFF">
                      Start a Conversation
                    </Text>
                    <Text fontSize={14} color="rgba(255,255,255,0.5)" textAlign="center" px={40}>
                      Ask me anything about your memories, photos, or get creative ideas!
                    </Text>
                  </VStack>
                </VStack>
              ) : (
                <VStack space="md">
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
              <VStack space="md">
                {/* Voice Chat Button */}
                <Pressable onPressIn={handleModalPressIn} onPressOut={handleModalPressOut}>
                  <Box
                    bg={isRecording ? "rgba(93,173,226,0.3)" : "rgba(255,255,255,0.1)"}
                    borderRadius={24}
                    borderWidth={1}
                    borderColor={isRecording ? "#5DADE2" : "rgba(255,255,255,0.2)"}
                    py={12}
                    px={16}
                    position="relative"
                    overflow="hidden"
                  >
                    {/* Progress bar for hold */}
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
                      <VStack space="xs" alignItems="center">
                        <HStack space="xs" alignItems="center" h={24}>
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
                          Listening...
                        </Text>
                        {recognizedText ? (
                          <Text fontSize={13} color="#FFFFFF" textAlign="center" px={8}>
                            {recognizedText}
                          </Text>
                        ) : null}
                      </VStack>
                    ) : (
                      <HStack justifyContent="center" alignItems="center" space="sm" zIndex={1}>
                        <Ionicons name="mic" size={20} color="#FFFFFF" />
                        <Text fontSize={13} fontWeight="600" color="#FFFFFF">
                          {isPressing ? 'Keep holding...' : 'Hold 1.5s to voice chat'}
                        </Text>
                      </HStack>
                    )}
                  </Box>
                </Pressable>

                {/* Text Input */}
                <HStack space="md" alignItems="flex-end">
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
              </VStack>
            </Box>
          </Box>
        </KeyboardAvoidingView>
      </Modal>
    </>
  );
}
