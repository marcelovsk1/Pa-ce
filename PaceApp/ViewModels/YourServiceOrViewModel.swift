//
//  YourServiceOrViewModel.swift
//  PaceApp
//
//  Created by Marcelo Amaral Alves on 2024-07-12.
//

import Foundation

class YourServiceOrViewModel: ObservableObject {
    private let throttleManager = ThrottleManager()

    func performSearchRequest() {
        if throttleManager.canMakeRequest() {
            // Perform your network request here
            // Example: URLSession.shared.dataTask(with: url) { data, response, error in ... }
            print("Request made")
        } else {
            // Wait until the reset time and then try again
            throttleManager.waitUntilReset {
                self.performSearchRequest()
            }
        }
    }
}
