//
//  TodoService.swift
//  Todo_App2
//
//  Created by Admin on 10/27/25.
//

import Foundation
import Supabase

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        self._encode = wrapped.encode(to:)
    }
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}


class TodoService {
    private let client = supabase

    func fetchTodos() async throws -> [Todo] {
//        guard let user = try? await supabase.auth.session.user else {
//            return []
//        }

        let todos: [Todo] =
            try await supabase
            .from("todo_list")
            .select()
//            .eq("user_id", value: user.id)
            .execute()
            .value

        print(todos.count)
        return todos
    }

    func addTodo(_ todo: Todo) async throws {
        guard let user = try? await supabase.auth.session.user else {
            throw NSError(
                domain: "AuthError",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No Active user"]
            )
        }

        let newTodo = todo
        // Attach the current user's id to the todo before inserting
        newTodo.user_id = user.id.uuidString
        try await supabase
            .from("todo_list")
            .insert(newTodo)
            .execute()

    }
    
    func updateCompleted(id: String, isCompleted: Bool) async throws {
        try await client
            .from("todo_list")
            .update(["isCompleted": isCompleted])
            .eq("id", value: id)
            .execute()
    }
    
    func deleteTodo(id: String) async throws {
        try await client
            .from("todo_list")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    func updateTodo(_ todo: Todo) async throws {
        var updateData: [String: AnyEncodable] = [:]
        if let title = todo.title { updateData["title"] = AnyEncodable(title) }
        if let content = todo.content { updateData["content"] = AnyEncodable(content) }
        if let category = todo.category { updateData["category"] = AnyEncodable(category) }
        if let time = todo.time { updateData["time"] = AnyEncodable(time) }
        
        try await client
            .from("todo_list")
            .update(updateData)
            .eq("id", value: todo.id)
            .execute()
    }

}
