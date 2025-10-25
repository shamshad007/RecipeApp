//
//  FavoritesListView.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import SwiftUI
import SwiftData

public struct FavoritesListView: View {
    // Use SwiftData's @Query to automatically fetch and update
    @Query(sort: \SavedRecipe.name) private var favorites: [SavedRecipe]
    
    // Get the context from the environment
    @Environment(\.modelContext) private var modelContext
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    emptyStateView
                } else {
                    favoritesList
                }
            }
            .navigationTitle("My Favorites")
        }
    }
    
    private var favoritesList: some View {
        List {
            ForEach(favorites) { recipe in
                RecipeRowView(recipe: recipe.toDomainModel())
            }
            .onDelete(perform: deleteFavorite)
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.7))
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.bold)
            Text("Save recipes you love for easy access and quick meal planning.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            modelContext.delete(favorite)
        }
        try? modelContext.save()
    }
}

#Preview {
    FavoritesListView()
}
