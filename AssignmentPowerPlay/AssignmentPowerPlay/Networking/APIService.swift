//
//  APIService.swift
//  AssignmentPowerPlay
//
//  Created by Abhinav Kumar on 24/09/25.
//


import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchProducts(page: Int, limit: Int = 10, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        let urlString = "https://fakeapi.net/products?page=\(page)&limit=\(limit)&category=electronics"
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(err))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let err = NSError(domain: "APIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(err))
                return
            }
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(APIResponse.self, from: data)
                completion(.success(apiResponse))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
