//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//
/*
 // completion을 속성으로 둔 이유 = 여러 함수에서 쓰려고 미리 저장해둔 것
 - private var completion: ((Result<AuthResult, Error>) -> Void)?
 
 ❌ 1. completion 계속 전달하는 경우
 func start(completion: @escaping () -> Void) {
     step1(completion: completion)
 }

 func step1(completion: @escaping () -> Void) {
     step2(completion: completion)
 }

 func step2(completion: @escaping () -> Void) {
     completion()
 }
 
 ✅ 2. completion 저장하는 경우
 var completion: (() -> Void)?
 func start(completion: @escaping () -> Void) {
     self.completion = completion
     step1()
 }

 func step1() {
     step2()
 }

 func step2() {
     completion?()
 }
 */

import KakaoSDKUser
import FirebaseAuth

final class KakaoLoginExecutor {
    private var completion: ((Result<AuthResult, Error>) -> Void)?
    
    func execute(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        self.completion = completion
        
        // 카카오톡 앱 로그인
        if UserApi.isKakaoTalkLoginAvailable() {
            loginWithKakaoTalk()
        } else {
            loginWithKakaoAccount()
        }
    }
}

private extension KakaoLoginExecutor {
    
    func firebaseLogin(idToken: String) {
        let credential = OAuthProvider.credential(
            providerID: .custom("oidc.kakao"),
            idToken: idToken,
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
    
    func loginWithKakaoTalk() {
        UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
            if let error {
                self?.completion?(.failure(error))
                return
            }
            
            guard let idToken = token?.idToken else {
                self?.completion?(.failure(NSError(domain: "Kakao", code: -1)))
                return
            }
            
            self?.firebaseLogin(idToken: idToken)
        }
    }
    
    func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] token, error in
            if let error {
                self?.completion?(.failure(error))
                return
            }
            
            guard let idToken = token?.idToken else {
                self?.completion?(.failure(NSError(domain: "Kakao", code: -1)))
                return
            }
            
            self?.firebaseLogin(idToken: idToken)
        }
    }
}
