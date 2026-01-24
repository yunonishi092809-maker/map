import Foundation

struct Topic: Identifiable, Codable {
    let id: String
    let question: String
    let inputQuestion: String
    let hint: String
}

struct TopicGenerator {
    // 19種類
    static let whoList: [String] = [
        "友達",
        "家族",
        "お母さん",
        "お父さん",
        "兄弟・姉妹",
        "おじいちゃん・おばあちゃん",
        "先生",
        "クラスメイト",
        "部活の仲間",
        "後輩",
        "先輩",
        "幼なじみ",
        "店員さん",
        "駅員さん",
        "近所の人",
        "知らない人",
        "ペット",
        "推し",
        "自分自身"
    ]

    // 20種類
    static let whatList: [String] = [
        "「ありがとう」を伝える",
        "「大好き」を伝える",
        "笑顔を見せる",
        "優しくする",
        "話を聞いてあげる",
        "相談に乗ってあげる",
        "助けてあげる",
        "褒めてあげる",
        "一緒に笑う",
        "励ましてあげる",
        "プレゼントをあげる",
        "応援する",
        "手伝いをする",
        "おすすめを教えてあげる",
        "一緒にご飯を食べる",
        "連絡する",
        "会う",
        "挨拶する",
        "気持ちを伝える",
        "感謝を伝える"
    ]

    // 19 x 20 = 380通り（365日以上カバー）
    static func generateTopic(for date: Date = Date()) -> Topic {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1

        let totalCombinations = whoList.count * whatList.count
        let index = (dayOfYear - 1) % totalCombinations

        let whoIndex = index % whoList.count
        let whatIndex = index / whoList.count

        let who = whoList[whoIndex]
        let what = whatList[whatIndex]

        let question = "\(who)に\(what)瞬間、あるかも？"
        let inputQuestion = "今日、\(who)に\(what)ことはあった？"
        let hint = hintFor(who: who, what: what)

        return Topic(
            id: "\(dayOfYear)",
            question: question,
            inputQuestion: inputQuestion,
            hint: hint
        )
    }

    private static func hintFor(who: String, what: String) -> String {
        switch who {
        case "自分自身":
            return "自分のことも大事にね！"
        case "ペット":
            return "もふもふタイムも最高〜"
        case "推し":
            return "心の中で応援もアリ！"
        case "知らない人":
            return "ちょっとしたことでOK"
        default:
            return "小さいことでも全然いいよ"
        }
    }

    static var totalCombinations: Int {
        whoList.count * whatList.count
    }
}

extension Topic {
    static let defaultTopics: [Topic] = [
        Topic(id: "1", question: "誰かに「ありがとう」を伝える瞬間、あるかも？", inputQuestion: "今日、誰かに「ありがとう」を伝えられた？", hint: "小さなことでもOK")
    ]

    static func todaysTopic() -> Topic {
        TopicGenerator.generateTopic()
    }
}
