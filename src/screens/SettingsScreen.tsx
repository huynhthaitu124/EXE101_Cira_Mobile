import React from 'react';
import { ScrollView, Switch } from 'react-native';
import {
  Box,
  VStack,
  HStack,
  Text,
  Heading,
  Card,
  Button,
  ButtonText,
  Divider,
} from '@gluestack-ui/themed';
import { Ionicons } from '@expo/vector-icons';

export default function SettingsScreen() {
  const [pushEnabled, setPushEnabled] = React.useState(true);
  const [emailEnabled, setEmailEnabled] = React.useState(false);
  const [darkMode, setDarkMode] = React.useState(false);

  return (
    <ScrollView style={{ flex: 1 }}>
      <Box flex={1} bg="$backgroundLight0" $dark-bg="$backgroundDark950">
        <Box px="$6" pt="$8" pb="$4">
          <Heading size="2xl" color="$textLight950" $dark-color="$textDark50">
            Settings
          </Heading>
          <Text size="md" color="$textLight700" $dark-color="$textDark400" mt="$2">
            Manage your preferences
          </Text>
        </Box>

        <VStack space="md" px="$4" pb="$6">
          {/* Notifications Section */}
          <Box>
            <Text size="sm" fontWeight="$bold" color="$textLight600" mb="$2" px="$2">
              NOTIFICATIONS
            </Text>
            <Card size="md" variant="outline" p="$4">
              <VStack space="md">
                <HStack justifyContent="space-between" alignItems="center">
                  <HStack space="sm" alignItems="center" flex={1}>
                    <Ionicons name="notifications-outline" size={20} />
                    <Text>Push Notifications</Text>
                  </HStack>
                  <Switch
                    value={pushEnabled}
                    onValueChange={setPushEnabled}
                  />
                </HStack>
                <Divider />
                <HStack justifyContent="space-between" alignItems="center">
                  <HStack space="sm" alignItems="center" flex={1}>
                    <Ionicons name="mail-outline" size={20} />
                    <Text>Email Notifications</Text>
                  </HStack>
                  <Switch
                    value={emailEnabled}
                    onValueChange={setEmailEnabled}
                  />
                </HStack>
              </VStack>
            </Card>
          </Box>

          {/* Appearance Section */}
          <Box>
            <Text size="sm" fontWeight="$bold" color="$textLight600" mb="$2" px="$2">
              APPEARANCE
            </Text>
            <Card size="md" variant="outline" p="$4">
              <HStack justifyContent="space-between" alignItems="center">
                <HStack space="sm" alignItems="center" flex={1}>
                  <Ionicons name="moon-outline" size={20} />
                  <Text>Dark Mode</Text>
                </HStack>
                <Switch
                  value={darkMode}
                  onValueChange={setDarkMode}
                />
              </HStack>
            </Card>
          </Box>

          {/* Account Section */}
          <Box>
            <Text size="sm" fontWeight="$bold" color="$textLight600" mb="$2" px="$2">
              ACCOUNT
            </Text>
            <VStack space="sm">
              <Card size="md" variant="outline" p="$4">
                <HStack space="md" alignItems="center">
                  <Ionicons name="key-outline" size={20} />
                  <Text flex={1}>Change Password</Text>
                  <Ionicons name="chevron-forward-outline" size={20} />
                </HStack>
              </Card>

              <Card size="md" variant="outline" p="$4">
                <HStack space="md" alignItems="center">
                  <Ionicons name="language-outline" size={20} />
                  <Text flex={1}>Language</Text>
                  <Text size="sm" color="$textLight500">English</Text>
                  <Ionicons name="chevron-forward-outline" size={20} />
                </HStack>
              </Card>

              <Card size="md" variant="outline" p="$4">
                <HStack space="md" alignItems="center">
                  <Ionicons name="shield-checkmark-outline" size={20} />
                  <Text flex={1}>Privacy Policy</Text>
                  <Ionicons name="chevron-forward-outline" size={20} />
                </HStack>
              </Card>

              <Card size="md" variant="outline" p="$4">
                <HStack space="md" alignItems="center">
                  <Ionicons name="document-text-outline" size={20} />
                  <Text flex={1}>Terms of Service</Text>
                  <Ionicons name="chevron-forward-outline" size={20} />
                </HStack>
              </Card>
            </VStack>
          </Box>

          {/* Logout Button */}
          <Button size="md" action="negative" mt="$4">
            <ButtonText>Logout</ButtonText>
          </Button>

          {/* App Version */}
          <Text size="xs" color="$textLight500" textAlign="center" mt="$4">
            Version 1.0.0
          </Text>
        </VStack>
      </Box>
    </ScrollView>
  );
}
