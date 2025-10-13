//
//  CookListView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 14.08.2025.
//

import SwiftUI
import RemoteImage

struct CookListView: View {
    let cook: Cook
    @State private var isExpanded = true
    @Binding var selectedFilter: CategoryContext?
    @Binding var searchText: String
    
    //Filtering by search String
    var searchFilteredFoods: [Food] {
        guard searchText != "" else { return cook.foods }
        return cook.foods.filter {
            [$0.name, $0.description, $0.category]
                .contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    //Filtering on the search with the categories
    var filteredFoods: [Food] {
        guard let selectedFilter = selectedFilter else { return searchFilteredFoods }
        return searchFilteredFoods.filter { CategoryContext(rawValue: $0.category) == selectedFilter }
    }
    
    var body: some View {
        if !filteredFoods.isEmpty {
            ZStack(alignment: .top) {
                // The cook card
                VStack(alignment: .leading) {
                    HStack {
                        CustomRemoteImage(urlString: cook.image_url, placeholderView: {
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        })
                        .clipShape(Circle())
                        .frame(width: 30, height: 30)
                        .padding(.leading, 15)
                        .padding(.trailing, 5)
                        NavigationLink(destination: {
                            CookDetailView(cook: cook)
                        }, label: {
                            Text(cook.name)
                                .font(.headline)
                                .minimumScaleFactor(0.5)
                                .foregroundStyle(Color.label)
                        })
                        
                        Spacer()
                        Button {
                            withAnimation(.easeInOut) {
                                isExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.foreground)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .frame(width: 120, alignment: .trailing)
                                .contentShape(Rectangle())
                        }
                    }
                    
                }
                .padding(.top, 20)
                .shadow(radius: 2)
                
                // The expanding foods
                if isExpanded {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredFoods) { food in
                            FoodListView(food: food, cook: cook)
                                .padding(.bottom, 10)
                        }
                    }
                    .padding()
                    .shadow(radius: 2)
                    .offset(y: 50) // starts slightly below the cook card
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(-1) // put it behind the cook card
                }
            }
            .frame(maxWidth: .infinity)
            Spacer()
                .frame(height: 20)
        }
    }
}
#Preview {
    CookListView(cook: MockData.sampleCook, selectedFilter: .constant(nil), searchText: .constant(""))
}
