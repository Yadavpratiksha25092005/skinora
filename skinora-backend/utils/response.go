package utils

import "github.com/gin-gonic/gin"

// JSONResponse is the consistent response envelope used across all API endpoints.
type JSONResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// Success sends a 2xx JSON response with the given message and data.
func Success(c *gin.Context, status int, message string, data interface{}) {
	c.JSON(status, JSONResponse{Success: true, Message: message, Data: data})
}

// Error sends an error JSON response with the given status and message.
func Error(c *gin.Context, status int, message string) {
	c.JSON(status, JSONResponse{Success: false, Message: message})
}
