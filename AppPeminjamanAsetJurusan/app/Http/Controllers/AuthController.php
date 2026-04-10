<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;


class AuthController extends Controller
{
    public function login(LoginRequest $request)
    {
        $credentials = $request->only('email', 'password');

        // Check if login with NIS for students
        if ($request->has('nis') && $request->nis) {
            $user = User::where('nis', $request->nis)->first();
            if ($user && $user->isStudent() && Hash::check($request->password, $user->password)) {
                Auth::login($user);
                $request->session()->regenerate();

                // Check if student needs to change password
                if ($user->must_change_password) {
                    return redirect()->route('password.change.form');
                }

                // Check if student needs to verify email
                if (!$user->hasVerifiedEmail()) {
                    return redirect()->route('verification.notice');
                }

                return redirect()->route('students.dashboard');
            }
        }

        if (Auth::attempt($credentials)) {
            $request->session()->regenerate();

            $user = Auth::user();

            // Check approval status for officers
            if ($user->isOfficer() && !$user->isApproved()) {
                Auth::logout();
                return redirect()->route('login')->with('error', 'Akun Anda belum disetujui admin.');
            }

            $role = strtolower($user->role);

            // Role-based routing
            switch ($role) {
                case 'admin':
                    return redirect()->route('admin.dashboard');
                case 'students':
                    // Check if student needs to change password
                    if ($user->must_change_password) {
                        return redirect()->route('password.change.form');
                    }
                    // Check if student needs to verify email
                    if (!$user->hasVerifiedEmail()) {
                        return redirect()->route('verification.notice');
                    }
                    return redirect()->route('students.dashboard');
                case 'officers':
                    return redirect()->route('officers.dashboard');
                default:
                    Auth::logout();
                    return redirect()->route('login')->with('error', 'Role tidak valid.');
            }
        }

        return back()->with('error', 'Email atau password salah.');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    public function showLoginForm()
    {
        return view('login');
    }

    // Email Verification
    public function showEmailVerificationForm()
    {
        return view('auth.verify_email');
    }

    public function verifyEmail(Request $request)
    {
        $request->user()->markEmailAsVerified();

        $user = $request->user();

        // After email verification, if student still needs to change password, redirect to change password page
        if ($user->isStudent() && $user->must_change_password) {
            return redirect()->route('password.change.form')->with('success', 'Email berhasil diverifikasi. Silakan ubah password Anda.');
        }

        // If password already changed, redirect to dashboard
        return redirect()->route('students.dashboard')->with('success', 'Email berhasil diverifikasi.');
    }

    public function resendVerification(Request $request)
    {
        $request->user()->sendEmailVerificationNotification();

        return back()->with('success', 'Link verifikasi email telah dikirim ulang.');
    }
}
