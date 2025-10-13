//
//  NetworkManager.swift
//  LoginTestApp
//
//  Created by Vojta Fluger on 12.08.2025.
//

import SwiftUI

enum AuthResult {
    case success
    case needsRegistration(GoogleSignRegisterResponse, token: String)
}

class NetworkManager {
//    let baseURL = "https://delihood-backend.onrender.com"
    let baseURL = "http://localhost:8080"
    
    static let shared = NetworkManager()
    
    func getMe() async throws -> User? {
        print("Refreshing user and state")
        let (data, response) = try await NetworkManager.shared.get(path: "/api/me")
        
        guard let _ = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        return try JSONDecoder().decode(getUserHelper.self, from: data).data
    }
    
    func getOrders() async throws -> OrdersResponse {
        let data = try await NetworkManager.shared.genericGet(path: "/api/me/orders")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OrdersResponse.self, from: data)
    }
    
    func getOrderDetails(id: Int) async throws -> OrderDetailResponse {
        let data = try await NetworkManager.shared.genericGet(path: "/api/me/order", query: "id=\(id)")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(OrderDetailResponse.self, from: data)
    }
    
    func updateOrder(id: Int) async throws -> OrderUpdateResponse {
        let data = try await NetworkManager.shared.genericGet(path: "/api/order/update")
        return try JSONDecoder().decode(OrderUpdateResponse.self, from: data)
    }
    
    func cancelOrder(id: Int) async throws {
        let data = try await NetworkManager.shared.genericPost(path: "/api/order/cancel", body: ["id": id])
        let _ = try JSONDecoder().decode(SuccessStruct.self, from: data)
    }
    
    func getPaymentSecret(orderId: Int) async throws -> String {
        let data = try await NetworkManager.shared.genericGet(path: "/api/order/payment", query: "id=\(orderId)")
        return try JSONDecoder().decode(OrderPaymentResponse.self, from: data).clientSecret
    }
    
    
    func postOrder (_ order: Order) async throws -> OrderPaymentResponse {
        let data = try await NetworkManager.shared.genericPost(path: "/api/new-order", body: order)
        print(try JSONSerialization.jsonObject(with: data))
        return try JSONDecoder().decode(OrderPaymentResponse.self, from: data)
    }
    
    func changeAccSetting(_ value: String, type: EditFieldKey) async throws {
        try await NetworkManager.shared.genericPost(path: "/api/change/\(type.rawValue)", body: EditAccField(newValue: value))
        
    }
    
    func uploadPfp(_ image: Data) async throws {
        let url = URL(string: "\(baseURL)/api/upload-pfp")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.getAccessToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"pfp\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, res) = try await URLSession.shared.data(for: request)
        print( try? JSONSerialization.jsonObject(with: data))
        }
    
    //MARK: - Main Get Of Content
    func getMainScreen(lat: Double, lng: Double) async throws -> HomeViewResponse {
        let (data, _) = try await NetworkManager.shared.get(path: "/api/main-screen?lat=\(lat)&lng=\(lng)")
        do {
            let decodedData = try JSONDecoder().decode(HomeViewResponse.self, from: data)
            print(decodedData)
            return decodedData
        }catch {
            print(error)
            throw MainError.cannotDecode
        }
    }
    
    @discardableResult
    func postGoogleToken(token: String) async throws -> AuthResult {
        let data = try await genericPost(path: "/auth/google-sign", body: GoogleSign(token: token), sendJWT: false)
        // If user exists, tokens send, if not, email and name send
        do {
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            
            if !AuthManager.shared.saveTokens(tokens) {
                throw MainError.saveTokensFailed
            }
            //SUCCESS
            return .success
            
        }catch {
            print("User not registered, try decode")
            let userData = try JSONDecoder().decode(GoogleSignRegisterResponse.self, from: data)
            //User not registered
            return .needsRegistration(userData, token: token)
        }
        
    }
    
    //MARK: - ConfirmMail and Reset password
    
    func getConfirmMail() async throws {
        try await genericGet(path: "/confirmations/generate-confirm")
    }
    
    func postConfirmMail(token: String) async throws {
        try await genericPost(path: "/confirmations/confirm-mail", body: TokenBody(token: token))
    }
    
    func postPasswordResetMail(email: String) async throws {
        try await genericPost(path: "/auth/generate-password-token", body: PasswordResetMail(email: email), sendJWT: false)
    }
    
    func postNewPassword(password: String, token: String) async throws {
        try await genericPost(path: "/auth/new-password", body: NewPassword(token: token, password: password), sendJWT: false)
    }
    
    
    //MARK: - Helpers, checking if { error: "" } is present
    @discardableResult
    func genericPost<T: Encodable>(path: String, body: T, sendJWT: Bool = true) async throws -> Data {
        let (data, _) = try await NetworkManager.shared.post(path: path, body: body, sendJWT: sendJWT)
        
        // Check if errors
        let decoded = try JSONDecoder().decode(ErrorStruct.self, from: data)
        
        if let errorMsg = decoded.error, !errorMsg.isEmpty {
            throw GenericError.error(errorMsg)
        } else {
            //SUCCESS
            return data
        }
    }
    
    @discardableResult
    func genericGet(path: String, query: String? = nil, sendJWT: Bool = true) async throws -> Data {
        let fullPath = query != nil ? "\(path)?\(query!)" : path
        let (data, response) = try await NetworkManager.shared.get(path: fullPath, sendJWT: sendJWT)
        
        let decoded = try JSONDecoder().decode(ErrorStruct.self, from: data)
        
        // Check if error
        if let errorMsg = decoded.error, !errorMsg.isEmpty {
            throw GenericError.error(errorMsg)
        } else {
            //SUCCESS
            return data
        }
    }
    
    //MARK: - Main Helper get and post, sendJWT decide if auth token included
    func get(path: String, sendJWT: Bool = true, retryCount: Int = 0) async throws -> (Data, URLResponse) {
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)

        if sendJWT {
            let accessToken = AuthManager.shared.getAccessToken() ?? ""
            if accessToken.isEmpty {
                // code
                print("Access Token not available")
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            return (data, response)
        case 401:
            if retryCount < 2 {
                // get new tokens
                try await AuthManager.shared.refreshToken()
                
                // call again
                return try await self.get(path: path, sendJWT: sendJWT, retryCount: retryCount + 1)
            } else {
                throw MainError.refreshFailed
            }
        case 403:
            throw MainError.emailNotVerified
        case 404:
//            throw MainError.notFound
            return (data, response)
        default:
            throw URLError(.badServerResponse)
        }
    }

    func post<T: Encodable>(path: String, body: T, sendJWT: Bool = true, retryCount: Int = 0) async throws -> (Data, URLResponse) {
        
        guard let url = URL(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)

        if sendJWT {
            let accessToken = AuthManager.shared.getAccessToken() ?? ""
            if accessToken.isEmpty {
                // code
                print("Access Token not available")
                throw MainError.cannotGetToken
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonData = try JSONEncoder().encode(body)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        switch httpResponse.statusCode {
        case 200:
            return (data, response)
        case 401:
            if retryCount < 2 {
                // get new tokens
                try await AuthManager.shared.refreshToken()
                
                // call again
                return try await self.post(path: path, body: body, sendJWT: sendJWT, retryCount: retryCount + 1)
            } else {
                throw MainError.cannotGetToken
            }
        case 403:
            throw MainError.emailNotVerified
        case 409:
            throw MainError.duplicateValue
        default:
            throw MainError.invalidResponse
        }
    }
}
