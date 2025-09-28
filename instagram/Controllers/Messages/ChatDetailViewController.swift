//
//  ChatDetailViewController.swift
//  instagram
//
//  Created by Müge Deniz on 11.12.2024.
import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation
import SDWebImage
import AVFoundation
import ContactsUI
import MobileCoreServices
import Lightbox
import MapKit

class ChatDetailViewController: MessagesViewController, CLLocationManagerDelegate, CNContactPickerDelegate  {
    var messages: [MessageStruct] = []
    var currentUserModel: UserModel?
    var allUserModel: [UserModel]?
    var user: User?
    var channel: Channel?
    var db = Firestore.firestore()
    var reference: CollectionReference?
    var messageListener: ListenerRegistration?
    var locationManager: CLLocationManager?
    let storage = Storage.storage().reference()
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession?
    let micButton = InputBarButtonItem()
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    init(user: User, channel: Channel) {
        self.user = user
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        messageListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helper.shared.showHud(text: "yukleniyor", view: view)
        setUI()
        setUser()
        configureNavigationBar()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.backgroundColor = .white
    }
    private func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showOptions)
        )
    }
    
    @objc private func showOptions() {
        let alertController = UIAlertController(title: "Seçenekler", message: "Bir işlem seçin", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Galeri", style: .default) { _ in
            self.showImagePicker()
        }
        let docAction = UIAlertAction(title: "Dosyalar", style: .default) { _ in
            self.showDocumentPicker()
        }
        let locationAction = UIAlertAction(title: "Konum Paylaş", style: .default) { _ in
            self.shareLocation()
        }
        let contactAction = UIAlertAction(title: "Kişi Seç", style: .default) { _ in
            self.showContactPicker()
        }
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(docAction)
        alertController.addAction(locationAction)
        alertController.addAction(contactAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func setUI() {
        self.title = "Mesajlar"
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .blue
        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        micButton.image = UIImage(systemName: "mic.fill")
        micButton.tintColor = .blue
        micButton.onTouchUpInside { [weak self] _ in
            self?.recordTapped()
        }
        
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.leftStackView.spacing = 5
        messageInputBar.leftStackView.addArrangedSubview(micButton)
        
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission({ allowed in
                if allowed {
                    print("ZAAART")
                } else {
                    print("ZOOORT")
                }
            })
        } catch {
            print("ZZZOOORT2")
        }
    }
    
    //MARK: - Audio -
    private func recordTapped() {
        let audioFileName = getDocumentDirectory().appendingPathComponent("recording.m4a")
        
        if audioRecorder == nil {
            startRecord()
        } else {
            finishRecord(success: true, url: audioFileName)
        }
    }
    
    private func startRecord() {
        let audioFileName = getDocumentDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            micButton.tintColor = .red
        } catch {
            finishRecord(success: false, url: audioFileName)
        }
    }
    private func finishRecord(success: Bool, url: URL) {
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            micButton.tintColor = .blue
            sendAudio(url: url)
        } else {
            micButton.tintColor = .red
        }
    }
    
    private func sendAudio(url: URL) {
        uploadAudio(url: url) { [weak self] url in
            guard let self else { return }
            guard let audioUrl = url else { return }
            var message = MessageStruct(user: Auth.auth().currentUser!, url: audioUrl)
            message.downloadURL = audioUrl
            save(message: message)
            messagesCollectionView.scrollToLastItem()
        }
    }
    
    private func uploadAudio(url: URL, completion: @escaping(_ url: URL?) -> Void) {
        guard let data = try? Data(contentsOf: url) else { return }
        
        let metaData = StorageMetadata()
        metaData.contentType = "audio/mp3"
        let audioName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child("audio").child(channel?.id ?? "").child(audioName).putData(data, metadata: metaData) { meta, error in
            let filePath = "audio/\(self.channel?.id ?? "")/\(audioName)"
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.storage.child(filePath).downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                completion(url)
            }
        }
    }
    //MARK: -Documents-
    func showDocumentPicker() {
        let supportedTypes = ["com.adobe.pdf", "com.microsoft.word.doc"]
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func uploadDocumentToFirebase(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let fileName = fileURL.lastPathComponent
        let storageRef = Storage.storage().reference().child("documents/\(fileName)")
        
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            if let error = error {
                print("Document upload error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting document URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                
                print("Document uploaded successfully. URL: \(downloadURL.absoluteString)")
                completion(downloadURL)
            }
        }
    }
    
    private func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    //MARK: -CONTACT-
    func showContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
        present(contactPicker, animated: true, completion: nil)
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? "Unknown Name"
        let phoneNumbers = contact.phoneNumbers.map { $0.value.stringValue }
        let emails = contact.emailAddresses.map { $0.value as String }
        
        let contactItem = ShareContactItem(displayName: fullName, initials: fullName, phoneNumbers: phoneNumbers, emails: emails)
        var message = MessageStruct(user: Auth.auth().currentUser!, contact: fullName)
        message.downloadContact = contactItem.displayName
        save(message: message)
    }
    //MARK: -IMAGE-
    func uploadImageToFirebase(image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Görsel yükleme hatası: \(error.localizedDescription)")
                completion(nil)
                return
            }
            ref.downloadURL { url, error in
                if let error = error {
                    print("URL alma hatası: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("Firebase'den gelen URL: \(url?.absoluteString ?? "URL yok")")
                    
                    completion(url)
                }
            }
        }
    }
    
    //MARK: -LOCATION-
    func shareLocation() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        }
        
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            print("Konum alınamadı.")
            return
        }
        
        var message = MessageStruct(user: Auth.auth().currentUser!, location: location)
        message.downloadLocation = GeoPoint(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        save(message: message)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hatası: \(error.localizedDescription)")
    }
    
    private func setUser() {
        FirebaseManager.shared.getUserData { userModelData in
            self.currentUserModel = userModelData
            self.getAllUser()
        }
    }
    
    private func getAllUser() {
        FirebaseManager.shared.fetchUsersData { userModelData in
            self.allUserModel = userModelData
            self.initChat()
        }
    }
    
    private func save(message: MessageStruct) {
        reference?.addDocument(data: message.representation) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    private func initChat() {
        Helper.shared.hideHud()
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        guard let id = channel?.id else {
            return
        }
        if channel?.otherUserId?.contains(userID) == true {
            reference = db.collection(["channels", id, "thread"].joined(separator: "/"))
            messageListener = reference?.order(by: "created", descending: false).addSnapshotListener({ querySnapShot, error in
                guard let snapSt = querySnapShot else {
                    print(error?.localizedDescription ?? "")
                    return
                }
                snapSt.documentChanges.forEach { change in
                    self.handleDocumentChange(change: change)
                }
            })
        }
    }
    
    private func handleDocumentChange(change: DocumentChange) {
        guard var message = MessageStruct(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                if url.absoluteString.contains("images") {
                    downloadImage(url: url) { image in
                        guard let image = image else {
                            print("Görsel indirilemedi.")
                            return
                        }
                        print("Görsel başarıyla indirildi.")
                        message.image = ImageMediaItem(image: image)
                        self.insertMessage(message: message)
                    }
                } else if url.absoluteString.contains("audio") {
                    message.audio = AudioMediaItem(url: url)
                    self.insertMessage(message: message)
                }
            } else if let contact = message.downloadContact {
                message.contact = ShareContactItem(displayName: contact, initials: "")
                self.insertMessage(message: message)
            } else if let userLocation = message.downloadLocation {
                message.location = CoordinateItem(location: CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude))
                self.insertMessage(message: message)
            } else {
                self.insertMessage(message: message)
            }
            
        default:
            break
        }
    }
    
    
    private func insertMessage(message: MessageStruct) {
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(10 * 1024 * 1024)
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: imageData)
            completion(image)
        }
    }
}

extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let message = MessageStruct(user: currentUser, content: text)
        save(message: message)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
}

extension ChatDetailViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == Auth.auth().currentUser?.uid {
            let url = URL(string: currentUserModel?.profilePhoto ?? "")
            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { image, data, error, cacheType, isFinish, imageUrl in
                avatarView.image = image
            }
        } else {
            let otherPerson = channel?.otherUserId?.filter { $0 != Auth.auth().currentUser?.uid }.first
            for index in 0..<(allUserModel?.count ?? 0) {
                if allUserModel?[index].userId == otherPerson {
                    let userPhotoUrl = URL(string: allUserModel?[index].profilePhoto ?? "")
                    SDWebImageManager.shared.loadImage(with: userPhotoUrl, options: .highPriority, progress: nil) { image, data, error, cacheType, isFinish, imageUrl in
                        avatarView.image = image
                    }
                }
            }
        }
    }
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .lightGray
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case .audio = message.kind {
            imageView.image = UIImage(systemName: "waveform.circle")
            imageView.tintColor = .systemBlue
        } else if case let .photo(mediaItem) = message.kind {
            if let imageItem = mediaItem as? ImageMediaItem {
                imageView.image = imageItem.image
            }
        }
    }
    
    @objc func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            return
        }
        
        if case .photo(let mediaItem) = message.kind, let image = mediaItem.image {
            let imageItem = LightboxImage(image: image)
            let lightbox = LightboxController(images: [imageItem])
            lightbox.modalPresentationStyle = .fullScreen
            present(lightbox, animated: true, completion: nil)
        }
    }
    func didTapMessage(in cell: MessageCollectionViewCell) { 
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              case .location(let locationItem) = messages[indexPath.section].kind else { return }

        let mapViewController = MapViewController()
        let region = MKCoordinateRegion(
            center: locationItem.location.coordinate,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapViewController.region = region
        navigationController?.pushViewController(mapViewController, animated: true)
    }

}

extension ChatDetailViewController: MessageCellDelegate {
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
}

extension ChatDetailViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return Sender(senderId: Auth.auth().currentUser?.uid ?? "", displayName: user?.displayName ?? "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}



extension ChatDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            uploadImageToFirebase(image: image) { url in
                if let downloadURL = url {
                    print("Fotoğraf URL'si başarıyla alındı: \(downloadURL.absoluteString)")
                    var message = MessageStruct(user: Auth.auth().currentUser!, image: image)
                    message.downloadURL = downloadURL
                    self.save(message: message)
                } else {
                    print("Fotoğraf Firebase'e yüklenemedi.")
                }
            }
        }
    }
}


extension ChatDetailViewController: AVAudioRecorderDelegate {
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
            return
        }
        
        guard audioController.state != .stopped else {
            audioController.playSound(for: message, in: cell)
            return
        }
        
        if audioController.playingMessage?.messageId == message.messageId {
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
}
extension ChatDetailViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        var message = MessageStruct(user: Auth.auth().currentUser!, url: selectedFileURL)
        message.downloadURL = selectedFileURL
        self.save(message: message)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Dokuman indirme iptal edildi/")
    }
}
