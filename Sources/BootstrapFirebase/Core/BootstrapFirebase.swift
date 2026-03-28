//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import FirebaseCore
import KakaoSDKCommon

public struct BootstrapConfig {
    public let firebase: Bool
    public let kakaoAppKey: String?
    
    public init(
        firebase: Bool,
        kakaoAppKey: String?
    ) {
        self.firebase = firebase
        self.kakaoAppKey = kakaoAppKey
    }
}

public enum BootstrapFirebase {
    public static func configure(_ config: BootstrapConfig) {
        
        if config.firebase {
            FirebaseApp.configure()
        }
        
        if let kakaoAppKey = config.kakaoAppKey {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        }
    }
}
