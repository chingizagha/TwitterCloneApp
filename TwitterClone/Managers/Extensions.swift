//
//  Extensions.swift
//  TwitterClone
//
//  Created by Chingiz on 04.03.24.
//

import UIKit

extension UIView{
    func addSubviews(_ views: UIView...){
        views.forEach({
            addSubview($0)
        })
    }
}

extension UIColor{
    static let twitterBlue = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
    
}
