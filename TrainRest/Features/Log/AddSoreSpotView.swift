import SwiftUI
import PhotosUI

struct AddSoreSpotView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SoreSpotStore

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var area: BodyArea = .knee
    @State private var intensity = 3
    @State private var note = ""
    @State private var showCamera = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 180)
                    }
                    PhotosPicker("Choose from library", selection: $pickerItem, matching: .images)
                    Button("Take photo") { showCamera = true }
                }
                Section("Where") {
                    Picker("Body area", selection: $area) {
                        ForEach(BodyArea.allCases) { Text($0.rawValue).tag($0) }
                    }
                }
                Section("How sore (1–5)") {
                    Stepper(value: $intensity, in: 1...5) {
                        Text("\(intensity)")
                    }
                }
                Section("Note (optional)") {
                    TextField("One short line", text: $note)
                }
                if let errorText {
                    Section { Text(errorText).foregroundStyle(.red) }
                }
            }
            .navigationTitle("New sore spot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .onChange(of: pickerItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let ui = UIImage(data: data) {
                        image = ui
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $image)
            }
        }
    }

    private func save() {
        do {
            try store.add(bodyArea: area.rawValue, intensity: intensity, note: note, image: image)
            dismiss()
        } catch {
            errorText = "Couldn’t save on this device. Try again."
        }
    }
}
