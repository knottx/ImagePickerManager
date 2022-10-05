# ImagePickerManager
ImagePickerManager

## 📲 Installation

`ImagePickerManager` is available on [CocoaPods](https://cocoapods.org/pods/ImagePickerManager):
```ruby
pod 'ImagePickerManager'
```

*Swift Package Manager**

* File > Swift Packages > Add Package Dependency
* Add `https://github.com/knottx/ImagePickerManager.git`
* Select "Up to Next Major" with "1.0.0"

## 📝 How
### Code Implementation
```swift
import ImagePickerManager
````

Request access only Camera
```swift
ImagePickerManager.shared.requestCameraAccess(at: self) { granted in
    guard granted else { return }
    // handle after Camera authorized.
}
```

Request access only Photo Library
```swift
ImagePickerManager.shared.requestPhotoLibraryAccess(at: self) { granted in
    guard granted else { return }
    // handle after Photo Library authorized.
}
```

Request access Camera and Photo Library
```swift
ImagePickerManager.shared.requestCameraAndPhotoAccess(at: self) { [weak self] granted in
    guard granted else { return }
    // handle after Camera and Photo Library authorized.
}
```

Present ImagePicker (Request access Camera and Photo Library Automatically):
```swift
ImagePickerManager.shared.presentImagePicker(at: self, title: <String?>, message: <String?>, allowEditing: <Bool>) { image in
    print("Has Image: \(image != nil)")
    // handle after get image.
} onCancel: {
    // handle did Cancel.
} onDelete: {
    // handle did Delete 
    // if remove onDelete will not show "Delete" button.
}
```

## 📋 Requirements

* iOS 10.0+
* Xcode 12+
* Swift 5.1+
