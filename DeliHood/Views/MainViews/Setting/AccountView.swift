//
//  AccountView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 16.08.2025.
//

import SwiftUI
import PhotosUI

struct AccountView: View {
    @EnvironmentObject var authStore: AuthStore
    
    @State private var showLogoutAlert = false
    
    var body: some View {
        //Shouldn't really happen but just to be sure
        if authStore.user == nil {
            ContentUnavailableView("Cannot get Account", systemImage: "xmark.app", description: Text("Please refresh the app"))
        }else {
            List {
                Section {
                    AccountInfoView(user: authStore.user!)
                }
                
                //Order section
                Section {
                    NavigationLink(destination: OrderHistoryView()) {
                        Label("Order history", systemImage: "receipt")
                    }
                    
                }
                
                //Main settings
                Section {
                    ForEach(AccountSetting.allCases) {setting in
                        NavigationLink(destination: setting.destination) {
                            Label(setting.label, systemImage: setting.icon)
                        }
                    }
                }
                
                //Log out section
                Section {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                        .onTapGesture {
                            showLogoutAlert = true
                        }
                }
            }
            .navigationTitle("Account")
            //Confirm for logging out
            .alert(isPresented: $showLogoutAlert) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out? You will need to sign in again to use your account."),
                    primaryButton: .destructive(Text("Log out")) {
                        Task {
                            let isLoggedOut = await AuthManager.shared.logout()
                            guard isLoggedOut else {return}
                            authStore.appState = .loggedOut
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct AccountInfoView: View {
    let user: User
    
    @State private var photoItem: PhotosPickerItem?
    @State private var image: Image?
    @State private var imageData: Data?
    @State private var alertItem: AlertItem?
    
    var body: some View {
        HStack {
            PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack {
                if let image {
                    image
                        .resizable()
                }else {
                    CustomRemoteImage(urlString: "\(NetworkManager.shared.baseURL)/api/pfp?userId=\(user.id)", placeholderView: {
                        Image(systemName: "person")
                            .scaleEffect(1.5)
                    })
                    .frame(width: 100, height: 100)
                    .background(.popup)
                    .clipShape(Circle())
                    .padding(5)
                }
                VStack {
                    Spacer()
                        .frame(height: 70)
                    HStack {
                        Spacer()
                            .frame(width: 70)
                        Image(systemName: "pencil")
                            .padding(7)
                            .glassEffect(.regular.tint(.brand.opacity(0.7)).interactive())
                    }
                }
            }
            }
                .onChange(of: photoItem) {oldValue, newValue in
                    Task {
                        do {
                            image = try await photoItem?.loadTransferable(type: Image.self)
                            imageData = try await photoItem?.loadTransferable(type: Data.self)
                            try await NetworkManager.shared.uploadPfp(imageData ?? Data())
                        }catch {
                            print(error.localizedDescription)
                            alertItem = AlertContext.cannotUploadImage
                        }
                    }
                }
                .foregroundStyle(Color.label)
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                Label(user.phone.formattedPhone(), systemImage: "phone")
                    .padding(.bottom, 5)
                Label(user.email, systemImage: "envelope")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.5)
            }
            .padding(.vertical)
        }
        .alert(item: $alertItem) {alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
    }
}

#Preview {
    AccountInfoView(user: User(id: 1, username: "Vojtech Fluger", email: "vojtech.fluger@gmail.com", phone: "746543455", image_url: nil, created_at: "2025"))
        .environmentObject(AuthStore())
}
