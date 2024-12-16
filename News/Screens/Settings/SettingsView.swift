//
//  SettingsView.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftUI

struct SettingsView: View {
    
    // MARK: - Properties
    @Binding var isPresentingModalSettings: Bool
    @Binding var isCompactMode: Bool
    @Binding var isNeedToClearCache: Bool
    @State private var refreshInterval: Int = UserDefaults.standard.refreshInterval
    var onDismiss: (() -> Void)?
    
    // MARK: UI
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Other section
                    Section {
                        // Compact mode
                        HStack {
                            Toggle(isOn: $isCompactMode) {
                                Text("Compact mode")
                                    .font(.headline)
                            }
                            .onChange(of: isCompactMode) { oldValue, newValue in
                                UserDefaults.standard.isCompactMode = newValue
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                        
                        // Clear cache
                        HStack {
                            Toggle(isOn: $isNeedToClearCache) {
                                Text("Clear cache after restart")
                                    .font(.headline)
                            }
                            .onChange(of: isNeedToClearCache) { oldValue, newValue in
                                UserDefaults.standard.isNeedToClearCache = newValue
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                        
                        // Refresh interval menu
                        HStack {
                            Text("Refresh interval")
                                .font(.headline)
                            
                            Spacer()
                            
                            Menu {
                                Button("5 seconds") {
                                    setRefreshInterval(5)
                                }
                                
                                Button("10 seconds") {
                                    setRefreshInterval(10)
                                }
                                
                                Button("30 seconds") {
                                    setRefreshInterval(30)
                                }
                                
                                Button("60 seconds") {
                                    setRefreshInterval(60)
                                }
                                
                                Button("600 seconds") {
                                    setRefreshInterval(600)
                                }
                            } label: {
                                Text("\(refreshInterval) seconds")
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.05))
                        .cornerRadius(8)
                    } header: {
                        Text("Other")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    // Sources section
                    Section {
                        ForEach(SourceManager.shared.allSources(), id: \.name) { source in
                            HStack {
                                Toggle(isOn: Binding<Bool>(get: { source.isEnabled },
                                                           set: { newValue in
                                    source.toggle()
                                })) {
                                    Text(source.name)
                                        .font(.headline)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.05))
                            .cornerRadius(8)
                        }
                    } header: {
                        Text("Sources")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresentingModalSettings = false
                    } label: {
                        Label("", systemImage: "xmark.circle.fill")
                    }
                }
            }
        }
        .onDisappear {
            onDismiss?()
        }
    }
    
}

// MARK: - Actions
private extension SettingsView {
    
    func setRefreshInterval(_ interval: Int) {
        refreshInterval = interval
        UserDefaults.standard.refreshInterval = interval
    }
    
}
