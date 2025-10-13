//
//  FoodListView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 14.08.2025.
//

import SwiftUI
import RemoteImage

struct FoodListView: View {
    let food: Food
    let cook: Cook
    @State var showDetail: Bool = false
    
    var body: some View {
            HStack {
                FoodListImageView(urlString: food.image_url)
                
                VStack(alignment: .leading) {
                    Text(food.name)
                        .fontWeight(.bold)
                        .padding(.top, 5)
                    
                    Text(food.description)
                        .frame(width: 120, height: 35, alignment: .leading)
                        .font(.footnote)
                        .lineLimit(2)
                        
                    CategoryView(string: food.category)
                    Spacer()
                }
                .frame(height: 80)
                Spacer()
                VStack {
                    Text("\(food.price) Kč")
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding()
            }
            .padding(.vertical, 2)
        
            .onTapGesture {
                showDetail = true
            }
            .sheet(isPresented: $showDetail) {
                NavigationStack {
                    FoodDetailView(vm: FoodDetailViewModel(food: food, cook: cook))
                }
            }
        }
}

struct FoodListImageView: View {
    let urlString: String
    
    var body: some View {
        CustomRemoteImage(urlString: urlString, placeholderView: {
            Image("food-placeholder")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.primary)
                .frame(width: 50)
        })
        .frame(width: 100, height: 100)
        .background(.popup)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal, 10)
    }
}

#Preview {
    FoodListView(food: Food(id: 1, name: "Pizza", description: "Pizza na pile asdf asdf asdf afd asdf", category: "italien", price: 100, image_url: "https://www.abeautifulplate.com/wp-content/uploadasdfs/2015/08/the-best-homemade-margherita-pizza-1-4.jpg"), cook: MockData.sampleCook)
}

