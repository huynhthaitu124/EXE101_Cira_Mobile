//
//  StoryCreatorView.swift
//  Cira
//
//  Story Creator - Chọn ảnh từ bộ sưu tập và tạo câu chuyện với AI
//  UI đơn giản: Khay ảnh đã chọn + Bộ sưu tập theo thời gian + Nút gửi AI
//

import SwiftUI
import Photos

struct StoryCreatorView: View {
    @StateObject private var viewModel = StoryCreatorViewModel()
    @EnvironmentObject var navigationManager: NavigationManager
    @State private var showDescriptionSheet = false
    @State private var selectedPhotoForDescription: StoryPhoto?
    @State private var showStoryResult = false
    
    var body: some View {
        ZStack {
            CiraColors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Selected photos tray (fixed at top)
                if !viewModel.selectedPhotos.isEmpty {
                    selectedPhotosTray
                }
                
                // Photo library grouped by time
                photoLibrarySection
            }
            
            // Floating action buttons
            VStack {
                Spacer()
                actionButtons
            }
            
            // Story result overlay
            if showStoryResult {
                storyResultOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { navigationManager.goBack() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CiraColors.textPrimary)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Tạo câu chuyện")
                    .font(CiraTypography.headline)
                    .foregroundColor(CiraColors.textPrimary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if !viewModel.selectedPhotos.isEmpty {
                    Button(action: { viewModel.selectedPhotos.removeAll() }) {
                        Text("Xóa hết")
                            .font(CiraTypography.caption)
                            .foregroundColor(CiraColors.error)
                    }
                }
            }
        }
        .sheet(isPresented: $showDescriptionSheet) {
            if let photo = selectedPhotoForDescription {
                PhotoDescriptionSheet(
                    photo: photo,
                    onSave: { description in
                        viewModel.updateDescription(description, for: photo.id)
                        showDescriptionSheet = false
                        selectedPhotoForDescription = nil
                    },
                    onCancel: {
                        showDescriptionSheet = false
                        selectedPhotoForDescription = nil
                    }
                )
            } else {
                AllPhotosDescriptionSheet(
                    photos: viewModel.selectedPhotos,
                    onSave: { description in
                        viewModel.setDescriptionForAll(description)
                        showDescriptionSheet = false
                    },
                    onCancel: {
                        showDescriptionSheet = false
                    }
                )
            }
        }
        .onAppear {
            viewModel.loadPhotoLibrary()
        }
    }
    
    // MARK: - Selected Photos Tray
    private var selectedPhotosTray: some View {
        VStack(spacing: CiraSpacing.sm) {
            // Tray header
            HStack {
                Image(systemName: "photo.stack.fill")
                    .foregroundColor(CiraColors.primary)
                Text("\(viewModel.selectedPhotos.count) ảnh đã chọn")
                    .font(CiraTypography.subheadline)
                    .foregroundColor(CiraColors.textPrimary)
                
                Spacer()
                
                // Add description for all button
                Button(action: {
                    selectedPhotoForDescription = nil
                    showDescriptionSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble")
                        Text("Mô tả chung")
                    }
                    .font(CiraTypography.caption)
                    .foregroundColor(CiraColors.primary)
                    .padding(.horizontal, CiraSpacing.sm)
                    .padding(.vertical, 4)
                    .background(CiraColors.primary.opacity(0.1))
                    .cornerRadius(CiraSize.radiusFull)
                }
            }
            .padding(.horizontal, CiraSpacing.lg)
            
            // Selected photos horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CiraSpacing.sm) {
                    ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.element.id) { index, photo in
                        SelectedPhotoItem(
                            photo: photo,
                            index: index,
                            onTap: {
                                selectedPhotoForDescription = photo
                                showDescriptionSheet = true
                            },
                            onRemove: {
                                viewModel.removePhoto(at: index)
                            }
                        )
                    }
                }
                .padding(.horizontal, CiraSpacing.lg)
            }
        }
        .padding(.vertical, CiraSpacing.md)
        .background(CiraColors.backgroundSecondary)
        .shadow(color: CiraShadow.card.color, radius: CiraShadow.card.radius, x: 0, y: 2)
    }
    
    // MARK: - Photo Library Section
    private var photoLibrarySection: some View {
        Group {
            if viewModel.isLoadingLibrary {
                VStack(spacing: CiraSpacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CiraColors.primary))
                    Text("Đang tải thư viện ảnh...")
                        .font(CiraTypography.body)
                        .foregroundColor(CiraColors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.photoLibraryAuthorized {
                permissionDeniedView
            } else if viewModel.photoGroups.isEmpty {
                emptyLibraryView
            } else {
                photoGroupsList
            }
        }
    }
    
    private var photoGroupsList: some View {
        ScrollView {
            LazyVStack(spacing: CiraSpacing.lg, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.photoGroups) { group in
                    Section {
                        photoGrid(for: group.photos)
                    } header: {
                        sectionHeader(title: group.title, count: group.photos.count)
                    }
                }
            }
            .padding(.bottom, 120) // Space for floating buttons
        }
    }
    
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(CiraTypography.subheadline)
                .foregroundColor(CiraColors.textPrimary)
            
            Text("(\(count))")
                .font(CiraTypography.caption)
                .foregroundColor(CiraColors.textTertiary)
            
            Spacer()
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.vertical, CiraSpacing.sm)
        .background(CiraColors.backgroundPrimary.opacity(0.95))
    }
    
    private func photoGrid(for assets: [PHAsset]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
        
        return LazyVGrid(columns: columns, spacing: 2) {
            ForEach(assets, id: \.localIdentifier) { asset in
                LibraryPhotoItem(
                    asset: asset,
                    isSelected: viewModel.isPhotoSelected(asset),
                    selectionOrder: viewModel.getSelectionOrder(for: asset),
                    onTap: {
                        viewModel.togglePhotoSelection(asset)
                    }
                )
            }
        }
        .padding(.horizontal, 2)
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: CiraSpacing.lg) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(CiraColors.textTertiary)
            
            Text("Không có quyền truy cập ảnh")
                .font(CiraTypography.headline)
                .foregroundColor(CiraColors.textPrimary)
            
            Text("Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt")
                .font(CiraTypography.body)
                .foregroundColor(CiraColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Mở Cài đặt")
                    .font(CiraTypography.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, CiraSpacing.xl)
                    .padding(.vertical, CiraSpacing.md)
                    .background(CiraColors.primary)
                    .cornerRadius(CiraSize.radiusFull)
            }
        }
        .padding(CiraSpacing.xl)
    }
    
    private var emptyLibraryView: some View {
        VStack(spacing: CiraSpacing.lg) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(CiraColors.textTertiary)
            
            Text("Thư viện ảnh trống")
                .font(CiraTypography.headline)
                .foregroundColor(CiraColors.textPrimary)
            
            Text("Hãy chụp hoặc thêm ảnh vào thư viện để bắt đầu")
                .font(CiraTypography.body)
                .foregroundColor(CiraColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(CiraSpacing.xl)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: CiraSpacing.md) {
            if !viewModel.selectedPhotos.isEmpty {
                // Generate Story Button
                Button(action: {
                    viewModel.generateStory()
                    showStoryResult = true
                }) {
                    HStack(spacing: CiraSpacing.sm) {
                        if viewModel.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(viewModel.isProcessing ? "Đang tạo..." : "Tạo câu chuyện với AI")
                    }
                    .font(CiraTypography.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CiraSpacing.lg)
                    .background(
                        viewModel.selectedPhotos.count >= 2
                            ? CiraGradients.primary
                            : LinearGradient(colors: [CiraColors.textTertiary], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(CiraSize.radiusFull)
                }
                .disabled(viewModel.selectedPhotos.count < 2 || viewModel.isProcessing)
                
                // Minimum photos hint
                if viewModel.selectedPhotos.count < 2 {
                    Text("Chọn ít nhất 2 ảnh để tạo câu chuyện")
                        .font(CiraTypography.caption)
                        .foregroundColor(CiraColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, CiraSpacing.lg)
        .padding(.bottom, CiraSpacing.lg)
        .background(
            LinearGradient(
                colors: [CiraColors.backgroundPrimary.opacity(0), CiraColors.backgroundPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }
    
    // MARK: - Story Result Overlay
    private var storyResultOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    if !viewModel.isProcessing {
                        showStoryResult = false
                    }
                }
            
            StoryResultCard(
                viewModel: viewModel,
                onClose: { showStoryResult = false },
                onSave: {
                    viewModel.saveStory()
                    showStoryResult = false
                    navigationManager.goBack()
                }
            )
            .padding(CiraSpacing.lg)
        }
    }
}

// MARK: - Selected Photo Item
struct SelectedPhotoItem: View {
    let photo: StoryPhoto
    let index: Int
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 4) {
                    Image(uiImage: photo.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: CiraSize.radiusSM))
                        .overlay(
                            RoundedRectangle(cornerRadius: CiraSize.radiusSM)
                                .stroke(
                                    photo.description.isEmpty ? CiraColors.border : CiraColors.success,
                                    lineWidth: 2
                                )
                        )
                    
                    // Description indicator
                    HStack(spacing: 2) {
                        Image(systemName: photo.description.isEmpty ? "text.bubble" : "checkmark.circle.fill")
                            .font(.system(size: 8))
                        Text(photo.description.isEmpty ? "Chưa mô tả" : "Đã mô tả")
                            .font(.system(size: 9))
                    }
                    .foregroundColor(photo.description.isEmpty ? CiraColors.textTertiary : CiraColors.success)
                }
                
                // Order badge
                ZStack {
                    Circle()
                        .fill(CiraColors.primary)
                        .frame(width: 18, height: 18)
                    Text("\(index + 1)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(x: 4, y: -4)
                
                // Remove button
                Button(action: onRemove) {
                    ZStack {
                        Circle()
                            .fill(CiraColors.error)
                            .frame(width: 18, height: 18)
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(x: -44, y: -4)
            }
        }
    }
}

// MARK: - Library Photo Item
struct LibraryPhotoItem: View {
    let asset: PHAsset
    let isSelected: Bool
    let selectionOrder: Int?
    let onTap: () -> Void
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(CiraColors.backgroundTertiary)
                }
            }
            .frame(height: (UIScreen.main.bounds.width - 8) / 3)
            .clipped()
            .overlay(
                ZStack {
                    if isSelected {
                        Color.black.opacity(0.3)
                        
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(CiraColors.primary)
                                        .frame(width: 26, height: 26)
                                    if let order = selectionOrder {
                                        Text("\(order)")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(CiraSpacing.sm)
                            }
                            Spacer()
                        }
                        
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(CiraColors.primary, lineWidth: 3)
                    }
                }
            )
        }
        .onAppear { loadThumbnail() }
    }
    
    private func loadThumbnail() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 200, height: 200),
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            self.thumbnail = image
        }
    }
}

// MARK: - Photo Description Sheet
struct PhotoDescriptionSheet: View {
    let photo: StoryPhoto
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var description: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: CiraSpacing.lg) {
                // Photo preview
                Image(uiImage: photo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 250)
                    .cornerRadius(CiraSize.radiusMD)
                
                // Description input
                VStack(alignment: .leading, spacing: CiraSpacing.sm) {
                    Text("Mô tả khoảnh khắc này")
                        .font(CiraTypography.subheadline)
                        .foregroundColor(CiraColors.textPrimary)
                    
                    TextField("Ví dụ: Kỷ niệm sinh nhật của bé...", text: $description, axis: .vertical)
                        .font(CiraTypography.body)
                        .lineLimit(3...6)
                        .padding(CiraSpacing.md)
                        .background(CiraColors.backgroundTertiary)
                        .cornerRadius(CiraSize.radiusMD)
                }
                
                Spacer()
                
                // Save button
                Button(action: { onSave(description) }) {
                    Text("Lưu mô tả")
                        .font(CiraTypography.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CiraSpacing.lg)
                        .background(CiraGradients.primary)
                        .cornerRadius(CiraSize.radiusFull)
                }
            }
            .padding(CiraSpacing.lg)
            .background(CiraColors.backgroundPrimary)
            .navigationTitle("Mô tả ảnh")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy", action: onCancel)
                }
            }
        }
        .onAppear {
            description = photo.description
        }
    }
}

// MARK: - All Photos Description Sheet
struct AllPhotosDescriptionSheet: View {
    let photos: [StoryPhoto]
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    @State private var description: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: CiraSpacing.lg) {
                // Photos preview
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CiraSpacing.sm) {
                        ForEach(photos) { photo in
                            Image(uiImage: photo.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: CiraSize.radiusSM))
                        }
                    }
                }
                .frame(height: 80)
                
                // Description input
                VStack(alignment: .leading, spacing: CiraSpacing.sm) {
                    Text("Mô tả chung cho \(photos.count) ảnh")
                        .font(CiraTypography.subheadline)
                        .foregroundColor(CiraColors.textPrimary)
                    
                    Text("AI sẽ sử dụng mô tả này để tạo câu chuyện kết nối các ảnh")
                        .font(CiraTypography.caption)
                        .foregroundColor(CiraColors.textSecondary)
                    
                    TextField("Ví dụ: Kỷ niệm chuyến du lịch Đà Lạt cùng gia đình...", text: $description, axis: .vertical)
                        .font(CiraTypography.body)
                        .lineLimit(3...6)
                        .padding(CiraSpacing.md)
                        .background(CiraColors.backgroundTertiary)
                        .cornerRadius(CiraSize.radiusMD)
                }
                
                Spacer()
                
                // Save button
                Button(action: { onSave(description) }) {
                    Text("Áp dụng cho tất cả")
                        .font(CiraTypography.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CiraSpacing.lg)
                        .background(CiraGradients.primary)
                        .cornerRadius(CiraSize.radiusFull)
                }
            }
            .padding(CiraSpacing.lg)
            .background(CiraColors.backgroundPrimary)
            .navigationTitle("Mô tả chung")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Hủy", action: onCancel)
                }
            }
        }
    }
}

// MARK: - Story Result Card
struct StoryResultCard: View {
    @ObservedObject var viewModel: StoryCreatorViewModel
    let onClose: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: CiraSpacing.lg) {
            // Header
            HStack {
                Text("Câu chuyện của bạn")
                    .font(CiraTypography.headline)
                    .foregroundColor(CiraColors.textPrimary)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(CiraColors.textTertiary)
                }
            }
            
            if viewModel.isProcessing {
                // Loading state
                VStack(spacing: CiraSpacing.md) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CiraColors.primary))
                        .scaleEffect(1.5)
                    
                    Text("AI đang viết câu chuyện...")
                        .font(CiraTypography.body)
                        .foregroundColor(CiraColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, CiraSpacing.xxl)
            } else if let story = viewModel.storyDraft.generatedStory {
                // Story content
                ScrollView {
                    Text(story)
                        .font(CiraTypography.body)
                        .foregroundColor(CiraColors.textPrimary)
                        .lineSpacing(6)
                }
                .frame(maxHeight: 300)
                
                // Actions
                HStack(spacing: CiraSpacing.md) {
                    Button(action: { viewModel.generateStory() }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Viết lại")
                        }
                        .font(CiraTypography.body)
                        .foregroundColor(CiraColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CiraSpacing.md)
                        .background(CiraColors.primary.opacity(0.1))
                        .cornerRadius(CiraSize.radiusFull)
                    }
                    
                    Button(action: onSave) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Lưu")
                        }
                        .font(CiraTypography.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CiraSpacing.md)
                        .background(CiraGradients.primary)
                        .cornerRadius(CiraSize.radiusFull)
                    }
                }
            }
        }
        .padding(CiraSpacing.lg)
        .background(CiraColors.backgroundSecondary)
        .cornerRadius(CiraSize.radiusLG)
    }
}

#Preview {
    NavigationStack {
        StoryCreatorView()
            .environmentObject(NavigationManager())
    }
}
