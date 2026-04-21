import Foundation

struct FocusArea {
    let icon: String
    let title: String
    let description: String
}

struct CustomPlan {
    let heroHeadline: String
    let subheadline: String
    let focusAreas: [FocusArea]
    let estimatedMonthlySavings: String
}

// Pure function — fully testable without UI.
enum CustomPlanBuilder {
    static func build(from answers: QuizAnswers) -> CustomPlan {
        CustomPlan(
            heroHeadline: heroHeadline(from: answers),
            subheadline: subheadline(from: answers),
            focusAreas: focusAreas(from: answers),
            estimatedMonthlySavings: estimatedSavings(from: answers)
        )
    }

    // MARK: - Private builders

    private static func heroHeadline(from a: QuizAnswers) -> String {
        let stress = a.moneyStress ?? ""
        let frustration = a.biggestFrustration ?? ""

        if stress == "daily" || stress == "a_lot" {
            return "Let's turn that daily stress into daily progress."
        }
        if frustration == "too_manual" {
            return "Two taps. No spreadsheets. Real results."
        }
        if frustration == "complicated" {
            return "Simple by design. Powerful when you need it."
        }
        if frustration == "restrictive" {
            return "Budgeting that works with your life, not against it."
        }
        return "Your personalized money plan starts here."
    }

    private static func subheadline(from a: QuizAnswers) -> String {
        let goal = a.firstSavingsGoal ?? "emergency"
        switch goal {
        case "emergency": return "We'll help you build your safety net, one week at a time."
        case "vacation":  return "Your next trip is closer than you think."
        case "home":      return "Homeownership starts with a clear number. Let's find yours."
        case "car":       return "Every dollar saved puts you one step closer to the keys."
        default:          return "We'll build a clear path to your first goal."
        }
    }

    private static func focusAreas(from a: QuizAnswers) -> [FocusArea] {
        var areas: [FocusArea] = []

        // Focus 1: based on tracking habit
        let habit = a.currentTrackingHabit ?? "none"
        if habit == "none" || habit == "mental" {
            areas.append(FocusArea(
                icon: "bolt.fill",
                title: "Frictionless tracking",
                description: "Log in 2 taps. Automatic categories. No Sunday catch-up sessions."
            ))
        } else {
            areas.append(FocusArea(
                icon: "arrow.up.right",
                title: "Upgrade your tracking",
                description: "You already track — we'll show you what the data actually means."
            ))
        }

        // Focus 2: based on debt situation
        let debt = a.debtSituation ?? "none"
        if debt == "none" {
            let goal = a.firstSavingsGoal ?? "emergency"
            areas.append(FocusArea(
                icon: "star.fill",
                title: "Goal acceleration",
                description: "No debt holding you back — \(goalLabel(goal)) here we come."
            ))
        } else {
            areas.append(FocusArea(
                icon: "link.badge.plus",
                title: "Debt payoff strategy",
                description: "See exactly when you'll be free. Watch the chain break, link by link."
            ))
        }

        // Focus 3: based on subscriptions
        let subs = a.subscriptionAwareness ?? "few"
        if subs == "none" || subs == "few" {
            areas.append(FocusArea(
                icon: "creditcard.fill",
                title: "Subscription audit",
                description: "The average person saves $43/mo just by knowing what they're paying for."
            ))
        } else {
            areas.append(FocusArea(
                icon: "checkmark.seal.fill",
                title: "Smart subscription tracking",
                description: "You're already on top of it. We'll make sure nothing slips through."
            ))
        }

        // Focus 4: shared or solo
        if let shared = a.sharedFinances, shared != "solo" {
            areas.append(FocusArea(
                icon: "person.2.fill",
                title: "Shared budgets",
                description: "Invite your \(shared == "partner" ? "partner" : "roommates") and stay on the same page — no more money guessing."
            ))
        }

        return Array(areas.prefix(3))
    }

    private static func estimatedSavings(from a: QuizAnswers) -> String {
        var monthly = 0

        let subs = a.subscriptionAwareness ?? "all"
        switch subs {
        case "none":  monthly += 80
        case "few":   monthly += 40
        case "most":  monthly += 15
        default:      monthly += 5
        }

        let habit = a.currentTrackingHabit ?? "none"
        if habit == "none" || habit == "mental" { monthly += 120 }

        let frustration = a.biggestFrustration ?? ""
        if frustration == "too_manual" { monthly += 60 }

        return "$\(monthly)"
    }

    private static func goalLabel(_ goal: String) -> String {
        switch goal {
        case "emergency": return "emergency fund"
        case "vacation":  return "vacation fund"
        case "home":      return "home fund"
        case "car":       return "car fund"
        default:          return "savings goal"
        }
    }
}
