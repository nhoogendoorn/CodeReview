//
//  VisitorListView.swift
//  CodeReview
//
//  Created by Niels Hoogendoorn on 26/07/2021.
//

import SwiftUI

public class Visitor: Codable, Identifiable {
    let name: String
    let email: String?
    let username: String
    let website: String?
    let avatarUrl: String?
    public var id: String { email ?? username }

}

public class APIService {

    var userlistService: UserListService

    init(service: UserListService) {
        self.userlistService = service
    }

    func getData() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let request = URLRequest(url: url, timeoutInterval: 3)
        URLSession(configuration: URLSessionConfiguration.default).dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let jsong = try JSONDecoder().decode([Visitor].self, from: data)
                    self.userlistService.items.append(contentsOf: jsong)
                } catch {
                    self.userlistService.items.append(contentsOf: [])
                }                
            }
        }
    }
}

public class UserListService {

    lazy var apiService: APIService = {
        APIService(service: self)
    }()
    @Published var items: [Visitor] = []
    var error: Error?

    func itemsIsNotEmpty() -> Bool {
        !items.isEmpty
    }
}

public struct VisitorListView: View {
    let service = UserListService()

    public var body: some View {

        List {
            if service.itemsIsNotEmpty() {
                ForEach(service.items) { item in
                    NavigationLink(destination: VisitorView(visitor: item)) {
                        Text(item.username)
                    }
                }
            } else {
                EmptyView()
            }
            ZStack {
                Color.red
                Text("Fetch visitorrs!")
            }
            .cornerRadius(8)
            .onTapGesture {
                service.apiService.getData()
            }
        }

    }
}

struct VisitorView: View {
    let visitor: Visitor

    var body: some View {
        VStack {
            HStack {
                if let urlString = visitor.avatarUrl {
                    AvatarView(url: URL(string: urlString))
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: "person.circle.fill")
                        .frame(width: 50, height: 50)
                }
                VStack {
                    Text("Name: " + visitor.username)
                    Text("Email: " + (visitor.email ?? ""))
                }
            }
        }
    }
}

// You can assume that this implementation works, it doesn't, but it's not part of the scope for now.
struct AvatarView: View {
    let url: URL?

    var body: some View {
        Color.yellow
    }
}
