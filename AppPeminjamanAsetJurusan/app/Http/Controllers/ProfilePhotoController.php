<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProfilePhotoController extends Controller
{
    /**
     * Upload a new profile photo, delete old photo if exists.
     */
    public function uploadNewPhoto(Request $request)
{
    $user = Auth::user();

    $request->validate([
        'cropped_image' => 'required|string', // base64 string, bukan file
    ]);

    if ($request->cropped_image) {
        $image = $request->cropped_image;

        // Pisahin "data:image/png;base64,"
        list($type, $image) = explode(';', $image);
        list(, $image) = explode(',', $image);

        $image = base64_decode($image);

        // Nama file unik
        $imageName = time().'.png';

        // Simpan ke storage
        \Storage::disk('public')->put('profiles/'.$imageName, $image);

        // Hapus foto lama kalau bukan default
        if ($user->profile_picture
            && $user->profile_picture !== 'uploads/profile_pictures/default.png'
            && \Storage::disk('public')->exists($user->profile_picture)) {
            \Storage::disk('public')->delete($user->profile_picture);
        }

        // Update DB
        $user->profile_picture = 'profiles/'.$imageName;
        $user->save();
    }

    return redirect()->back()->with('success', 'Profile photo updated successfully.');
}



    /**
     * Delete profile photo and set to default.png
     */
    public function deletePhoto()
    {
        $user = Auth::user();

        if ($user->profile_picture && $user->profile_picture !== 'uploads/profile_pictures/default.png' && file_exists(public_path($user->profile_picture))) {
            unlink(public_path($user->profile_picture));
        }

        // Set profile_picture to default.png
        $user->profile_picture = 'uploads/profile_pictures/default.png';
        $user->save();

        return redirect()->back()->with('success', 'Profile photo deleted successfully.');
    }
}
