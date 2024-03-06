//
//  TweetComposeViewController.swift
//  TwitterClone
//
//  Created by Chingiz on 06.03.24.
//

import UIKit
import Combine

class TweetComposeViewController: UIViewController {
    
    private var viewModel = TweetComposeViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let tweetButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tweet", for: .normal)
        button.backgroundColor = UIColor.twitterBlue
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.7), for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private let tweetContentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.systemBlue]
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .gray
        textView.text = "What's happening"
        return textView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Tweet"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))
        view.addSubviews(tweetButton, tweetContentTextView)
        addConstraints()
        tweetContentTextView.delegate = self
        bindViews()
        tweetButton.addTarget(self, action: #selector(didTapRetweet), for: .touchUpInside)
    }
    
    @objc private func didTapRetweet(){
        viewModel.dispatchTweet()
    }
    
    @objc
    private func didTapCancel(){
        dismiss(animated: true)
    }
    
    private func bindViews(){
        viewModel.$isValidToTweet.sink { [weak self] state in
            self?.tweetButton.isEnabled = state
        }
        .store(in: &subscriptions)
        
        viewModel.$shouldDismissComposer.sink { [weak self] success in
            if success {
                self?.dismiss(animated: true)
            }
        }
        .store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getUserData()
    }
    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            tweetButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            tweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tweetButton.widthAnchor.constraint(equalToConstant: 120),
            tweetButton.heightAnchor.constraint(equalToConstant: 40),
            
            tweetContentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tweetContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tweetContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tweetContentTextView.bottomAnchor.constraint(equalTo: tweetButton.topAnchor, constant: -10)
        ])
    }
}

extension TweetComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.textColor = .gray
            textView.text = "What's happening"
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.tweetContent = textView.text
        viewModel.validateTweet()
    }
}
