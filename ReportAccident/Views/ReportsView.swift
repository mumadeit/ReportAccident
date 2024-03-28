import SwiftUI

struct Report: Codable {
    let uuid: String
    let name: String
    let status: String
    let accidentType: String
    let location: String?
    let counts: String
    let createdAt: String?
    let image: String
}


struct ReportsView: View {
    @State private var reports: [Report] = []
    @State private var isRefreshing = false
    @State private var isMarkingSolved: Set<String> = []
    
    // Function to fetch reports from the API
    func fetchReports() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/reports/all") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching reports: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data in response")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode([Report].self, from: data)
                DispatchQueue.main.async {
                    self.reports = decodedData
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    var body: some View {
        
        List(reports, id: \.uuid) { report in // Change id: \.id to id: \.uuid
            VStack(alignment: .leading) {
                
                if reports.isEmpty {
                    Text("No reports at this time.")
                } else {
                   
                    AsyncImage(url: URL(string: "\(report.image)")) { image in
                               image.resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 250, height: 200)
                           } placeholder: {
                               ProgressView()
                           }
                    
                    Text("Name: \(report.name)")
                    if report.status == "0 ⏱️"{
                        Text("Status: Pending")
                    }
                    if report.status == "1"{
                        Text("Status: Resolved ✅")
                    }
                    
                    if report.status == "2"{
                        Text("Status: Canceled ❌")
                    }
                    
                    
                    
                    Text("Accident Type: \(report.accidentType)")
                    if let location = report.location {
                        Text("Location: \(location)")
                    }
                    if let createdAt = report.createdAt {
                        Text("Created At: \(createdAt)")
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Button(action: {
                                markReportAsSolved(reportUUID: report.uuid)
                            }) {
                                Text("Mark as Solved")
                                    .foregroundColor(Color.white)
                                    .padding()
                                    .background(isMarkingSolved.contains(report.uuid) ? Color.green.opacity(0.5) : Color.green)
                                    .cornerRadius(8)
                            }
                            .disabled(isMarkingSolved.contains(report.uuid)) // Disable button when already marking as solved
                            
                            if report.status != "1" && !isMarkingSolved.contains(report.uuid) {
                                Button(action: {
                                    deleteReport(reportUUID: report.uuid)
                                }) {
                                    Text("Delete Report")
                                        .foregroundColor(Color.white)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                        }

                        .contentShape(Rectangle()) // Ensure the whole row is tappable
                    }
                }
            }
        }
        
        .refreshable {
            // Action to perform when the user triggers a refresh
            await refreshData()
        }
        .onAppear {
            fetchReports() // Fetch reports when the view appears
        }
    }
    
    // Function to refresh data
    func refreshData() async {
        // Ensure only one refresh operation is active at a time
        guard !isRefreshing else { return }
        
        // Set isRefreshing to true to show the refresh indicator
        isRefreshing = true
        
        // Fetch new data
        await fetchReports()
        
        // Set isRefreshing back to false to hide the refresh indicator
        isRefreshing = false
    }
    
    // Function to fetch reports asynchronously
    func fetchReports() async {
        guard let token = UserSession.shared.accessToken,
              let userID = UserSession.shared.userID,
              let url = URL(string: "http://127.0.0.1:8000/api/reports/\(userID)") else {
            print("Invalid URL or credentials not found")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode([Report].self, from: data)
            DispatchQueue.main.async {
                self.reports = decodedData
            }
        } catch {
            print("Error fetching reports: \(error)")
        }
    }


    
    // Function to delete a report
    func deleteReport(reportUUID: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/reports/delete/\(reportUUID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting report: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            // Update the local data after deletion
            fetchReports()
        }.resume()
    }
    
    // Function to mark a report as solved
    func markReportAsSolved(reportUUID: String) {
        isMarkingSolved.insert(reportUUID)
        
        guard let url = URL(string: "http://127.0.0.1:8000/api/reports/solved/\(reportUUID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error marking report as solved: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            // Update the local data after the status change
            fetchReports()
            
            // Remove from marking solved set
            isMarkingSolved.remove(reportUUID)
        }.resume()
    }
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
