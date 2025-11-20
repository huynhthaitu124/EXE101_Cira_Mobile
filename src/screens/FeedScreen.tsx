import React, { useState } from 'react';
import {
  View,
  ScrollView,
  TouchableOpacity,
  Image,
  Dimensions,
  StatusBar,
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

const { width } = Dimensions.get('window');

// Mock data for family feed
const feedData = [
  {
    id: '1',
    user: {
      name: 'Mom',
      avatar: '👩',
    },
    image: 'https://picsum.photos/400/500?random=1',
    caption: 'Beautiful sunset at the beach today! 🌅',
    timestamp: '2 hours ago',
    likes: 12,
    isLiked: true,
    comments: [
      { id: '1', user: 'Dad', text: 'Gorgeous! Miss you ❤️', avatar: '👨' },
      { id: '2', user: 'Sister', text: 'So pretty! 😍', avatar: '👧' },
    ],
  },
  {
    id: '2',
    user: {
      name: 'Dad',
      avatar: '👨',
    },
    image: 'https://picsum.photos/400/500?random=2',
    caption: 'Made pancakes for breakfast! 🥞',
    timestamp: '5 hours ago',
    likes: 8,
    isLiked: false,
    comments: [
      { id: '1', user: 'Mom', text: 'Yummy! Save some for me 😋', avatar: '👩' },
    ],
  },
  {
    id: '3',
    user: {
      name: 'Sister',
      avatar: '👧',
    },
    image: 'https://picsum.photos/400/500?random=3',
    caption: 'First day at the new job! Wish me luck! 💼✨',
    timestamp: '1 day ago',
    likes: 15,
    isLiked: true,
    comments: [
      { id: '1', user: 'Mom', text: 'So proud of you! 🎉', avatar: '👩' },
      { id: '2', user: 'Dad', text: 'Good luck sweetheart! 👍', avatar: '👨' },
      { id: '3', user: 'Grandma', text: 'You got this! ❤️', avatar: '👵' },
    ],
  },
  {
    id: '4',
    user: {
      name: 'Grandma',
      avatar: '👵',
    },
    image: 'https://picsum.photos/400/500?random=4',
    caption: 'Garden is blooming! 🌸🌺',
    timestamp: '2 days ago',
    likes: 20,
    isLiked: true,
    comments: [
      { id: '1', user: 'Mom', text: 'Beautiful flowers! 🌹', avatar: '👩' },
      { id: '2', user: 'Sister', text: 'Can I come visit? 🥰', avatar: '👧' },
    ],
  },
];

export default function FeedScreen({ navigation }: any) {
  const [posts, setPosts] = useState(feedData);

  const toggleLike = (postId: string) => {
    setPosts(posts.map(post => {
      if (post.id === postId) {
        return {
          ...post,
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        };
      }
      return post;
    }));
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: '#FFFFFF' }} edges={['top']}>
      <StatusBar barStyle="dark-content" />
      <Box flex={1} bg="#FFFFFF">
        {/* Header */}
        <HStack
          justifyContent="space-between"
          alignItems="center"
          px={20}
          py={16}
          borderBottomWidth={1}
          borderBottomColor="rgba(0,0,0,0.1)"
        >
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
          <Text fontSize={18} fontWeight="600" color="#000000">
            Everyone
          </Text>
          <TouchableOpacity>
            <Box
              w={36}
              h={36}
              borderRadius={18}
              bg="rgba(0,0,0,0.05)"
              justifyContent="center"
              alignItems="center"
            >
              <Ionicons name="chatbubble-outline" size={20} color="#000000" />
            </Box>
          </TouchableOpacity>
        </HStack>

        {/* Feed */}
        <ScrollView
          showsVerticalScrollIndicator={false}
        >
          {posts.map((post) => (
            <Box key={post.id} mb={24}>
              {/* User Header */}
              <HStack
                px={20}
                py={12}
                alignItems="center"
                justifyContent="space-between"
              >
                <HStack alignItems="center" gap={12}>
                  <Box
                    w={40}
                    h={40}
                    borderRadius={20}
                    bg="rgba(0,0,0,0.05)"
                    justifyContent="center"
                    alignItems="center"
                  >
                    <Text fontSize={20}>{post.user.avatar}</Text>
                  </Box>
                  <VStack gap={2}>
                    <Text fontSize={15} fontWeight="600" color="#000000">
                      {post.user.name}
                    </Text>
                    <Text fontSize={12} color="rgba(0,0,0,0.5)">
                      {post.timestamp}
                    </Text>
                  </VStack>
                </HStack>
                <TouchableOpacity>
                  <Ionicons name="ellipsis-horizontal" size={20} color="rgba(0,0,0,0.7)" />
                </TouchableOpacity>
              </HStack>

              {/* Image */}
              <Image
                source={{ uri: post.image }}
                style={{
                  width: width,
                  height: width * 1.25,
                  backgroundColor: 'rgba(0,0,0,0.02)',
                }}
                resizeMode="cover"
              />

              {/* Actions */}
              <HStack
                px={20}
                py={12}
                alignItems="center"
                justifyContent="space-between"
              >
                <HStack gap={20} alignItems="center">
                  <TouchableOpacity onPress={() => toggleLike(post.id)}>
                    <Ionicons
                      name={post.isLiked ? "heart" : "heart-outline"}
                      size={26}
                      color={post.isLiked ? "#FF3B30" : "#000000"}
                    />
                  </TouchableOpacity>
                  <TouchableOpacity>
                    <Ionicons name="chatbubble-outline" size={24} color="#000000" />
                  </TouchableOpacity>
                  <TouchableOpacity>
                    <Ionicons name="paper-plane-outline" size={24} color="#000000" />
                  </TouchableOpacity>
                </HStack>
                <TouchableOpacity>
                  <Ionicons name="bookmark-outline" size={24} color="#000000" />
                </TouchableOpacity>
              </HStack>

              {/* Likes */}
              <Box px={20} pb={8}>
                <Text fontSize={14} fontWeight="600" color="#000000">
                  {post.likes} {post.likes === 1 ? 'like' : 'likes'}
                </Text>
              </Box>

              {/* Caption */}
              <Box px={20} pb={8}>
                <Text fontSize={14} color="#000000">
                  <Text fontWeight="600">{post.user.name}</Text>{' '}
                  {post.caption}
                </Text>
              </Box>

              {/* Comments */}
              {post.comments.length > 0 && (
                <Box px={20}>
                  <TouchableOpacity>
                    <Text fontSize={13} color="rgba(0,0,0,0.5)" mb={8}>
                      View all {post.comments.length} comments
                    </Text>
                  </TouchableOpacity>
                  {post.comments.slice(0, 2).map((comment) => (
                    <HStack key={comment.id} gap={8} mb={6} alignItems="flex-start">
                      <Text fontSize={16}>{comment.avatar}</Text>
                      <Text fontSize={13} color="#000000" flex={1}>
                        <Text fontWeight="600">{comment.user}</Text>{' '}
                        {comment.text}
                      </Text>
                    </HStack>
                  ))}
                </Box>
              )}

              {/* Add Comment */}
              <HStack px={20} pt={12} gap={12} alignItems="center">
                <Box
                  w={32}
                  h={32}
                  borderRadius={16}
                  bg="rgba(0,0,0,0.05)"
                  justifyContent="center"
                  alignItems="center"
                >
                  <Ionicons name="person-circle-outline" size={20} color="#000000" />
                </Box>
                <TouchableOpacity style={{ flex: 1 }}>
                  <Text fontSize={13} color="rgba(0,0,0,0.5)">
                    Add a comment...
                  </Text>
                </TouchableOpacity>
              </HStack>
            </Box>
          ))}
        </ScrollView>

        {/* AI Bubble */}
        <AIBubble />
      </Box>
    </SafeAreaView>
  );
}
