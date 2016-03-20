//
//  ContentController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-19.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import BetaSeriesKit
import ReactiveCocoa

protocol Show {
    var id: Int { get }
    var name: String { get }
}

protocol Episode {
    var id: Int { get }
    var title: String { get }
    var episode: Int { get }
    var season: Int { get }
    var summary: String { get }
}

struct BetaseriesShow: Show {
    let wrappedShow: BetaSeriesKit.Show
    
    var id: Int {
        return wrappedShow.id
    }
    
    var name: String {
        return wrappedShow.name
    }
    
    init(wrappedShow: BetaSeriesKit.Show) {
        self.wrappedShow = wrappedShow
    }
}

struct BetaseriesEpisode: Episode {
    let wrappedEpisode: BetaSeriesKit.Episode
    
    init(wrappedEpisode: BetaSeriesKit.Episode) {
        self.wrappedEpisode = wrappedEpisode
    }
    
    var id: Int {
        return wrappedEpisode.id
    }
    
    var title: String {
        return wrappedEpisode.title
    }
    
    var episode: Int {
        return wrappedEpisode.episode
    }
    
    var season: Int {
        return wrappedEpisode.season
    }
    
    var summary: String {
        return wrappedEpisode.summary
    }
    
}

enum ContentError: ErrorType {
    case ClientError
    case UnauthenticatedError
}

protocol ContentController {

    var rawLogin: String? { get }
    
    func fetchShows() -> SignalProducer<Show, ContentError>
    func fetchEpisodes(show: Show) -> SignalProducer<Episode, ContentError>
    
}

class UnauthenticatedContentController: ContentController {
    
    var rawLogin: String? {
        return nil
    }
    
    func fetchEpisodes(show: Show) -> SignalProducer<Episode, ContentError> {
        return SignalProducer(error: .UnauthenticatedError)
    }
    
    func fetchShows() -> SignalProducer<Show, ContentError> {
        return SignalProducer(error: .UnauthenticatedError)
    }
}

class BetaseriesContentController: ContentController {
    
    let authenticatedClient: AuthenticatedClient

    var rawLogin: String? {
        return authenticatedClient.token
    }

    init(authenticatedClient: AuthenticatedClient) {
        self.authenticatedClient = authenticatedClient
    }
    
    func fetchEpisodes(show: Show) -> SignalProducer<Episode, ContentError> {
        guard let betaseriesShow = show as? BetaseriesShow else { return SignalProducer(error: ContentError.ClientError) }
        
        let episodes = authenticatedClient
            .fetchEpisodes(betaseriesShow.wrappedShow)
            .flatMapError { _ in return SignalProducer(error: ContentError.ClientError) }

        return episodes.map { episode in BetaseriesEpisode(wrappedEpisode: episode) }
    }
    
    func fetchShows() -> SignalProducer<Show, ContentError> {
        return authenticatedClient
            .fetchShows()
            .map { show in BetaseriesShow(wrappedShow: show) }
            .flatMapError { _ in return SignalProducer(error: ContentError.ClientError) }
    }
    
}