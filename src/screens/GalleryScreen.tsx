import React, { useState, useEffect } from 'react';
import { 
  ScrollView, 
  Dimensions, 
  TouchableOpacity, 
  Image,
  ActivityIndicator,
  FlatList,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  Box,
  VStack,
  HStack,
  Text,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';
import * as MediaLibrary from 'expo-media-library';

const { width } = Dimensions.get('window');
const imageSize = (width - 8) / 3; // 3 columns with gaps

interface Photo {
  id: string;
  uri: string;
  creationTime: number;
  filename: string;
}

interface Collection {
  id: string;
  title: string;
  photos: Photo[];
  aiDescription?: string;
}

export default function GalleryScreen({ navigation }: any) {
  const [photos, setPhotos] = useState<Photo[]>([]);
  const [collections, setCollections] = useState<Collection[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState<'grid' | 'collections'>('grid');
  const [isOrganizing, setIsOrganizing] = useState(false);
  const [mediaLibraryPermission, requestMediaLibraryPermission] = MediaLibrary.usePermissions();

  useEffect(() => {
    loadPhotos();
  }, []);

  const loadPhotos = async () => {
    try {
      if (!mediaLibraryPermission?.granted) {
        const { status } = await requestMediaLibraryPermission();
        if (status !== 'granted') {
          setLoading(false);
          return;
        }
      }

      const { assets } = await MediaLibrary.getAssetsAsync({
        mediaType: 'photo',
        sortBy: ['creationTime'],
        first: 100,
      });

      // Convert ph:// URIs to file:// URIs
      const formattedPhotos: Photo[] = await Promise.all(
        assets.map(async (asset) => {
          try {
            // Always get asset info to get the actual file URI
            const assetInfo = await MediaLibrary.getAssetInfoAsync(asset.id);
            // Prefer localUri over uri - localUri is always file://
            const uri = assetInfo.localUri || assetInfo.uri;
            
            // Skip if still ph:// protocol
            if (uri.startsWith('ph://')) {
              return null;
            }
            
            return {
              id: asset.id,
              uri: uri,
              creationTime: asset.creationTime,
              filename: asset.filename,
            };
          } catch (error) {
            console.error('Error getting asset info:', error);
            return null;
          }
        })
      );

      // Filter out null values
      const validPhotos = formattedPhotos.filter((p): p is Photo => p !== null);
      setPhotos(validPhotos);
      setLoading(false);
    } catch (error) {
      console.error('Error loading photos:', error);
      setLoading(false);
    }
  };

  const organizeWithAI = async () => {
    setIsOrganizing(true);
    
    // Simulate AI organization - In production, call your AI API
    setTimeout(() => {
      // Ensure all photos have proper URIs
      const validPhotos = photos.filter(p => p.uri && !p.uri.startsWith('ph://'));
      
      const mockCollections: Collection[] = [
        {
          id: '1',
          title: 'Family Moments',
          photos: validPhotos.slice(0, Math.min(5, validPhotos.length)),
          aiDescription: 'Beautiful family gatherings and celebrations',
        },
        {
          id: '2',
          title: 'Nature & Outdoors',
          photos: validPhotos.slice(5, Math.min(10, validPhotos.length)),
          aiDescription: 'Scenic landscapes and outdoor adventures',
        },
        {
          id: '3',
          title: 'Daily Life',
          photos: validPhotos.slice(10, Math.min(15, validPhotos.length)),
          aiDescription: 'Everyday moments that matter',
        },
      ].filter(collection => collection.photos.length > 0);

      setCollections(mockCollections);
      setViewMode('collections');
      setIsOrganizing(false);
    }, 2000);
  };

  const generateStorytellingAudio = (collection: Collection) => {
    // TODO: Call AI API to generate voice storytelling
    console.log('Generating storytelling for:', collection.title);
    // This will integrate with AI voice API to create narration based on photos
  };

  const renderPhotoGrid = () => (
    <FlatList
      data={photos}
      numColumns={3}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <TouchableOpacity>
          <Box m={1}>
            <Image
              source={{ uri: item.uri }}
              style={{ width: imageSize, height: imageSize }}
              resizeMode="cover"
            />
          </Box>
        </TouchableOpacity>
      )}
      contentContainerStyle={{ paddingBottom: 100 }}
    />
  );

  const renderCollections = () => (
    <ScrollView showsVerticalScrollIndicator={false}>
      <VStack gap={20} pb={100}>
        {collections.map((collection) => (
          <Box key={collection.id} px={16}>
            {/* Collection Header */}
            <HStack justifyContent="space-between" alignItems="center" mb={12}>
              <VStack gap={4}>
                <Text fontSize={18} fontWeight="600" color="#2C3E50">
                  {collection.title}
                </Text>
                <Text fontSize={12} color="#95A5A6">
                  {collection.photos.length} photos
                </Text>
              </VStack>
              <TouchableOpacity onPress={() => generateStorytellingAudio(collection)}>
                <Box
                  bg="#5DADE2"
                  px={16}
                  py={8}
                  borderRadius={20}
                >
                  <HStack gap={6} alignItems="center">
                    <Ionicons name="volume-high" size={16} color="#FFFFFF" />
                    <Text fontSize={12} fontWeight="600" color="#FFFFFF">
                      Story
                    </Text>
                  </HStack>
                </Box>
              </TouchableOpacity>
            </HStack>

            {/* AI Description */}
            {collection.aiDescription && (
              <Box bg="#F8F9FA" px={12} py={8} borderRadius={12} mb={12}>
                <HStack gap={8} alignItems="flex-start">
                  <Ionicons name="sparkles" size={14} color="#5DADE2" style={{ marginTop: 2 }} />
                  <Text fontSize={13} color="#7F8C8D" flex={1}>
                    {collection.aiDescription}
                  </Text>
                </HStack>
              </Box>
            )}

            {/* Photo Scroll */}
            <ScrollView horizontal showsHorizontalScrollIndicator={false}>
              <HStack gap={8}>
                {collection.photos.map((photo) => (
                  <TouchableOpacity key={photo.id}>
                    <Image
                      source={{ uri: photo.uri }}
                      style={{ width: 150, height: 150, borderRadius: 12 }}
                      resizeMode="cover"
                    />
                  </TouchableOpacity>
                ))}
              </HStack>
            </ScrollView>
          </Box>
        ))}
      </VStack>
    </ScrollView>
  );

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={['top']}>
      <Box flex={1} bg="#FFFFFF">
        {/* Header */}
        <Box px={16} py={12} borderBottomWidth={1} borderBottomColor="#F0F0F0">
          <HStack justifyContent="space-between" alignItems="center" mb={12}>
            <TouchableOpacity onPress={() => navigation.goBack()}>
              <Ionicons name="arrow-back" size={24} color="#2C3E50" />
            </TouchableOpacity>
            <Text fontSize={18} fontWeight="600" color="#2C3E50">
              My Photos
            </Text>
            <Box w={24} />
          </HStack>

          {/* View Toggle & AI Organize Button */}
          <HStack gap={12}>
            <HStack flex={1} bg="#F5F5F5" borderRadius={12} p={2}>
              <TouchableOpacity 
                onPress={() => setViewMode('grid')}
                style={{ flex: 1 }}
              >
                <Box
                  bg={viewMode === 'grid' ? '#FFFFFF' : 'transparent'}
                  py={8}
                  borderRadius={10}
                  alignItems="center"
                >
                  <Ionicons 
                    name="grid-outline" 
                    size={18} 
                    color={viewMode === 'grid' ? '#5DADE2' : '#95A5A6'} 
                  />
                </Box>
              </TouchableOpacity>
              <TouchableOpacity 
                onPress={() => setViewMode('collections')}
                style={{ flex: 1 }}
              >
                <Box
                  bg={viewMode === 'collections' ? '#FFFFFF' : 'transparent'}
                  py={8}
                  borderRadius={10}
                  alignItems="center"
                >
                  <Ionicons 
                    name="albums-outline" 
                    size={18} 
                    color={viewMode === 'collections' ? '#5DADE2' : '#95A5A6'} 
                  />
                </Box>
              </TouchableOpacity>
            </HStack>

            {/* AI Organize Button */}
            <TouchableOpacity onPress={organizeWithAI} disabled={isOrganizing}>
              <Box
                bg="#5DADE2"
                px={16}
                py={10}
                borderRadius={12}
                opacity={isOrganizing ? 0.6 : 1}
              >
                <HStack gap={8} alignItems="center">
                  {isOrganizing ? (
                    <ActivityIndicator size="small" color="#FFFFFF" />
                  ) : (
                    <Ionicons name="sparkles" size={16} color="#FFFFFF" />
                  )}
                  <Text fontSize={13} fontWeight="600" color="#FFFFFF">
                    AI Organize
                  </Text>
                </HStack>
              </Box>
            </TouchableOpacity>
          </HStack>
        </Box>

        {/* Content */}
        {loading ? (
          <Box flex={1} justifyContent="center" alignItems="center">
            <ActivityIndicator size="large" color="#5DADE2" />
            <Text mt={12} color="#95A5A6">Loading photos...</Text>
          </Box>
        ) : photos.length === 0 ? (
          <Box flex={1} justifyContent="center" alignItems="center" px={40}>
            <Ionicons name="images-outline" size={64} color="#D5D8DC" />
            <Text mt={16} fontSize={16} fontWeight="600" color="#2C3E50" textAlign="center">
              No Photos Yet
            </Text>
            <Text mt={8} fontSize={13} color="#95A5A6" textAlign="center">
              Capture moments to see them here
            </Text>
          </Box>
        ) : viewMode === 'grid' ? (
          renderPhotoGrid()
        ) : (
          collections.length > 0 ? renderCollections() : (
            <Box flex={1} justifyContent="center" alignItems="center" px={40}>
              <Ionicons name="albums-outline" size={64} color="#D5D8DC" />
              <Text mt={16} fontSize={16} fontWeight="600" color="#2C3E50" textAlign="center">
                No Collections Yet
              </Text>
              <Text mt={8} fontSize={13} color="#95A5A6" textAlign="center">
                Use AI Organize to create collections
              </Text>
            </Box>
          )
        )}
      </Box>
    </SafeAreaView>
  );
}
