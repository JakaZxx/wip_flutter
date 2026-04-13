<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    /**
     * Handle login request
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        Log::info('AuthController::login started');
        try {
            // Validate input
            $validator = Validator::make($request->all(), [
                'email' => 'required', // Relaxed to allow NIS
                'password' => 'required|string|min:6',
            ]);

            if ($validator->fails()) {
                Log::warning('AuthController::login validation failed', ['errors' => $validator->errors()]);
                Log::info('AuthController::login ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Validation errors',
                    'errors' => $validator->errors()
                ], 422);
            }

            $credentials = $request->only('email', 'password');

            // Find user by email or nis
            $user = \App\Models\User::where('email', $credentials['email'])
                ->orWhere('nis', $credentials['email'])
                ->first();

            if ($user && \Illuminate\Support\Facades\Hash::check($credentials['password'], $user->password)) {
                $user->load('student.schoolClass');
                $token = $user->createToken('API Token')->plainTextToken;
                Log::info('AuthController::login ended successfully');
                return response()->json([
                    'success' => true,
                    'message' => 'Login successful',
                    'data' => $user,
                    'token' => $token
                ]);
            } else {
                Log::warning('AuthController::login failed: Invalid credentials', ['email' => $request->email]);
                Log::info('AuthController::login ended');
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid email/NIS or password'
                ], 401);
            }
        } catch (\Exception $e) {
            Log::error('AuthController::login error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('AuthController::login ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred during login'
            ], 500);
        }
    }
}
