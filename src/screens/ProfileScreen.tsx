import React from 'react';
import { ScrollView, Dimensions } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
  Avatar,
  AvatarFallbackText,
  Pressable,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');

export default function ProfileScreen() {
  // Mock photo grid
  const photos = Array.from({ length: 12 }, (_, i) => ({ id: i + 1 }));

  return (
    <Box flex={1} bg="#FAFAFA">
      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Profile Header */}
        <Box bg="#FFFFFF" px="$6" pt="$12" pb="$6">
          <HStack space="lg" alignItems="center">
            {/* Avatar */}
            <Avatar 
              size="2xl" 
              bg="#E8F4F8" 
              borderWidth={3} 
              borderColor="#5DADE2"
            >
              <AvatarFallbackText color="#5DADE2">
                You
              </AvatarFallbackText>
            </Avatar>

            {/* Stats */}
            <HStack flex={1} justifyContent="space-around">
              <VStack alignItems="center">
                <Text fontSize="$xl" fontWeight="$bold" color="#2C3E50">
                  42
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  Photos
                </Text>
              </VStack>
              <VStack alignItems="center">
                <Text fontSize="$xl" fontWeight="$bold" color="#2C3E50">
                  8
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  Family
                </Text>
              </VStack>
              <VStack alignItems="center">
                <Text fontSize="$xl" fontWeight="$bold" color="#2C3E50">
                  156
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  Memories
                </Text>
              </VStack>
            </HStack>
          </HStack>

          {/* User Info */}
          <VStack space="xs" mt="$4">
            <Text fontSize="$lg" fontWeight="$bold" color="#2C3E50">
              Your Name
            </Text>
            <Text fontSize="$md" color="#95A5A6">
              Family member since 2024
            </Text>
          </VStack>

          {/* Action Buttons */}
          <HStack space="sm" mt="$4">
            <Pressable flex={1}>
              <Box
                bg="#5DADE2"
                py="$3"
                borderRadius="$lg"
                alignItems="center"
              >
                <Text color="#FFFFFF" fontSize="$md" fontWeight="$medium">
                  Edit Profile
                </Text>
              </Box>
            </Pressable>
            <Pressable>
              <Box
                bg="#E8F4F8"
                px="$4"
                py="$3"
                borderRadius="$lg"
                justifyContent="center"
                alignItems="center"
              >
                <Ionicons name="settings-outline" size={24} color="#5DADE2" />
              </Box>
            </Pressable>
          </HStack>
        </Box>

        {/* Quick Actions - Elder Friendly Large Buttons */}
        <VStack space="sm" px="$4" py="$4">
          <Pressable>
            <HStack
              bg="#FFFFFF"
              px="$5"
              py="$5"
              borderRadius="$xl"
              alignItems="center"
              space="md"
            >
              <Box
                w={50}
                h={50}
                bg="#E8F4F8"
                borderRadius="$full"
                justifyContent="center"
                alignItems="center"
              >
                <Ionicons name="mic" size={26} color="#5DADE2" />
              </Box>
              <VStack flex={1}>
                <Text fontSize="$lg" fontWeight="$semibold" color="#2C3E50">
                  Record Voice Story
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  Share your memories with voice
                </Text>
              </VStack>
              <Ionicons name="chevron-forward" size={24} color="#95A5A6" />
            </HStack>
          </Pressable>

          <Pressable>
            <HStack
              bg="#FFFFFF"
              px="$5"
              py="$5"
              borderRadius="$xl"
              alignItems="center"
              space="md"
            >
              <Box
                w={50}
                h={50}
                bg="#E8F4F8"
                borderRadius="$full"
                justifyContent="center"
                alignItems="center"
              >
                <Ionicons name="albums" size={26} color="#5DADE2" />
              </Box>
              <VStack flex={1}>
                <Text fontSize="$lg" fontWeight="$semibold" color="#2C3E50">
                  My Albums
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  View organized photo collections
                </Text>
              </VStack>
              <Ionicons name="chevron-forward" size={24} color="#95A5A6" />
            </HStack>
          </Pressable>

          <Pressable>
            <HStack
              bg="#FFFFFF"
              px="$5"
              py="$5"
              borderRadius="$xl"
              alignItems="center"
              space="md"
            >
              <Box
                w={50}
                h={50}
                bg="#E8F4F8"
                borderRadius="$full"
                justifyContent="center"
                alignItems="center"
              >
                <Ionicons name="people" size={26} color="#5DADE2" />
              </Box>
              <VStack flex={1}>
                <Text fontSize="$lg" fontWeight="$semibold" color="#2C3E50">
                  Family Members
                </Text>
                <Text fontSize="$sm" color="#95A5A6">
                  Manage your family circle
                </Text>
              </VStack>
              <Ionicons name="chevron-forward" size={24} color="#95A5A6" />
            </HStack>
          </Pressable>
        </VStack>

        {/* Photo Grid */}
        <Box px="$4" py="$2">
          <Text fontSize="$lg" fontWeight="$semibold" color="#2C3E50" mb="$3">
            Your Photos
          </Text>
          <VStack space="xs">
            {Array.from({ length: Math.ceil(photos.length / 3) }).map((_, rowIdx) => (
              <HStack key={rowIdx} space="xs">
                {photos.slice(rowIdx * 3, rowIdx * 3 + 3).map((photo) => (
                  <Box
                    key={photo.id}
                    w={(width - 40) / 3}
                    h={(width - 40) / 3}
                    bg="#F0F0F0"
                    borderRadius="$md"
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Ionicons name="image-outline" size={32} color="#D5D8DC" />
                  </Box>
                ))}
              </HStack>
            ))}
          </VStack>
        </Box>
      </ScrollView>
    </Box>
  );
}
