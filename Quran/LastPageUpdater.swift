//
//  LastPageUpdater.swift
//  Quran
//
//  Created by Mohamed Afifi on 11/10/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import Foundation

class LastPageUpdater {
    private let persistence: LastPagesPersistence
    private (set) var lastPage: LastPage?

    init(persistence: LastPagesPersistence) {
        self.persistence = persistence
    }

    func configure(initialPage: Int, lastPage: LastPage?) {
        self.lastPage = lastPage

        if lastPage == nil {
            create(page: initialPage)
        } else {
            forceUpdateTo(page: initialPage)
        }
    }

    func updateTo(page: Int) {
        // don't update if it's the same page
        guard let lastPage = lastPage, page != lastPage.page else { return }
        forceUpdateTo(page: page)
    }

    private func forceUpdateTo(page: Int) {
        guard let lastPage = lastPage else { return }
        DispatchQueue.lastPages
            .promise { try self.persistence.update(page: lastPage, toPage: page) }
            .then (on: .main) { self.lastPage = $0 }
            .cauterize(tag: "LastPagesPersistence.update(page:toPage:)")
    }

    private func create(page: Int) {
        DispatchQueue.lastPages
            .promise { try self.persistence.add(page: page) }
            .then (on: .main) { self.lastPage = $0 }
            .cauterize(tag: "LastPagesPersistence.update(page:toPage:)")
    }
}
