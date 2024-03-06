//
//  TweetComposeViewViewModel.swift
//  TwitterClone
//
//  Created by Chingiz on 06.03.24.
//

import Foundation
import Combine
import FirebaseAuth

final class TweetComposeViewViewModel: ObservableObject {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var isValidToTweet: Bool = false
    @Published var error: String = ""
    @Published var shouldDismissComposer: Bool = false
    var tweetContent: String = ""
    private var user: TwitterUser?
    
    
    func getUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        DatabaseManager.shared.collectionUsers(retrive: userID)
            .sink { [weak self] completion in
                if case .failure(let error) = completion{
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)
    }
    
    func validateTweet(){
        isValidToTweet = !tweetContent.isEmpty
    }
    
    func dispatchTweet() {
        guard let user = user else {return}
        let tweet = Tweet(author: user, authorID: user.id, tweetContent: tweetContent,  likesCount: 0, likers: [], isReply: false, parentReference: nil)
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .sink { [weak self] completion in
                if case .failure(let error) = completion{
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] state in
                self?.shouldDismissComposer = state 
            }
            .store(in: &subscriptions)
    }
}
