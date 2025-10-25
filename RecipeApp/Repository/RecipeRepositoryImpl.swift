//
//  RecipeRepositoryImpl.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation

public class RecipeRepositoryImpl: RecipeRepository {
    
    private let baseURL = "https://dummyjson.com/recipes"
    
    public init() {}

    //Fetch Recipe
    public func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    //Fetch Recipe Details by id
    public func fetchRecipeDetails(id: Int) async throws -> Recipe {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Recipe.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    //Search Recipe
    public func searchRecipes(query: String) async throws -> [Recipe] {
        var components = URLComponents(string: "\(baseURL)/search")
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    // Function to avoid repetition
    private func performRequest(url: URL) async throws -> [Recipe] {
        let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(RecipeResponse.self, from: data)
            return response.recipes
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Errors
public enum NetworkError: Error {
    case invalidURL
    case serverError
    case decodingError(Error)
    case unknown
}
