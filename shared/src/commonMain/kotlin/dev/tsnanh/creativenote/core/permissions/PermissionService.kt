package dev.tsnanh.creativenote.core.permissions

enum class AppPermission { Camera, Photos, Location, Notifications }
enum class PermissionStatus { Granted, Denied, Limited, NotDetermined }

interface PermissionService {
    suspend fun status(permission: AppPermission): PermissionStatus
    suspend fun request(permission: AppPermission): PermissionStatus
}

class DefaultPermissionService : PermissionService {
    override suspend fun status(permission: AppPermission) = PermissionStatus.NotDetermined
    override suspend fun request(permission: AppPermission) = PermissionStatus.Denied
}
