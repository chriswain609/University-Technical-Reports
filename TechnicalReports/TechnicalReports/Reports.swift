//
//  Reports.swift
//  TechnicalReports
//
//  Created by Christopher Wainwright on 01/11/2018.
//  Copyright © 2018 Christopher Wainwright. All rights reserved.
//

import Foundation

// this is the structure of the json file to be decoded
// an array of tech reports
struct Reports: Decodable {
    let techreports: [TechReports]?
}

