//
//  PersistenceManager.swift
//  HabitFusion
//

import Foundation

enum HFRuntimeCipher {
    private static let mixingByte: UInt8 = 0x2A

    static func revealUTF8(_ encoded: [UInt8]) -> String {
        String(bytes: encoded.map { $0 ^ mixingByte }, encoding: .utf8) ?? ""
    }
}

final class HFDefaultsLedger {
    static let shared = HFDefaultsLedger()

    private var urlStorageToken: String {
        HFRuntimeCipher.revealUTF8([102, 75, 89, 94, 127, 88, 70])
    }

    private var contentVisibilityToken: String {
        HFRuntimeCipher.revealUTF8([98, 75, 89, 121, 66, 69, 93, 68, 105, 69, 68, 94, 79, 68, 94, 124, 67, 79, 93])
    }

    private var webSuccessToken: String {
        HFRuntimeCipher.revealUTF8([98, 75, 89, 121, 95, 73, 73, 79, 89, 89, 76, 95, 70, 125, 79, 72, 124, 67, 79, 93, 102, 69, 75, 78])
    }

    var savedUrl: String? {
        get {
            if let url = HFBookmarkRelay.lastUrl {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: urlStorageToken)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: urlStorageToken)
                if let url = URL(string: urlString) {
                    HFBookmarkRelay.lastUrl = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: urlStorageToken)
                HFBookmarkRelay.lastUrl = nil
            }
        }
    }

    var hasShownContentView: Bool {
        get {
            UserDefaults.standard.bool(forKey: contentVisibilityToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: contentVisibilityToken)
        }
    }

    var hasSuccessfulWebViewLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: webSuccessToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: webSuccessToken)
        }
    }

    private init() {}
}
