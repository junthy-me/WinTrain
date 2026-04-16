import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var router = AppRouter()
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var flowViewModel: AnalysisFlowViewModel

    init() {
        let analysisService = AnalysisService(
            apiClient: APIClient(baseURL: URL(string: "http://localhost:8080")!),
            installIDStore: InstallIDStore(),
            quotaStore: QuotaStore()
        )
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(analysisService: analysisService))
        _flowViewModel = StateObject(wrappedValue: AnalysisFlowViewModel(analysisService: analysisService, historyStore: HistoryStore()))
    }

    var body: some View {
        ZStack {
            AppSurfaceBackground()

            Group {
                if let route = router.currentRoute {
                    destination(for: route)
                } else {
                    rootView(for: router.selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .environmentObject(router)
            .environmentObject(environment.historyStore)
            .environmentObject(environment.quotaStore)
            .environmentObject(environment)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomNavigationBar(selectedTab: router.selectedTab) { tab in
                router.selectTab(tab)
            }
        }
        .onAppear {
            bindEnvironmentServicesIfNeeded()
        }
    }

    @ViewBuilder
    private func rootView(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            HomeView(
                viewModel: homeViewModel,
                flowViewModel: flowViewModel
            )
        case .capture:
            SelectionView()
        case .history:
            HistoryView()
        case .profile:
            ProfileView()
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .guide(let exerciseID):
            GuideView(exercise: Exercise.find(exerciseID), flowViewModel: flowViewModel)
        case .analyzing(let exerciseID):
            AnalyzingView(exercise: Exercise.find(exerciseID), flowViewModel: flowViewModel)
        case .result(let context):
            ResultView(context: context)
        case .paywall:
            PaywallView()
        case .helpFeedback:
            HelpFeedbackView()
        case .privacyNotice:
            PrivacyNoticeView()
        }
    }

    private func bindEnvironmentServicesIfNeeded() {
        if homeViewModel.usesSame(analysisService: environment.analysisService) == false {
            homeViewModel.replaceAnalysisService(environment.analysisService)
        }
        if flowViewModel.usesSame(
            analysisService: environment.analysisService,
            historyStore: environment.historyStore
        ) == false {
            flowViewModel.replaceDependencies(
                analysisService: environment.analysisService,
                historyStore: environment.historyStore
            )
        }
    }
}
