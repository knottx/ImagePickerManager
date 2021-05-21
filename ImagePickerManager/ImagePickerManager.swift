//
//  ImagePickerManager.swift
//  ImagePickerManager
//
//  Created by Visarut Tippun on 21/5/21.
//

import UIKit
import Photos

public enum ImagePickerAccessType {
    case camera
    case photoLibrary
    
    public var message: String? {
        switch self {
        case .camera:
            return Bundle.main.object(forInfoDictionaryKey: "NSCameraUsageDescription") as? String
        case .photoLibrary:
            return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as? String
        }
    }
    
}

public class ImagePickerManager: NSObject {
    
    public static let shared:ImagePickerManager = ImagePickerManager()
    
    public var cameraTitle: String = "Camera"
    public var photoLibraryTitle: String = "Photo Library"
    public var deleteTitle: String = "Delete"
    public var cancelTitle: String = "Cancel"
    public var openSettingsTitle: String = "Open Settings"
    
    public var errorCameraTitle: String = "Open Settings"
    public var errorCameraMessage: String? = nil
    public var errorPhotoLibraryTitle: String = "Open Settings"
    public var erorrPhotoLibraryMessage: String? = nil
    
    
    private var imagePickerViewController: UIImagePickerController?
    private var onCompleted: ((UIImage?) -> ())?
    private var onCancel: (() -> ())?
    private var allowEditing: Bool = false
    
    public func setButtonTitle(camera:String? = nil, photoLibrary:String? = nil, delete:String? = nil,
                               cancel:String? = nil, openSettings:String? = nil) {
        self.cameraTitle = camera ?? self.cameraTitle
        self.photoLibraryTitle = photoLibrary ?? self.photoLibraryTitle
        self.deleteTitle = delete ?? self.deleteTitle
        self.cancelTitle = cancel ?? self.cancelTitle
        self.openSettingsTitle = openSettings ?? self.openSettingsTitle
    }
    
    public func setErrorMessage(type:ImagePickerAccessType, title:String, message:String?) {
        switch type {
        case .camera:
            self.errorCameraTitle = title
            self.errorCameraMessage = message
        case .photoLibrary:
            self.errorPhotoLibraryTitle = title
            self.erorrPhotoLibraryMessage = message
        }
    }
    
    
    //MARK: - Check Available
    
    public func isCameraAvailable() -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        default: return false
        }
    }
    
    public func isPhotoLibraryAvailable() -> Bool {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited: return true
        default: return false
        }
    }
    
    
    //MARK: - Camera
    
    public func requestCameraAccess(at viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    completion(true)
                }else{
                    self?.alertOpenSettings(from: viewController, type: .camera) {
                        completion(false)
                    }
                }
            }
        default:
            self.alertOpenSettings(from: viewController, type: .camera) {
                completion(false)
            }
        }
    }
    
    
    //MARK: - Photo Library
    
    public func requestPhotoLibraryAccess(at viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized, .limited:
                    completion(true)
                default:
                    self?.alertOpenSettings(from: viewController, type: .photoLibrary) {
                        completion(false)
                    }
                }
            }
        default:
            self.alertOpenSettings(from: viewController, type: .photoLibrary) {
                completion(false)
            }
        }
    }
    
    
    //MARK: - Camera and Photo Library
    
    public func requestCameraAndPhotoAccess(at viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        self.requestCamera(from: viewController) {
            self.requestPhotoLibrary(from: viewController) { granted in
                completion(granted)
            }
        }
    }
    
    private func requestCamera(from viewController: UIViewController, completion: @escaping () -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion()
            }
        default:
            self.alertOpenSettings(from: viewController, type: .camera) {
                completion()
            }
        }
    }
    
    private func requestPhotoLibrary(from viewController: UIViewController, completion: @escaping (Bool) -> ()) {
        let isCameraAvailable = self.isCameraAvailable()
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                switch status {
                case .authorized, .limited:
                    completion(true)
                default:
                    if isCameraAvailable {
                        completion(true)
                    }else{
                        self?.alertOpenSettings(from: viewController, type: .photoLibrary) {
                            completion(false)
                        }
                    }
                }
            }
        default:
            self.alertOpenSettings(from: viewController, type: .photoLibrary) {
                completion(isCameraAvailable)
            }
        }
    }
    
    //MARK: - Alert Open Settings
    
    private func alertOpenSettings(from viewController: UIViewController, type:ImagePickerAccessType, cancelCompletion: (() -> ())? = nil) {
        DispatchQueue.main.async { [weak self] in
            var title:String? = nil
            var message:String? = nil
            switch type {
            case .camera:
                title = self?.errorCameraTitle
                message = self?.errorCameraMessage ?? type.message
            case .photoLibrary:
                title = self?.errorPhotoLibraryTitle
                message = self?.erorrPhotoLibraryMessage ?? type.message
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: self?.cancelTitle, style: .cancel) { _ in
                cancelCompletion?()
            }
            alertController.addAction(cancel)
            
            let openSettings = UIAlertAction(title: self?.openSettingsTitle, style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            alertController.addAction(openSettings)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Present ImagePicker
    
    public func presentImagePicker(at viewController: UIViewController, title:String?, message:String?, allowEditing: Bool,
                                   onCompleted: @escaping (UIImage?) -> (),
                                   onCancel: (() -> ())? = nil,
                                   onDelete: (() -> ())? = nil) {
        self.requestCameraAndPhotoAccess(at: viewController) { [weak self] granted in
            if granted, let `self` = self {
                self.showSelectSource(at: viewController, title: title, message: message, allowEditing: allowEditing,
                                      onCompleted: onCompleted, onCancel: onCancel, onDelete: onDelete)
            }else{
                onCancel?()
            }
        }
    }
    
    private func showSelectSource(at viewController: UIViewController, title:String?, message:String?, allowEditing: Bool,
                                   onCompleted: @escaping (UIImage?) -> (),
                                   onCancel: (() -> ())?,
                                   onDelete: (() -> ())?) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let isCameraAvailable = self.isCameraAvailable()
            let isPhotoLibraryAvailable = self.isPhotoLibraryAvailable()
            guard isCameraAvailable || isPhotoLibraryAvailable else {
                onCancel?()
                return
            }
            
            if self.imagePickerViewController == nil {
                self.imagePickerViewController = UIImagePickerController()
                self.imagePickerViewController!.delegate = self
            }
            self.imagePickerViewController!.allowsEditing = allowEditing
            
            self.allowEditing = allowEditing
            self.onCompleted = onCompleted
            self.onCancel = onCancel
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            if isCameraAvailable {
                let camera = UIAlertAction(title: self.cameraTitle, style: .default) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.imagePickerViewController!.sourceType = .camera
                    viewController.present(self.imagePickerViewController!, animated: true, completion: nil)
                }
                alertController.addAction(camera)
            }
            
            if isPhotoLibraryAvailable {
                let photoLibrary = UIAlertAction(title: self.photoLibraryTitle, style: .default) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.imagePickerViewController!.sourceType = .photoLibrary
                    viewController.present(self.imagePickerViewController!, animated: true, completion: nil)
                }
                alertController.addAction(photoLibrary)
            }
            
            
            if onDelete != nil {
                let delete = UIAlertAction(title: self.deleteTitle, style: .destructive) { _ in
                    onDelete?()
                }
                alertController.addAction(delete)
            }
            
            let cancel = UIAlertAction(title: self.cancelTitle, style: .cancel) { _ in
                onCancel?()
            }
            alertController.addAction(cancel)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.onCancel?()
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let editedImage = info[.editedImage] as? UIImage
        let originalImage = info[.originalImage] as? UIImage
        self.onCompleted?(self.allowEditing ? editedImage : originalImage)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
