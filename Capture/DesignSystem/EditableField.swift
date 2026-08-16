import SwiftUI

/// Parsed value the user can glance at and fix. Empty is a calm placeholder, never an error.
struct EditableField<Editor: View>: View {
    var label: String?
    @Binding var value: String
    var placeholder: String = "Not set"
    var icon: MurmurIconName?
    var isEditing: Bool = false
    var isMuted: Bool = false
    var onPress: () -> Void = {}
    @ViewBuilder var editor: () -> Editor

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var textFocused: Bool

    var body: some View {
        HStack(alignment: .center, spacing: MurmurSpace.space4) {
            if let icon {
                MurmurIcon(name: icon, size: 19)
                    .foregroundStyle(MurmurColor.textTertiary)
            }

            VStack(alignment: .leading, spacing: 2) {
                if let label {
                    Text(label)
                        .font(MurmurType.caption)
                        .tracking(0.96)
                        .textCase(.uppercase)
                        .foregroundStyle(MurmurColor.textTertiary)
                }

                if isEditing {
                    editingContent
                } else {
                    Text(display)
                        .font(MurmurType.body)
                        .tracking(MurmurType.trackingBody)
                        .foregroundStyle(valueForeground)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !isEditing {
                MurmurIcon(name: .pencil, size: 16)
                    .foregroundStyle(MurmurColor.textTertiary)
                    .opacity(0.65)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, MurmurSpace.space5)
        .frame(minHeight: 60)
        .background(isEditing ? MurmurColor.bgRaised : Color.clear)
        .overlay {
            RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous)
                .strokeBorder(
                    isEditing ? MurmurColor.accent : Color.clear,
                    lineWidth: MurmurRadius.strokeHairline
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: MurmurRadius.md, style: .continuous))
        .onTapGesture {
            if !isEditing { onPress() }
        }
        .animation(
            MurmurMotion.animation(.exhale, .normal, reduceMotion: reduceMotion),
            value: isEditing
        )
        .onChange(of: isEditing) { _, editing in
            textFocused = editing && Editor.self == EmptyView.self
        }
        .accessibilityElement(children: isEditing ? .contain : .combine)
        .accessibilityLabel(accessibilityName)
        .accessibilityValue(isEditing ? "" : display)
        .accessibilityAddTraits(isEditing ? [] : .isButton)
        .accessibilityHint(isEditing ? "" : "Edits this field")
    }

    @ViewBuilder
    private var editingContent: some View {
        if Editor.self == EmptyView.self {
            TextField("", text: $value)
                .font(MurmurType.body)
                .foregroundStyle(MurmurColor.textPrimary)
                .textFieldStyle(.plain)
                .focused($textFocused)
                .accessibilityLabel(label ?? "Value")
        } else {
            editor()
        }
    }

    private var display: String {
        value.isEmpty ? placeholder : value
    }

    private var valueForeground: Color {
        if value.isEmpty { return MurmurColor.textTertiary }
        return isMuted ? MurmurColor.textSecondary : MurmurColor.textPrimary
    }

    private var accessibilityName: String {
        label ?? "Field"
    }
}

extension EditableField where Editor == EmptyView {
    init(
        label: String? = nil,
        value: Binding<String>,
        placeholder: String = "Not set",
        icon: MurmurIconName? = nil,
        isEditing: Bool = false,
        isMuted: Bool = false,
        onPress: @escaping () -> Void = {}
    ) {
        self.init(
            label: label,
            value: value,
            placeholder: placeholder,
            icon: icon,
            isEditing: isEditing,
            isMuted: isMuted,
            onPress: onPress
        ) {
            EmptyView()
        }
    }
}
