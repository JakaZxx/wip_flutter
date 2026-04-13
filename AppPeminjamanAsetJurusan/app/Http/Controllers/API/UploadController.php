<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class UploadController extends Controller
{
    /**
     * Handle file uploads from clients (mobile/web).
     * Expects multipart/form-data with a file field named 'file' (configurable client-side).
     * Stores into the 'public' disk under a 'commodities' directory and returns the stored path
     * prefixed with 'public/' so it can be saved into the commodity.photo column.
     */
    public function upload(Request $request)
    {
        try {
            if (! $request->hasFile('file')) {
                return response()->json([
                    'success' => false,
                    'message' => 'No file uploaded'
                ], 400);
            }

            $file = $request->file('file');

            if (! $file->isValid()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Uploaded file is not valid'
                ], 400);
            }

            // Store in public disk under commodities/ with default visibility
            $relativePath = $file->store('commodities', 'public'); // e.g. commodities/abc.jpg

            // Prepend 'public/' to match how photo paths are stored in models/controllers
            $storedPath = 'public/' . $relativePath; // e.g. public/commodities/abc.jpg

            Log::info('UploadController::upload stored file', ['path' => $storedPath]);

            return response()->json([
                'success' => true,
                'path' => $storedPath,
            ], 200);
        } catch (\Exception $e) {
            Log::error('UploadController::upload error', ['message' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred during file upload',
            ], 500);
        }
    }
}
