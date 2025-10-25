//
//  RecipeDetailViewModel.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 25/10/25.
//

import Foundation
import Combine

@MainActor
public class RecipeDetailViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let recipeRepository: RecipeRepository
    private let favoritesRepository: FavoritesRepository
    private let recipeId: Int
    
    // MARK: - State
    @Published public var recipe: Recipe?
    @Published public var viewState: ViewState = .loading
    @Published public var isFavorite: Bool = false
    
    public enum ViewState: Equatable {
            case loading
            case content
            case error(String)
            
            public static func == (lhs: RecipeDetailViewModel.ViewState, rhs: RecipeDetailViewModel.ViewState) -> Bool {
                switch (lhs, rhs) {
                case (.loading, .loading):
                    return true
                case (.content, .content):
                    return true
                case (.error, .error):
                    return true
                default:
                    return false
                }
            }
        }

    public init(recipeId: Int, recipeRepository: RecipeRepository, favoritesRepository: FavoritesRepository) {
        self.recipeId = recipeId
        self.recipeRepository = recipeRepository
        self.favoritesRepository = favoritesRepository
    }

    public func loadDetails() async {
        viewState = .loading
        
        //Fetch the recipe details
        do {
            let fetchedRecipe = try await recipeRepository.fetchRecipeDetails(id: recipeId)
            self.recipe = fetchedRecipe
            
            //Check favorite status immediately after fetching
            self.isFavorite = await favoritesRepository.isFavorite(id: recipeId)
            
            viewState = .content
        } catch {
            viewState = .error("Failed to load recipe details. \(error.localizedDescription)")
        }
    }
    
    public func toggleFavorite() async {
        guard let recipe = self.recipe else { return }
        
        if isFavorite {
            // Remove from favorites
            await favoritesRepository.removeFavorite(id: recipe.id)
            self.isFavorite = false
        } else {
            // Add to favorites
            await favoritesRepository.addFavorite(recipe: recipe)
            self.isFavorite = true
        }
    }
}
