//
//  RSSItem.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import UIKit

struct RSSItem: Decodable {
    
    // MARK: - Properties
    let rss: RSS?
    
}

struct RSS: Decodable {
    
    // MARK: - Properties
    let channel: Channel?
    
}

struct Channel: Decodable {
    
    // MARK: - Properties
    let description: String?
    let image: RSSImage?
    let item: [Item]?
    
}

struct RSSImage: Decodable {
    
    // MARK: - Properties
    let url: String?
    let title: String?
    
}

struct Item: Decodable, Identifiable {
    
    // MARK: - Properties
    let title: Category?
    let description: Category?
    let publicationDate: String?
    let sourceName: String?
    let sourceURL: String?
    let imageURL: String?
    var isRead: Bool = false
    
    var id: String {
        guard
            let title,
            let publicationDate
        else {
            return UUID().uuidString
        }
        
        let idString = String(describing: title) + String(describing: publicationDate)
        
        return idString.hashString()
    }
    
    // CodingKeys
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case publicationDate = "pubDate"
        case sourceName
        case sourceURL
        case imageURL
        case isRead
    }
    
}

struct Category: Decodable {
    
    // MARK: - Properties
    let cdata: String?
    
    // CodingKeys
    private enum CodingKeys: String, CodingKey {
        case cdata = "__cdata"
    }
    
}
