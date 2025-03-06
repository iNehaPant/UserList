//
//  ContentView.swift
//  UserList
//
//  Created by Neha Pant on 06/03/2025.
//

//pull to referesh

//How would you cache the data for offline access?

//How would you handle pagination if the API supports it?
//search

//Filter the list of items based on the search query.

//Update the UI in real-time as the user types.

//Follow-up Questions:

//How would you optimize the search for a large dataset?

//How would you debounce the search to avoid excessive network calls?
//Implement a Coordinator Pattern
//Task: Implement a navigation flow using the Coordinator pattern.

//Requirements:

//Create a Coordinator class to manage navigation.

//Move navigation logic out of the view controller.

//Handle navigation between two screens (e.g., a list and a detail view).

//Follow-up Questions:

//What are the benefits of using the Coordinator pattern?

//How would you handle deep linking in this architecture?
import SwiftUI

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let email: String
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.email == rhs.email
    }
}

protocol NetworkService {
    func fetchUsers(_ endPoint: String) async throws -> [User]
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {
    // No implementation needed since `URLSession` already implements `data(for:)`
}

struct NetworkManager: NetworkService {
    enum NetworkError: Error {
        case invalidUrl
        case server
        case jsonDecoding
    }
    
    private let session: URLSessionProtocol
    private let baseUrl: String
    
    init(session: URLSessionProtocol, baseUrl: String) {
        self.session = session
        self.baseUrl = baseUrl
    }
    
    func fetchUsers(_ endPoint: String) async throws -> [User] {
        guard let url = URL(string: baseUrl + endPoint) else {
            throw NetworkError.invalidUrl
        }
        let (data, response) = try await session.data(for: URLRequest(url: url))

        guard let res = response as? HTTPURLResponse, res.statusCode == 200 else {
            throw NetworkError.server
        }
        do {
            return try JSONDecoder().decode([User].self, from: data)
        } catch {
            throw NetworkError.jsonDecoding
        }
    }
}

@MainActor
class UserListViewModel: ObservableObject {
    private let networkManager: NetworkService
    @Published var users: [User] = [User]()
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
//    @Published var searchTxt: String = "" {
//        didSet {
//            if self.searchTxt.trimmingCharacters(in: .whitespaces).count > 0 {
//                self.filterUsers = self.users.filter($0.name == self.searchTxt)
//            }
//        }
//    }
//    
//    @Published var filterUsers: [User] = [User]()
    
    init(networkManager: NetworkService) {
        self.networkManager = networkManager
    }
    
    func getUsers() async {
        self.isLoading = true
        do {
            self.users = try await networkManager.fetchUsers("/users")
        } catch {
            self.isError = true
            self.errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
}


struct ContentView: View {
    @StateObject var viewModel: UserListViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.users) {user in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity,  maxHeight: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                }
                .onAppear {
                    Task {
                        await viewModel.getUsers()
                    }
                }
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert("Ok", isPresented: $viewModel.isError, actions: {
                Button("Ok", role: .cancel, action: {})
            }, message: {
                Text(viewModel.errorMessage)
            })
        }
        //.searchable(text: $viewModel.searchTxt, prompt: "Search User")
        
    }
}

#Preview {
    ContentView(viewModel: UserListViewModel(networkManager: MockNetwork()))
}


struct MockNetwork: NetworkService {

    let mockUsers: [User]
    
    init(mockUsers: [User] = [User(id: 1, name: "Neha", email: "nehapant@gmail.com"), User(id: 2, name: "Megha", email: "meghapant@gmail.com")]) {
        self.mockUsers = mockUsers
    }
    
    func fetchUsers(_ endPoint: String) async throws -> [User]  {
        return self.mockUsers
    }
    
    
}
