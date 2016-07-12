//
//  ContentViewController.swift
//  FaceIt
//
//  Created by Ivan Lazarev on 12.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

extension UIViewController {
    var contentViewController: UIViewController{
        if let navcon = self as? UINavigationController{
            return navcon.visibleViewController ?? self
        } else{
            return self
        }
    }
}