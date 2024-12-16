//
//  CachedAsyncImage.swift
//  News
//
//  Created by Dzmitry on 15.12.24.
//

import SwiftUI

struct CachedAsyncImage<Content>: View where Content: View {
    
    // MARK: - Properties
    @State private var phase: AsyncImagePhase
    private let urlRequest: URLRequest?
    private let urlSession: URLSession
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    
    // MARK: UI
    var body: some View {
        content(phase)
            .task(id: urlRequest, load)
    }
    
    // MARK: - Init methods
    init(url: URL?,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        let urlRequest = url.map { URLRequest(url: $0, cachePolicy: cachePolicy) }
        self.init(urlRequest: urlRequest, content: content)
    }
    
    private init(urlRequest: URLRequest?,
         urlCache: URLCache = .shared,
         scale: CGFloat = 1,
         transaction: Transaction = Transaction(),
         @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        
        self.urlRequest = urlRequest
        self.urlSession = URLSession(configuration: configuration)
        self.scale = scale
        self.transaction = transaction
        self.content = content
        
        self._phase = State(wrappedValue: .empty)
        
        do {
            if let urlRequest,
               let image = try cachedImage(from: urlRequest, cache: urlCache) {
                self._phase = State(wrappedValue: .success(image))
            }
        } catch {
            self._phase = State(wrappedValue: .failure(error))
        }
    }
    
}

// MARK: - Load methods
private extension CachedAsyncImage {
    
    @Sendable
    func load() async {
        do {
            if let urlRequest {
                let (image, metrics) = try await remoteImage(from: urlRequest,
                                                             session: urlSession)
                
                if metrics.transactionMetrics.last?.resourceFetchType == .localCache {
                    phase = .success(image)
                } else {
                    withAnimation(transaction.animation) {
                        phase = .success(image)
                    }
                }
            } else {
                withAnimation(transaction.animation) {
                    phase = .empty
                }
            }
        } catch {
            withAnimation(transaction.animation) {
                phase = .failure(error)
            }
        }
    }
    
}

// MARK: - Actions
private extension CachedAsyncImage {
    
    func remoteImage(from request: URLRequest,
                     session: URLSession) async throws -> (Image, URLSessionTaskMetrics) {
        let (data, _, metrics) = try await session.data(for: request)
        
        if metrics.redirectCount > 0,
           let lastResponse = metrics.transactionMetrics.last?.response {
            let requests = metrics.transactionMetrics.map(\.request)
            requests.forEach(session.configuration.urlCache!.removeCachedResponse)
            
            let lastCachedResponse = CachedURLResponse(response: lastResponse, data: data)
            session.configuration.urlCache!.storeCachedResponse(lastCachedResponse, for: request)
        }
        
        return try (image(from: data), metrics)
    }
    
    func cachedImage(from request: URLRequest, cache: URLCache) throws -> Image? {
        guard let cachedResponse = cache.cachedResponse(for: request) else { return nil }
        
        return try image(from: cachedResponse.data)
    }
    
    func image(from data: Data) throws -> Image {
        if let uiImage = UIImage(data: data, scale: scale) {
            return Image(uiImage: uiImage)
        } else {
            throw AsyncImage<Content>.LoadingError()
        }
    }
    
}

// MARK: - LoadingError
private extension AsyncImage {
    
    struct LoadingError: Error {}
    
}

// MARK: - URLSession
private extension URLSession {
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse, URLSessionTaskMetrics) {
        let controller = URLSessionTaskController()
        let (data, response) = try await data(for: request, delegate: controller)
        
        return (data, response, controller.metrics!)
    }
    
}

// MARK: - AsyncImageURLSession
private class URLSessionTaskController: NSObject, URLSessionTaskDelegate {
    
    var metrics: URLSessionTaskMetrics?
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.metrics = metrics
    }
    
}
