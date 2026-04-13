<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use App\Models\User;

class PasswordController extends Controller
{
    // Show password change form
    public function showChangeForm()
    {
        return view('auth.change_password');
    }

    // Handle password change
    public function change(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator);
        }

        $user = Auth::user();

        // Check current password
        if (!Hash::check($request->current_password, $user->password)) {
            return redirect()->back()->withErrors(['current_password' => 'Password saat ini salah.']);
        }

        // Update password
        $user->update([
            'password' => Hash::make($request->password),
            'password_changed_at' => now(),
            'must_change_password' => false,
        ]);

        // Send email verification if not verified
        if (!$user->hasVerifiedEmail()) {
            $user->sendEmailVerificationNotification();
        }

        $role = strtolower($user->role);

        // For students, check if email verification is needed
        if ($role === 'students' && !$user->hasVerifiedEmail()) {
            return redirect()->route('verification.notice')->with('success', 'Password berhasil diubah. Silakan verifikasi email Anda.');
        }

        $redirectRoute = match($role) {
            'admin' => 'admin.dashboard',
            'officers' => 'officers.dashboard',
            'students' => 'students.dashboard',
            default => 'login'
        };

        return redirect()->route($redirectRoute)->with('success', 'Password berhasil diubah.');
    }

    // Admin reset password
    public function adminReset(Request $request, $userId)
    {
        $user = \App\Models\User::findOrFail($userId);

        $newPassword = 'password123'; // Default password

        $user->update([
            'password' => Hash::make($newPassword),
            'password_changed_at' => null, // Reset so they have to change it
            'must_change_password' => true,
        ]);

        return redirect()->back()->with('success', 'Password berhasil direset. Password baru: ' . $newPassword);
    }

    // Show forgot password form
    public function showForgotForm()
    {
        return view('auth.forgot_password');
    }

    // Send reset link
    public function sendResetLink(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return back()->withErrors(['email' => 'Email tidak ditemukan.']);
        }

        // Create custom reset token without email verification check
        $token = app('auth.password.broker')->createToken($user);

        // Send custom notification
        $user->sendPasswordResetNotification($token);

        return back()->with(['status' => 'Link reset password telah dikirim ke email Anda.']);
    }

    // Show reset password form
    public function showResetForm(Request $request)
    {
        return view('auth.reset_password', ['request' => $request]);
    }

    // Reset password
    public function reset(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return back()->withErrors(['email' => 'Email tidak ditemukan.']);
        }

        // Verify token manually using database
        $record = DB::table('password_resets')
            ->where('email', $request->email)
            ->first();

        if (!$record || !Hash::check($request->token, $record->token)) {
            return back()->withErrors(['token' => 'Token reset password tidak valid.']);
        }

        // Reset password
        $user->forceFill([
            'password' => Hash::make($request->password)
        ])->setRememberToken(Str::random(60));

        // For students, mark password as changed but keep verification requirement
        if ($user->isStudent()) {
            $user->must_change_password = false; // Already changed via reset
            $user->password_changed_at = now();
            // Email verification is still required for student access
        }

        $user->save();

        // Delete the token from database
        DB::table('password_resets')->where('email', $request->email)->delete();

        return redirect()->route('login')->with('status', 'Password berhasil direset. Silakan login dan verifikasi email jika diperlukan.');
    }
}
