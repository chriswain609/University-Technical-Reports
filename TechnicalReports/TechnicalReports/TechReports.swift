//
//  TechReports.swift
//  TechnicalReports
//
//  Created by Christopher Wainwright on 01/11/2018.
//  Copyright © 2018 Christopher Wainwright. All rights reserved.
//

import Foundation

// this is the structure of each tech report to be decoded
struct TechReports: Decodable {
    let year: String
    let id: String
    let owner: String?
    let authors: String
    let title: String
    let abstract: String?
    let pdf: URL?
    let comment: String?
    let lastModified: String
}
