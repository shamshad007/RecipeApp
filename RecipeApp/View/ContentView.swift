//
//  ContentView.swift
//  RecipeApp
//
//  Created by Md Shamshad Akhtar on 24/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var recipeListViewModel: RecipeListViewModel
    
    var body: some View {
        TabView {
            RecipeListView(viewModel: recipeListViewModel)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
            
            FavoritesListView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
    }
}

