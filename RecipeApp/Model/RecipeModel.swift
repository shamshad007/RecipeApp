//
//  RecipeModel.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation

public struct RecipeResponse: Codable {
    public let recipes: [Recipe]
    public let total, skip, limit: Int
}

public struct Recipe: Codable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let ingredients: [String]
    public let instructions: [String]
    public let prepTimeMinutes: Int
    public let cookTimeMinutes: Int
    public let servings: Int
    public let difficulty: String
    public let cuisine: String
    public let tags: [String]
    public let image: String
    public let rating: Double
    public let reviewCount: Int
    public let mealType: [String]
    public var totalTime: Int {
        prepTimeMinutes + cookTimeMinutes
    }
    
    public init(id: Int, name: String, ingredients: [String], instructions: [String], prepTimeMinutes: Int, cookTimeMinutes: Int, servings: Int, difficulty: String, cuisine: String, tags: [String], image: String, rating: Double, reviewCount: Int, mealType: [String], description: String? = nil, chefSource: String? = nil, galleryImages: [String] = [], nutritionalInfo: String = "", allergenInfo: String? = nil) {
            self.id = id
            self.name = name
            self.ingredients = ingredients
            self.instructions = instructions
            self.prepTimeMinutes = prepTimeMinutes
            self.cookTimeMinutes = cookTimeMinutes
            self.servings = servings
            self.difficulty = difficulty
            self.cuisine = cuisine
            self.tags = tags
            self.image = image
            self.rating = rating
            self.reviewCount = reviewCount
            self.mealType = mealType
        }
}
