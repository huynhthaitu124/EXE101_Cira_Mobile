import React from 'react';
import { ScrollView } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
  Avatar,
  AvatarFallbackText,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';

export default function NotificationsScreen() {
  // Mock notifications data
  const notifications = [
    {
      id: 1,
      user: 'Grandma',
      action: 'loved your photo',
      time: '5m ago',
      type: 'like',
      hasPhoto: true,
    },
    {
      id: 2,
      user: 'Mom',
      action: 'commented: "Beautiful memory!"',
      time: '1h ago',
      type: 'comment',
      hasPhoto: true,
    },
    {
      id: 3,
      user: 'Dad',
      action: 'shared a new photo',
      time: '2h ago',
      type: 'photo',
      hasPhoto: true,
    },
    {
      id: 4,
      user: 'Sister',
      action: 'added a voice note',
      time: '3h ago',
      type: 'voice',
      hasPhoto: false,
    },
    {
      id: 5,
      user: 'Uncle John',
      action: 'loved your photo',
      time: '5h ago',
      type: 'like',
      hasPhoto: true,
    },
    {
      id: 6,
      user: 'Aunt Sarah',
      action: 'commented: "Miss you all!"',
      time: 'Yesterday',
      type: 'comment',
      hasPhoto: true,
    },
  ];

  const getIcon = (type: string) => {
    switch (type) {
      case 'like':
        return <Ionicons name="heart" size={24} color="#E74C3C" />;
      case 'comment':
        return <Ionicons name="chatbubble" size={22} color="#5DADE2" />;
      case 'photo':
        return <Ionicons name="image" size={22} color="#5DADE2" />;
      case 'voice':
        return <Ionicons name="mic" size={22} color="#5DADE2" />;
      default:
        return null;
    }
  };

  return (
    <Box flex={1} bg="#FAFAFA">
      {/* Header */}
      <Box bg="#FFFFFF" px="$6" pt="$12" pb="$4" borderBottomWidth={1} borderBottomColor="#F0F0F0">
        <Text fontSize="$2xl" fontWeight="$bold" color="#2C3E50">
          Notifications
        </Text>
      </Box>

      <ScrollView showsVerticalScrollIndicator={false}>
        <VStack>
          {notifications.map((notification) => (
            <Box
              key={notification.id}
              px="$4"
              py="$4"
              bg="#FFFFFF"
              borderBottomWidth={1}
              borderBottomColor="#F5F5F5"
            >
              <HStack space="md" alignItems="center">
                {/* Avatar with icon badge */}
                <Box position="relative">
                  <Avatar size="lg" bg="#E8F4F8" borderWidth={2} borderColor="#5DADE2">
                    <AvatarFallbackText color="#5DADE2">
                      {notification.user}
                    </AvatarFallbackText>
                  </Avatar>
                  
                  {/* Action Icon Badge */}
                  <Box
                    position="absolute"
                    bottom={-2}
                    right={-2}
                    bg="#FFFFFF"
                    borderRadius="$full"
                    p="$1"
                    borderWidth={2}
                    borderColor="#FFFFFF"
                  >
                    {getIcon(notification.type)}
                  </Box>
                </Box>

                {/* Notification Content */}
                <VStack flex={1} space="xs">
                  <Text fontSize="$md" color="#2C3E50">
                    <Text fontWeight="$semibold">{notification.user}</Text>
                    {' '}
                    <Text>{notification.action}</Text>
                  </Text>
                  <Text fontSize="$sm" color="#95A5A6">
                    {notification.time}
                  </Text>
                </VStack>

                {/* Thumbnail if has photo */}
                {notification.hasPhoto && (
                  <Box
                    w={50}
                    h={50}
                    borderRadius="$md"
                    bg="#F0F0F0"
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Ionicons name="image-outline" size={24} color="#D5D8DC" />
                  </Box>
                )}
              </HStack>
            </Box>
          ))}
        </VStack>
      </ScrollView>
    </Box>
  );
}
