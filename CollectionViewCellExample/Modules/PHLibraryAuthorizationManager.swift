//
//  RequestPhotoLibraryAuthorizationController.swift
//  TestTaskTurkcell
//
//  Created by User on 6/23/21.
//

import Foundation
import Photos

enum PhotoLibraryAuthorizationStatus {
    case notRequested
    case granted
    case unauthorized
}

typealias RequestPhotoLibraryAuthCompletionHandler = (PhotoLibraryAuthorizationStatus) -> Void

class PHLibraryAuthorizationManager {
    
    static func requestPhotoLibraryAuthorization(completionHandler: @escaping RequestPhotoLibraryAuthCompletionHandler) {
        DispatchQueue.main.async {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getPhotoLibraryAuthorizationStatus() -> PhotoLibraryAuthorizationStatus {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
