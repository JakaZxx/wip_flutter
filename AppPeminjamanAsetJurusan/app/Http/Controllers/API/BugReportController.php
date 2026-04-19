<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use App\Mail\BugReportMail;

class BugReportController extends Controller
{
    /**
     * Submit a bug report from the API.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function submitForm(Request $request)
    {
        try {
            $request->validate([
                'device_type' => 'required|in:mobile,desktop',
                'bug_type' => 'required|in:tampilan,sistem',
                'bug_description' => 'required|string|max:2000',
                'expected_behavior' => 'nullable|string|max:2000',
                'bug_image' => 'nullable|image|max:10000', // max 10MB
            ]);

            $user = $request->user();

            $data = [
                'name' => $user->name ?? 'Unknown',
                'email' => $user->email ?? 'Unknown',
                'device_type' => $request->input('device_type'),
                'bug_type' => $request->input('bug_type'),
                'bug_description' => $request->input('bug_description'),
                'expected_behavior' => $request->input('expected_behavior'),
                'reported_at' => now()->toDateTimeString(),
                'bug_image_path' => null,
            ];

            if ($request->hasFile('bug_image')) {
                $image = $request->file('bug_image');
                $imageName = time() . '_' . $image->getClientOriginalName();
                $image->storeAs('public/bug_images', $imageName);
                $data['bug_image_path'] = 'storage/bug_images/' . $imageName;
            }

            // Send bug report email to admin
            Mail::to(env('MAIL_ADMIN_ADDRESS', 'emailadmin@gmail.com'))->send(new BugReportMail($data));

            return response()->json([
                'success' => true,
                'message' => 'Bug report sent successfully.',
                'data' => $data
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation Error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('Bug Report Submission Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to submit bug report.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
