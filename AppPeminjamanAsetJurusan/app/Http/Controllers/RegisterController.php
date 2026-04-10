<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    // Show registration form for officers
    public function showRegistrationForm()
    {
        return view('auth.register');
    }

    // Handle registration request for officers
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        // Create user with role officer and approval_status pending
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'role' => 'officers',
            'approval_status' => 'pending',
            'password' => Hash::make($request->password),
        ]);

        // Optionally send notification to admin for approval

        return redirect()->route('login')->with('success', 'Registrasi berhasil. Silakan tunggu persetujuan admin.');
    }
}
