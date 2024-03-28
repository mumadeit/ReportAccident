import SwiftUI

struct InsuranceCompany: Codable, Identifiable {
    var id: Int
    var name: String
    var logo: String
    var phone: String
    var createdAt: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, logo, phone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CompaniesView: View {
    @State private var companies: [InsuranceCompany] = []

    var body: some View {
        NavigationView {
            List(companies) { company in
                HStack {
                    // Company logo
                    AsyncImage(url: URL(string: "http://127.0.0.1:8000/\(company.logo)")) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    // Company name and phone
                    VStack(alignment: .leading) {
                        Text(company.name).fontWeight(.bold)
                        Text(company.phone)
                    }

                    Spacer()

                    // Call button
                    Button(action: {
                        callCompany(phoneNumber: company.phone)
                    }) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Insurance Companies")
            .onAppear(perform: loadCompanies)
        }
    }
    
    // Function to initiate a phone call
    func callCompany(phoneNumber: String) {
        let formattedNumber = phoneNumber.filter("0123456789".contains)
        if let url = URL(string: "tel://\(formattedNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    // Function to load companies data
    func loadCompanies() {
        let urlString = "http://127.0.0.1:8000/api/companies/all" // Replace with your actual API URL
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([InsuranceCompany].self, from: data) {
                    DispatchQueue.main.async {
                        self.companies = decodedResponse
                    }
                }
            }
        }.resume()
    }
}

struct CompaniesView_Previews: PreviewProvider {
    static var previews: some View {
        CompaniesView()
    }
}
