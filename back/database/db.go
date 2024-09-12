package database

import (
	"fmt"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"log"
	"os"
	"time"
)

// DB Global variable to hold the database connection
var DB *gorm.DB

// ConnectDatabase initializes the database connection and assigns it to the global DB variable
func ConnectDatabase() error {
	var dsn string

	// Check the environment and set the DSN accordingly
	if os.Getenv("GO_ENV") == "development" {
		dsn = fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
			os.Getenv("DB_HOST"),
			os.Getenv("DB_PORT"),
			os.Getenv("DB_USER"),
			os.Getenv("DB_PASSWORD"),
			os.Getenv("DB_NAME"))
	} else {
		dsn = os.Getenv("DATABASE_URL")
		if dsn == "" {
			return fmt.Errorf("DATABASE_URL environment variable is not set")
		}
	}

	// Try to connect to the database 5 times
	var err error
	for i := 0; i < 5; i++ {
		DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			log.Println("Database connection established successfully")
			return nil
		}
		log.Printf("Failed to connect to the database. Retrying in 5 seconds... (attempt %d/5)", i+1)
		time.Sleep(5 * time.Second)
	}

	return fmt.Errorf("failed to connect to the database after 5 attempts: %v", err)
}
