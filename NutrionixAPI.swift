//
//  NutrionixAPI.swift
//  GroupApp
//
//  Created by SAMUEL LIM on 2/10/23.
//

import Foundation

struct foodItem: Codable{
    let calories: Double
    let item_id: String
    let serving_qty: Double?
    let serving_unit: String?
    let item_name: String
    var addedtoCart: Bool?
}

struct listReponse: Codable{
    let items: [foodItem]
    let total_hits: Int
}

// Gets the list of menu items from a restauarant ID (from getRestaurant function)
func getMenu(_ id: String) async throws -> [foodItem] {
    var menuItems: [foodItem] = []
    
    let urlString = "https://www.nutritionix.com/nixapi/brands/\(id)/items/1?limit=15&search="
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(url: url as URL)
    
    var res: listReponse
    
    do{
        let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
        res = try JSONDecoder().decode(listReponse.self, from: data)
        
        for page in 1...res.total_hits/15 + (res.total_hits % 15 == 0 ? 0 : 1){ // Creates a for loop that goes through every page of items on the menu
            let urlString = "https://www.nutritionix.com/nixapi/brands/\(id)/items/\(page)?limit=15&search="
            let url = NSURL(string: urlString)!
            let request = NSMutableURLRequest(url: url as URL)
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            print("\(page) out of \(res.total_hits/15)")
            
            // Decodes the data from the API call to a struct and adds it to the output
            do {
                let res = try JSONDecoder().decode(listReponse.self, from: data)
                menuItems.append(contentsOf: res.items)
            } catch let error {
                print(error)
                throw error
            }
        }
        return menuItems
    } catch{
        print(error)
        throw apiError.unknownError
        
    }
}

struct restaurant: Codable{
    let name: String
    let address: String
    let address2: String?
    let city: String
    let country: String
    let zip: String
    let phone: String?
    let website: String?
    let guide: String?
    let id: Int
    let lat: Double
    let lng: Double
    let created_at: String
    let updated_at: String
    let distance_km: Float
    let brand_id: String
}

struct restaurantsReponse: Codable{
    let locations: [restaurant]
}

enum apiError: Error {
    case noConnection
    case unknownError
}

// Gets restaurants list of restaurants around a latitude and longitude; Distance and limit are optional
func getRestaurant(_ latitude: Double, _ longitude: Double, _ distance: Int = 50, _ limit: Int = 20) async throws -> [restaurant] {
    let urlString = "https://trackapi.nutritionix.com/v2/locations?ll=\(latitude)%2C%20\(longitude)&distance=\(distance)&limit=\(limit)"
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(url: url as URL)
    
    request.setValue("0033f8cd", forHTTPHeaderField: "x-app-id")
    request.setValue("SECRET_KEY", forHTTPHeaderField: "x-app-key") // TODO: .env for secret key
    var res: restaurantsReponse
    
    do{
        let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
        res = try JSONDecoder().decode(restaurantsReponse.self, from: data)
        return res.locations
    } catch{
        print(error)
        throw apiError.unknownError
        
    }
    
}

struct itemInfo: Codable{
    let nf_calories: Double?
    let nf_calories_from_fat: Double?
    let nf_total_fat: Double?
    let nf_saturated_fat: Double?
    let nf_trans_fatty_acid: Double?
    let nf_polyunsaturated_fat: Double?
    let nf_monounsaturated_fat: Double?
    let nf_cholesterol: Double?
    let nf_sodium: Double?
    let nf_total_carbohydrate: Double?
    let nf_dietary_fiber: Double?
    let nf_sugars: Double?
    let nf_added_sugars: Double?
    let nf_protein: Double?
    let nf_potassium: Double?
    let nf_vitamin_a_dv: Double?
    let nf_vitamin_c_dv: Double?
    let nf_vitamin_d_dv: Double?
    let nf_vitamin_d_mcg: Double?
    let nf_calcium_dv: Double?
    let nf_calcium_mg: Double?
    let nf_iron_dv: Double?
    let nf_iron_mg: Double?
    
    struct trackFood: Codable{
        let nf_total_fat: Double?
        let nf_saturated_fat: Double?
        let nf_sodium: Double?
        let nf_total_carbohydrate: Double?
        let nf_dietary_fiber: Double?
        let nf_sugars: Double?
        let nf_protein: Double?
        let nf_potassium: Double?
    }
    
    let track_food: trackFood?
    
    
}

func getItemInfo(_ id: String) async throws -> itemInfo {
    
    let urlString = "https://www.nutritionix.com/nixapi/items/" + id
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(url: url as URL)
    
    var res: itemInfo
    
    do{
        let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
        res = try JSONDecoder().decode(itemInfo.self, from: data)
        
        return res
    } catch{
        print(error)
        throw apiError.unknownError
        
    }
}

struct brandInfo: Codable{
    let logo: String?
}

func getBrandInfo(_ id: String) throws -> brandInfo {
    
    let urlString = "https://www.nutritionix.com/nixapi/brands/" + id
    let url = URL(string: urlString)!
    
    var res: brandInfo
    
    
    
    do{
        let data =  try? Data(contentsOf: url)
        res = try JSONDecoder().decode(brandInfo.self, from: (data ?? "{logo: \"https://d2eawub7utcl6.cloudfront.net/images/nix-apple-grey.png\"}".data(using: .utf8))!)
        return res
    } catch{
        print(error)
        res = brandInfo(logo: "https://d2eawub7utcl6.cloudfront.net/images/nix-apple-grey.png")
        return res
    }
}

struct sortedMenu {
    var appetizer: [(foodItem,String,Int)]?
    var entre: [(foodItem,String,Int)]?
    var dessert: [(foodItem,String,Int)]?
    var drink: [(foodItem,String,Int)]?
}




struct classifications: Codable{
    let id: String
    let input: String
    let prediction: String
    let confidence: Float
    
}

struct sortMenuResponse: Codable{
    let id: String
    let classifications: [classifications]
}

func sortMenu(_ input: [foodItem]) async throws -> sortedMenu {
    var classifiedItems: [classifications] = []
    do {
        for index in stride(from: 0, through: input.count, by: 96){ // Loop through input array in 96 step increments
            var inputJson: [String] = []
            print(input.count)
            print(index, " out of ", input.count)
            
            for subindex in index...(index+95 < input.count-1 ? index + 95 : input.count-1) { // Loop through a sub index of the input array, limiting it to the length of the input array's length. Adds them to inputJson to be sent to the classification API
                
                let item = input[subindex]
                let jsonData = try JSONEncoder().encode(item)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                inputJson.append(jsonString)
            }
            
            let headers = [
                "Authorization": "BEARER SECRET_KEY", // TODO: .env token
                "Content-Type": "application/json"
            ]
            
            
            let parameters = [
                "model": "562d8f7b-3a68-45ab-ab34-9db7cf9a0332-ft", // TODO: .env model ID
                "inputs": inputJson
            ] as [String : Any]
            
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            
            let request = NSMutableURLRequest(url: NSURL(string: "https://api.cohere.ai/v1/classify")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 60.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            var res: sortMenuResponse
            
            
            let (data, _) = try await URLSession.shared.data(for: request as URLRequest)
            res = try JSONDecoder().decode(sortMenuResponse.self, from: data)
            
            classifiedItems.append(contentsOf: res.classifications) // Adds the data from API call to a combined array
        }
        
        var output = sortedMenu(appetizer: [], entre: [], dessert: [], drink: [])
        
        // Loops through combined array to add classified items to their assigned arrays
        for item in classifiedItems {
            let food = try JSONDecoder().decode(foodItem.self, from: item.input.data(using: .utf8)!)
            
            switch item.prediction {
            case "appetizer":
                output.appetizer!.append((food,"appetizer",output.appetizer!.count-1))
            case "entre":
                output.entre!.append((food,"entre",output.entre!.count-1))
            case "dessert":
                output.dessert!.append((food,"dessert",output.dessert!.count-1))
            case "drink":
                output.drink!.append((food,"drink",output.drink!.count-1))
            default:
                output.entre!.append((food,"entre",output.entre!.count-1))
            }
        }
        
        return output
        
    } catch {
        print(error)
        throw apiError.unknownError
    }
    
}


