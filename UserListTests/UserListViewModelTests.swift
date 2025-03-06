//
//  Untitled.swift
//  UserList
//
//  Created by Neha Pant on 06/03/2025.
//


import Testing
import XCTest
@testable import UserList

@MainActor
struct UserListViewModelTests {
    
    let sut = UserListViewModel(networkManager: MockNetwork())

    @Test func getUsers() async throws {
        //given
        let users: [User] = [User(id: 1, name: "Neha", email: "nehapant@gmail.com"),
                             User(id: 2, name: "Megha", email: "meghapant@gmail.com")]
        //when
        await sut.getUsers()
        //then
        #expect(sut.users == users, "Users are not equal")
    }

}
