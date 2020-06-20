//
//  ViewController.swift
//  Earth
//
//  Created by Anastasia Myropolska on 20.06.20.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit

class EarthViewController: UIViewController {

    private let accelerator = EarthAccelerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let earthView = EarthView(frame: CGRect.zero)
        view.addSubview(earthView)
        earthView.translatesAutoresizingMaskIntoConstraints = false
        earthView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor).isActive = true
        earthView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor).isActive = true
        earthView.widthAnchor.constraint(equalTo: earthView.heightAnchor).isActive = true
        earthView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }


}

