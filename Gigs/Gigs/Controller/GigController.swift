//
//  GigController.swift
//  Gigs
//
//  Created by Lorenzo on 1/30/21.
//

import Foundation
import UIKit

class GigController {
    var bearer: Bearer?
    private let baseURL = URL(string: "https://lambdagigapi.herokuapp.com/api")!
    private lazy var registerURL = baseURL.appendingPathComponent("/users/signup")
    private lazy var loginURL = baseURL.appendingPathComponent("/users/login")
    
    
    enum NetworkError: Error {
        case noData
        case failedSignup
        case failedSignIn
        case noToken
    }
    
    func register(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = createPostRequest(for: registerURL)
        
        do {
            // Encode the data into json
            let credentials = try JSONEncoder().encode(user)
            // add body
            request.httpBody = credentials
            
            let task = URLSession.shared.dataTask(with: request) { (_, response, error) in
                if let error = error {
                    print("error creating data task,", error)
                    completion(.failure(.failedSignup))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("sign up was unseccsessful")
                    completion(.failure(.failedSignup))
                    return
                }
                completion(.success(true))
            }
            task.resume()
            
        } catch {
            print("error encoding user")
            completion(.failure(.failedSignup))
        }
        
    }
    
    private func createPostRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    
    func login(with user: User, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = createPostRequest(for: loginURL)
        print("login called")
        
        do {
            // encode the credentials
            let credentials = try JSONEncoder().encode(user)
            request.httpBody = credentials
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("error signing in", error)
                    completion(.failure(.failedSignIn))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print("bad response")
                    completion(.failure(.failedSignIn))
                    return
                }
                guard let data = data else {
                    print("no data")
                    completion(.failure(.noData))
                    return
                }
                // handle the credentials
                
                do {
                    self.bearer = try JSONDecoder().decode(Bearer.self, from: data)
                    completion(.success(true))
                    
                } catch {
                    print("no token returned from request or failed to decode")
                    completion(.failure(.noToken))
                }
            }
            task.resume()
            
            
        } catch {
            print("error encoding user")
            completion(.failure(.failedSignIn))
        }
    }
}

