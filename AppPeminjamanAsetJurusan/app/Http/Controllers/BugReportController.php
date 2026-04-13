<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use App\Mail\BugReportMail;

class BugReportController extends Controller
{
    public function showForm()
    {
        return view('bugreport.form');
    }

    public function submitForm(Request $request)
    {
        $request->validate([
            'device_type' => 'required|in:mobile,desktop',
            'bug_type' => 'required|in:tampilan,sistem',
            'bug_description' => 'required|string|max:2000',
            'expected_behavior' => 'nullable|string|max:2000',
            'bug_image' => 'nullable|image|max:10000', // max 2MB
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

        // Send bug report email to admin@example.com via Mailpit SMTP
        Mail::to('admin@example.com')->send(new BugReportMail($data));

        // For demonstration, we'll also store it in session to show it was processed
        session(['last_bug_report' => $data]);

        return redirect()->back()->with('success', 'Bug report sent successfully.');
    }

    private function formatBugReport(array $data): string
    {
        $report = "Bug Description:\n" . $data['bug_description'] . "\n\n";

        if (!empty($data['steps_to_reproduce'])) {
            $report .= "Steps to Reproduce:\n" . $data['steps_to_reproduce'] . "\n\n";
        }
        if (!empty($data['expected_behavior'])) {
            $report .= "Expected Behavior:\n" . $data['expected_behavior'] . "\n\n";
        }
        if (!empty($data['actual_behavior'])) {
            $report .= "Actual Behavior:\n" . $data['actual_behavior'] . "\n\n";
        }

        return $report;
    }
}
