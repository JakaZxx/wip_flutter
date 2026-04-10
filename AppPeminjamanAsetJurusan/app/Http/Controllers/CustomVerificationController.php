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
    public function verify(EmailVerificationRequest $request): RedirectResponse
    {
        $request->fulfill();

        $user = $request->user();

        // After email verification, if student still needs to change password, redirect to change password page
        if ($user->isStudent() && $user->must_change_password) {
            Auth::logout(); // Log out to force re-login for password change
            // Instead of redirecting directly, redirect to login with a session flag
            return redirect()->route('login')->with('must_change_password', true)->with('success', 'Email berhasil diverifikasi. Silakan ubah password Anda.');
        }

        // If password already changed, redirect to dashboard
        return redirect()->route('students.dashboard')->with('success', 'Email berhasil diverifikasi.');
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
