//
//  NetworkStructs.swift
//  DeliHood
//
//  Created by Vojta Fluger on 13.08.2025.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String?
    let phone: String
    let username: String
}

struct RegisterResponse: Codable {
    let success: Bool?
    let error: String?
}

struct AuthTokens: Codable {
    let accessToken: String
    let refreshToken: String
}

struct ErrorStruct: Codable {
    let error: String?
}

struct SuccessStruct: Decodable {
    let success: Bool
}

struct TokenBody: Encodable {
    let token: String
}

struct PasswordResetMail: Encodable {
    let email: String
}

struct NewPassword: Encodable {
    let token: String
    let password: String
}

struct GoogleSign: Encodable {
    let token:  String
}

struct GoogleSignRegisterResponse: Decodable {
    let email: String
    let username: String
}

struct WrongPassOrMailResp: Decodable {
    let isIncorrectPasswordOrUser: Bool
}

struct HomeViewResponse: Decodable {
    let success: Bool
    let data: [Cook]
}

struct EditAccField: Encodable {
    let newValue: String
}

struct OrderPaymentResponse: Decodable {
    let clientSecret: String
    let orderId: Int
}

struct OrderUpdateResponse: Decodable {
    let orderId: Int
    let status: OrderStatus
}

struct OrdersResponse: Decodable {
    let data: [OrderHistory]
}

struct OrderDetailResponse: Decodable {
    let data: OrderHistory
}

struct PfpUpload: Encodable {
    let pfp: Data
}
