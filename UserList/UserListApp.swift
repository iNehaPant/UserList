//
//  UserListApp.swift
//  UserList
//
//  Created by Neha Pant on 06/03/2025.
//

import SwiftUI

@main
struct UserListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: UserListViewModel(networkManager:
                                                        NetworkManager(session: URLSession.shared,
                                                                       baseUrl: "https://jsonplaceholder.typicode.com")))
        }
    }
}
