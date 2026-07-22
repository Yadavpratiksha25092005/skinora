package routes

import (
	"github.com/gin-gonic/gin"

	"skinora-backend/controllers"
	"skinora-backend/middleware"
)

func SetupRoutes(r *gin.Engine) {
	api := r.Group("/api")

	// ---------- Public auth routes ----------
	auth := api.Group("/auth")
	{
		auth.POST("/user/signup", controllers.UserSignup)
		auth.POST("/doctor/signup", controllers.DoctorSignup)
		auth.POST("/login", controllers.Login) // role passed in body: "user" or "doctor"
	}

	// ---------- Protected: User-only routes ----------
	userRoutes := api.Group("/user")
	userRoutes.Use(middleware.AuthMiddleware(), middleware.RequireRole("user"))
	{
		// userRoutes.GET("/profile", controllers.GetProfile)
		// userRoutes.PUT("/basic-info", controllers.UpdateBasicInfo)
	}

	// ---------- Protected: Doctor-only routes ----------
	doctorRoutes := api.Group("/doctor")
	doctorRoutes.Use(middleware.AuthMiddleware(), middleware.RequireRole("doctor"))
	{
		// doctorRoutes.GET("/profile", controllers.GetDoctorProfile)
		// doctorRoutes.PUT("/availability", controllers.UpdateAvailability)
	}
}
