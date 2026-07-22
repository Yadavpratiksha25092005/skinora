package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"

	"skinora-backend/config"
	"skinora-backend/models"
	"skinora-backend/routes"
)

// corsMiddleware allows cross-origin requests from the Flutter app (mobile/web/emulator).
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func main() {
	// Load environment variables from .env
	if err := godotenv.Load(); err != nil {
		log.Println("warning: .env file not found, relying on system environment variables")
	}

	// Connect to PostgreSQL via GORM
	config.ConnectDB()

	// Auto-migrate models
	if err := config.DB.AutoMigrate(&models.User{}, &models.Doctor{}); err != nil {
		log.Fatalf("failed to auto-migrate models: %v", err)
	}

	// Set up Gin router
	r := gin.Default()
	r.Use(corsMiddleware())

	// Register routes
	routes.SetupRoutes(r)

	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Skinora backend server running successfully on http://localhost:%s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("failed to start server: %v", err)
	}
}
