import SwiftUI

struct ContentView: View {
    @StateObject var authManager = AuthenticationManager.shared  // Assuming AuthenticationManager is a Singleton

    var body: some View {
        if authManager.isLoggedIn {
            mainTabView
        } else {
            LoginView()
        }
    }

    var mainTabView: some View {
        TabView {
            ReportView()
                .tabItem {
                    Label("New Report", systemImage: "plus")
                }
            
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "info.bubble")
                }
            BreakdownView()
                .tabItem {
                    Label("Breakdown", systemImage: "car.2.fill")
                }
            CompaniesView()
                .tabItem {
                    Label("Insurance", systemImage: "rectangle.inset.filled.and.person.filled")
                }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Optional, for iPad and Mac
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
