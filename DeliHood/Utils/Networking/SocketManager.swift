//
//  SocketManager.swift
//  DeliHood
//
//  Created by Vojta Fluger on 22.02.2026.
//

import Foundation
import SocketIO

// MARK: - Socket Event Names
private enum SocketEvent: String {
    // SEND
    case orderDelivered

    // RECEIVE
    case orderDeliveredError
    case orderAccepted
    case orderAcceptedError
    case orderReady
    case foodPickup
    case driverLocation
    case dropoffReady
}

final class AppSocketManager {
    static let shared = AppSocketManager()

    private let baseUrl = URL(string: "http://localhost:8080")!

    // Init manager
    private lazy var manager: SocketIO.SocketManager = {
        SocketIO.SocketManager(socketURL: baseUrl, config: [
            .log(true),
            .compress,
            .reconnects(true),
            .reconnectAttempts(-1),
            .reconnectWait(2)
        ])
    }()

    private var socket: SocketIOClient = {
        manager.defaultSocket
    }()

    var onOrderDeliveredError: ((Any) -> Void)?
    var onOrderAccepted: ((Any) -> Void)?
    var onOrderAcceptedError: ((Any) -> Void)?
    var onOrderReady: ((Any) -> Void)?
    var onFoodPickup: ((Any) -> Void)?
    var onDriverLocation: ((Any) -> Void)?
    var onDropoffReady: ((Any) -> Void)?

    private init() {
        registerLogging()
        registerReceiveHandlers()
    }

    // MARK: - Public API

    func connect() {
        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    // SEND: orderDelivered
    // You can adjust the payload shape to match your server contract
    func sendOrderDelivered(orderId: String, payload: [String: Any] = [:]) {
        var body: [String: Any] = ["orderId": orderId]
        payload.forEach { body[$0.key] = $0.value }
        socket.emit(SocketEvent.orderDelivered.rawValue, body)
    }

    // MARK: - Private

    private func registerLogging() {
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            print("[Socket] Connected")
        }

        socket.on(clientEvent: .disconnect) { _, _ in
            print("[Socket] Disconnected")
        }

        socket.on(clientEvent: .error) { data, _ in
            print("[Socket] Error: \(data)")
        }

        socket.on(clientEvent: .reconnect) { data, _ in
            print("[Socket] Reconnecting… \(data)")
        }
    }

    private func registerReceiveHandlers() {
        // orderDeliveredError
        socket.on(SocketEvent.orderDeliveredError.rawValue) { [weak self] data, _ in
            self?.onOrderDeliveredError?(data.first as Any)
        }

        // orderAccepted
        socket.on(SocketEvent.orderAccepted.rawValue) { [weak self] data, _ in
            self?.onOrderAccepted?(data.first as Any)
        }

        // orderAcceptedError
        socket.on(SocketEvent.orderAcceptedError.rawValue) { [weak self] data, _ in
            self?.onOrderAcceptedError?(data.first as Any)
        }

        // orderReady
        socket.on(SocketEvent.orderReady.rawValue) { [weak self] data, _ in
            self?.onOrderReady?(data.first as Any)
        }

        // foodPickup
        socket.on(SocketEvent.foodPickup.rawValue) { [weak self] data, _ in
            self?.onFoodPickup?(data.first as Any)
        }

        // driverLocation
        socket.on(SocketEvent.driverLocation.rawValue) { [weak self] data, _ in
            self?.onDriverLocation?(data.first as Any)
        }

        // dropoffReady
        socket.on(SocketEvent.dropoffReady.rawValue) { [weak self] data, _ in
            self?.onDropoffReady?(data.first as Any)
        }
    }
}
