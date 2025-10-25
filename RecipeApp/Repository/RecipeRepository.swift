//
//  RecipeRepository.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation

// Protocol for fetching recipes from the network
public protocol RecipeRepository {
    func fetchRecipes() async throws -> [Recipe]
    func fetchRecipeDetails(id: Int) async throws -> Recipe 
    func searchRecipes(query: String) async throws -> [Recipe]
}
