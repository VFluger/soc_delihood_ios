//
//  HomeView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 13.08.2025.
//

import SwiftUI
struct HomeView: View {
    @EnvironmentObject var authStore: AuthStore
    @StateObject var vm = HomeViewModel()
    
    @StateObject var locationManager = LocationManager()
    
    private var userLat: Double? {
        locationManager.lastLocation?.coordinate.latitude
    }
    
    private var userLng: Double? {
        locationManager.lastLocation?.coordinate.longitude
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        //If alert, show error view
                        if vm.isError == false {
                            ForEach(vm.mainScreenData ?? []) { cook in
                                CookListView(cook: cook,
                                             selectedFilter: $vm.selectedFilter,
                                             searchText: $vm.searchText)
                            }
                            Color.clear
                                    .frame(height: 200)
                        } else {
                            ErrorView()
                        }
                    }
                }
                .refreshable {
                    vm.getData(lat: userLat, lng: userLng)
                }
                Spacer()
            }
            .navigationTitle(!vm.isError ? "Home" : "Error")
            //Settings icon
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        vm.showAccount = true
                    } label: {
                        CustomRemoteImage(UrlString: "http://localhost:8080/api/pfp?userId=\(authStore.user?.id)") {
                            Image(systemName: "person")
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    }
                }
            }
            //Open settings
            .navigationDestination(isPresented: $vm.showAccount) {
                AccountView()
            }
            
            // only show overlay when NOT in account
            .overlay {
                if !vm.showAccount {
                    VStack {
                        Spacer()
                        //Search and categorys + finish order btn
                        SearchAndOrderView(selectedFilter: $vm.selectedFilter,
                                           searchText: $vm.searchText, isOrderPresented: $vm.isOrderPresented)
                        .padding()
                        //Fade on the bottom
                        .background(Gradient(colors: [.clear, .black.opacity(0.5)]))
                    }
                }
            }
            .task { vm.getData(lat: userLat, lng: userLng) }
            .sheet(isPresented: $vm.isOrderPresented) {
                OrderFinishView()
            }
            //If order in AppStorage changes, get again (filters the cooks)
            //TODO: MAKE IT FILTER EXISTING DATA - SHOUDLNT CONTACT SERVER ALL THE TIME
            .onChange(of: vm.orderData) {
                            vm.getData(lat: userLat, lng: userLng)
                        }
            .alert(item: $vm.alertItem) { alert in
                Alert(title: Text(alert.title),
                      message: Text(alert.message),
                      dismissButton: .default(Text("Ok")))
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthStore())
}
