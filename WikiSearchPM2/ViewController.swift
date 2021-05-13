//
//  ViewController.swift
//  WikiSearchPM2
//
//  Created by Ramiro y Jennifer on 07/05/21.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var buscarTextField: UITextField!
    @IBOutlet weak var WebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlWikipedia = URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/74/Wikipedia-logo-es.png"){
            WebView.load(URLRequest(url: urlWikipedia))
        }
        
    }
    
    @IBAction func buscarPalabraButton(_ sender: UIButton) {
        buscarTextField.resignFirstResponder()
        guard let palabraABuscar = buscarTextField.text else {return}
        buscarWikipedia(palabra: palabraABuscar)
    }
    
    func buscarWikipedia(palabra: String){
        if let urlAPI = URL(string: "https://es.wikipedia.org/w/api.php?action=query&prop=extracts&format=json&titles=\(palabra.replacingOccurrences(of: " ", with: "%20"))"){
            
            let peticion = URLRequest(url: urlAPI)
            
            let tarea = URLSession.shared.dataTask(with: peticion) { (datos, respuesta, error) in
                if error != nil{
                    //si hubo error
                    print(error?.localizedDescription)
                }//cierra if de rror
                else{
                    do {
                        let objJson = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    
                        //print("El objJson es \(objJson)")
                        
                        let querySubJson = objJson["query"] as! [String: Any]
                        //print(querySubJson)
                        let pagesSubJson = querySubJson["pages"] as! [String: Any]
                        let pageId = pagesSubJson.keys
                        let llaveExtracto = pageId.first!
                        
                        if llaveExtracto == "-1"{
                            print("Llave extracto: \(llaveExtracto) no se encontro la página")
                            DispatchQueue.main.async {
                                self.WebView.loadHTMLString("<h1>Tu búsqueda no tiene resultados\n</h1>", baseURL: nil)
                            }
                            
                        }
                        
                        let idSubJson = pagesSubJson[llaveExtracto] as! [String: Any]
                        let extracto = idSubJson["extract"] as? String
                        //print(extracto)
                        //imprimir en la UI
                        
                        DispatchQueue.main.async {
                            self.WebView.loadHTMLString(extracto ?? "<h1>No se obtuvieron resultados</h1>", baseURL: nil)
                        }
                    } catch {
                        print("Error al procesar el Json \(error.localizedDescription)")
                    } //cierra el docatch
                }//cierra el else
            }//cierra la tarea
            tarea.resume()
        }//Cierra el iflet
    }//termina la funcion


}

