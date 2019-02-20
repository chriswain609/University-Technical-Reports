//
//  ViewController.swift
//  TechnicalReports
//
//  Created by Christopher Wainwright on 29/10/2018.
//  Copyright © 2018 Christopher Wainwright. All rights reserved.
//  ID: 201081733

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // declare variables for use of core data
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
    var results: [Any]?
    
    
    var reports = [TechReports]()
    var reportNum = 0
    var sortedReports = [TechReports]()
    
    var years = [String]()  // this will be used to store the unique years from the json file
    var sections = [(year: String, reports: [TechReports])]() // this will be used to populate the table cells and headers
    
    // used to get the report index to pass to the next view in segue
    var segueSection: Int?
    var segueRow: Int?
    
    // saves to core data
    func save() {
        do {
            try context?.save()
            print("Saved")
        } catch {
            print("error")
        }
    }
    
    // adds swipe on cell functionality to favourite and remove favourite reports
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // concatinate the year and id of report as this is what is stored in core data if favourite
        // this will always be unique as a report cant have the same id if from the same year
        // then set the predicate as as the id in the string format
        let id = String(indexPath.section) + String(indexPath.row)
        let predicate = NSPredicate(format: "id == %@", id)
        self.request.predicate = predicate
        
        // method for what happens if favourite clicked
        let favourite = UITableViewRowAction(style: .normal, title: "Favourite") { action, index in
            do {
                
                // fetch results from table where id is equal to the id for the item selected
                let results = try self.context!.fetch(self.request)
                
                // if a result exists in core data then delete the result (there can only ever be a maximum of 1 result)
                // if there isn't a result in core data then save the id into core data
                if results.count > 0 {
                    for result in results {
                        self.context?.delete(result as! NSManagedObject)
                    }
                    self.save()
                    tableView.reloadData()
                } else {
                    let newItem = NSEntityDescription.insertNewObject(forEntityName: "Favourites", into: self.context!) as! Favourites
                    newItem.setValue(id, forKey: "id")
                    self.save()
                    tableView.reloadData()
                }
            } catch {
                print("error")
            }
        }
        
        // check if there are any results in the same way as above
        // then format the colour and text of the option accordingly
        do {
            let results = try self.context!.fetch(self.request)
            if results.count > 0 {
                favourite.title = "Remove Favourite"
                favourite.backgroundColor = .red
            } else {
                favourite.backgroundColor = .green
            }
        } catch {
            print("error")
        }
        
        return [favourite]
    }
    
    // return the amount of cells in each section by counting how many reports in each year
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].reports.count
    }
    
    // create cell when it enters the users view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "reportCell")
        
        // concatinate the year and id of report as this is what is stored in core data if favourite
        // this will always be unique as a report cant have the same id if from the same year
        // then set the predicate as as the id in the string format
        let id = String(indexPath.section) + String(indexPath.row)
        let predicate = NSPredicate(format: "id == %@", id)

        // index "sections" to get the title and authors for that report
        // the cell has a title and subtitle
        cell.textLabel?.text = sections[indexPath.section].reports[indexPath.row].title
        cell.detailTextLabel?.text = sections[indexPath.section].reports[indexPath.row].authors
        
        request.predicate = predicate
        do {
            // get results from core data if they exist, then if it does, add checkmark to cell
            let results = try context!.fetch(request)
            if results.count > 0 {
                cell.accessoryType = .checkmark
            }

        } catch {
            print("couldn't fetch")
        }
        return cell
    }
    
    // return the number of years from years array as the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }
    
    // set the headers for the sections as the items in the years array at the section index,
    // this means they are ordered too
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return years[section]
    }
    
    // when cell clicked store the index of cell in variables then segue to detail view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueSection = indexPath.section
        segueRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "tableToDetail", sender: self)
    }
    
    // assign the report in the cell clicked (index stored in variables) to variable of type report in detail view
    // this happens before segue is performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tableToDetail" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.report = sections[segueSection!].reports[segueRow!]
        }
    }
    
    
    @IBOutlet weak var dataTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // define the context for use in core data
        context = appDelegate.persistentContainer.viewContext
        
        // set the url of the json file
        let urlString = "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/techreports/data.php?class=techreports"
        guard let url = URL(string: urlString) else {return}
        
        // start background task to retrieve the data from the json file
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                if let urlContent = data {
                    do {
                        
                        // use json decoder to retrieve the information in the file as type Reports
                        let data = Data(urlContent)
                        let decoder = JSONDecoder()
                        let documentContents = try decoder.decode(Reports.self, from: data)
                        
                        // set my array of reports as the array of reports retrieved
                        self.reports = documentContents.techreports!
                        self.reportNum = self.reports.count
                        
                        // sort the reports first in order of year the id
                        // integer version of id needed as otherwise the sort produces incorrect results
                        self.sortedReports = self.reports.sorted {
                            if $0.year != $1.year {
                                return $0.year > $1.year
                            } else {
                                return Int($0.id)! < Int($1.id)!
                            }
                        }
                        
                        // add 1 occurence of each year to the years array
                        // go through each report and if the year is different than the previous report then add to array
                        // this works as sorted array of reports is used
                        var newYear: Int = 0
                        var currentYear: String
                        currentYear = self.sortedReports[0].year
                        for i in 1..<(self.reportNum-1) {
                            if self.sortedReports[i].year != currentYear {
                                self.years.append(currentYear)
                                newYear += newYear
                                currentYear = self.sortedReports[i].year
                            }
                        }
                        self.years.append(currentYear)
                        
                        // add to "sections", each year and for each year, every report from that year as an array of reports
                        // loop through years array then for ech item compare with all reports and add to temp array if corresponding year
                        // at end of cycle for each year add the year and temp array to "sections"
                        for i in 0..<self.years.count {
                            var tempReportsArray = [TechReports]()
                            for j in 0..<self.reportNum {
                                if self.sortedReports[j].year == self.years[i] {
                                    tempReportsArray.append(self.sortedReports[j])
                                }
                            }
                            self.sections.append((self.years[i], tempReportsArray))
                        }
                        
                        // call foreground task from background task to reload table
                        DispatchQueue.main.async {
                            self.dataTable.reloadData()
                        }
                        
                    } catch {
                        print("error")
                    }
                }
            }
        }
        task.resume()
    }
}

