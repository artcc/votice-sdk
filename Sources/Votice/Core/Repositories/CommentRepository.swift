//
//  CommentRepository.swift
//  Votice
//
//  Created by Arturo Carretero Calvo on 28/6/25.
//  Copyright © 2025 ArtCC. All rights reserved.
//

import Foundation

protocol CommentRepositoryProtocol: Sendable {
    func fetchComments(request: FetchCommentsRequest) async throws -> CommentsResponse
    func createComment(request: CreateCommentRequest) async throws -> CreateCommentResponse
    func deleteComment(request: DeleteCommentRequest) async throws
}

final class CommentRepository: CommentRepositoryProtocol {
    // MARK: - Properties

    private let networkManager: NetworkManagerProtocol

    // MARK: - Init

    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }

    // MARK: - CommentRepositoryProtocol

    func fetchComments(request: FetchCommentsRequest) async throws -> CommentsResponse {
        var path = "/v1/sdk/comments/fetch?suggestionId=\(request.suggestionId)"

        if let startAfter = request.pagination.startAfter {
            path += "&startAfter=\(startAfter.createdAt)"
        }

        if let pageLimit = request.pagination.pageLimit {
            path += "&pageLimit=\(pageLimit)"
        }

        let endpoint = NetworkEndpoint(path: path, method: .GET, body: nil)

        return try await networkManager.request(endpoint: endpoint, responseType: CommentsResponse.self)
    }

    func createComment(request: CreateCommentRequest) async throws -> CreateCommentResponse {
        let bodyData = try JSONEncoder().encode(request)
        let endpoint = NetworkEndpoint(path: "/v1/sdk/comments/create", method: .POST, body: bodyData)

        return try await networkManager.request(endpoint: endpoint, responseType: CreateCommentResponse.self)
    }

    func deleteComment(request: DeleteCommentRequest) async throws {
        let bodyData = try JSONEncoder().encode(request)
        let endpoint = NetworkEndpoint(path: "/v1/sdk/comments/delete", method: .POST, body: bodyData)

        _ = try await networkManager.request(endpoint: endpoint, responseType: BaseResponse.self)
    }
}
