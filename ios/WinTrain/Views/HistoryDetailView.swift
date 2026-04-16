import SwiftUI

struct HistoryDetailView: View {
    let record: HistoryRecord

    var body: some View {
        ResultView(context: .history(record))
    }
}
