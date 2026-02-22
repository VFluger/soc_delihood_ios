//
//  OrderView.swift
//  DeliHood
//
//  Created by Vojta Fluger on 21.08.2025.
//

import SwiftUI
import Lottie

import MapKit

private struct DriverAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct OrderView: View {
    @EnvironmentObject var orderStore: OrderStore
    @EnvironmentObject var authStore: AuthStore

    @State private var showSettings = false
    @State private var alertItem: AlertItem?
    @State private var driverLocation: MKMapPoint? = nil
    @State private var mapRegion: MKCoordinateRegion? = nil
    
    @State var liveActivityVm = LiveActivityViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                switch orderStore.currentOrder?.status {
                case .paid:
                    OrderInfoView(title: "Waiting for your cook to accept your order.",
                                  description: "The payment was successful and now we're waiting for the cook to accept.",
                                  lottieName: "clock-animation")
                case .accepted:
                    OrderInfoView(title: "Your order is being prepared...",
                                  description: "The cook is making your order right now. You will receive a notification once it's ready!",
                                  lottieName: "cooking-animation")
                    
                case .waitingForPickup:
                    OrderInfoView(title: "Food ready, waiting for driver!",
                                  description: "The food is hot n ready! Waiting for the driver to pickup your order.",
                                  lottieName: "waiting-for-pickup-animation")
                case .delivering:
                    OrderInfoView(title: "The food is on the way!",
                                  description: "Driver is already on the way to deliver your order. They'll call you when it's there.",
                                  lottieName: "delivering-animation")
                    if let driverLocation {
                        let coord = driverLocation.coordinate
                        let region = MKCoordinateRegion(center: coord,
                                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        let annotations = [DriverAnnotation(coordinate: coord)]
                        Map(coordinateRegion: Binding(get: {
                            mapRegion ?? region
                        }, set: { newValue in
                            mapRegion = newValue
                        }), annotationItems: annotations) { item in
                            MapMarker(coordinate: item.coordinate)
                        }
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                case .delivered:
                    OrderInfoView(title: "Done! Your order is at your doorstep.",
                                  description: "Come pickup your delicious meal and bon appetit!",
                                  lottieName: "delivered-animation")
                case .cancelled:
                    OrderInfoView(title: "Oops, your order has been cancelled...",
                                  description: "The order has been cancelled, please contact support if this was a mistake.",
                                  lottieName: "cancelled-animation")
                case nil:
                    ContentUnavailableView("No order status",
                                           systemImage: "xmark.app",
                                           description: Text("We were unable to get your order status, please try to restart the app."))
                //No other statuses should happen
                default:
                    EmptyView()
                }
            
            }
            .refreshable {
                Task {
                    try await orderStore.updateStatus()
                }
            }
            .task {
                if let order = orderStore.currentOrder {
                    //Update variables in vm
                    liveActivityVm.orderId = order.serverId ?? -1
                    liveActivityVm.orderStatus = order.status.rawValue
                    
                    //If live activity exists, update it
                    if liveActivityVm.orderActivity != nil {
                        liveActivityVm.updateLiveActivity()
                    //If not create it
                    }else {
                        liveActivityVm.startLiveActivity()
                    }
                }
            }
            .onAppear {
                // Ensure socket is connected
                AppSocketManager.shared.connect()

                AppSocketManager.shared.onOrderAccepted = { [weak orderStore] _ in
                    DispatchQueue.main.async {
                        orderStore?.currentOrder?.status = .accepted
                    }
                }

                AppSocketManager.shared.onOrderReady = { [weak orderStore] _ in
                    DispatchQueue.main.async {
                        orderStore?.currentOrder?.status = .waitingForPickup
                    }
                }

                AppSocketManager.shared.onFoodPickup = { [weak orderStore] _ in
                    DispatchQueue.main.async {
                        orderStore?.currentOrder?.status = .delivering
                    }
                }

                AppSocketManager.shared.onDropoffReady = { [weak orderStore] _ in
                    DispatchQueue.main.async {
                        orderStore?.currentOrder?.status = .dropoffReady
                    }
                }

                AppSocketManager.shared.onDriverLocation = { [weak self] payload in
                    guard let self = self else { return }
                    // Expecting { locationLat, locationLng, orderId }
                    if let dict = payload as? [String: Any] {
                        let lat = dict["locationLat"] as? Double
                        let lng = dict["locationLng"] as? Double
                        if let lat = lat, let lng = lng {
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            let point = MKMapPoint(coordinate)
                            DispatchQueue.main.async {
                                self.driverLocation = point
                            }
                        }
                    }
                }
            }
            .onDisappear {
                // Clear callbacks to avoid retain cycles / duplicate handlers
                AppSocketManager.shared.onOrderAccepted = nil
                AppSocketManager.shared.onOrderReady = nil
                AppSocketManager.shared.onFoodPickup = nil
                AppSocketManager.shared.onDropoffReady = nil
                AppSocketManager.shared.onDriverLocation = nil
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AccountView()) {
                        CustomRemoteImage(urlString: authStore.user?.image_url) {
                            Image(systemName: "person")
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    }
                }
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        alertItem = AlertContext.getSupport
                    } label: {
                        Image(systemName: "questionmark.message.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color.label)
                            .frame(width: 20, height: 20)
                            .padding()
                    }
                }
            }
            .alert(item: $alertItem) {alert in
                Alert(title: Text(alert.title), message: Text(alert.message))
            }
            .navigationTitle("Current order")
        }
    }
}

struct OrderInfoView: View {
    var title: String
    var description: String
    var lottieName: String? = nil
    var imageName: String? = nil
    
    var body: some View {
        VStack {
            if lottieName != nil {
                Spacer()
                    .frame(height: 70)
                LottieView(animation: .asset(lottieName!))
                    .looping()
                    .frame(width: 200, height: 200)
                Spacer()
                    .frame(height: 50)
                Text(title)
                    .font(.title2.bold())
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Spacer()
                    .frame(height: 10)
                Text(description)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                
            }else if imageName != nil {
                Spacer()
                    .frame(height: 70)
                Image(imageName!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
                    .frame(height: 50)
                Text(title)
                    .font(.title2.bold())
                    .padding(.horizontal)
                Spacer()
                    .frame(height: 10)
                Text(description)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        }
    }
}
//
//#Preview {
//    @Previewable @StateObject var orderStore = OrderStore()
//    OrderView()
//        .onAppear {
//            orderStore.currentOrder = MockData.order
//            orderStore.currentOrder!.status = .accepted
//        }
//        .environmentObject(orderStore)
//        
//}

#Preview {
    OrderInfoView(title: "Your order is being prepared...", description: "The cook is making your order right now. You will receive a notification once it's ready.", lottieName: "cooking-animation")
}

