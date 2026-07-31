//
//  AddHabitViewModel.swift
//  Dopamine
//
//  Created by PortalGrup on 27.02.2026.
//


// MARK: - Imports
import SwiftUI
import SwiftData

// MARK: - Add Habit ViewModel
@Observable
class AddHabitViewModel {
    // MARK: Properties
    /// Katalogda gösterilen seviye sekmesi.
    var browsingLevel: HabitDifficulty = .easy

    /// Kullanıcının katalogdan seçtiği hazır aktivite. Tek veri girişi budur.
    private(set) var selectedTemplate: HabitTemplate?

    var errorMessage: String?

    // MARK: Computed
    /// Kaydedilecek başlık — yalnızca katalogdan gelir.
    var title: String { selectedTemplate?.title ?? "" }

    var isValid: Bool { selectedTemplate != nil }

    /// Zorluk kullanıcı tarafından seçilmez; katalog belirler.
    var resolvedDifficulty: HabitDifficulty {
        selectedTemplate?.difficulty ?? browsingLevel
    }

    var rewardPoints: Int { resolvedDifficulty.points }

    /// Seçim yapıldıysa zorluk rozeti gösterilir.
    var hasSelection: Bool { selectedTemplate != nil }

    /// Ekranda gösterilecek gruplar.
    var visibleGroups: [(category: HabitCategory, items: [HabitTemplate])] {
        HabitCatalog.grouped(for: browsingLevel)
    }

    // MARK: Actions
    func select(_ template: HabitTemplate) {
        // Aynı karta tekrar dokunmak seçimi kaldırır.
        if selectedTemplate?.id == template.id {
            selectedTemplate = nil
        } else {
            selectedTemplate = template
        }
        errorMessage = nil
        HapticManager.light()
    }

    func isSelected(_ template: HabitTemplate) -> Bool {
        selectedTemplate?.id == template.id
    }

    func changeLevel(to level: HabitDifficulty) {
        guard browsingLevel != level else { return }
        browsingLevel = level
        HapticManager.light()
    }

    @discardableResult
    func saveHabit(modelContext: ModelContext) -> Bool {
        guard let template = selectedTemplate else {
            errorMessage = "Listeden bir hedef seç."
            HapticManager.error()
            return false
        }

        // Aynı hedefin ikinci kez eklenmesini engelle.
        let existingTitles = (try? modelContext.fetch(FetchDescriptor<Habit>()))?.map(\.title) ?? []
        guard !existingTitles.contains(template.title) else {
            errorMessage = "Bu hedef zaten listende."
            HapticManager.error()
            return false
        }

        let nextOrder = (try? modelContext.fetchCount(FetchDescriptor<Habit>())) ?? 0
        let newHabit = Habit(
            title: template.title,
            difficulty: template.difficulty.rawValue,
            sortOrder: nextOrder
        )
        modelContext.insert(newHabit)

        do {
            try modelContext.save()
            errorMessage = nil
            HapticManager.success()
            return true
        } catch {
            errorMessage = "Kaydedilemedi: \(error.localizedDescription)"
            HapticManager.error()
            return false
        }
    }
}
