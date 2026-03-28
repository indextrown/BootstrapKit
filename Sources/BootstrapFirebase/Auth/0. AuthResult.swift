//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import Foundation

public struct AuthResult {
    public let uid: String
    public let idToken: String
    
    public init(uid: String, idToken: String) {
        self.uid = uid
        self.idToken = idToken
    }
}
