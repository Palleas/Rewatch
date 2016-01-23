//
//  MockClient.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-12-30.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class MockClient: Client {

    init() {
        super.init(key: "some-key", secret: "some-secret")
    }
    
    override func authorize() -> SignalProducer<String, NSError> {
        return SignalProducer(value: "here is a token of my affection")
    }
    
    override func fetchShows() -> SignalProducer<Client.Show, NSError> {
        let doctorWho = Client.Show(id: 1, name: "Doctor Who")
        
        return SignalProducer(value: doctorWho)
    }
    
    override func fetchEpisodesFromShow(showId: Int) -> SignalProducer<Client.Episode, NSError> {
        
        let episode = Episode(id: 1, title: "Tooth and Claw", episode: 2, season: 2, summary: "Le Docteur et Rose doivent protéger la reine Victoria, mais quelque chose peut-il encore arrêter l'Empire des loups ? Cet épisode est lié aux origines de Torchwood.", seen: true)
        
        return SignalProducer(value: episode)
    }
    
    override func fetchPictureForEpisodeId(id: String) -> SignalProducer<UIImage, NSError> {
        let path = NSBundle.mainBundle().pathForResource("doctor-who-episode", ofType: "jpg")!
        let content = NSData(contentsOfFile: path)!
        let image = UIImage(data: content)!
        
        return SignalProducer(value: image)
    }
    
    override func fetchMemberInfos() -> SignalProducer<Client.Member, NSError> {
        let url = NSBundle.mainBundle().URLForResource("stripes", withExtension: "png")
        let member = Client.Member(id: 1, login: "David Tennant", avatar: url)
        
        return SignalProducer(value: member)
    }
}
