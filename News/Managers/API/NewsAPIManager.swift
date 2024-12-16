//
//  NewsAPIManager.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

final class NewsAPIManager: APIManager {
    
    // MARK: - Properties
    static let shared = NewsAPIManager()
    
}

// MARK: - Open methods
extension NewsAPIManager {
    
    func fetchNews(with source: Source, actor: ThreadsafeActor) async throws -> [Item] {
        do {
            let data: Data = try await XMLDataRequest(url: source.url, method: .GET)
            let parser = RSSParser(source: source)
            let news = try await parseXMLToEntity(data: data, parser: parser)
            
            await actor.saveNews(news, for: source)
            
            return news
        } catch {
            return await actor.fetchSavedNews(with: source)
        }
    }
    
}
