//
//  StorageManager.swift
//  TwitterClone
//
//  Created by Chingiz on 06.03.24.
//

import Foundation
import Combine
import FirebaseStorage
import FirebaseStorageCombineSwift

enum FirestorageError: Error{
    case invalidImageID
}

final class StorageManager{
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error>{
        return storage
            .reference()
            .child("images/\(randomID).jpg")
            .putData(image, metadata: metaData)
            .eraseToAnyPublisher()
    }
    
    func getDownloadURL(for id: String?) -> AnyPublisher<URL, Error>{
        guard let id = id else{
            return Fail(error: FirestorageError.invalidImageID)
                .eraseToAnyPublisher()
        }
        return storage
            .reference(withPath: id)
            .downloadURL()
            .eraseToAnyPublisher()
        
        
    }
}

