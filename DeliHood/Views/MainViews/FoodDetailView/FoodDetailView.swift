//
//  FoodDetailView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 16.08.2025.
//

import SwiftUI

struct FoodDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: FoodDetailViewModel
    
    @State var quantity: Int = 1
    
    var body: some View {
        ScrollView {
            VStack {
                CustomRemoteImage(urlString: vm.food.image_url) {
                        Image("food-placeholder")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.primary)
                            .scaledToFit()
                            .frame(width: 70, height: 200)
                            .offset(y: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(.popup)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding(.horizontal, 5)
                Text(vm.food.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                HStack {
                    CategoryView(string: vm.food.category)
                        .scaleEffect(1.2)
                        .foregroundStyle(.brand)
                    Text("•")
                        .font(.title)
                        .offset(x: 10)
                    HStack {
                        CustomRemoteImage(urlString: vm.cook.image_url) {
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        
                        NavigationLink(destination: {
                            CookDetailView(cook: vm.cook)
                        }, label: {
                            Text(vm.cook.name)
                                .minimumScaleFactor(0.5)
                                .padding(.horizontal, 5)
                                .foregroundStyle(Color.label)
                        })
                    }
                    .padding(5)
                    .background(.popup)
                    .clipShape(Capsule())
                }
            }
            // Options
            VStack(alignment: .leading) {
                Text("Description:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                
                Text(vm.food.description)
                    .padding(10)
                    .padding(.horizontal, 15)
                
                Text("Options:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 10)
                VStack(alignment: .leading, spacing: 10) {
                    CheckboxView(isChecked: $vm.isExtraNapkins, text: "Extra napkins")
                    CheckboxView(isChecked: $vm.isExtraSalt, text: "Extra salty")
                    CheckboxView(isChecked: $vm.isGlutenFree, text: "Gluten-free")
                }
                .font(.headline)
                .fontWeight(.medium)
                .padding(.horizontal)
                VStack(alignment: .leading) {
                    Text("Notes: ")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ZStack(alignment: .topLeading) {
                        if vm.notes.isEmpty {
                            Text("eg. no olives, vegan or extra spicy")
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 15)
                                .zIndex(1)
                        }
                        
                        TextEditor(text: $vm.notes)
                            .frame(height: 120)
                            .padding(8)
                            .background(.popup)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                }.padding()
            }
        }
        .alert(item: $vm.alertItem) {alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
        //Add to order btn, favorite and share
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if vm.itemQuantity != nil {
                    QuantityBtn(
                        quantity: Binding(
                            get: { vm.itemQuantity ?? 1 },
                            set: { vm.itemQuantity = $0 }
                        )) {quantity in
                            vm.addToOrder(quantity: quantity) { dismiss() }
                        }
            }else {
                    Button {
                        vm.addToOrder(quantity: quantity) { dismiss() }
                    }label: {
                        
                        BrandBtn(text: "Order • \(vm.food.price) Kč", width: 200)
                    }
                }
            }
            .sharedBackgroundVisibility(.hidden)
            ToolbarSpacer(.flexible, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    // Add to favorites
                }label: {
                    Image(systemName: "star")
                }
                .padding(2)
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    
                }label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .padding(2)
            }
        }
        .blur(radius: vm.showSuccess ? 5 : 0)
        .overlay {
            if vm.showSuccess {
                FoodAddedToOrderView()
            }
        }
        .onAppear {
            if let quantity = vm.checkQuantity() {
                vm.itemQuantity = quantity
            }
        }
    }
}

#Preview {
    FoodDetailView(vm: FoodDetailViewModel(food: MockData.sampleCook.foods[0], cook: MockData.sampleCook))
}
