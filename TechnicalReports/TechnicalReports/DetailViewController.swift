//
//  DetailViewController.swift
//  TechnicalReports
//
//  Created by Christopher Wainwright on 29/10/2018.
//  Copyright © 2018 Christopher Wainwright. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    // variable that will be called in view controller so prepare for segue
    var report: TechReports?
    
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pdfBtn: UIButton!
    @IBOutlet weak var abstractTextView: UITextView!
    
    
    // pass the reports pdf link to the pdf view when segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPDFView" {
            let pdfViewController = segue.destination as! PDFViewController
            pdfViewController.pdfUrl = report?.pdf
        }
    }
    
    // display abstract text view from first line of text
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        abstractTextView.setContentOffset(.zero, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // output the title and authors of report
        titleLabel.text = report!.title
        authorsLabel.text = report!.authors
        
        // check for abstract and display if possible
        // if not then display message
        if report!.abstract != nil {
            abstractTextView.text = report!.abstract
        } else {
            abstractTextView.textAlignment = NSTextAlignment.center
        }
        
        // check if the file at url is a pdf and if there is a url
        // if not then disable button and display message
        if report!.pdf == nil {
            pdfBtn.isEnabled = false
            pdfBtn.setTitle("No PDF available", for: .normal)
        }else if report!.pdf!.absoluteString.suffix(3) != "pdf" {
            pdfBtn.isEnabled = false
            pdfBtn.setTitle("No PDF available", for: .normal)
        } else {
            pdfBtn.isEnabled = true
            pdfBtn.setTitle("PDF", for: .normal)
        }
        
    }
}
