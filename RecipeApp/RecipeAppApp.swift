//
//  RecipeAppApp.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import SwiftUI
import SwiftData

@main
struct RecipeAppApp: App {
    
    private let modelContainer: ModelContainer
    let recipeRepository: any RecipeRepository
    let favoritesRepository: any FavoritesRepository
    let recipeListViewModel: RecipeListViewModel
    
    init() {
        do {
            self.modelContainer = try ModelContainer(for: SavedRecipe.self)
        } catch {
            fatalError("Failed to initialize SwiftData Container: \(error)")
        }
        
        self.recipeRepository = RecipeRepositoryImpl()
        self.favoritesRepository = FavoritesRepositoryImpl(modelContainer: self.modelContainer)
        
        DefaultAppServiceLocator.shared.setRepositories(
            recipe: recipeRepository,
            favorites: favoritesRepository
        )
        
        self.recipeListViewModel = RecipeListViewModel(recipeRepository: self.recipeRepository)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(recipeListViewModel: recipeListViewModel)
                .modelContainer(modelContainer)
        }
    }
}
