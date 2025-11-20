import React from 'react';
import { ScrollView, TouchableOpacity } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';
import AIBubble from '../components/AIBubble';

export default function NotificationsScreen({ navigation }: any) {
  // Mock memories data - "On This Day" / Birthdays / Anniversary
  const memories = [
    {
      id: 'm1',
      type: 'on-this-day',
      title: 'On This Day',
      subtitle: '3 years ago - Nov 5, 2022',
      description: 'Family trip to Da Lat',
      photoCount: 8,
      icon: 'time-outline',
      color: '#9B59B6',
      hasPhoto: true,
    },
    {
      id: 'm2',
      type: 'birthday',
      title: 'Birthday',
      subtitle: 'Today - November 5',
      description: 'Happy Birthday Grandma! 🎂',
      photoCount: 0,
      icon: 'gift-outline',
      color: '#E74C3C',
      hasPhoto: false,
    },
    {
      id: 'm3',
      type: 'anniversary',
      title: 'Anniversary',
      subtitle: '10 years wedding anniversary - Nov 8',
      description: 'Mom & Dad\'s wedding day',
      photoCount: 15,
      icon: 'heart-outline',
      color: '#E91E63',
      hasPhoto: true,
    },
    {
      id: 'm4',
      type: 'untold-story',
      title: 'Untold Stories',
      subtitle: '12 photos without captions',
      description: 'Add stories to these beautiful moments',
      photoCount: 12,
      icon: 'albums-outline',
      color: '#5DADE2',
      hasPhoto: true,
    },
    {
      id: 'm5',
      type: 'weekly-reminder',
      title: 'Weekly Reminder',
      subtitle: '7 days since last photo',
      description: 'Share a new moment with your family!',
      photoCount: 0,
      icon: 'notifications-outline',
      color: '#F39C12',
      hasPhoto: false,
    },
  ];

  return (
    <Box flex={1} bg="#FFFFFF">
      {/* Header */}
      <Box bg="#FFFFFF" px={20} pt={50} pb={16} borderBottomWidth={1} borderBottomColor="rgba(0,0,0,0.1)">
        <HStack justifyContent="space-between" alignItems="center">
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Box
              w={36}
              h={36}
              borderRadius={18}
              bg="rgba(0,0,0,0.05)"
              justifyContent="center"
              alignItems="center"
            >
              <Ionicons name="arrow-back" size={20} color="#000000" />
            </Box>
          </TouchableOpacity>
          <Text fontSize={18} fontWeight="700" color="#000000">
            Memories & Reminders
          </Text>
          <Box w={36} h={36} />
        </HStack>
      </Box>

      <ScrollView showsVerticalScrollIndicator={false}>
        <VStack space="md" p={16}>
          {memories.map((memory) => (
            <TouchableOpacity key={memory.id}>
              <Box
                bg="#FFFFFF"
                borderRadius={16}
                overflow="hidden"
                borderWidth={1}
                borderColor="rgba(0,0,0,0.08)"
              >
                <HStack p={16} space="md" alignItems="center">
                  {/* Icon */}
                  <Box
                    w={48}
                    h={48}
                    borderRadius={24}
                    bg={`${memory.color}15`}
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Ionicons name={memory.icon as any} size={24} color={memory.color} />
                  </Box>

                  {/* Content */}
                  <VStack flex={1} space="xs">
                    <Text fontSize={15} fontWeight="600" color="#000000">
                      {memory.title}
                    </Text>
                    <Text fontSize={13} color="rgba(0,0,0,0.6)">
                      {memory.subtitle}
                    </Text>
                    <Text fontSize={13} color="rgba(0,0,0,0.5)">
                      {memory.description}
                    </Text>
                    {memory.photoCount > 0 && (
                      <HStack space="xs" alignItems="center" mt={4}>
                        <Ionicons name="images" size={14} color="#5DADE2" />
                        <Text fontSize={12} fontWeight="600" color="#5DADE2">
                          {memory.photoCount} {memory.photoCount === 1 ? 'photo' : 'photos'}
                        </Text>
                      </HStack>
                    )}
                  </VStack>

                  {/* Thumbnail or arrow */}
                  {memory.hasPhoto ? (
                    <Box
                      w={60}
                      h={60}
                      borderRadius="$xl"
                      bg="rgba(0,0,0,0.05)"
                      justifyContent="center"
                      alignItems="center"
                    >
                      <Ionicons name="image-outline" size={28} color="rgba(0,0,0,0.3)" />
                    </Box>
                  ) : (
                    <Ionicons name="chevron-forward" size={20} color="rgba(0,0,0,0.3)" />
                  )}
                </HStack>
              </Box>
            </TouchableOpacity>
          ))}
        </VStack>
      </ScrollView>

      {/* AI Bubble */}
      <AIBubble />
    </Box>
  );
}
