//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import SwiftUI
import SwiftData

public struct RecipeListView: View {
    
    @StateObject private var viewModel: RecipeListViewModel
    
    public init(viewModel: RecipeListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Recipes")
                .searchable(text: $viewModel.searchText, prompt: "Search recipes or ingredients")
                .toolbar {
                    // Group items
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        filterMenu
                        sortMenu
                    }
                }
                .task {
                    await viewModel.onAppear()
                }
        }
    }
    
    @ViewBuilder
        private var contentView: some View {
            switch viewModel.viewState {
            case .loading:
                ProgressView("Loading Recipes...")
                    .controlSize(.large)
            case .content:
                recipeList
            case .empty:
                Text("No recipes found.")
                    .font(.headline)
                    .foregroundColor(.secondary)
            case .error(let message):
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Error: \(message)")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    
    private var recipeList: some View {
        List(viewModel.filteredRecipes) { recipe in
            NavigationLink(value: recipe) {
                // This row will now show tags
                RecipeRowView(recipe: recipe)
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Recipe.self) { recipe in
            let locator = DefaultAppServiceLocator.shared
            
            RecipeDetailView(viewModel: RecipeDetailViewModel(
                recipeId: recipe.id,
                recipeRepository: locator.recipeRepository,
                favoritesRepository: locator.favoritesRepository
            ))
        }
    }

    private var sortMenu: some View {
        Menu {
            Picker("Sort By", selection: $viewModel.currentSort) {
                Text("Name").tag(RecipeListViewModel.SortOption.name)
                Text("Time").tag(RecipeListViewModel.SortOption.time)
                Text("Rating").tag(RecipeListViewModel.SortOption.rating)
                Text("Difficulty").tag(RecipeListViewModel.SortOption.difficulty)
            }
            .onChange(of: viewModel.currentSort) { oldValue, newValue in
                viewModel.sort(by: newValue)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
    }
    
    // Filter Menu
    @ViewBuilder
    private var filterMenu: some View {
        // Only show if there are tags
        if !viewModel.allTags.isEmpty {
            Menu {
                Text("Filter by Tag").font(.headline)
                
                // Button to clear all filters
                if !viewModel.selectedTags.isEmpty {
                    Button(role: .destructive) {
                        viewModel.selectedTags.removeAll()
                    } label: {
                        Label("Clear Filters", systemImage: "xmark.circle")
                    }
                    Divider()
                }
                
                // List of selectable tags
                ForEach(viewModel.allTags, id: \.self) { tag in
                    Button {
                        viewModel.toggleTagSelection(tag)
                    } label: {
                        let isSelected = viewModel.selectedTags.contains(tag)
                        Label(tag, systemImage: isSelected ? "checkmark.circle.fill" : "circle")
                    }
                }
            } label: {
                // Add a badge to the icon
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .overlay(
                        Text("\(viewModel.selectedTags.count)")
                            .font(.system(size: 10))
                            .fontWeight(.bold)
                            .padding(4)
                            .background(viewModel.selectedTags.isEmpty ? Color.clear : Color.red)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .offset(x: 10, y: -10)
                            .opacity(viewModel.selectedTags.isEmpty ? 0 : 1)
                            .animation(.default, value: viewModel.selectedTags.count)
                    )
            }
        }
    }
}

// Reusable Row View
struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 15) {
            // Use AsyncImage for network loading and caching
            AsyncImage(url: URL(string: recipe.image)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: "photo") // Placeholder on error
                        .foregroundColor(.gray)
                } else {
                    ProgressView() // Placeholder while loading
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Label("\(recipe.totalTime) min", systemImage: "clock")
                    Text("•")
                    Label(recipe.difficulty, systemImage: "chart.bar")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                HStack {
                    Label(String(format: "%.1f", recipe.rating), systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Text("•")
                    Label("\(recipe.servings) servings", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if !recipe.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(recipe.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color.accentColor.opacity(0.1))
                                    .foregroundColor(Color.accentColor)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 25) // Constrain the tag row height
                }
            }
        }
        .padding(.vertical, 8)
    }
}


