import SwiftUI

struct CalendarView: View {
    let entryDates: Set<Date>
    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            monthHeader

            weekdayHeader

            daysGrid
                .frame(maxHeight: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(Color.appVermillion)
            }

            Spacer()

            Text(dateFormatter.string(from: displayedMonth))
                .font(.squadaOne(30))
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(Color.appVermillion)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .font(.zenMaru(17, weight: .bold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let weeks = generateWeeks()
        return VStack(spacing: 6) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let date = weeks[weekIndex][dayIndex] {
                            dayCell(for: date)
                        } else {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let hasEntry = entryDates.contains(calendar.startOfDay(for: date))
        let isToday = calendar.isDateInToday(date)

        return ZStack {
            Circle()
                .fill(hasEntry ? Color.appVermillion : Color.clear)
                .overlay(
                    Circle()
                        .stroke(isToday ? Color.appVermillion : Color.clear, lineWidth: 2)
                )
                .aspectRatio(1, contentMode: .fit)

            Text("\(day)")
                .font(.zenMaru(22, weight: .bold))
                .foregroundStyle(hasEntry ? .white : (isToday ? Color.appVermillion : Color.appTextPrimary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) != nil else {
            return []
        }

        var days: [Date?] = []
        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)

        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = next
        }

        return days
    }

    private func generateWeeks() -> [[Date?]] {
        var days = generateDaysInMonth()
        while days.count % 7 != 0 {
            days.append(nil)
        }
        return stride(from: 0, to: days.count, by: 7).map {
            Array(days[$0..<$0 + 7])
        }
    }
}

#Preview {
    CalendarView(entryDates: [Date(), Calendar.current.date(byAdding: .day, value: -1, to: Date())!])
        .padding()
        .background(Color.appBackground)
}
