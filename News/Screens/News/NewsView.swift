//
//  NewsView.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftUI
import SwiftData

struct NewsView: View {
    
    // MARK: - Properties
    let viewModel: NewsViewModel
    
    @State private var isPresentingModalSettings = false
    @State private var isCompactMode = UserDefaults.standard.isCompactMode
    @State private var isNeedToClearCache = UserDefaults.standard.isNeedToClearCache
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
        
    // MARK: UI
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    switch viewModel.loadingState {
                    case .initial:
                        EmptyView()
                        
                    case .loading:
                        if viewModel.items.isEmpty {
                            loadingView
                        } else {
                            itemsListView(with: viewModel.items, isCompactMode: isCompactMode)
                        }
                        
                    case .loaded(let items):
                        if items.isEmpty {
                            emptyDataView
                        } else {
                            itemsListView(with: viewModel.items, isCompactMode: isCompactMode)
                        }
                        
                    case .failed(let error):
                        if viewModel.items.isEmpty {
                            emptyDataView
                                .onAppear {
                                    showError(with: error.errorDescription)
                                }
                        } else {
                            itemsListView(with: viewModel.items, isCompactMode: isCompactMode)
                                .onAppear {
                                    showError(with: error.errorDescription)
                                }
                        }
                    }
                }
            }
            .navigationTitle("News")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsButton
                }
            }
            .onAppear {
                if viewModel.items.isEmpty {
                    viewModel.loadData()
                }
                viewModel.startAutoRefresh()
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
            .alert("Something went wrong",
                   isPresented: $showErrorAlert,
                   actions: {
                Button("OK") {
                    showErrorAlert = false
                }
            }, message: { Text(errorMessage) } )
        }
    }
    
}

// MARK: - Subviews
private extension NewsView {
    
    var loadingView: some View {
        LoadingList()
    }
    
    struct LoadingList: View {
        
        // MARK: - Properties
        var count: Int = 10
        
        // MARK: UI
        var body: some View {
            ForEach(0..<count, id: \.self) { _ in
                LoadingView()
            }
            .listStyle(.plain)
        }
    }
    
    struct LoadingView: View {
        
        // MARK: - Properties
        let id = UUID()
        
        // MARK: UI
        var body: some View {
            let width = UIScreen.main.bounds.width - 40
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: width * 0.7, height: 20)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 8)
                    .frame(width: width * 0.5, height: 20)
                    .foregroundColor(.gray)
                
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: width * 0.7, height: 14)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: width * 0.5, height: 14)
                    .foregroundColor(.gray)
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: width * 0.3, height: 14)
                    .foregroundColor(.gray)
            }
            .blinking(duration: 0.5)
        }
    }
    
    var emptyDataView: some View {
        ContentUnavailableView("No data available",
                               systemImage: "exclamationmark.warninglight")
        .foregroundColor(.gray)
    }
    
    @ViewBuilder
    func itemsListView(with items: [Item], isCompactMode: Bool) -> some View {
        ForEach(items, id: \.id) { item in
            NavigationLink(destination: NewsDetailView(newsItem: item)
                .onAppear {
                    viewModel.markItemAsRead(item)
                }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.sourceName ?? "No name")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                        
                        Text(item.sourceURL ?? "-")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        if let urlString = item.imageURL {
                            CachedAsyncImage(url: URL(string: urlString), cachePolicy: .returnCacheDataElseLoad) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    ZStack {
                                        Image(systemName: "photo")
                                        Color.gray.opacity(0.1)
                                    }
                                }
                            }
                            .frame(width: 60, height: 40)
                            .cornerRadius(8)
                        } else {
                            ZStack {
                                Image(systemName: "photo")
                                Color.gray.opacity(0.1)
                                    .frame(width: 60, height: 40)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Text(item.title?.cdata ?? "No title")
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(item.isRead ? .green : .primary)
                    }
                    
                    if !isCompactMode {
                        Text(item.description?.cdata ?? "No description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                    }
                }
            }
        }
    }
    
    var settingsButton: some View {
        Button {
            viewModel.stopAutoRefresh()
            self.isPresentingModalSettings = true
        } label: {
            Label("", systemImage: "gearshape.fill")
        }
        .fullScreenCover(isPresented: $isPresentingModalSettings) {
            SettingsView(isPresentingModalSettings: $isPresentingModalSettings,
                         isCompactMode: $isCompactMode,
                         isNeedToClearCache: $isNeedToClearCache) {
                viewModel.loadData()
                viewModel.startAutoRefresh()
            }
        }
    }
    
}

// MARK: - Actions
private extension NewsView {
    
    func showError(with message: String) {
        errorMessage = message
        showErrorAlert = true
    }
    
}

// MARK: - Preview
#Preview {
    do {
        let container = try ModelContainer(for: NewsItem.self)
        let viewModel = NewsViewModel(modelContainer: container)
        
        return NewsView(viewModel: viewModel)
    } catch {
        fatalError("Failed to create container")
    }
}
