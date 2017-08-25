//
//  FriendsListAPI.swift
//  TestApp
//
//  Created by sergey on 8/25/17.
//  Copyright © 2017 sergey. All rights reserved.
//

import Foundation
import Moya

// MARK: - Provider setup

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

let FriendsMOC = MoyaProvider<Friends>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])

// MARK: - Provider support

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

public enum Friends {
    case friendsList
    case friendById(String)
}

extension Friends: TargetType {
    public var baseURL: URL { return URL(string: "http://private-5bdb3-friendmock.apiary-mock.com")! }
    public var path: String {
        switch self {
        case .friendsList:
            return "/friends"
        case .friendById( _):
            return "/friends/id"
        }
    }
    public var method: Moya.Method {
        return .get
    }
    
    
    public var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    public var task: Task {
        return .request
    }
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    public var sampleData: Data {
        switch self {
        case .friendsList:
            return "{\"results\": \"[]\"}".data(using: String.Encoding.utf8)!
        case .friendById( _):
            return "{\"results\": \"[]\"}".data(using: String.Encoding.utf8)!
        }
    }
    public var headers: [String: String]? {
        return nil
    }
}

public func url(_ route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

//MARK: - Response Handlers

extension Moya.Response {
    func mapNSDictionary() throws -> NSDictionary {
        let any = try self.mapJSON()
        guard let dict = any as? NSDictionary else {
            throw MoyaError.jsonMapping(self)
        }
        return dict
    }
    func mapNSArray() throws -> NSArray {
        let any = try self.mapJSON()
        guard let array = any as? NSArray else {
            throw MoyaError.jsonMapping(self)
        }
        return array
    }
}

