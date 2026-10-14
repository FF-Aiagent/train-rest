import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
            LogGateView()
                .tabItem { Label("Log", systemImage: "camera") }
            CalendarGateView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
        }
    }
}

#Preview {
    RootTabView()
}
