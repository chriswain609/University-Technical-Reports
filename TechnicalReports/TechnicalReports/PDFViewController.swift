//
//  PDFViewController.swift
//  TechnicalReports
//
//  Created by Christopher Wainwright on 06/11/2018.
//  Copyright © 2018 Christopher Wainwright. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    // url variable called when prepare for segue to this view
    var pdfUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // create a pdf view and set constraints to fill screen
        let pdfView = PDFView()
        
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // display the document at url in the pdf view
        if let document = PDFDocument(url: pdfUrl!) {
            pdfView.document = document
        }
    }
}
