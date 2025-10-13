//
//  CookDetailView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 15.08.2025.
//

import SwiftUI

struct CookDetailView: View {
    var cook: Cook
    @State private var isBadgesSheetPresented = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                //Card
                HStack {
                    CustomRemoteImage(urlString: cook.image_url) {
                        Image(systemName: "person.fill")
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(cook.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                        
                        Label("Olomouc", systemImage: "mappin.circle")
                            .padding(.vertical, 5)
                        
                        //Badges
                        HStack {
                            Image(systemName: "flame")
                                .foregroundStyle(.accentred)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.accentblue)
                            
                        }
                        .onTapGesture {
                            isBadgesSheetPresented.toggle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    Spacer()
                }
                .padding()
                VStack(alignment: .leading) {
                    Text("Description:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 10)
                    Text(cook.description)
                        .padding(.horizontal, 10)
                    Text("Foods: ")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                    ForEach(cook.foods) {food in
                        FoodListView(food: food, cook: cook)
                            .padding(.bottom)
                    }
                }
                
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
        }
        .sheet(isPresented: $isBadgesSheetPresented) {
            BadgesSheetView()
                .presentationDetents([.height(400)])
        }
        
            
    }
}

#Preview {
    CookDetailView(cook: MockData.sampleCook)

}
