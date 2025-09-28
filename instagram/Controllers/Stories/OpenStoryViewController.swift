import UIKit
import SDWebImage
import FirebaseAuth

class OpenStoryViewController: UIViewController {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var storypicImage: UIImageView!
    @IBOutlet weak var userNickNameLabel: UILabel!
    @IBOutlet weak var storyMessageTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var storyProgressView: UIProgressView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!

    var users: [UserModel] = []
    var currentUserIndex: Int = 0
    var currentStoryIndex: Int = 0
    var progress: Float = 0.0
    var timer: Timer?
    var stories: [String]?
    var user: UserModel?
    var storyDuration: TimeInterval = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.isHidden = false
        userNickNameLabel.isHidden = false
        
        stories = user?.userStory
        loadUserStories()
        setupGestures()
        setupProfilePhoto()
        
        storyProgressView.progressTintColor = UIColor.white
        storyProgressView.trackTintColor = UIColor.lightGray
        
        storyProgressView.progress = 0.0
        startProgress()
        rightButton.isUserInteractionEnabled = true
            leftButton.isUserInteractionEnabled = true
    }

    func setupProfilePhoto() {
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
    }

//    func setupGestures() {
//        storypicImage.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightTapped))
//        storypicImage.addGestureRecognizer(tapGesture)
//    }
    func setupGestures() {
        storypicImage.isUserInteractionEnabled = true
        
        let rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRightTap))
        rightTapGesture.numberOfTapsRequired = 1
        storypicImage.addGestureRecognizer(rightTapGesture)

        let leftTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeftTap))
        leftTapGesture.numberOfTapsRequired = 1
        storypicImage.addGestureRecognizer(leftTapGesture)
    }

    @objc func handleRightTap(_ gesture: UITapGestureRecognizer) {
        moveToNextStory()
    }

    @objc func handleLeftTap(_ gesture: UITapGestureRecognizer) {
        moveToPreviousStory()
    }

    func moveToNextStory() {
        if let stories = stories, currentStoryIndex < stories.count - 1 {
            currentStoryIndex += 1
            loadUserStories()
            startProgress()
        } else {
            dismiss(animated: true)         }
    }

    func moveToPreviousStory() {
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
            loadUserStories()
            startProgress()
        } else {
            print("Bu, kullanıcının ilk hikayesi.")
        }
    }

    @objc func rightTapped() {
        if currentStoryIndex < (stories?.count ?? 0) - 1 {
            currentStoryIndex += 1
            loadUserStories()
            startProgress()
        } else {
            dismiss(animated: true)
        }
    }
    
    private func loadUserStories() {
        guard let stories = stories, !stories.isEmpty else {
            print("Stories array is empty or nil.")
            return
        }
        
        guard currentStoryIndex >= 0, currentStoryIndex < stories.count else {
            print("Invalid currentStoryIndex: \(currentStoryIndex).")
            return
        }
        
        guard let url = URL(string: stories[currentStoryIndex]) else {
            print("Invalid URL for the current story.")
            return
        }
        
        storypicImage.sd_setImage(with: url)
        
        if let user = user {
            if let profilePhotoURL = user.profilePhoto, let profileURL = URL(string: profilePhotoURL) {
                profilePhoto.sd_setImage(with: profileURL, completed: nil)
            } else {
                print("Invalid user profile photo URL.")
            }
            userNickNameLabel.text = user.userNickName
        }
    }

    func startProgress() {
        progress = 0.0
        storyProgressView.progress = progress
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }

    @objc func updateProgress() {
        progress += 0.05 / Float(storyDuration)
        storyProgressView.setProgress(progress, animated: true)

        if progress >= 1.0 {
            timer?.invalidate()
            moveToNextStory()
        }
    }
    @IBAction func rightButtonTapped(_ sender: UIButton) {
        moveToNextStory()
    }

    @IBAction func leftButtonTapped(_ sender: UIButton) {
        moveToPreviousStory()
    }

    @IBAction func closeButtonAction() {
        timer?.invalidate()
        dismiss(animated: true, completion: nil)
    }
}

