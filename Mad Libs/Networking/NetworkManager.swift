//
//  NetworkManager.swift
//  Mad Libs
//
//  Created by Bassam on 4/6/24.
//

import Foundation
import Network

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func checkNetworkAvailability(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue.global()
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        monitor.start(queue: queue)
    }
}
