<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Testing Officer Asset Controller Modal Functionality\n";
echo "==================================================\n\n";

// Test 1: Check if Commodity model has all required fields
echo "1. Testing Commodity model fillable fields:\n";
$commodity = new App\Models\Commodity();
$fillable = $commodity->getFillable();
echo "Fillable fields: " . implode(', ', $fillable) . "\n";

$requiredFields = ['name', 'code', 'stock', 'jurusan', 'lokasi', 'condition', 'photo', 'merk', 'sumber', 'tahun', 'deskripsi', 'harga_satuan'];
$missingFields = array_diff($requiredFields, $fillable);

if (empty($missingFields)) {
    echo "✓ All required fields are present in the model\n";
} else {
    echo "✗ Missing fields: " . implode(', ', $missingFields) . "\n";
}

echo "\n";

// Test 2: Check if controller exists and has detail method
echo "2. Testing OfficerAssetController:\n";
if (class_exists('App\Http\Controllers\OfficerAssetController')) {
    echo "✓ OfficerAssetController class exists\n";

    $controller = new App\Http\Controllers\OfficerAssetController();
    $methods = get_class_methods($controller);

    if (in_array('detail', $methods)) {
        echo "✓ detail method exists in controller\n";
    } else {
        echo "✗ detail method missing in controller\n";
    }
} else {
    echo "✗ OfficerAssetController class not found\n";
}

echo "\n";

// Test 3: Check if route exists
echo "3. Testing routes:\n";
$routes = app('router')->getRoutes();
$detailRouteExists = false;

foreach ($routes as $route) {
    if ($route->uri() === 'officers/assets/{id}/detail' && in_array('GET', $route->methods())) {
        $detailRouteExists = true;
        break;
    }
}

if ($detailRouteExists) {
    echo "✓ Detail route exists: GET officers/assets/{id}/detail\n";
} else {
    echo "✗ Detail route not found\n";
}

echo "\n";

// Test 4: Check database table structure
echo "4. Testing database table structure:\n";
try {
    $columns = \Illuminate\Support\Facades\Schema::getColumnListing('commodities');
    echo "Database columns: " . implode(', ', $columns) . "\n";

    $requiredColumns = ['merk', 'sumber', 'tahun', 'deskripsi', 'harga_satuan'];
    $missingColumns = array_diff($requiredColumns, $columns);

    if (empty($missingColumns)) {
        echo "✓ All required database columns exist\n";
    } else {
        echo "✗ Missing database columns: " . implode(', ', $missingColumns) . "\n";
    }
} catch (Exception $e) {
    echo "✗ Error checking database: " . $e->getMessage() . "\n";
}

echo "\n";
echo "Modal functionality test completed!\n";
