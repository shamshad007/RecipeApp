//
//  MockRecipeRepository.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 25/10/25.
//

import Foundation

public final class MockRecipeRepository: RecipeRepository {
    public func fetchRecipes() async throws -> [Recipe] {
        return []
    }
    
    public func fetchRecipeDetails(id: Int) async throws -> Recipe {
        // Return a basic, safe Recipe instance or throw an error
        throw NSError(domain: "MockError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Mock not configured to fetch data."])
    }
    
    public func searchRecipes(query: String) async throws -> [Recipe] {
        return []
    }
    
    public init() {}
}

public final class MockFavoritesRepository: FavoritesRepository {
    public func fetchFavorites() async -> [Recipe] {
        return []
    }
    
    public func addFavorite(recipe: Recipe) async {}
    
    public func removeFavorite(id: Int) async {}
    
    public func isFavorite(id: Int) async -> Bool {
        return false
    }
    
    public init() {}
}
