<?php
/**
 * CiviCore - Database Configuration
 * 
 * Database connection settings for MySQL
 * Supports transparency and accountability in data access
 */

class Database {
    private $host = "localhost";
    private $db_name = "civicore";
    private $username = "root";
    private $password = "";
    private $conn = null;

    /**
     * Get database connection
     * @return PDO|null
     */
    public function getConnection() {
        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
        } catch(PDOException $e) {
            error_log("Database Connection Error: " . $e->getMessage());
            $this->conn = null;
        }
        return $this->conn;
    }
}
