//
//  Untitled.swift
//  UserList
//
//  Created by Neha Pant on 06/03/2025.
//

import Testing
@testable import UserList
import Foundation

struct NetworkManagerTests {
    
    @Test func fetchUsers() async throws {
        //given
        let session = MockUrlSession()
        session.data = try JSONEncoder().encode([User(id: 1, name: "neha", email: "neha@g.com")])
        let sut: NetworkManager =  NetworkManager(session: session, baseUrl: "https://jsonplaceholder.typicode.com/users")
        //when
        let users = try await sut.fetchUsers()
        
        print(users)
        //then
        #expect(users.count == 1, "Invalid name")
        #expect(users[0].name == "neha", "Invalid name")

        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
}


class MockUrlSession: URLSessionProtocol {
    
    var data: Data?
    var error: Error?
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        guard let data = data else {
            throw NSError(domain: "MockError", code: 0, userInfo: nil)
        }
        
        let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!
        return (data, response)
    }
}
