//
//  NewsItem.swift
//  News
//
//  Created by Dzmitry on 15.12.24.
//

import SwiftData

@Model
final class NewsItem {
    
    // MARK: - Properties
    @Attribute(.unique) var id: String
    var title: String?
    var newsDescription: String?
    var publicationDate: String?
    var sourceName: String?
    var sourceURL: String?
    var imageURL: String?
    var isRead: Bool = false
    
    // MARK: - Init methods
    init(id: String,
         title: String? = nil,
         newsDescription: String? = nil,
         publicationDate: String? = nil,
         sourceName: String? = nil,
         sourceURL: String? = nil,
         imageURL: String? = nil,
         isRead: Bool = false) {
        self.id = id
        self.title = title
        self.newsDescription = newsDescription
        self.publicationDate = publicationDate
        self.sourceName = sourceName
        self.sourceURL = sourceURL
        self.imageURL = imageURL
        self.isRead = isRead
    }
    
}
