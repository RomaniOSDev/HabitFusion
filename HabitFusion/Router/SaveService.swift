//
//  SaveService.swift
//  HabitFusion
//

import Foundation

struct HFBookmarkRelay {
    private static var lastUrlKey: String {
        HFRuntimeCipher.revealUTF8([102, 75, 89, 94, 127, 88, 70])
    }

    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: lastUrlKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastUrlKey) }
    }
}
