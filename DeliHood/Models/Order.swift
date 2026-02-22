//
//  Order.swift
//  DeliHood
//
//  Created by Vojta Fluger on 17.08.2025.
//

import SwiftUI

// same enum as in db, notOrdered added
enum OrderStatus: String, Codable {
    case notOrdered = "not ordered"
    case pending
    case paid
    case accepted
    case waitingForPickup = "waiting for pickup"
    case delivering
    case dropoffReady
    case delivered
    case cancelled
}

struct Order: Codable, Identifiable {
    var id: UUID?
    var serverId: Int?
    
    var items: [OrderItem] = []
    
    var cook: Cook?
    
    var deliveryLocationLat: Double?
    var deliveryLocationLng: Double?
    
    var status: OrderStatus
    var created_at: Date?
    
    var totalPrice: Int {
        items.reduce(0) { $0 + $1.food.price * $1.quantity }
    }
    var tip: Int
    
    private enum CodingKeys: String, CodingKey {
            case id = "serverId"       // struct’s id is `UUID`, so you keep it
            case serverId = "id"       // JSON "id" → struct `serverId`
            case items, cook, deliveryLocationLat, deliveryLocationLng, status, tip
        }
    
    init(id: UUID? = nil, serverId: Int? = nil, items: [OrderItem], cook: Cook? = nil, deliveryLocationLat: Double? = nil, deliveryLocationLng: Double? = nil, status: OrderStatus, tip: Int) {
        self.id = id
        self.serverId = serverId
        self.items = items
        self.cook = cook
        self.deliveryLocationLat = deliveryLocationLat
        self.deliveryLocationLng = deliveryLocationLng
        self.status = status
        self.tip = tip
    }
    
    init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try c.decodeIfPresent(UUID.self, forKey: .id)
            serverId = try c.decodeIfPresent(Int.self, forKey: .serverId)
            
            // Changin to decodeIfPresent, if not empty array
            items = try c.decodeIfPresent([OrderItem].self, forKey: .items) ?? []
            
            cook = try c.decodeIfPresent(Cook.self, forKey: .cook)
            deliveryLocationLat = try c.decodeIfPresent(Double.self, forKey: .deliveryLocationLat)
            deliveryLocationLng = try c.decodeIfPresent(Double.self, forKey: .deliveryLocationLng)
            status = try c.decode(OrderStatus.self, forKey: .status)
            tip = try c.decode(Int.self, forKey: .tip)
        }
}

struct OrderHistory: Codable, Identifiable {
    var id: Int
    var created_at: Date
    var tip: Int
    var total_price: Int
    var status: OrderStatus
    
    var items: [OrderItemHistory]?
}


