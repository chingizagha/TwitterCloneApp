//
//  HomeViewController.swift
//  TwitterClone
//
//  Created by Chingiz on 04.03.24.
//

import UIKit
import FirebaseAuth
import Firebase
import Combine

class HomeViewController: UIViewController {
    
    private var viewModel = HomeViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []
    private var tweets: [Tweet] = []
    
    private func configureNavigationBar() {
        let size: CGFloat = 36
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "logo")
        
        let middleView = UIView(frame:  CGRect(x: 0, y: 0, width: size, height: size))
        middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
    }
    
    private lazy var composeTweetButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction{ [weak self] _ in
            self?.navigateToTweetComopser()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.twitterBlue
        button.tintColor = .white
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
    
    private func navigateToTweetComopser(){
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc
    private func didTapSignOut() {
        try? Auth.auth().signOut()
        handleAuthentication()
    }
    
    private let timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(timelineTableView, composeTweetButton)
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        configureNavigationBar()
        bindViews()
        addConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        handleAuthentication()
        viewModel.retreiveUser()
    }
    
    private func handleAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    @objc
    private func didTapProfile(){
        let vc = ProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func bindViews(){
        viewModel.$user.sink { [weak self] user in
            guard let user = user else {return}
            if !user.isUserOnboarded {
                self?.completeUserOnboarding()
            }
        }
        .store(in: &subscriptions)
        
        viewModel.$tweets.sink { [weak self] tweets in
            self?.tweets = tweets
            DispatchQueue.main.async {
                self?.timelineTableView.reloadData()
            }
        }
        .store(in: &subscriptions)
    }
    
    func completeUserOnboarding(){
        let vc = ProfileDataFormViewController()
        present(vc, animated: true)
    }

    
    private func addConstraints(){
        NSLayoutConstraint.activate([
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {fatalError()}
        let tweet = tweets[indexPath.row]
        cell.configure(with: tweet)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 120
//    }
    
}
