import React from 'react';
import { Dimensions } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
  Pressable,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';
import AIBubble from '../components/AIBubble';

const { width, height } = Dimensions.get('window');

export default function UploadScreen() {
  return (
    <Box flex={1} bg="#2C3E50">
      {/* Header */}
      <Box 
        position="absolute" 
        top={0} 
        left={0} 
        right={0} 
        zIndex={10}
        px="$4" 
        pt="$12" 
        pb="$4"
      >
        <HStack justifyContent="space-between" alignItems="center">
          <Pressable>
            <Ionicons name="close" size={30} color="#FFFFFF" />
          </Pressable>
          <Text color="#FFFFFF" fontSize="$lg" fontWeight="$medium">
            Share Memory
          </Text>
          <Pressable>
            <Ionicons name="flash-outline" size={28} color="#FFFFFF" />
          </Pressable>
        </HStack>
      </Box>

      {/* Camera Viewfinder Area */}
      <Box 
        flex={1} 
        justifyContent="center" 
        alignItems="center"
        bg="#1A252F"
      >
        <VStack space="lg" alignItems="center">
          <Box 
            w={width * 0.7} 
            h={width * 0.7} 
            borderRadius="$2xl"
            bg="#2C3E50"
            borderWidth={3}
            borderColor="#5DADE2"
            justifyContent="center"
            alignItems="center"
          >
            <Ionicons name="camera-outline" size={80} color="#5DADE2" />
          </Box>
          <Text color="#FFFFFF" fontSize="$sm" opacity={0.8}>
            Tap to capture a moment
          </Text>
        </VStack>
      </Box>

      {/* Bottom Controls */}
      <Box 
        position="absolute" 
        bottom={0} 
        left={0} 
        right={0}
        px="$6" 
        pb="$8"
      >
        <VStack space="xl">
          {/* Main Action Buttons */}
          <HStack justifyContent="space-around" alignItems="center">
            {/* Gallery */}
            <Pressable>
              <VStack space="xs" alignItems="center">
                <Box 
                  w={60} 
                  h={60} 
                  borderRadius="$lg"
                  bg="#F5F5F5"
                  justifyContent="center"
                  alignItems="center"
                >
                  <Ionicons name="images-outline" size={30} color="#2C3E50" />
                </Box>
                <Text color="#FFFFFF" fontSize="$xs">Gallery</Text>
              </VStack>
            </Pressable>

            {/* Camera Shutter */}
            <Pressable>
              <Box 
                w={80} 
                h={80} 
                borderRadius="$full"
                bg="#FFFFFF"
                borderWidth={4}
                borderColor="#5DADE2"
                justifyContent="center"
                alignItems="center"
              >
                <Box 
                  w={60} 
                  h={60} 
                  borderRadius="$full"
                  bg="#5DADE2"
                />
              </Box>
            </Pressable>

            {/* Flip Camera */}
            <Pressable>
              <VStack space="xs" alignItems="center">
                <Box 
                  w={60} 
                  h={60} 
                  borderRadius="$lg"
                  bg="#F5F5F5"
                  justifyContent="center"
                  alignItems="center"
                >
                  <Ionicons name="camera-reverse-outline" size={30} color="#2C3E50" />
                </Box>
                <Text color="#FFFFFF" fontSize="$xs">Flip</Text>
              </VStack>
            </Pressable>
          </HStack>

          {/* Quick Share Options */}
          <HStack justifyContent="center" space="md">
            <Pressable>
              <HStack 
                px="$4" 
                py="$2" 
                borderRadius="$full"
                bg="rgba(93, 173, 226, 0.2)"
                borderWidth={1}
                borderColor="#5DADE2"
                alignItems="center"
                space="xs"
              >
                <Ionicons name="mic-outline" size={18} color="#5DADE2" />
                <Text color="#5DADE2" fontSize="$sm">Add Voice</Text>
              </HStack>
            </Pressable>

            <Pressable>
              <HStack 
                px="$4" 
                py="$2" 
                borderRadius="$full"
                bg="rgba(93, 173, 226, 0.2)"
                borderWidth={1}
                borderColor="#5DADE2"
                alignItems="center"
                space="xs"
              >
                <Ionicons name="location-outline" size={18} color="#5DADE2" />
                <Text color="#5DADE2" fontSize="$sm">Add Location</Text>
              </HStack>
            </Pressable>
          </HStack>
        </VStack>
      </Box>

      {/* AI Bubble */}
      <AIBubble />
    </Box>
  );
}
