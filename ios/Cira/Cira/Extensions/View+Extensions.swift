//
//  View+Extensions.swift
//  CiraSwift
//
//  SwiftUI View modifiers for glassmorphism and common styling
//

import SwiftUI

extension View {
    // MARK: - Glassmorphism Effect (from RN BlurView)
    func glassEffect(
        tint: Color = .white,
        opacity: Double = 0.95,
        blur: CGFloat = 10
    ) -> some View {
        self
            .background(
                ZStack {
                    tint.opacity(opacity)
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialLight)
                }
            )
    }
    
    // MARK: - Glass Button Style (from RN TouchableOpacity with glass background)
    func glassButton(
        tint: Color = Color.black.opacity(0.08),
        cornerRadius: CGFloat = 12
    ) -> some View {
        self
            .background(tint)
            .cornerRadius(cornerRadius)
    }
    
    // MARK: - Gradient Overlay (from RN LinearGradient)
    func gradientOverlay(
        colors: [Color],
        startPoint: UnitPoint = .top,
        endPoint: UnitPoint = .bottom,
        opacity: Double = 1.0
    ) -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: startPoint,
                endPoint: endPoint
            )
            .opacity(opacity)
        )
    }
    
    // MARK: - Haptic Feedback
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

// MARK: - UIVisualEffectView Wrapper for Blur
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}
