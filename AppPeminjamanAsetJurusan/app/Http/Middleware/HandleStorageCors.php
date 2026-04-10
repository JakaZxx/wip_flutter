<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class HandleStorageCors
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        $path = $request->path();

        // Only run for storage/public access routes we created
        if (str_starts_with($path, 'storage/') || str_starts_with($path, 'api/public-storage/')) {
            // BinaryFileResponse (used by response()->file()) exposes headers via ->headers
            if ($response instanceof BinaryFileResponse) {
                $response->headers->set('Access-Control-Allow-Origin', '*');
                $response->headers->set('Access-Control-Allow-Methods', 'GET, OPTIONS');
                $response->headers->set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
                $response->headers->set('Cache-Control', 'public, max-age=3600');
            } else {
                // Regular responses (Illuminate\Http\Response etc.)
                $response->headers->set('Access-Control-Allow-Origin', '*');
                $response->headers->set('Access-Control-Allow-Methods', 'GET, OPTIONS');
                $response->headers->set('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept');
                $response->headers->set('Cache-Control', 'public, max-age=3600');
            }
        }

        return $response;
    }
}