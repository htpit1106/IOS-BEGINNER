//
//  Todo.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation

class Todo: Codable {
     var id: String?
     var title: String?
     var category: Category?
     var created_at: String?
     var content: String?
     var time: String?
     var isComplete: Bool?
     var user_id: String?

    init(
        id: String? = nil,
        title: String? = nil,
        category: Category? = .list,
        created_at: String? = nil,
        content: String? = nil,
        time: String? = nil,
        isComplete: Bool? = nil,
        user_id: String? = nil
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.created_at = created_at
        self.content = content
        self.time = time
        self.isComplete = isComplete
        self.user_id = user_id
    }

}

