//
//  GoogleAuthService.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import UIKit

final class GoogleLoginExecutor {
    private var completion: ((Result<AuthResult, Error>) -> Void)?
    
    @MainActor
    func execute(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        self.completion = completion
        
        guard let vc = ViewControllerResolver.topViewController() else {
            completion(.failure(NSError(domain: "Google", code: -100)))
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "Google", code: -1)))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { [weak self] result, error in
            if let error {
                self?.completion?(.failure(error))
                // SWIFT TASK CONTINUATION MISUSE: loginWithGoogle() leaked its continuation without resuming it. This may cause tasks waiting on it to remain suspended forever.
                return
            }
            
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                self?.completion?(.failure(NSError(domain: "Google", code: -2)))
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            self?.firebaseLogin(idToken: idToken, accessToken: accessToken)
        }
    }
}

private extension GoogleLoginExecutor {
    
    func firebaseLogin(idToken: String, accessToken: String) {
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        FirebaseAuthService.signIn(credential: credential) { [weak self] result in
            switch result {
            case .success(let user):
                self?.completion?(
                    .success(AuthResult(uid: user.uid, idToken: idToken))
                )
            case .failure(let error):
                self?.completion?(.failure(error))
            }
        }
    }
}

enum ViewControllerResolver {
    
    @MainActor
    static func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return nil
        }
        
        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        
        return top
    }
}
