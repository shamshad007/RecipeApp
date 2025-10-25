//
//  ServiceLocator.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 25/10/25.
//

import Foundation

final class DefaultAppServiceLocator {
    
    static let shared = DefaultAppServiceLocator()
    
    private(set) var recipeRepository: any RecipeRepository
    private(set) var favoritesRepository: any FavoritesRepository
    
    private init() {
        self.recipeRepository = MockRecipeRepository()
        self.favoritesRepository = MockFavoritesRepository()
    }
    
    func setRepositories(recipe: any RecipeRepository, favorites: any FavoritesRepository) {
        self.recipeRepository = recipe
        self.favoritesRepository = favorites
    }
}
