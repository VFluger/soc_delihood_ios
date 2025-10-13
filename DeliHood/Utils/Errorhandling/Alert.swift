//
//  Alert.swift
//  DeliHood
//
//  Created by Vojta Fluger on 13.08.2025.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

enum AlertContext {
    static let failRegister = AlertItem(title: "Cannot register",
                                        message: "Sorry, we cannot register you at the moment")
    
    static let failLogin = AlertItem(title: "Cannot login",
                                     message: "Sorry, we cannot log you in at the moment")
    
    static let wrongPassOrMail = AlertItem(title: "Wrong password or email",
                                           message: "Check that your email and password are correct.\n\n If you forgot your password, you can reset it.")
    
    static let networkFail = AlertItem(title: "No Network",
                                       message: "Check your internet connection and try again.\n If the problem persists, please contact support.")
   
    static let userAlreadyInDb = AlertItem(title: "User already registered",
                                           message: "A user with this email, phone or username already exists, please choose a different one.")
    
    static let cannotUploadImage = AlertItem(title: "Upload failed",
                                           message: "Unfortunatelly, upload of the image failed, please try again later.")
    
    //MARK: Reset password
    static let forgottenPasswordSend = AlertItem(title: "Check your email", message: "If this email was registered, you should receive an email with a reset link.")
    static let resetPassSuccess = AlertItem(title: "Password reset successful", message: "Password was reset successfully. You can now log in with your new password.")
    static let resetPassFail = AlertItem(title: "Password reset failed", message: "Cannot reset password at the moment, please try again.")
    
    //MARK: - Generic
    static let cannotGetData = AlertItem(title: "Cannot get data", message: "Cannot get data from the server, please try again later.")
    //MARK: - Invalid and duplicate values
    static let invalidValue = AlertItem(title: "Invalid value", message: "This value is not valid. Check if it contains only allowed symbols.")
    static let duplicateValue = AlertItem(title: "Value not available", message: "User with this value already exists. Please try another one.")
    //MARK: - Order
    static let cannotAddToOrder = AlertItem(title: "Cannot add to order", message: "We're unable to add your item to the order, you can have only items from one cook.")
    static let cannotProceedOrder = AlertItem(title: "Cannot proceed with your order", message: "Check if you set an address and try again.")
    static let cannotGetPaymentData = AlertItem(title: "Cannot get your payment", message: "We're unable to get details about your order and payment, please try again later.")
    static let cannotSendOrder = AlertItem(title: "Cannot send order", message: "We're unable to send your order at the moment, please try again later.")
    static let cannotCancel = AlertItem(title: "Cannot cancel order", message: "We're unable to cancel your order at the moment, please restart the app.")
    static let noLocation = AlertItem(title: "No location access", message: "Please enable location access in settings so we can find the nearest cook for you.")
    //MARK: - Demo project alerts
    static let getSupport = AlertItem(title: "No support in demo", message: "Building entire support FAQ or live chat is out of the scope of this app.")
}
