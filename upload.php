<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

$host = 'localhost';
$user = 'root'; // Your MySQL username
$password = ''; // Your MySQL password
$database = 'disease';

// Create a connection
$conn = new mysqli($host, $user, $password, $database);

// Check the connection
if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Connection failed: ' . $conn->connect_error]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Log the received files
    error_log(print_r($_FILES, true)); // Log the contents of $_FILES for debugging

    // Handle image upload
    if (isset($_FILES['image'])) {
        $image = $_FILES['image'];
        $targetDirectory = 'uploads/';
        
        // Generate a unique name for the file to avoid overwriting
        $fileExtension = pathinfo($image["name"], PATHINFO_EXTENSION);
        $newFileName = uniqid('img_', true) . '.' . $fileExtension; // Unique filename
        $targetFile = $targetDirectory . $newFileName;

        // Create uploads directory if it doesn't exist
        if (!file_exists($targetDirectory)) {
            mkdir($targetDirectory, 0777, true);
        }

        // Move the uploaded file to the uploads directory
        if (move_uploaded_file($image["tmp_name"], $targetFile)) {
            // Build the full URL to the image
            $fullUrl = 'http://' . $_SERVER['HTTP_HOST'] . '/' . $targetFile; // Adjust this line if needed

            // Save image path to the database
            $sql = "INSERT INTO images (image_path) VALUES ('$fullUrl')";
            if ($conn->query($sql) === TRUE) {
                echo json_encode(['success' => true, 'message' => 'Image uploaded successfully', 'url' => $fullUrl]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Database error: ' . $conn->error]);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Error uploading file']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'No file uploaded']);
    }
}

$conn->close();
?>
