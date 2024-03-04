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
