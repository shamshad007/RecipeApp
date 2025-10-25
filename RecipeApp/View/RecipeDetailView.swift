//
//  RecipeDetailView.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 25/10/25.
//

import SwiftUI

public struct RecipeDetailView: View {
    
    @StateObject private var viewModel: RecipeDetailViewModel
    
    public init(viewModel: RecipeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Recipe...")
            case .error(let message):
                VStack {
                    Text("Error").font(.title)
                    Text(message).multilineTextAlignment(.center)
                }
            case .content:
                if let recipe = viewModel.recipe {
                    detailContentView(recipe: recipe)
                } else {
                    Text("Recipe data not available.")
                }
            }
        }
        .task {
            await viewModel.loadDetails()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Bookmark Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.toggleFavorite()
                    }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundColor(viewModel.isFavorite ? .accentColor : .gray)
                }
            }
        }
    }
    
    @ViewBuilder
    private func detailContentView(recipe: Recipe) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                
                // 1. Hero Image
                heroImageView(url: recipe.image)
                
                // Content Wrapper (for padding)
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 2. Title, Description, and Source
                    HeaderSectionView(recipe: recipe)
                    
                    Divider()
                    
                    // 3. Time, Difficulty, and Servings
                    InfoSectionView(recipe: recipe)
                    
                    Divider()
                    
                    // 4. Nutritional Info and Dietary Tags
                    NutritionalAndDietarySectionView(recipe: recipe)
                    
                    Divider()
                    
                    // 5. Complete Ingredients List
                    SectionView(title: "Ingredients", items: recipe.ingredients, icon: "list.bullet.clipboard")
                    
                    Divider()
                    
                    // 6. Step-by-step Instructions
                    InstructionsSectionView(instructions: recipe.instructions)
                    
                    Divider()
                    
                    // 7. User Ratings and Reviews
                    RatingsAndReviewsView(rating: recipe.rating, reviewCount: recipe.reviewCount)
                }
                .padding(.horizontal) // Apply padding to the inner content
            }
        }
    }
}

private struct SectionView: View {
    let title: String
    let items: [String]
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ForEach(items.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 8) {
                    // Check if instructions to show step number
                    if title == "Instructions" {
                        Text("\(index + 1).")
                            .fontWeight(.bold)
                            .frame(width: 20, alignment: .leading)
                    } else {
                        // Use a bullet point for ingredients
                        Image(systemName: "circle.fill")
                            .font(.system(size: 8))
                            .offset(y: 6)
                    }
                    Text(items[index])
                }
                .padding(.leading, title == "Instructions" ? 0 : 15)
            }
        }
        .padding(.horizontal)
    }
}


private struct InfoPill: View {
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .foregroundColor(Color.accentColor)
        .cornerRadius(10)
    }
}

@ViewBuilder
private func heroImageView(url: String) -> some View {
    AsyncImage(url: URL(string: url)) { phase in
        if let image = phase.image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if phase.error != nil {
            Color.gray.opacity(0.3)
                .overlay(Image(systemName: "photo").font(.largeTitle))
        } else {
            ProgressView()
        }
    }
    .frame(height: 250)
    .clipped()
    .listRowInsets(EdgeInsets()) // Crucial for full width in a list/scroll
}

// Title
private struct HeaderSectionView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recipe.name)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

// Cooking time, prep time, and difficulty level
private struct InfoSectionView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Preparation")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 10) {
                InfoPill(value: "\(recipe.prepTimeMinutes) min (Prep)", icon: "hourglass")
                InfoPill(value: "\(recipe.cookTimeMinutes) min (Cook)", icon: "flame")
                InfoPill(value: recipe.difficulty, icon: "chart.bar")
                InfoPill(value: "\(recipe.servings) Servings", icon: "person.2")
            }
        }
    }
}

// Nutritional Info and Dietary Tags
private struct NutritionalAndDietarySectionView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Dietary & Nutrition")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Dietary Tags
            HStack(spacing: 8) {
                ForEach(recipe.tags, id: \.self) { tag in
                    Text(tag)
                        .tagPillStyle(color: .green)
                }
            }
            .padding(.bottom, 5)
        }
    }
}

// Step-by-step Instructions
private struct InstructionsSectionView: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Instructions")
                .font(.title2)
                .fontWeight(.semibold)
            
            ForEach(instructions.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1).")
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    Text(instructions[index])
                }
            }
        }
    }
}

// User Ratings and Reviews
private struct RatingsAndReviewsView: View {
    let rating: Double
    let reviewCount: Int
    
    var body: some View {
        HStack {
            Label(String(format: "%.1f", rating), systemImage: "star.fill")
                .foregroundColor(.yellow)
            Text("(\(reviewCount) reviews)")
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, 20)
    }
}

// Helper View Modifier (Defined once for consistent look)
private extension View {
    func tagPillStyle(color: Color) -> some View {
        self
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(10)
    }
}
