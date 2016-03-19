//
//  ViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa
import BetaSeriesKit

class WTFController: NetworkController {}

class LoginViewController: UIViewController {
    let persistenceController: PersistenceController

    var loginView: LoginView {
        get {
            return view as! LoginView
        }
    }
    
    private let networkController = MutableProperty<NetworkController>(WTFController())
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.delegate = self
        
        title = "REWATCH"
        view.backgroundColor = Stylesheet.appBackgroundColor
    }
}

extension LoginViewController: LoginViewDelegate {

    func didStartAuthenticationInLoginView(loginView: LoginView) {
        let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]
        let client = BetaSeriesKit.Client(key: keys["BetaseriesAPIKey"]!)
        let secret = keys["BetaseriesAPISecret"]!
        
        let producer: SignalProducer<NetworkController, AuthenticationFlowError> = BetaseriesAuthenticationFlow(client: client, secret: secret)
            .signalProducer
//            .promoteErrors(NSError)
//            .flatMap(FlattenStrategy.Latest) { (client) -> SignalProducer<NetworkController, NoError> in
//                return SignalProducer<NetworkController, NoError>(value: BetaseriesNetworkController(client: client))
//            }
//            .flatMap(FlattenStrategy.Latest) {
//            }
//            .map { BetaseriesNetworkController(client: $0) }
        
//        networkController <~ producer
        
        producer.startWithNext {
                print("Possible Network controller: \($0)")
            }
    }
}
