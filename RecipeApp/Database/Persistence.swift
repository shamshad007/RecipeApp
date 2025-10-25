//
//  Persistence.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation
import SwiftData

// SwiftData Model for persistence
@Model
public final class SavedRecipe {
    @Attribute(.unique) public var id: Int
    public var name: String
    public var image: String
    public var cookTimeMinutes: Int
    public var difficulty: String
    public var rating: Double
    public var servings: Int
    
    public init(id: Int, name: String, image: String, cookTimeMinutes: Int, difficulty: String, rating: Double, servings: Int) {
        self.id = id
        self.name = name
        self.image = image
        self.cookTimeMinutes = cookTimeMinutes
        self.difficulty = difficulty
        self.rating = rating
        self.servings = servings
    }

    public convenience init(from recipe: Recipe) {
        self.init(
            id: recipe.id,
            name: recipe.name,
            image: recipe.image,
            cookTimeMinutes: recipe.cookTimeMinutes,
            difficulty: recipe.difficulty,
            rating: recipe.rating,
            servings: recipe.servings
        )
    }
    
    public func toDomainModel() -> Recipe {
        return Recipe(
            id: self.id,
            name: self.name,
            ingredients: [],
            instructions: [],
            prepTimeMinutes: 0,
            cookTimeMinutes: self.cookTimeMinutes,
            servings: self.servings,
            difficulty: self.difficulty,
            cuisine: "",
            tags: [],
            image: self.image,
            rating: self.rating,
            reviewCount: 0,
            mealType: []
        )
    }
}
