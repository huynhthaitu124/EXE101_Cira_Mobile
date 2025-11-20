import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Modal,
  TouchableOpacity,
  ScrollView,
  Animated,
  Dimensions,
  TouchableWithoutFeedback,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';

const { height } = Dimensions.get('window');

interface SubscriptionPlan {
  id: string;
  name: string;
  targetUsers: string;
  monthlyPrice: number;
  yearlyPrice: number;
  storage: string;
  aiVoice: string;
  sharing: string;
  duration: string;
  color: [string, string];
  icon: string;
  popular?: boolean;
}

interface SubscriptionModalProps {
  visible: boolean;
  onClose: () => void;
  onSelectPlan?: (planId: string) => void;
}

const PLANS: SubscriptionPlan[] = [
  {
    id: 'free',
    name: 'Free / Starter',
    targetUsers: 'New users, gifting first memory',
    monthlyPrice: 0,
    yearlyPrice: 0,
    storage: '20 photos / 1 story',
    aiVoice: '1 auto-generated voice story',
    sharing: '3 story chapters',
    duration: '30 days (temporary)',
    color: ['#95A5A6', '#7F8C8D'],
    icon: 'gift-outline',
  },
  {
    id: 'personal',
    name: 'Personal',
    targetUsers: 'Individuals (memory journaling)',
    monthlyPrice: 79000,
    yearlyPrice: 899000,
    storage: '200 photos / 10 stories',
    aiVoice: 'Warm family storytelling AI',
    sharing: 'Shared family feed',
    duration: 'Permanent',
    color: ['#3498DB', '#2980B9'],
    icon: 'person-outline',
  },
  {
    id: 'family',
    name: 'Family',
    targetUsers: 'Families (2–5 members)',
    monthlyPrice: 179000,
    yearlyPrice: 2040000,
    storage: '1,000 photos',
    aiVoice: 'Personalized voices',
    sharing: 'Shared family feed',
    duration: 'Permanent',
    color: ['#F39C12', '#E67E22'],
    icon: 'people-outline',
    popular: true,
  },
  {
    id: 'premium',
    name: 'Premium Family',
    targetUsers: 'Large or extended families',
    monthlyPrice: 499000,
    yearlyPrice: 5599000,
    storage: 'Unlimited',
    aiVoice: 'Personalized voices',
    sharing: 'Shared family feed',
    duration: 'Lifetime',
    color: ['#9B59B6', '#8E44AD'],
    icon: 'star-outline',
  },
];

const formatPrice = (price: number): string => {
  if (price === 0) return 'Free';
  return `₫${price.toLocaleString('vi-VN')}`;
};

export default function SubscriptionModal({ visible, onClose, onSelectPlan }: SubscriptionModalProps) {
  const slideAnim = useRef(new Animated.Value(height)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (visible) {
      Animated.parallel([
        Animated.spring(slideAnim, {
          toValue: 0,
          useNativeDriver: true,
          tension: 65,
          friction: 11,
        }),
        Animated.timing(opacityAnim, {
          toValue: 1,
          duration: 300,
          useNativeDriver: true,
        }),
      ]).start();
    } else {
      Animated.parallel([
        Animated.timing(slideAnim, {
          toValue: height,
          duration: 250,
          useNativeDriver: true,
        }),
        Animated.timing(opacityAnim, {
          toValue: 0,
          duration: 250,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [visible]);

  const handleClose = () => {
    Animated.parallel([
      Animated.timing(slideAnim, {
        toValue: height,
        duration: 250,
        useNativeDriver: true,
      }),
      Animated.timing(opacityAnim, {
        toValue: 0,
        duration: 250,
        useNativeDriver: true,
      }),
    ]).start(() => {
      onClose();
    });
  };

  const handleSelectPlan = (planId: string) => {
    if (onSelectPlan) {
      onSelectPlan(planId);
    }
    handleClose();
  };

  return (
    <Modal
      visible={visible}
      transparent
      animationType="none"
      onRequestClose={handleClose}
      statusBarTranslucent
    >
      <View style={styles.modalContainer}>
        {/* Backdrop */}
        <TouchableWithoutFeedback onPress={handleClose}>
          <Animated.View 
            style={[
              styles.backdrop,
              {
                opacity: opacityAnim,
              },
            ]}
          />
        </TouchableWithoutFeedback>

        {/* Modal Content */}
        <Animated.View
          style={[
            styles.modalContent,
            {
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          {/* Handle Bar */}
          <View style={styles.handleContainer}>
            <View style={styles.handle} />
          </View>

          {/* Header */}
          <View style={styles.header}>
            <View style={styles.headerLeft}>
              <LinearGradient
                colors={['#F39C12', '#E67E22']}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 1 }}
                style={styles.headerIcon}
              >
                <Ionicons name="star" size={24} color="#FFFFFF" />
              </LinearGradient>
              <View>
                <Text style={styles.headerTitle}>Cira Gold</Text>
                <Text style={styles.headerSubtitle}>Choose your perfect plan</Text>
              </View>
            </View>
            <TouchableOpacity onPress={handleClose} style={styles.closeButton}>
              <Ionicons name="close" size={28} color="#2C3E50" />
            </TouchableOpacity>
          </View>

          {/* Plans List */}
          <ScrollView
            style={styles.scrollView}
            contentContainerStyle={styles.scrollContent}
            showsVerticalScrollIndicator={false}
          >
            {PLANS.map((plan, index) => (
              <View key={plan.id} style={styles.planWrapper}>
                {plan.popular && (
                  <View style={styles.popularBadge}>
                    <LinearGradient
                      colors={['#F39C12', '#E67E22']}
                      start={{ x: 0, y: 0 }}
                      end={{ x: 1, y: 1 }}
                      style={styles.popularGradient}
                    >
                      <Ionicons name="star" size={12} color="#FFFFFF" />
                      <Text style={styles.popularText}>MOST POPULAR</Text>
                    </LinearGradient>
                  </View>
                )}

                <TouchableOpacity
                  activeOpacity={0.9}
                  onPress={() => handleSelectPlan(plan.id)}
                  style={[
                    styles.planCard,
                    plan.popular && styles.popularCard,
                  ]}
                >
                  {/* Plan Header */}
                  <LinearGradient
                    colors={plan.color}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 1 }}
                    style={styles.planHeader}
                  >
                    <Ionicons name={plan.icon as any} size={32} color="#FFFFFF" />
                    <View style={styles.planHeaderText}>
                      <Text style={styles.planName}>{plan.name}</Text>
                      <Text style={styles.planTarget}>{plan.targetUsers}</Text>
                    </View>
                  </LinearGradient>

                  {/* Pricing */}
                  <View style={styles.pricingSection}>
                    <View style={styles.priceRow}>
                      <Text style={styles.priceLabel}>Monthly</Text>
                      <Text style={styles.priceValue}>{formatPrice(plan.monthlyPrice)}</Text>
                    </View>
                    {plan.yearlyPrice > 0 && (
                      <View style={styles.priceRow}>
                        <Text style={styles.priceLabel}>Yearly</Text>
                        <View style={styles.yearlyPriceContainer}>
                          <Text style={styles.priceValue}>{formatPrice(plan.yearlyPrice)}</Text>
                          <View style={styles.savingsBadge}>
                            <Text style={styles.savingsText}>
                              Save {Math.round((1 - plan.yearlyPrice / (plan.monthlyPrice * 12)) * 100)}%
                            </Text>
                          </View>
                        </View>
                      </View>
                    )}
                  </View>

                  {/* Features */}
                  <View style={styles.featuresSection}>
                    <View style={styles.featureRow}>
                      <Ionicons name="folder-outline" size={18} color="#3498DB" />
                      <View style={styles.featureTextContainer}>
                        <Text style={styles.featureLabel}>Storage</Text>
                        <Text style={styles.featureValue}>{plan.storage}</Text>
                      </View>
                    </View>

                    <View style={styles.featureRow}>
                      <Ionicons name="mic-outline" size={18} color="#9B59B6" />
                      <View style={styles.featureTextContainer}>
                        <Text style={styles.featureLabel}>AI Voice</Text>
                        <Text style={styles.featureValue}>{plan.aiVoice}</Text>
                      </View>
                    </View>

                    <View style={styles.featureRow}>
                      <Ionicons name="share-social-outline" size={18} color="#E74C3C" />
                      <View style={styles.featureTextContainer}>
                        <Text style={styles.featureLabel}>Sharing</Text>
                        <Text style={styles.featureValue}>{plan.sharing}</Text>
                      </View>
                    </View>

                    <View style={styles.featureRow}>
                      <Ionicons name="time-outline" size={18} color="#F39C12" />
                      <View style={styles.featureTextContainer}>
                        <Text style={styles.featureLabel}>Duration</Text>
                        <Text style={styles.featureValue}>{plan.duration}</Text>
                      </View>
                    </View>
                  </View>

                  {/* Select Button */}
                  <LinearGradient
                    colors={plan.color}
                    start={{ x: 0, y: 0 }}
                    end={{ x: 1, y: 1 }}
                    style={styles.selectButton}
                  >
                    <Text style={styles.selectButtonText}>
                      {plan.id === 'free' ? 'Start Free' : 'Select Plan'}
                    </Text>
                    <Ionicons name="arrow-forward" size={20} color="#FFFFFF" />
                  </LinearGradient>
                </TouchableOpacity>
              </View>
            ))}

            {/* Bottom Info */}
            <View style={styles.bottomInfo}>
              <Ionicons name="shield-checkmark-outline" size={24} color="#27AE60" />
              <Text style={styles.bottomInfoText}>
                All plans include secure cloud storage and 24/7 support
              </Text>
            </View>

            <View style={styles.bottomPadding} />
          </ScrollView>
        </Animated.View>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  modalContainer: {
    flex: 1,
    justifyContent: 'flex-end',
  },
  backdrop: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
  },
  modalContent: {
    height: height * 0.9,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.15,
    shadowRadius: 12,
    elevation: 10,
  },
  handleContainer: {
    alignItems: 'center',
    paddingTop: 12,
    paddingBottom: 8,
  },
  handle: {
    width: 40,
    height: 4,
    backgroundColor: '#BDC3C7',
    borderRadius: 2,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingTop: 8,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#ECF0F1',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    flex: 1,
  },
  headerIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerTitle: {
    fontSize: 22,
    fontWeight: '700',
    color: '#2C3E50',
  },
  headerSubtitle: {
    fontSize: 13,
    color: '#7F8C8D',
    marginTop: 2,
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#F8F9FA',
    justifyContent: 'center',
    alignItems: 'center',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 20,
  },
  planWrapper: {
    marginBottom: 20,
    position: 'relative',
  },
  popularBadge: {
    position: 'absolute',
    top: -8,
    left: 16,
    right: 16,
    zIndex: 1,
    alignItems: 'center',
  },
  popularGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 12,
    shadowColor: '#F39C12',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.3,
    shadowRadius: 4,
    elevation: 3,
  },
  popularText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#FFFFFF',
    letterSpacing: 0.5,
  },
  planCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    borderWidth: 2,
    borderColor: '#E8E8E8',
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  popularCard: {
    borderColor: '#F39C12',
    borderWidth: 2,
    marginTop: 8,
    shadowColor: '#F39C12',
    shadowOpacity: 0.2,
  },
  planHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    gap: 16,
  },
  planHeaderText: {
    flex: 1,
  },
  planName: {
    fontSize: 20,
    fontWeight: '700',
    color: '#FFFFFF',
    marginBottom: 4,
  },
  planTarget: {
    fontSize: 13,
    color: 'rgba(255, 255, 255, 0.95)',
    fontWeight: '500',
  },
  pricingSection: {
    padding: 20,
    paddingTop: 16,
    backgroundColor: '#F8F9FA',
    gap: 12,
  },
  priceRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  priceLabel: {
    fontSize: 15,
    fontWeight: '600',
    color: '#7F8C8D',
  },
  priceValue: {
    fontSize: 18,
    fontWeight: '700',
    color: '#2C3E50',
  },
  yearlyPriceContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  savingsBadge: {
    backgroundColor: '#27AE60',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  savingsText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  featuresSection: {
    padding: 20,
    gap: 16,
  },
  featureRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 12,
  },
  featureTextContainer: {
    flex: 1,
  },
  featureLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: '#7F8C8D',
    marginBottom: 4,
  },
  featureValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2C3E50',
    lineHeight: 20,
  },
  selectButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 16,
    margin: 20,
    marginTop: 8,
    borderRadius: 14,
    gap: 8,
  },
  selectButtonText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  bottomInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 20,
    backgroundColor: '#E8F8F5',
    borderRadius: 16,
    marginTop: 8,
  },
  bottomInfoText: {
    flex: 1,
    fontSize: 13,
    fontWeight: '600',
    color: '#27AE60',
    lineHeight: 18,
  },
  bottomPadding: {
    height: 20,
  },
});
