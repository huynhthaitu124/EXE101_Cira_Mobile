import React, { useState } from 'react';
import {
  View,
  ScrollView,
  TouchableOpacity,
  Image,
  StatusBar,
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
import AIBubble from '../components/AIBubble';

// Mock data for message conversations
const mockConversations = [
  {
    id: '1',
    name: 'Mom',
    avatar: 'https://i.pravatar.cc/150?img=1',
    lastMessage: 'Cảm ơn con đã chia sẻ những bức ảnh đẹp! ❤️',
    timestamp: '2 phút trước',
    unread: 2,
    online: true,
  },
  {
    id: '2',
    name: 'Dad',
    avatar: 'https://i.pravatar.cc/150?img=2',
    lastMessage: 'Bức ảnh hôm nay đẹp quá!',
    timestamp: '15 phút trước',
    unread: 0,
    online: true,
  },
  {
    id: '3',
    name: 'Sister Emily',
    avatar: 'https://i.pravatar.cc/150?img=3',
    lastMessage: 'Mình thích tấm ảnh sunset lắm 🌅',
    timestamp: '1 giờ trước',
    unread: 1,
    online: false,
  },
  {
    id: '4',
    name: 'Brother John',
    avatar: 'https://i.pravatar.cc/150?img=4',
    lastMessage: 'Haha cái ảnh này vui quá 😂',
    timestamp: '3 giờ trước',
    unread: 0,
    online: false,
  },
  {
    id: '5',
    name: 'Grandma',
    avatar: 'https://i.pravatar.cc/150?img=5',
    lastMessage: 'Con yêu ơi, bà nhớ con lắm',
    timestamp: 'Hôm qua',
    unread: 0,
    online: false,
  },
  {
    id: '6',
    name: 'Uncle Mike',
    avatar: 'https://i.pravatar.cc/150?img=6',
    lastMessage: 'Cuối tuần này đi chơi nhé!',
    timestamp: 'Hôm qua',
    unread: 0,
    online: true,
  },
  {
    id: '7',
    name: 'Aunt Sarah',
    avatar: 'https://i.pravatar.cc/150?img=7',
    lastMessage: 'Ảnh gia đình đẹp quá ❤️',
    timestamp: '2 ngày trước',
    unread: 0,
    online: false,
  },
];

interface MessagesScreenProps {
  navigation: any;
}

const MessagesScreen: React.FC<MessagesScreenProps> = ({ navigation }) => {
  const [conversations] = useState(mockConversations);

  const handleConversationPress = (conversation: any) => {
    // TODO: Navigate to chat screen with specific conversation
    console.log('Open conversation with:', conversation.name);
  };

  const handleCallPress = (conversation: any) => {
    Alert.alert(
      'Gọi điện',
      `Bạn có muốn gọi cho ${conversation.name} không?`,
      [
        {
          text: 'Hủy',
          style: 'cancel',
        },
        {
          text: 'Gọi ngay',
          onPress: () => {
            // TODO: Implement actual call functionality
            console.log('Calling:', conversation.name);
            Alert.alert('Đang gọi...', `Gọi cho ${conversation.name}`);
          },
        },
      ],
      { cancelable: true }
    );
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={['top']}>
      <StatusBar barStyle="dark-content" />
      
      <Box flex={1} bg="#FFFFFF">
        {/* Header */}
        <Box px={20} pt={16} pb={12} borderBottomWidth={1} borderBottomColor="rgba(0,0,0,0.1)">
          <HStack justifyContent="space-between" alignItems="center">
            <HStack alignItems="center" gap={16}>
              <TouchableOpacity onPress={() => navigation.goBack()}>
                <Ionicons name="arrow-back" size={24} color="#000000" />
              </TouchableOpacity>
              <Text fontSize={24} fontWeight="700" color="#000000">
                Messages
              </Text>
            </HStack>
            
            <TouchableOpacity>
              <Ionicons name="create-outline" size={24} color="#4CAF50" />
            </TouchableOpacity>
          </HStack>
        </Box>

        {/* Search Bar */}
        <Box px={20} py={12}>
          <HStack
            bg="rgba(0,0,0,0.05)"
            borderRadius={12}
            px={12}
            py={10}
            alignItems="center"
            gap={8}
          >
            <Ionicons name="search" size={18} color="rgba(0,0,0,0.4)" />
            <Text fontSize={15} color="rgba(0,0,0,0.4)">
              Tìm kiếm tin nhắn...
            </Text>
          </HStack>
        </Box>

        {/* Conversations List */}
        <ScrollView style={{ flex: 1 }} showsVerticalScrollIndicator={false}>
          <VStack>
            {conversations.map((conversation) => (
              <TouchableOpacity
                key={conversation.id}
                onPress={() => handleConversationPress(conversation)}
                activeOpacity={0.7}
              >
                <Box
                  px={20}
                  py={14}
                  borderBottomWidth={1}
                  borderBottomColor="rgba(0,0,0,0.05)"
                  bg={conversation.unread > 0 ? 'rgba(93,173,226,0.05)' : 'transparent'}
                >
                  <HStack gap={12} alignItems="center">
                    {/* Avatar with online indicator */}
                    <Box position="relative">
                      <Image
                        source={{ uri: conversation.avatar }}
                        style={{
                          width: 56,
                          height: 56,
                          borderRadius: 28,
                          backgroundColor: 'rgba(255,255,255,0.1)',
                        }}
                      />
                      {conversation.online && (
                        <Box
                          position="absolute"
                          bottom={2}
                          right={2}
                          w={14}
                          h={14}
                          borderRadius={7}
                          bg="#4ADE80"
                          borderWidth={2}
                          borderColor="#FFFFFF"
                        />
                      )}
                    </Box>

                    {/* Message Info */}
                    <VStack flex={1} gap={4}>
                      <HStack justifyContent="space-between" alignItems="center">
                        <VStack flex={1} gap={4}>
                          <HStack justifyContent="space-between" alignItems="center">
                            <Text
                              fontSize={16}
                              fontWeight={conversation.unread > 0 ? '700' : '600'}
                              color="#000000"
                            >
                              {conversation.name}
                            </Text>
                            <Text
                              fontSize={12}
                              color={conversation.unread > 0 ? '#5DADE2' : 'rgba(0,0,0,0.5)'}
                              fontWeight={conversation.unread > 0 ? '600' : '400'}
                            >
                              {conversation.timestamp}
                            </Text>
                          </HStack>

                          <HStack justifyContent="space-between" alignItems="center" gap={8}>
                            <Text
                              fontSize={14}
                              color={conversation.unread > 0 ? '#000000' : 'rgba(0,0,0,0.6)'}
                              fontWeight={conversation.unread > 0 ? '500' : '400'}
                              numberOfLines={1}
                              flex={1}
                            >
                              {conversation.lastMessage}
                            </Text>
                            {conversation.unread > 0 && (
                              <Box
                                minWidth={20}
                                height={20}
                                borderRadius={10}
                                bg="#5DADE2"
                                alignItems="center"
                                justifyContent="center"
                                px={6}
                              >
                                <Text fontSize={11} fontWeight="700" color="#000000">
                                  {conversation.unread}
                                </Text>
                              </Box>
                            )}
                          </HStack>
                        </VStack>

                        {/* Call Button - Positioned at the end */}
                        <TouchableOpacity
                          onPress={(e) => {
                            e.stopPropagation();
                            handleCallPress(conversation);
                          }}
                          activeOpacity={0.7}
                        >
                          <Box
                            w={36}
                            h={36}
                            borderRadius={18}
                            bg="rgba(93,173,226,0.15)"
                            justifyContent="center"
                            alignItems="center"
                            ml={12}
                          >
                            <Ionicons name="call" size={18} color="#5DADE2" />
                          </Box>
                        </TouchableOpacity>
                      </HStack>
                    </VStack>
                  </HStack>
                </Box>
              </TouchableOpacity>
            ))}
          </VStack>

          {/* Empty space at bottom */}
          <Box height={20} />
        </ScrollView>

        {/* AI Bubble */}
        <AIBubble />
      </Box>
    </SafeAreaView>
  );
};

export default MessagesScreen;
