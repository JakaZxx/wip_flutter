<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class VerifiedEmail
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        if (Auth::check() && Auth::user()->isStudent() && !Auth::user()->hasVerifiedEmail()) {
            if (!$request->is('students/request/borrowings*') && !$request->is('students/borrowings*') && !$request->is('email/verify*') && !$request->is('verification*')) {
                return redirect()->route('verification.notice')->with('error', 'Anda harus memverifikasi email terlebih dahulu.');
            }
        }

        return $next($request);
    }
}
