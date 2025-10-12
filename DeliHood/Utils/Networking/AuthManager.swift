//
//  Auth.swift
//  LoginTestApp
//
//  Created by Vojta Fluger on 12.08.2025.
//
import Foundation
import JWTDecode
import SimpleKeychain

class AuthManager {
    static let shared = AuthManager()
    
//    private let authDomain = "https://delihood-backend.onrender.com"
    private let authDomain = "http://localhost:8080"
    
    private let keychain = SimpleKeychain(service: "com.VFluger.DeliHood", synchronizable: true)
    
    func login(email: String, password: String) async throws {
        let loginRequest = LoginRequest(email: email, password: password)
        
        let url = URL(string: "\(authDomain)/auth/login")!
        let (data, _) = try await performRequest(url: url, method: "POST", body: loginRequest)
        do {
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            if !saveTokens(tokens) {
                throw MainError.saveTokensFailed
            }
        } catch {
            // Check if wrong password or mail
                let _ = try JSONDecoder().decode(WrongPassOrMailResp.self, from: data)
                throw MainError.wrongPassOrMail
        }
        
    }
    
    func register(email: String, password: String? = nil, phone: String, name: String) async throws {
        let registerRequest = RegisterRequest(email: email, password: password, phone: phone, username: name)
        let url = URL(string: "\(authDomain)/auth/register")!
        
        let (data, response) = try await performRequest(url: url, method: "POST", body: registerRequest)
        //Check if user in db (error 409)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 409 {
            throw MainError.userAlreadyInDb
        }
        
        let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
        
        
        if let errorMessage = registerResponse.error {
            throw MainError.networkError(description: errorMessage)
        }
        
        guard registerResponse.success == true else {
            throw MainError.invalidResponse
        }
    }
    
    func refreshToken() async throws {
        do {
            let refreshToken = try keychain.string(forKey: "refreshToken")
            let url = URL(string: "\(authDomain)/auth/refresh")!
            let body = ["refreshToken": refreshToken]
            
            let (data, _) = try await performRequest(url: url, method: "POST", body: body)
            let tokens = try JSONDecoder().decode(AuthTokens.self, from: data)
            
            if !saveTokens(tokens) {
                throw MainError.saveTokensFailed
            }
        }catch {
            throw MainError.cannotGetToken
        }
    }
    
    // MARK: Help funcs
    private func performRequest<T: Codable>(url: URL, method: String, body: T? = nil) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        return try await URLSession.shared.data(for: request)
    }
    
    func saveTokens(_ tokens: AuthTokens) -> Bool {
        do {
            try keychain.set(tokens.accessToken, forKey: "accessToken")
            try keychain.set(tokens.refreshToken, forKey: "refreshToken")
            return true
        } catch {
            return false
        }
    }
    
    func getAccessToken() -> String? {
        do {
            return try keychain.string(forKey: "accessToken")
        }catch {
            return nil
        }
    }
    
    func decodeAccessToken() throws -> JWT {
        guard let token = getAccessToken() else {
            throw MainError.cannotGetToken
        }
        return try decode(jwt: token)
    }
    @discardableResult
    func logout() async -> Bool {
        do {
            try keychain.deleteItem(forKey: "accessToken")
            try keychain.deleteItem(forKey: "refreshToken")
            let (_, resp) = try await performRequest(url: URL(string: "/auth/logout")!, method: "GET", body: [""])
            if let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 {
                return true
            }
            return false
        }catch {
            return false
        }
    }
}
