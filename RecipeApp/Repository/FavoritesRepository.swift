//
//  FavoritesRepository.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation

// Protocol for managing local favorites
public protocol FavoritesRepository {
    func addFavorite(recipe: Recipe) async
    func removeFavorite(id: Int) async
    func fetchFavorites() async -> [Recipe]
    func isFavorite(id: Int) async -> Bool
}
