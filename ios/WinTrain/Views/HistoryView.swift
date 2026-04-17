import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var historyStore: HistoryStore
    @State private var selectedBodyPartID = "all"
    @State private var selectedExerciseID = "all"
    @State private var selectedDate: Date?
    @State private var showCalendar = false

    private var selectedBodyPart: ExerciseBodyPart? {
        ExerciseBodyPart(rawValue: selectedBodyPartID)
    }

    private var bodyPartTabs: [ExerciseBodyPart] {
        ExerciseBodyPart.allCases
    }

    private var exerciseTabs: [Exercise] {
        Exercise.supported(bodyPart: selectedBodyPart)
    }

    private var baseRecords: [HistoryRecord] {
        historyStore.records
    }

    private var filteredRecords: [HistoryRecord] {
        baseRecords.filter { record in
            let bodyPartMatches = selectedBodyPart == nil || Exercise.find(record.exerciseID).bodyPart == selectedBodyPart
            let exerciseMatches = selectedExerciseID == "all" || record.exerciseID == selectedExerciseID
            let dateMatches = selectedDate == nil || Calendar.current.isDate(record.createdAt, inSameDayAs: selectedDate!)
            return bodyPartMatches && exerciseMatches && dateMatches
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                bodyPartFilterTabs
                if selectedBodyPart != nil {
                    filterTabs
                }

                if let selectedDate {
                    HStack {
                        Text("筛选日期: \(selectedDateString(selectedDate))")
                        Spacer()
                        Button("清除") {
                            self.selectedDate = nil
                        }
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppTheme.primary.opacity(0.1))
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(AppTheme.primary.opacity(0.2))
                            .frame(height: 1)
                    }
                }

                ScrollView(showsIndicators: false) {
                    if filteredRecords.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "calendar")
                                .font(.system(size: 48, weight: .regular))
                                .foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                            Text("没有找到相关记录")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 120)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(filteredRecords) { record in
                                historyCard(record)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppSurfaceBackground())

            if showCalendar {
                HistoryCalendarOverlay(
                    selectedDate: selectedDate,
                    onSelect: { selectedDate = $0 },
                    onClose: { showCalendar = false }
                )
            }
        }
        .onChange(of: selectedBodyPartID) { _ in
            if selectedExerciseID == "all" {
                return
            }
            let availableExerciseIDs = Set(exerciseTabs.map(\.id))
            if availableExerciseIDs.contains(selectedExerciseID) == false {
                selectedExerciseID = "all"
            }
        }
    }

    private var header: some View {
        HStack {
            AppIconButton(systemImage: "chevron.left", tint: .white) {
                router.selectTab(.home)
            }

            Text("训练记录")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            if selectedDate == nil {
                AppIconButton(systemImage: "calendar", tint: .white) {
                    showCalendar = true
                }
            } else {
                AppIconButton(systemImage: "xmark", tint: AppTheme.primary) {
                    selectedDate = nil
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(AppTheme.background.opacity(0.9))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }

    private var bodyPartFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                capsuleFilterButton(title: "全部", value: "all", selection: $selectedBodyPartID)
                ForEach(bodyPartTabs) { bodyPart in
                    capsuleFilterButton(title: bodyPart.title, value: bodyPart.rawValue, selection: $selectedBodyPartID)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppTheme.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                filterButton(title: "全部动作", value: "all")
                ForEach(exerciseTabs) { exercise in
                    filterButton(title: exercise.name, value: exercise.id)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 50)
        .background(AppTheme.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }

    private func filterButton(title: String, value: String) -> some View {
        Button {
            selectedExerciseID = value
        } label: {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 14, weight: selectedExerciseID == value ? .bold : .medium))
                    .foregroundStyle(selectedExerciseID == value ? AppTheme.primary : Color.gray.opacity(0.9))

                Rectangle()
                    .fill(selectedExerciseID == value ? AppTheme.primary : .clear)
                    .frame(height: 2)
            }
            .padding(.top, 12)
        }
        .buttonStyle(.plain)
    }

    private func capsuleFilterButton(title: String, value: String, selection: Binding<String>) -> some View {
        let isSelected = selection.wrappedValue == value

        return Button {
            selection.wrappedValue = value
        } label: {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? AppTheme.primary : AppTheme.cardMuted)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppTheme.primary : AppTheme.border, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func historyCard(_ record: HistoryRecord) -> some View {
        let exercise = Exercise.find(record.exerciseID)

        return Button {
            router.push(.result(.history(record)))
        } label: {
            AppCard(padding: 0, cornerRadius: 16) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.exerciseName)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                            Text(historyDateString(record.createdAt))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        let style = resultStatusStyle(for: record.result)
                        Text(resultStatusTitle(for: record.result))
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.8)
                            .textCase(.uppercase)
                            .foregroundStyle(style.foreground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(style.background)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(style.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                    .padding(16)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("主要问题摘要")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)

                        HStack(spacing: 6) {
                            Image(systemName: historySummaryIcon(record.result))
                                .font(.system(size: 14, weight: .semibold))
                            Text(record.primaryFeedbackTitle)
                                .font(.system(size: 14, weight: .medium))
                                .lineLimit(2)
                        }
                        .foregroundStyle(historySummaryColor(record.result))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(AppTheme.background.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.horizontal, 16)

                    HStack {
                        HStack(spacing: 24) {
                            historyMetric(title: "重量", value: exercise.defaultWeight)
                            historyMetric(title: "次数", value: exercise.defaultReps)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 16)
                }
            }
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    historyStore.delete(recordID: record.id)
                }
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private func historyMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func historyDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日 · HH:mm"
        return formatter.string(from: date)
    }

    private func selectedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func historySummaryIcon(_ result: AnalysisResult) -> String {
        let title = resultStatusTitle(for: result)
        if title == "优秀" {
            return "checkmark.circle.fill"
        }
        if title == "良好" {
            return "checkmark.seal.fill"
        }
        if title == "需改进" {
            return "exclamationmark.triangle.fill"
        }
        return "info.circle.fill"
    }

    private func historySummaryColor(_ result: AnalysisResult) -> Color {
        let title = resultStatusTitle(for: result)
        if title == "优秀" {
            return AppTheme.success
        }
        if title == "良好" {
            return AppTheme.primary
        }
        if title == "需改进" {
            return AppTheme.warning
        }
        return AppTheme.textSecondary
    }
}

private struct HistoryCalendarOverlay: View {
    let selectedDate: Date?
    let onSelect: (Date) -> Void
    let onClose: () -> Void

    @State private var currentMonth: Date
    private let calendar = Calendar(identifier: .gregorian)
    private let years: [Int]

    init(selectedDate: Date?, onSelect: @escaping (Date) -> Void, onClose: @escaping () -> Void) {
        self.selectedDate = selectedDate
        self.onSelect = onSelect
        self.onClose = onClose

        let initial = selectedDate ?? .now
        _currentMonth = State(initialValue: initial)
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: .now)
        years = Array((currentYear - 10)...currentYear)
    }

    private var monthTitleYear: Int {
        calendar.component(.year, from: currentMonth)
    }

    private var monthTitleMonth: Int {
        calendar.component(.month, from: currentMonth)
    }

    private var availableMonths: [Int] {
        Array(1...12)
    }

    private var days: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday,
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }

        var result = Array(repeating: Optional<Date>.none, count: max(firstWeekday - 1, 0))
        for day in range {
            if let date = calendar.date(bySetting: .day, value: day, of: monthInterval.start) {
                result.append(date)
            }
        }
        return result
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    HStack {
                        calendarNavButton(systemName: "chevron.left") {
                            shiftMonth(by: -1)
                        }

                        Spacer()

                        HStack(spacing: 6) {
                            Menu {
                                ForEach(years, id: \.self) { year in
                                    Button("\(String(year))年") {
                                        updateMonth(year: year, month: monthTitleMonth)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("\(String(monthTitleYear))年")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }

                            Menu {
                                ForEach(availableMonths, id: \.self) { month in
                                    Button("\(month)月") {
                                        updateMonth(year: monthTitleYear, month: month)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("\(monthTitleMonth)月")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                        Spacer()

                        calendarNavButton(systemName: "chevron.right") {
                            shiftMonth(by: 1)
                        }
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                        ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { weekday in
                            Text(weekday)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity)
                        }

                        ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                            if let date {
                                let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false

                                Button {
                                    onSelect(date)
                                    onClose()
                                } label: {
                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                        .frame(maxWidth: .infinity, minHeight: 38)
                                        .foregroundStyle(isSelected ? AppTheme.background : Color.white.opacity(0.85))
                                        .background(
                                            isSelected ? AppTheme.primary : Color.clear
                                        )
                                        .clipShape(Circle())
                                        .shadow(color: isSelected ? AppTheme.primary.opacity(0.4) : .clear, radius: 12)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Color.clear
                                    .frame(height: 38)
                            }
                        }
                    }

                    HStack {
                        Spacer()
                        Button("取消", action: onClose)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                }
                .padding(20)
                .background(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.black.opacity(0.4), radius: 24, y: 12)
                .frame(maxWidth: 420)
                .padding(.horizontal, 24)
            }
        }
    }

    private func calendarNavButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.05))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func shiftMonth(by offset: Int) {
        if let updated = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = updated
        }
    }

    private func updateMonth(year: Int, month: Int) {
        var components = calendar.dateComponents([.day], from: currentMonth)
        components.year = year
        components.month = month
        components.day = 1
        if let updated = calendar.date(from: components) {
            currentMonth = updated
        }
    }
}
