//
//  RSSParser.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

protocol Parsable {
    associatedtype T
    func parse(data: Data) async throws -> T
}

final class RSSParser: NSObject {
        
    // MARK: - Properties
    let source: SourceProtocol
    private var element: String?
    private var title: String?
    private var itemDescription: String?
    private var publicationDate: String?
    private var imageURL: String?
    private var items = [Item]()
    private var continuation: CheckedContinuation<T, Error>?
    
    init(source: SourceProtocol) {
        self.source = source
    }
    
}

// MARK: - Parserable
extension RSSParser: Parsable {
    
    func parse(data: Data) async throws -> [Item] {
        items.removeAll()
        
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    }
    
}

// MARK: - XMLParserDelegate
extension RSSParser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        element = elementName
        
        if element == "item" {
            title = nil
            itemDescription = nil
            publicationDate = nil
        }
        
        if element == "enclosure" {
            imageURL = attributeDict["url"]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch element {
        case "title":
            title = (title ?? "") + string
        case "description":
            itemDescription = (itemDescription ?? "") + string
        case "pubDate":
            publicationDate = (publicationDate ?? "") + string
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "item" {
            let item = Item(title: title.map { Category(cdata: $0) },
                            description: itemDescription.map { Category(cdata: $0) },
                            publicationDate: publicationDate,
                            sourceName: source.name,
                            sourceURL: source.url,
                            imageURL: imageURL)
            
            items.append(item)
        }
        
        element = nil
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        continuation?.resume(returning: items)
        continuation = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        continuation?.resume(throwing: parseError)
        continuation = nil
    }
    
}
