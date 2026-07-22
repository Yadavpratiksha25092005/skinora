package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	"skinora-backend/utils"
)

// AuthMiddleware verifies the JWT and stores userID + role in context.
// Use this on every protected route.
func AuthMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Authorization token required",
			})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		claims, err := utils.ValidateJWT(tokenString)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Invalid or expired token",
			})
			c.Abort()
			return
		}

		c.Set("userID", claims.UserID)
		c.Set("role", claims.Role)
		c.Next()
	}
}

// RequireRole restricts a route to a specific role (e.g. "doctor" only,
// or "user" only). Use AFTER AuthMiddleware in the route chain.
func RequireRole(allowedRole string) gin.HandlerFunc {
	return func(c *gin.Context) {
		role, exists := c.Get("role")
		if !exists || role != allowedRole {
			c.JSON(http.StatusForbidden, gin.H{
				"success": false,
				"message": "You do not have permission to access this resource",
			})
			c.Abort()
			return
		}
		c.Next()
	}
}
