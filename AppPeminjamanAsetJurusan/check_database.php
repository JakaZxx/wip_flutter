<?php
// Simple database connection test
$host = 'localhost';
$user = 'root'; // default XAMPP MySQL user
$pass = ''; // default XAMPP MySQL password
$db = 'db_asetkejuruan'; // assuming this is the database name

echo "Testing database connection...\n";

try {
    $conn = new mysqli($host, $user, $pass, $db);
    
    if ($conn->connect_error) {
        echo "Database connection failed: " . $conn->connect_error . "\n";
        exit(1);
    } else {
        echo "Database connection successful!\n";
        
        // Check if students table exists
        $result = $conn->query("SHOW TABLES LIKE 'students'");
        if ($result->num_rows > 0) {
            echo "Students table exists.\n";
            
            // Count students
            $countResult = $conn->query("SELECT COUNT(*) as count FROM students");
            $count = $countResult->fetch_assoc()['count'];
            echo "Number of students: " . $count . "\n";
            
            // Show student data
            $students = $conn->query("SELECT * FROM students");
            if ($students->num_rows > 0) {
                echo "Student records:\n";
                while ($student = $students->fetch_assoc()) {
                    echo "ID: " . $student['id'] . ", Name: " . $student['name'] . ", User ID: " . ($student['user_id'] ?? 'NULL') . "\n";
                }
            } else {
                echo "No student records found.\n";
            }
        } else {
            echo "Students table does not exist.\n";
        }
        
        // Check users table
        echo "\nChecking users table:\n";
        $result = $conn->query("SHOW TABLES LIKE 'users'");
        if ($result->num_rows > 0) {
            echo "Users table exists.\n";
            
            // Count users
            $countResult = $conn->query("SELECT COUNT(*) as count FROM users");
            $count = $countResult->fetch_assoc()['count'];
            echo "Number of users: " . $count . "\n";
            
            // Show user data
            $users = $conn->query("SELECT * FROM users");
            if ($users->num_rows > 0) {
                echo "User records:\n";
                while ($user = $users->fetch_assoc()) {
                    echo "ID: " . $user['id'] . ", Name: " . $user['name'] . ", Role: " . $user['role'] . "\n";
                }
            } else {
                echo "No user records found.\n";
            }
        } else {
            echo "Users table does not exist.\n";
        }
        
        $conn->close();
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
