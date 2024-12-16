//
//  NewsDetailView.swift
//  News
//
//  Created by Dzmitry on 15.12.24.
//

import SwiftUI

struct NewsDetailView: View {
    
    // MARK: - Properties
    var newsItem: Item
    
    // MARK: UI
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(newsItem.title?.cdata ?? "No title")
                        .font(.title)
                        .bold()
                    
                    Text(newsItem.publicationDate ?? "No date")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(newsItem.description?.cdata ?? "No description")
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading) 
                .padding(.horizontal, 20)
            }
            .navigationTitle("Details")
        }
    }
    
}

// MARK: - Preview
#Preview {
    NewsDetailView(newsItem: Item(title: Category(cdata: "Test"),
                                  description: Category(cdata: "Test"),
                                  publicationDate: "20.11.2024",
                                  sourceName: "Test",
                                  sourceURL: "test.com",
                                  imageURL: ""))
}
