//
//  ChangeSettingsView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 17.08.2025.
//

import SwiftUI
import SwiftData


struct ChangeSettingsView: View {
    @EnvironmentObject var authStore: AuthStore
    @Environment(\.modelContext) var context
    
    @Query var locationModels: [Location]
    
    @State var updateSheet: Location? = nil
    @State var addSheet = false
    
    private var usernameBinding: Binding<String> {
        Binding(
            get: { authStore.user?.username ?? "" },
            set: { newValue in authStore.user?.username = newValue }
        )
    }
    private var emailBinding: Binding<String> {
        Binding(
            get: { authStore.user?.email ?? "" },
            set: { newValue in authStore.user?.email = newValue }
        )
    }
    private var phoneBinding: Binding<String> {
        Binding(
            get: { authStore.user?.phone ?? "" },
            set: { newValue in authStore.user?.phone = newValue }
        )
    }
    
    var body: some View {
        List {
            Section(header: Text("Account Info")) {
                NavigationLink {
                    EditFieldView(vm: EditFieldViewModel(title: "Edit name", fieldKey: .name, currentValue: usernameBinding.wrappedValue), currentValue: usernameBinding)
                } label: {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(authStore.user?.username ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }
                NavigationLink {
                    EditFieldView(vm: EditFieldViewModel(title: "Edit email", fieldKey: .email, currentValue: emailBinding.wrappedValue), currentValue: emailBinding)
                } label: {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(authStore.user?.email ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }
                NavigationLink {
                    EditFieldView(vm: EditFieldViewModel(title: "Edit phone", fieldKey: .phone, currentValue: phoneBinding.wrappedValue), currentValue: phoneBinding)
                } label: {
                    HStack {
                        Text("Phone Number")
                        Spacer()
                        Text(authStore.user?.phone.formattedPhone() ?? "-")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Section(header: Text("Profile Picture")) {
                HStack {
                    Text("Profile Picture")
                    Spacer()
                    Group {
                        if let imageUrl = authStore.user?.image_url, !imageUrl.isEmpty {
                            CustomRemoteImage(urlString: "https://localhost:8080/api/pfp?userId=\(authStore.user?.id)") {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                }
            }
            DeliveryAddressesSection(
                locationModels: locationModels,
                updateSheet: $updateSheet,
                addSheet: $addSheet,
                context: context
            )
        }
        .sheet(item: $updateSheet) {location in
            UpdateAddressView(locationModel: location)
                .presentationDetents([.height(600)])
        }
        .sheet(isPresented: $addSheet) {
            AddLocationView()
                .presentationDetents([.height(600)])
        }
        .navigationTitle("Change Settings")
    }
}

struct LocationListView: View {
    var locationModel: Location
    @Binding var updateSheet: Location?
    var body: some View {
        HStack {
            Label(locationModel.address, systemImage: "mappin.circle")
        }
        .onTapGesture {
            updateSheet = locationModel
        }
    }
}


struct DeliveryAddressesSection: View {
    let locationModels: [Location]
    @Binding var updateSheet: Location?
    @Binding var addSheet: Bool
    var context: ModelContext
    
    var body: some View {
        Section(header: Text("Delivery Addresses")) {
            if locationModels.isEmpty {
                HStack {
                    Image(systemName: "truck.box")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    Text("You have no addresses yet. \n Add a new one")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            Button {
                addSheet = true
            } label: {
                Label("Add a new address", systemImage: "plus")
            }
            ForEach(locationModels) { location in
                LocationListView(locationModel: location, updateSheet: $updateSheet)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(locationModels[index])
                }
            }
        }
    }
}
//
//#Preview {
//    let user = User(username: "Jane Doe", email: "jane@example.com", phone: "+123456789", image_url: nil, created_at: "2024-08-17")
//    let authStore = AuthStore()
//    authStore.user = user
//    return NavigationStack { ChangeSettingsView().environmentObject(authStore) }
//}

