//
//  RecipeListViewModel.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import Foundation
import Combine

@MainActor
public class RecipeListViewModel: ObservableObject {
    private let recipeRepository: RecipeRepository
    
    //State
    @Published public var allRecipes: [Recipe] = []
    @Published public var filteredRecipes: [Recipe] = []
    @Published public var searchText: String = ""
    @Published public var viewState: ViewState = .loading
    @Published public var currentSort: SortOption = .name
    
    //Filter State
    @Published public var allTags: [String] = []
    @Published public var selectedTags: Set<String> = []
    
    public enum ViewState {
        case loading
        case content
        case error(String)
        case empty
    }
    
    public enum SortOption {
        case name, time, rating, difficulty
    }
    
    private var cancellables = Set<AnyCancellable>()

    public init(recipeRepository: RecipeRepository) {
        self.recipeRepository = recipeRepository
        let searchPublisher = $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            
        let filterPublisher = $selectedTags
            .removeDuplicates()
            
        Publishers.CombineLatest(searchPublisher, filterPublisher)
            .sink { [weak self] (searchText, selectedTags) in
                self?.filterAndSortRecipes(searchText: searchText, tags: selectedTags)
            }
            .store(in: &cancellables)
    }

    public func onAppear() async {
        guard allRecipes.isEmpty else { return }
        await fetchRecipes()
    }
    
    public func fetchRecipes() async {
        viewState = .loading
        do {
            let recipes = try await recipeRepository.fetchRecipes()
            self.allRecipes = recipes
            
            //Extract all unique tags
            let uniqueTags = Set(recipes.flatMap { $0.tags })
            self.allTags = Array(uniqueTags).sorted()
            
            self.filterAndSortRecipes(searchText: self.searchText, tags: self.selectedTags)
            self.viewState = recipes.isEmpty ? .empty : .content
        } catch {
            self.viewState = .error(error.localizedDescription)
        }
    }
    
    public func sort(by option: SortOption) {
        self.currentSort = option
        filterAndSortRecipes(searchText: self.searchText, tags: self.selectedTags)
    }
    
    //Function to toggle a filter
    public func toggleTagSelection(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
    
    //filterAndSortRecipes
    private func filterAndSortRecipes(searchText: String, tags: Set<String>) {
        var filtered: [Recipe] = allRecipes
        
        //Filter by Search Text
        if !searchText.isEmpty {
            let lowercasedQuery = searchText.lowercased()
            filtered = filtered.filter {
                $0.name.lowercased().contains(lowercasedQuery) ||
                $0.ingredients.contains { $0.lowercased().contains(lowercasedQuery) }
            }
        }
        
        //Filter by Tags ---
        if !tags.isEmpty {
            filtered = filtered.filter { recipe in
                // The recipe must contain ALL selected tags
                tags.isSubset(of: Set(recipe.tags))
            }
        }
        
        // Sort (Sorting cases remain the same)
        switch currentSort {
        case .name:
            filteredRecipes = filtered.sorted { $0.name < $1.name }
        case .time:
            filteredRecipes = filtered.sorted { $0.totalTime < $1.totalTime }
        case .rating:
            filteredRecipes = filtered.sorted { $0.rating > $1.rating }
        case .difficulty:
            let difficultyOrder: [String: Int] = ["Easy": 1, "Medium": 2, "Hard": 3]
            filteredRecipes = filtered.sorted {
                (difficultyOrder[$0.difficulty] ?? 4) < (difficultyOrder[$1.difficulty] ?? 4)
            }
        }
        
        // Update view state
        if filteredRecipes.isEmpty && !allRecipes.isEmpty {
            viewState = .empty
        } else if !allRecipes.isEmpty {
            viewState = .content
        }
    }
}
