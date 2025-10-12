//
//  AccountView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 16.08.2025.
//

import SwiftUI

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
    
    var body: some View {
        HStack {
            CustomRemoteImage(UrlString: "http://localhost:8080/api/pfp?userId=\(user.id)", placeholderView: {
                Image(systemName: "person")
                    .scaleEffect(1.5)
            })
            .frame(width: 100, height: 100)
            .background(.popup)
            .clipShape(Circle())
            .padding(5)
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
    }
}

#Preview {
    AccountView()
        .environmentObject(AuthStore())
}
