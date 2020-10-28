//
//  EasyAlbumCameraVC.swift
//  EasyAlbum
//
//  Created by Ray on 2019/3/3.
//  Copyright © 2019 Ray. All rights reserved.
//

import UIKit

class EasyAlbumCameraVC: UIImagePickerController {

    var isEdit: Bool = false {
        didSet {
            allowsEditing = isEdit
            sourceType = .camera
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) == false {
            dismiss(animated: true, completion: nil)
        }
        
        delegate = self
    }
    
    private func didFinishTakePhoto(_ picker: UIImagePickerController, image: UIImage?) {
        // Use UIImageWriteToSavedPhotosAlbum, because after take photo no path so take photo to save album.
        guard let image = image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(handleSavePhoto(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
        isFromEasyAlbumCamera = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleSavePhoto(_ image: UIImage,
                                       didFinishSavingWithError error: NSError?,
                                       contextInfo: UnsafeRawPointer) {
        // do nothing
    }
}

extension EasyAlbumCameraVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         .editedImage(UIImage)        = nil (需搭配allowsEditing = true)
         .cropRect(CGRect)            = nil (需搭配allowsEditing = true)
         .originalImage(UIImage)      = <UIImage: 0x282d84310> size {3024, 4032} orientation 3 scale 1.000000
         .referenceURL(NSURL)         = nil (iOS 11.0 up use info[UIImagePickerController.InfoKey.phAsset])
         .imageURL(NSURL)             = nil (sourceType can't be .camera)
         .phAsset(PHAsset)            = nil (sourceType can't be .camera)
         .livePhoto(PHLivePhoto)      = nil (sourceType can't be .camera)
         .mediaMetadata(NSDictionary) = a lot of
         .mediaType                   = public.image
         .mediaURL                    = nil (sourceType can't be .camera)
         */

        var image: UIImage?
        if let img = info[.editedImage] as? UIImage {
            image = img
        } else if let img = info[.originalImage] as? UIImage {
            image = img
        }
        
        didFinishTakePhoto(picker, image: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
