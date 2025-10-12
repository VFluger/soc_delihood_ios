//
//  User.swift
//  LoginTestApp
//
//  Created by Vojta Fluger on 12.08.2025.
//

import Foundation

struct getUserHelper: Codable {
    let status: Bool?
    let data: User
}

// var because can be changes in settings
struct User: Codable {
    let id: Int
    var username: String
    var email: String
    var phone: String
    var image_url: String?
    var created_at: String
}
