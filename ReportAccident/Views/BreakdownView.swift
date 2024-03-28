import SwiftUI

struct BreakdownService: Codable, Identifiable {
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

struct BreakdownView: View {
    @State private var services: [BreakdownService] = []

    var body: some View {
        NavigationView {
            List(services) { service in
                HStack {
                    // Service logo
                    AsyncImage(url: URL(string: "http://127.0.0.1:8000/\(service.logo)")) { image in
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }

                    // Service name and phone
                    VStack(alignment: .leading) {
                        Text(service.name).fontWeight(.bold)
                        Text(service.phone)
                    }

                    Spacer()

                    // Call button
                    Button(action: {
                        callService(phoneNumber: service.phone)
                    }) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Breakdown Services")
            .onAppear(perform: loadServices)
        }
    }

    // Function to initiate a phone call
    func callService(phoneNumber: String) {
        let formattedNumber = phoneNumber.filter("0123456789".contains)
        if let url = URL(string: "tel://\(formattedNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    // Function to load services data
    func loadServices() {
        let urlString = "http://127.0.0.1:8000/api/breakdowns/all" // Replace with your actual API URL
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([BreakdownService].self, from: data) {
                    DispatchQueue.main.async {
                        services = decodedResponse
                    }
                }
            }
        }.resume()
    }
}

struct BreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        BreakdownView()
    }
}
