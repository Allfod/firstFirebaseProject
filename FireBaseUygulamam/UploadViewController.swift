//
//  UploadViewController.swift
//  FireBaseUygulamam
//
//  Created by Vural ÇETİN on 18.07.2021.
//

import UIKit
import Firebase

class UploadViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
   @IBOutlet weak var yorumTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(gestureRecognizer)

        // Do any additional setup after loading the view.
    }
    @objc func gorselSec() {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func uploadTiklandi(_ sender: Any) {
        let storage = Storage.storage()
        let storageReferance = storage.reference()
        let mediaFolder = storageReferance.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageReferance = mediaFolder.child("\(uuid).jpg")
            imageReferance.putData(data, metadata: nil) { storagemetadata, error in
                if error != nil {
                    self.hataMesajiGoster(title: "Hata", message: error?.localizedDescription ?? "Hata aldınız tekrar deneyin.")
                    
                }else {
                    imageReferance.downloadURL { url, error in
                        if error == nil {
                            let imageURL = url?.absoluteString
                            if let imageUrl = imageURL {
                                let firestoreDatabase = Firestore.firestore()
                                let firestorePost = ["gorselurl" : imageUrl ,"yorum" : self.yorumTextField.text,"email" : Auth.auth().currentUser!.email, "tarih" : FieldValue.serverTimestamp() ] as [String : Any]
                                
                                firestoreDatabase.collection("Post").addDocument(data: firestorePost) { (error) in
                                    if error != nil {
                                        self.hataMesajiGoster(title: "Hata", message: error?.localizedDescription ?? "Hata aldınız , tekrar deneyiniz")
                                        
                                    
                                    }else {
                                        self.imageView.image = UIImage(named: "gorselsec")
                                        self.yorumTextField.text = ""
                                        self.tabBarController?.selectedIndex = 0
                                        
                                }
                                
                            }
                            
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    }
    func  hataMesajiGoster (title : String , message : String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
}

