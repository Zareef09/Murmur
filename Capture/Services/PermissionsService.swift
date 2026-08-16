@MainActor
protocol PermissionsServicing: AnyObject {
    var allGranted: Bool { get }
    func requestAll() async
}

@MainActor
final class PermissionsService: PermissionsServicing {
    var allGranted: Bool { false }

    func requestAll() async {}
}
