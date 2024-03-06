//
//  ProfileDataFormViewController.swift
//  TwitterClone
//
//  Created by Chingiz on 06.03.24.
//

import UIKit
import PhotosUI
import Combine

class ProfileDataFormViewController: UIViewController {
    
    private var viewModel = ProfileDataFormViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.text = "Fill in you data"
        return label
    }()
    
    let displayNameTextField: UITextField = {
        let tf = UITextField()
        //tf.textColor = .label
        tf.translatesAutoresizingMaskIntoConstraints = false
        //tf.tintColor = .systemBlue
        //tf.textAlignment = .center
        //tf.font = .systemFont(ofSize: 17, weight: .semibold)
        
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 8
        tf.backgroundColor = .secondarySystemFill
        tf.keyboardType = .default
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(string: "Display Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        //tf.autocapitalizationType = .sentences
        //tf.autocorrectionType = .default
        
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        //tf.textColor = .label
        tf.translatesAutoresizingMaskIntoConstraints = false
        //tf.tintColor = .systemBlue
        //tf.textAlignment = .center
        //tf.font = .systemFont(ofSize: 17, weight: .semibold)
        
        tf.layer.masksToBounds = true
        tf.layer.cornerRadius = 8
        tf.backgroundColor = .secondarySystemFill
        tf.keyboardType = .default
        
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        tf.leftViewMode = .always
        
        tf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        //tf.autocapitalizationType = .sentences
        //tf.autocorrectionType = .default
        
        return tf
    }()
    
    let avatarPlaceholderImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 60
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .lightGray
        image.image = UIImage(systemName: "camera.fill")
        image.tintColor = .gray
        image.isUserInteractionEnabled = true
        return image
    }()
    
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        textView.backgroundColor = .secondarySystemFill
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .gray
        textView.text = "Tell the world about yourself"
        return textView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.tintColor = .white
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(scrollView)
        scrollView.addSubviews(hintLabel, avatarPlaceholderImageView,
                               displayNameTextField, usernameTextField,
                               bioTextView, submitButton
        )
        bioTextView.delegate = self
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        isModalInPresentation = true
        avatarPlaceholderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUpload)))
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDismiss)))
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        addConstraints()
        bindViews()
    }
    
    private func bindViews(){
        displayNameTextField.addTarget(self, action: #selector(didUpdateDisplayName), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(didUpdateUsername), for: .editingChanged)
        viewModel.$isFormValid.sink { [weak self] buttonState in
            self?.submitButton.isEnabled = buttonState
        }
        .store(in: &subscriptions)
        
        viewModel.$isOnboardingFinished.sink { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)
    }
    
    @objc
    private func didTapSubmit(){
        viewModel.uploadAvatar()
    }
    
    @objc
    private func didTapDismiss(){
        view.endEditing(true)
    }
    
    @objc
    private func didUpdateDisplayName() {
        viewModel.displayName = displayNameTextField.text
        viewModel.validateUserProfileForm()
    }
    
    @objc
    private func didUpdateUsername(){
        viewModel.username = usernameTextField.text
        viewModel.validateUserProfileForm()
    }
    
    @objc
    private func didTapUpload() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            hintLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30),
            
            avatarPlaceholderImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            avatarPlaceholderImageView.heightAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 30),
            
            displayNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayNameTextField.topAnchor.constraint(equalTo: avatarPlaceholderImageView.bottomAnchor, constant: 20),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            usernameTextField.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            usernameTextField.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            usernameTextField.topAnchor.constraint(equalTo: displayNameTextField .bottomAnchor, constant: 20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            bioTextView.leadingAnchor.constraint(equalTo: displayNameTextField.leadingAnchor),
            bioTextView.trailingAnchor.constraint(equalTo: displayNameTextField.trailingAnchor),
            bioTextView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            bioTextView.heightAnchor.constraint(equalToConstant: 150),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20)
        ])
    }
}

extension ProfileDataFormViewController: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 100), animated: true)
        if textView.textColor == .gray {
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        if textView.text.isEmpty{
            textView.textColor = .gray
            textView.text = "Tell the world about yourself"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bio = textView.text
        viewModel.validateUserProfileForm()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension ProfileDataFormViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage{
                    DispatchQueue.main.async {
                        self?.avatarPlaceholderImageView.image = image
                        self?.viewModel.imageData = image
                        self?.viewModel.validateUserProfileForm()
                    }
                }
            }
        }
    }
    
    
}
