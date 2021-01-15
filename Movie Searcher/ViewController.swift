//
//  ViewController.swift
//  Movie Searcher
//
//  Created by Ciprian Cucu-Ciuhan on 15.01.2021.
//

import UIKit
import SafariServices

//UI
//Network request for movie list
//Tap a cell to see info about movie
//Custom cell

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    var movies = [Movie]() //array de movie objects

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        table.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.indentifier)
        table.delegate = self
        table.dataSource = self
        field.delegate = self
        
    }
    
    //Field function
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//cu asta capturezi eventul atunci cand utilizatorul apasa return pe tastatura
        searchMovies()
        return true
    }
    
    func searchMovies(){
        
        field.resignFirstResponder()//se duce tastatura
        
        guard let text = field.text, !text.isEmpty else {
            return
        }
        
        let query = text.replacingOccurrences(of: " ", with: "%20")
        
        movies.removeAll()
        
        URLSession.shared.dataTask(with: URL(string: "https://omdbapi.com/?apikey=3aea79ac&s=\(query)&type=movie")!, completionHandler: { data, response, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            //convert
            
            var result: MovieResult?
            
            do {
                
                result = try JSONDecoder().decode(MovieResult.self, from: data)
                
            } catch {
                print("error")
            }
            
            guard let finalResult = result else {
                return
            }
            
            //print("\(finalResult.Search.first?.Title)")
            
            //update movies array
            
            let newMovies = finalResult.Search
            self.movies.append(contentsOf: newMovies)
            
            //refresh table
            
            DispatchQueue.main.async { //asa se face mereu cand dai refresh la UI
                self.table.reloadData()
            }
            
        }).resume()
        
    }
    
    //Table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//returneaza un int, cate rows sa bage in tabel
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//celula pe care o returneaza
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.indentifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //show movie details
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
        let vc = SFSafariViewController(url: URL(string: url)!)
        present (vc, animated: true)
    }


}

//codable: ii dam date iar swift converteste acele date in obiecte care au aceleasi key ca JSON-ul nostru

struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String
    
    private enum CodingKeys: String, CodingKey { //ca sa stim ce vine de la json
        case Title, Year, imdbID, _Type = "Type", Poster
    }
    
}

