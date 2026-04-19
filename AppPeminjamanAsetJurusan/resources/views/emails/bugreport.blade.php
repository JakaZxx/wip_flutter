<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>New Bug Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            background-color: #ffffff;
            color: #333;
            padding: 20px;
            margin: 0;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: #1e3a8a;
            color: #ffffff;
            padding: 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: bold;
        }
        .content {
            padding: 20px;
            font-size: 16px;
        }
        .footer {
            background: #f3f4f6;
            padding: 20px;
            text-align: center;
            color: #6b7280;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>New Bug Report</h1>
        </div>
        <div class="content">
            <p><strong>User Name:</strong> {{ $name }}</p>
            <p><strong>User Email:</strong> {{ $email }}</p>
            <p><strong>Report Time:</strong> {{ $reported_at }}</p>
            <p><strong>Device Type:</strong> {{ ucfirst($device_type) }}</p>
            <p><strong>Bug Type:</strong> {{ ucfirst($bug_type) }}</p>
            <p><strong>Bug Description:</strong></p>
            <p>{{ $bug_description }}</p>
            <p><strong>Expected Behavior:</strong></p>
            <p>{{ $expected_behavior }}</p>
            @if($bug_image_path)
                <p><strong>Bug Image:</strong></p>
                <img src="{{ asset($bug_image_path) }}" alt="Bug Image" style="max-width: 100%; height: auto;">
            @endif
        </div>
        <div class="footer">
            <p>&copy; 2026 SMKN 4 Bandung. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
