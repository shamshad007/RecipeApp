//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import XCTest
@testable import RecipeApp

class MockRecipeRepositorySuccess: RecipeRepository {
    private let testRecipe = Recipe(
        id: 100,
        name: "Test Carbonara",
        ingredients: [], instructions: [], prepTimeMinutes: 20, cookTimeMinutes: 20,
        servings: 4, difficulty: "Medium", cuisine: "Italian", tags: ["Pasta"],
        image: "url", rating: 4.5, reviewCount: 10, mealType: ["Dinner"],
        description: "Delicious test dish.", chefSource: "Test Chef",
        galleryImages: ["img1"], nutritionalInfo: "350kcal", allergenInfo: nil
    )
    
    func fetchRecipes() async throws -> [Recipe] { return [] }
    func searchRecipes(query: String) async throws -> [Recipe] { return [] }
    func fetchRecipeDetails(id: Int) async throws -> Recipe {
        return testRecipe
    }
}

// A mock that guarantees a network error
class MockRecipeRepositoryError: RecipeRepository {
    enum MockError: Error, LocalizedError {
            case failedToFetch
            var errorDescription: String? {
                switch self {
                case .failedToFetch:
                    return "Mock failure: The data fetch failed."
                }
            }
        }
    func fetchRecipes() async throws -> [Recipe] { return [] }
    func searchRecipes(query: String) async throws -> [Recipe] { return [] }
    func fetchRecipeDetails(id: Int) async throws -> Recipe {
            throw MockError.failedToFetch
        }
}

// A mock to control the favorite state
class MockFavoritesRepositoryControl: FavoritesRepository {
    var initialFavoriteState: Bool
    var isFavoriteStore: [Int: Bool] = [:]
    
    init(initialFavoriteState: Bool) {
        self.initialFavoriteState = initialFavoriteState
    }
    
    func fetchFavorites() async -> [Recipe] { return [] }
    func addFavorite(recipe: Recipe) async {
        isFavoriteStore[recipe.id] = true
    }
    func removeFavorite(id: Int) async {
        isFavoriteStore[id] = false
    }
    func isFavorite(id: Int) async -> Bool {
        // Look up in store first, then fall back to initial state for a clean check
        return isFavoriteStore[id] ?? initialFavoriteState
    }
}

// MARK: - RecipeDetailViewModel Tests

final class RecipeDetailViewModelTests: XCTestCase {
    
    let recipeId = 100
    
    // MARK: - Test Fetch Success
    
    @MainActor
    func test_loadDetails_success_shouldSetContentAndRecipe() async throws {
        // ARRANGE
        let mockRecipeRepo = MockRecipeRepositorySuccess()
        let mockFavoritesRepo = MockFavoritesRepositoryControl(initialFavoriteState: false)
        let viewModel = RecipeDetailViewModel(
            recipeId: recipeId,
            recipeRepository: mockRecipeRepo,
            favoritesRepository: mockFavoritesRepo
        )
        
        // ASSERT initial state
        XCTAssertEqual(viewModel.viewState, .loading)
        XCTAssertNil(viewModel.recipe)
        
        // ACT
        await viewModel.loadDetails()
        
        // ASSERT final state
        XCTAssertEqual(viewModel.viewState, .content)
        XCTAssertNotNil(viewModel.recipe)
        XCTAssertEqual(viewModel.recipe?.id, recipeId)
        XCTAssertFalse(viewModel.isFavorite, "Should be false based on initial mock state.")
    }
    
    // MARK: - Test Fetch Failure
    
    @MainActor
    func test_loadDetails_failure_shouldSetErrorState() async throws {
        // ARRANGE
        let mockRecipeRepo = MockRecipeRepositoryError()
        let mockFavoritesRepo = MockFavoritesRepositoryControl(initialFavoriteState: false)
        let viewModel = RecipeDetailViewModel(
            recipeId: recipeId,
            recipeRepository: mockRecipeRepo,
            favoritesRepository: mockFavoritesRepo
        )
        
        // ACT
        await viewModel.loadDetails()
        
        if case .error(let message) = viewModel.viewState {
            XCTAssertTrue(message.contains("Mock failure"), "Error message should reflect the known mock failure.")
        } else {
            XCTFail("ViewState should be in error state.")
        }
        XCTAssertNil(viewModel.recipe)
    }
    
    // MARK: - Test Favorite Toggle
    
    @MainActor
    func test_toggleFavorite_fromFalseToTrueAndBack() async {
        // ARRANGE
        let mockRecipeRepo = MockRecipeRepositorySuccess()
        let mockFavoritesRepo = MockFavoritesRepositoryControl(initialFavoriteState: false)
        let viewModel = RecipeDetailViewModel(
            recipeId: recipeId,
            recipeRepository: mockRecipeRepo,
            favoritesRepository: mockFavoritesRepo
        )
        
        // Load the recipe first
        await viewModel.loadDetails()
        XCTAssertFalse(viewModel.isFavorite, "Precondition: Should not be favorite initially.")
        
        // Toggle ON
        
        // ACT
        await viewModel.toggleFavorite()
        
        // ASSERT
        XCTAssertTrue(viewModel.isFavorite, "ViewModel should reflect favorited state.")
        
        // Assert repository state using the corrected synchronous call
        let repoStateAfterOn = await mockFavoritesRepo.isFavorite(id: recipeId)
        XCTAssertTrue(repoStateAfterOn, "Repository should confirm addition.")
        
        // Toggle OFF 
        
        // ACT
        await viewModel.toggleFavorite()
        
        // ASSERT
        XCTAssertFalse(viewModel.isFavorite, "ViewModel should reflect unfavorited state.")
        
        // Assert repository state
        let repoStateAfterOff = await mockFavoritesRepo.isFavorite(id: recipeId)
        XCTAssertFalse(repoStateAfterOff, "Repository should confirm removal.")
    }
}
