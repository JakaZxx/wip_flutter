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
        Log::info('AuthController::login started', ['request' => $request->all()]);
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

            // Find in User table (Unified: Admin/Officer/Student)
            $user = \App\Models\User::where('email', $credentials['email'])
                ->orWhere('nis', $credentials['email']) // Support login by NIS for students in users table
                ->first();

            if ($user && \Illuminate\Support\Facades\Hash::check($credentials['password'], $user->password)) {
                Log::info('AuthController::login: User found and password correct', ['user_id' => $user->id, 'role' => $user->role]);
                
                // Load additional data for students or officers
                if ($user->role === 'students') {
                    $user->load('student.schoolClass');
                } else {
                    $user->load('student.schoolClass'); // Consistent loading
                }

                $token = $user->createToken('API Token')->plainTextToken;
                return response()->json([
                    'success' => true,
                    'message' => 'Login successful',
                    'data' => $user,
                    'token' => $token
                ]);
            }

            Log::warning('AuthController::login failed: Invalid credentials', ['identifier' => $request->email]);
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);
        } catch (\Exception $e) {
            Log::error('AuthController::login error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('AuthController::login ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred during login'
            ], 500);
        }
    }
    /**
     * Handle logout request
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        Log::info('AuthController::logout started');
        try {
            // Revoke the token that was used to authenticate the current request
            $request->user()->currentAccessToken()->delete();
            
            Log::info('AuthController::logout ended successfully');
            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully'
            ]);
        } catch (\Exception $e) {
            Log::error('AuthController::logout error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            Log::info('AuthController::logout ended with error');
            return response()->json([
                'success' => false,
                'message' => 'An error occurred during logout'
            ], 500);
        }
    }

    /**
     * Handle email verification
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verify(Request $request)
    {
        $user = \App\Models\User::findOrFail($request->id);

        if (! hash_equals((string) $request->hash, sha1($user->getEmailForVerification()))) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid verification link'
            ], 403);
        }

        if ($user->hasVerifiedEmail()) {
            return response()->json([
                'success' => true,
                'message' => 'Email already verified'
            ]);
        }

        if ($user->markEmailAsVerified()) {
            event(new \Illuminate\Auth\Events\Verified($user));
        }

        return response()->json([
            'success' => true,
            'message' => 'Email verified successfully'
        ]);
    }

    /**
     * Resend verification email
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resend(Request $request)
    {
        if ($request->user()->hasVerifiedEmail()) {
            return response()->json([
                'success' => false,
                'message' => 'Email already verified'
            ], 400);
        }

        $request->user()->sendEmailVerificationNotification();

        return response()->json([
            'success' => true,
            'message' => 'Verification link sent'
        ]);
    }
}
