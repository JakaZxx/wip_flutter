<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Borrowing Request Notification</title>
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
        .button {
            display: inline-block;
            margin: 20px 0;
            padding: 12px 24px;
            background: #3b82f6;
            color: #ffffff;
            text-decoration: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            text-align: center;
        }
        .button:hover {
            background: #2563eb;
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
            <h1>Borrowing Request Notification</h1>
        </div>
        <div class="content">
            <p>Dear {{ $recipientName }},</p>
            <p>A new borrowing request has been submitted.</p>
            <p><strong>Requested By:</strong> {{ $borrowing->student->name }}</p>
            <p><strong>Items:</strong></p>
            <ul>
                @foreach($borrowing->items as $item)
                    <li>{{ $item->commodity->name }} (Quantity: {{ $item->quantity }})</li>
                @endforeach
            </ul>
            <a href="{{ $url }}" class="button">View Request</a>
        </div>
        <div class="footer">
            <p>&copy; 2023 SMKN 4 Bandung. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
