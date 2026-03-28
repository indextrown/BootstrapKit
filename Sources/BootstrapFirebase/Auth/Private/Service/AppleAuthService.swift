//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import CryptoKit
import UIKit
import AuthenticationServices
import FirebaseAuth

enum Nonce {
    static func random(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String((0..<length).map { _ in charset.randomElement()! })
    }
    
    static func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

final class AppleLoginExecutor: NSObject {
    
    private var completion: ((Result<AuthResult, Error>) -> Void)?
    private var currentNonce: String?
    
    func execute(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        self.completion = completion
        
        let nonce = Nonce.random()
        currentNonce = nonce
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Nonce.sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
}

// MARK: - Delegate
extension AppleLoginExecutor: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            completion?(.failure(NSError(domain: "AppleAuth", code: -1)))
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idToken,
            rawNonce: nonce
        )
        
        FirebaseAuthService.signIn(credential: firebaseCredential) { result in
            switch result {
            case .success(let user):
                self.completion?(
                    .success(AuthResult(uid: user.uid, idToken: idToken))
                )
            case .failure(let error):
                self.completion?(.failure(error))
            }
        }
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        completion?(.failure(error))
    }
}
