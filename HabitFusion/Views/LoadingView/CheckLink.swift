//
//  CheckLink.swift
//  BubblyBass
//
//  Created by Роман Главацкий on 26.10.2025.
//

import Foundation

struct CheckURLService {
    
    static let link = URL(string: "https://stretching-fitnessboom.com/MhCgCb")
    
    static  func checkURLStatus( completion: @escaping (Bool) -> Void) {
        guard let url = link  else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 404 {
                    completion(true)
                    
                } else {
                    print("code is 404")
                    completion(false)
                }
            } else {completion(false)}
        }        
        task.resume()
    }
}
