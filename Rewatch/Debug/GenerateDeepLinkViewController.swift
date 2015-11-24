//
//  GenerateDeepLinkViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import Mustache
import Swifter

class GenerateDeepLinkViewController: UIViewController {
    lazy private(set) var template: Template? = {
        return try? Template(named: "generate-deeplink")
    }()
    
    lazy var server = HttpServer()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .yellowColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        do {
            guard let result = try template?.render(Box(["episode": "239502"])) else { return }
            guard let encodedPage = result.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else { return }
            
            server["/save"] = { _ in
                return HttpResponse.MovedPermanently("data:text/html;charset=utf-8,%3C!DOCTYPE%20html%3E%0A%0A%3Chtml%20class=%22no-js%22%3E%20%0A%09%3Chead%3E%0A%09%09%3Cmeta%20charset=%22utf-8%22%3E%0A%09%09%3Cmeta%20http-equiv=%22X-UA-Compatible%22%20content=%22IE=edge%22%3E%0A%09%09%3Ctitle%3ECreate%20Deeplink%3C/title%3E%0A%09%09%3Cmeta%20name=%22viewport%22%20content=%22width=device-width,%20initial-scale=1%22%3E%0A%09%3C/head%3E%0A%0A%09%3Cbody%3E%0A%09%09%3Ch1%3EEpisode%20239502%3C/h1%3E%0A%09%3C/body%3E%0A%3C/html%3E")
            }
            
            try server.start()
            
            UIApplication.sharedApplication().openURL(NSURL(string: "http://localhost:8080/save")!)
        } catch {
            print("Unable to generate page: \(error)")
        }
    }
}
