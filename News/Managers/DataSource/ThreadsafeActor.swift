//
//  ThreadsafeActor.swift
//  News
//
//  Created by Dzmitry on 16.12.24.
//

import SwiftData
import SwiftUI

@ModelActor
actor ThreadsafeActor: Sendable {
    
    // MARK: - Properties
    private var context: ModelContext { modelExecutor.modelContext }
    
}

// MARK: - Open methods
extension ThreadsafeActor {
    
    func saveNews(_ items: [Item], for source: Source) {
        for item in items {
            let id = item.id
            let sourceName = item.sourceName
            
            if let existingNews = try? context.fetch(FetchDescriptor<NewsItem>(predicate: #Predicate<NewsItem> { newsItem in
                newsItem.id == id && newsItem.sourceName == sourceName
            })).first {
                existingNews.title = item.title?.cdata
                existingNews.newsDescription = item.description?.cdata
                existingNews.publicationDate = item.publicationDate
                existingNews.sourceName = item.sourceName
                existingNews.sourceURL = item.sourceURL
                existingNews.imageURL = item.imageURL
                existingNews.isRead = item.isRead
            } else {
                let newNews = NewsItem(id: id,
                                       title: item.title?.cdata,
                                       newsDescription: item.description?.cdata,
                                       publicationDate: item.publicationDate,
                                       sourceName: item.sourceName,
                                       sourceURL: item.sourceURL,
                                       imageURL: item.imageURL,
                                       isRead: item.isRead)
                
                context.insert(newNews)
            }
        }
        
        try? context.save()
    }
    
    func fetchSavedNews(with source: Source) -> [Item] {
        let sourceName = source.name
        let fetchDescriptor = FetchDescriptor<NewsItem>(predicate: #Predicate<NewsItem> { newsItem in
            newsItem.sourceName == sourceName
        }, sortBy: [SortDescriptor(\NewsItem.publicationDate, order: .reverse)])
        
        do {
            let savedItems = try context.fetch(fetchDescriptor)
            
            return savedItems.map { Item(title: Category(cdata: $0.title ?? ""),
                                         description: Category(cdata: $0.newsDescription ?? ""),
                                         publicationDate: $0.publicationDate,
                                         sourceName: $0.sourceName,
                                         sourceURL: $0.sourceURL,
                                         imageURL: $0.imageURL,
                                         isRead: $0.isRead) }
        } catch {
            return []
        }
    }
    
    func clearCache() {
        let fetchDescriptor = FetchDescriptor<NewsItem>()
        let itemsToDelete = try? context.fetch(fetchDescriptor)
        
        guard let itemsToDelete else { return }
        
        for item in itemsToDelete {
            context.delete(item)
        }
        
        try? context.save()
    }
    
}
