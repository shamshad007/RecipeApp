//
//  FavoritesRepositoryImpl.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation
import SwiftData

public class FavoritesRepositoryImpl: FavoritesRepository {
    private let modelContainer: ModelContainer
    
    @MainActor
    private var modelContext: ModelContext {
        modelContainer.mainContext
    }

    @MainActor
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    //Add Favorite
    public func addFavorite(recipe: Recipe) async {
        let savedRecipe = SavedRecipe(from: recipe)
        await MainActor.run {
            modelContext.insert(savedRecipe)
            try? modelContext.save()
        }
    }

    //Remove Favorite
    public func removeFavorite(id: Int) async {
        let predicate = #Predicate<SavedRecipe> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        await MainActor.run {
            if let objectsToDelete = try? modelContext.fetch(descriptor) {
                for object in objectsToDelete {
                    modelContext.delete(object)
                }
                try? modelContext.save()
            }
        }
    }

    //Fetch Favorite
    public func fetchFavorites() async -> [Recipe] {
        let descriptor = FetchDescriptor<SavedRecipe>()
        
        return await MainActor.run {
            guard let saved = try? modelContext.fetch(descriptor) else {
                return []
            }
            return saved.map { $0.toDomainModel() }
        }
    }

    public func isFavorite(id: Int) async -> Bool {
        let predicate = #Predicate<SavedRecipe> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        return await MainActor.run {
            guard let count = try? modelContext.fetchCount(descriptor) else {
                return false
            }
            return count > 0
        }
    }
}
