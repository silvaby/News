//
//  NewsViewModel.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Combine
import SwiftUI
import SwiftData
import Observation

@Observable
final class NewsViewModel: Loadable, Sendable {
    
    // MARK: - Properties
    let modelContainer: ModelContainer
    
    private let sourceManager = SourceManager.shared
    private let newsAPIManager = NewsAPIManager.shared
    private var timerCancellable: AnyCancellable?
    private(set) var loadingState: LoadingState<[Item]> = .initial
    private(set) var items = [Item]()
    
    // MARK: - Init methods
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        
        let jsonSources = [
            ["name": "rbc.ru", "url": "https://rssexport.rbc.ru/rbcnews/news/30/full.rss"],
            ["name": "gazeta.ru", "url": "https://www.gazeta.ru/export/rss/first.xml"],
            ["name": "mk.ru", "url": "https://www.mk.ru/rss/index.xml"]
        ]
        
        sourceManager.createSources(from: jsonSources)
    }
    
}

// MARK: - Open methods
extension NewsViewModel {
    
    func loadData() {
        Task { await loadAllNews() }
    }
    
    func startAutoRefresh() {
        stopAutoRefresh()
        
        if UserDefaults.standard.refreshInterval == 0 {
            UserDefaults.standard.refreshInterval = 60
        }
        
        timerCancellable = Timer.publish(every: TimeInterval(UserDefaults.standard.refreshInterval),
                                         on: .main,
                                         in: .common)
        .autoconnect()
        .sink { _ in
            self.loadData()
        }
    }
    
    func stopAutoRefresh() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    func markItemAsRead(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isRead = true
        }
    }
    
}

// MARK: - Private methods
private extension NewsViewModel {
    
    @MainActor
    func loadAllNews() async {
        let actor = ThreadsafeActor(modelContainer: modelContainer)
        
        if items.isEmpty {
            var allItems = [Item]()
            
            for source in sourceManager.isEnabledSources() {
                let savedNews = await actor.fetchSavedNews(with: source)
                allItems.append(contentsOf: savedNews)
            }
            
            if !allItems.isEmpty {
                loadingState = .loaded(allItems)
                items = allItems
            } else {
                loadingState = .loading
            }
        }
        
        do {
            var allItems = [Item]()
            
            try await withThrowingTaskGroup(of: [Item].self) { [weak self] group in
                guard let self else { return }
                
                sourceManager.isEnabledSources().forEach { source in
                    group.addTask { try await self.newsAPIManager.fetchNews(with: source,
                                                                            actor: actor) }
                }
                
                for try await items in group {
                    allItems.append(contentsOf: items)
                }
            }
            
            allItems.sort { $0.publicationDate?.toDate() ?? Date() > $1.publicationDate?.toDate() ?? Date() }
            
            loadingState = .loaded(allItems)
            items = allItems
        } catch {
            if items.isEmpty {
                loadingState = .failed(error.networkError)
            }
        }
    }
    
}
