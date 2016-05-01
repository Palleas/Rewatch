//
//  StaticContentProvider.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-05-01.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import ReactiveCocoa

class StaticContentController: ContentController {
    var rawLogin: String?

    struct MockedShow: Show {
        let id: Int
        let title: String
    }

    struct MockedEpisode: Episode {
        let id: Int
        let title: String
        let episode: Int
        let season: Int
        let summary: String
    }

    struct MockedMember: Member {
        let login: String
        let avatar: NSURL?
    }

    func fetchShows() -> SignalProducer<Show, ContentError> {
        let shows: [Show] = [MockedShow(id: 1, title: "Arrow"), MockedShow(id: 2, title: "Doctor Who"), MockedShow(id: 3, title: "Flash")]

        return SignalProducer(values: shows)
    }

    func fetchEpisodes(id: Int) -> SignalProducer<Episode, ContentError> {
        let episode = MockedEpisode(id: 1, title: "Tooth and Claw", episode: 2, season: 2, summary: "Le Docteur et Rose doivent protéger la reine Victoria, mais quelque chose peut-il encore arrêter l'Empire des loups ? Cet épisode est lié aux origines de Torchwood.")

        return SignalProducer(value: episode)
    }

    func fetchPictureForEpisode(id: Int) -> SignalProducer<UIImage, ContentError> {
        let path = NSBundle.mainBundle().pathForResource("doctor-who-episode", ofType: "jpg")!
        let content = NSData(contentsOfFile: path)!
        let image = UIImage(data: content)!

        return SignalProducer(value: image)
    }

    func fetchMemberInfos() -> SignalProducer<Member, ContentError> {
        let url = NSBundle.mainBundle().URLForResource("stripes", withExtension: "png")
        let member = MockedMember(login: "David Tennant", avatar: url)

        return SignalProducer(value: member)
    }
}