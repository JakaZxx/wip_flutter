<!DOCTYPE html>
<html>
<head>
    <title>Assets Report</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1>Assets Report</h1>
    <table>
        <thead>
            <tr>
                <th>Asset Name</th>
                <th>Quantity</th>
                <th>Status</th>
                <th>Borrow Date</th>
                <th>Return Date</th>
            </tr>
        </thead>
        <tbody>
            @foreach($borrowings as $borrowing)
            <tr>
                <td>{{ $borrowing->commodity->name ?? 'N/A' }}</td>
                <td>{{ $borrowing->quantity }}</td>
                <td>{{ $borrowing->status }}</td>
                <td>{{ $borrowing->borrow_date }}</td>
                <td>{{ $borrowing->return_date }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>
</body>
</html>
