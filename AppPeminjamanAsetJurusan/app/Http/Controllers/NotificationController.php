<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    /**
     * Return notifications and unread count for the logged-in user.
     */
    public function index()
    {
        $user = Auth::user();

        $notifications = $user->notifications()->orderBy('created_at', 'desc')->take(20)->get();

        $unreadCount = $user->unreadNotifications()->count();

        // Format notifications for frontend
        $formatted = $notifications->map(function ($notification) {
            return [
                'id' => $notification->id,
                'type' => class_basename($notification->type),
                'data' => $notification->data,
                'is_read' => $notification->read_at !== null,
                'created_at' => $notification->created_at->toDateTimeString(),
                'link' => $notification->data['link'] ?? '#',
                'message' => $notification->data['requestDetails']['message'] ?? 'Notifikasi baru',
                'sender' => $notification->data['sender'] ?? null,
            ];
        });

        return response()->json([
            'notifications' => $formatted,
            'unreadCount' => $unreadCount,
        ]);
    }

    /**
     * Mark a notification as read.
     */
    public function markAsRead($id)
    {
        $user = Auth::user();

        $notification = $user->notifications()->where('id', $id)->first();

        if ($notification) {
            $notification->markAsRead();
            return response()->json(['success' => true]);
        }

        return response()->json(['success' => false], 404);
    }
}
