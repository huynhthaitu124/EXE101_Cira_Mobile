import React, { useState } from 'react';
import { ScrollView, Dimensions } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
  Input,
  InputField,
  InputIcon,
  InputSlot,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';

const { width } = Dimensions.get('window');
const imageSize = (width - 4) / 3; // 3 columns with 1px gaps

export default function SearchScreen() {
  const [searchText, setSearchText] = useState('');

  // Mock recent searches
  const recentSearches = ['Family dinner', 'Grandma birthday', 'Park photos', 'Tết 2025'];

  // Mock photo grid
  const photos = Array.from({ length: 24 }, (_, i) => ({ id: i + 1 }));

  return (
    <Box flex={1} bg="#FAFAFA">
      {/* Header */}
      <Box px="$4" pt="$12" pb="$2" bg="#FFFFFF">
        <Text fontSize="$2xl" fontWeight="$bold" color="#2C3E50" mb="$3">
          Search
        </Text>
        <HStack
          bg="#F5F5F5"
          borderRadius="$lg"
          px="$3"
          py="$3"
          alignItems="center"
          space="sm"
        >
          <Ionicons name="search" size={20} color="#95A5A6" />
          <Input 
            flex={1}
            variant="outline" 
            size="md"
            bg="transparent"
            borderWidth={0}
          >
            <InputField 
              placeholder="Search photos, people, places..." 
              value={searchText}
              onChangeText={setSearchText}
              color="#2C3E50"
            />
          </Input>
        </HStack>
      </Box>

      <ScrollView showsVerticalScrollIndicator={false}>
        {/* Recent Searches */}
        {searchText === '' && (
          <VStack space="sm" px="$4" py="$4">
            <HStack justifyContent="space-between" alignItems="center" mb="$2">
              <Text fontWeight="$semibold" color="#2C3E50">Recent</Text>
              <Text size="sm" color="#5DADE2">Clear all</Text>
            </HStack>
            
            {recentSearches.map((search, idx) => (
              <HStack 
                key={idx} 
                py="$3" 
                alignItems="center" 
                justifyContent="space-between"
              >
                <HStack space="sm" alignItems="center">
                  <Ionicons name="time-outline" size={20} color="#95A5A6" />
                  <Text color="#2C3E50">{search}</Text>
                </HStack>
                <Ionicons name="close" size={20} color="#95A5A6" />
              </HStack>
            ))}
          </VStack>
        )}

        {/* Photo Grid */}
        <Box px={2} py="$2">
          <VStack gap={2}>
            {Array.from({ length: Math.ceil(photos.length / 3) }).map((_, rowIdx) => (
              <HStack key={rowIdx} gap={2}>
                {photos.slice(rowIdx * 3, rowIdx * 3 + 3).map((photo) => (
                  <Box 
                    key={photo.id}
                    w={imageSize} 
                    h={imageSize} 
                    bg="#F0F0F0"
                    alignItems="center"
                    justifyContent="center"
                  >
                    <Ionicons name="image-outline" size={40} color="#D5D8DC" />
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
