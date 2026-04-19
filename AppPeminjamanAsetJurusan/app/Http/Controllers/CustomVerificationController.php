<?php

namespace App\Http\Controllers;

use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class CustomVerificationController extends Controller
{
    /**
     * Mark the authenticated user's email address as verified.
     *
     * @param  \Illuminate\Foundation\Auth\EmailVerificationRequest  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function verify(\Illuminate\Http\Request $request): RedirectResponse
    {
        $user = \App\Models\User::findOrFail($request->route('id'));

        if (! hash_equals((string) $request->route('hash'), sha1($user->getEmailForVerification()))) {
            abort(403, 'Invalid verification link');
        }

        if ($user->hasVerifiedEmail()) {
            return redirect()->route('login')->with('success', 'Email already verified. Please login.');
        }

        if ($user->markEmailAsVerified()) {
            event(new \Illuminate\Auth\Events\Verified($user));
        }

        // After email verification, if student still needs to change password, redirect to login page with flag
        if ($user->isStudent() && $user->must_change_password) {
            Auth::logout(); // Log out to force re-login for password change
            // Instead of redirecting directly, redirect to login with a session flag
            return redirect()->route('login')->with('must_change_password', true)->with('success', 'Email berhasil diverifikasi. Silakan ubah password Anda.');
        }

        // If password already changed, redirect to login so they can return to the app
        return redirect()->route('login')->with('success', 'Email berhasil diverifikasi. Silakan kembali ke aplikasi.');
    }

    /**
     * Resend the email verification notification.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function resend(\Illuminate\Http\Request $request)
    {
        if ($request->user()->hasVerifiedEmail()) {
            return redirect()->route('students.dashboard');
        }

        $request->user()->sendEmailVerificationNotification();

        return back()->with('resent', true);
    }
}
