//
//  Tweet.swift
//  TwitterClone
//
//  Created by Chingiz on 06.03.24.
//

import Foundation

struct Tweet: Codable{
    var id = UUID().uuidString
    let author: TwitterUser
    let authorID: String
    let tweetContent: String
    var likesCount: Int
    var likers: [String]
    var isReply: Bool
    var parentReference: String?
}
