import SwiftUI

struct CalendarView: View {
    let entryDates: Set<Date>
    @State private var displayedMonth: Date = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 16) {
            monthHeader

            weekdayHeader

            daysGrid
        }
        .padding()
        .background(Color.appCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appVermillionLight, lineWidth: 1)
        )
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.appVermillion)
            }

            Spacer()

            Text(dateFormatter.string(from: displayedMonth))
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.appVermillion)
            }
        }
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var daysGrid: some View {
        let days = generateDaysInMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Text("")
                        .frame(height: 32)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let hasEntry = entryDates.contains(calendar.startOfDay(for: date))
        let isToday = calendar.isDateInToday(date)

        return Text("\(day)")
            .font(.subheadline)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(hasEntry ? Color.appVermillion : Color.clear)
            )
            .foregroundStyle(hasEntry ? .white : (isToday ? Color.appVermillion : Color.appTextPrimary))
            .overlay(
                Circle()
                    .stroke(isToday ? Color.appVermillion : Color.clear, lineWidth: 2)
            )
    }

    private func moveMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
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
}

#Preview {
    CalendarView(entryDates: [Date(), Calendar.current.date(byAdding: .day, value: -1, to: Date())!])
        .padding()
        .background(Color.appBackground)
}
