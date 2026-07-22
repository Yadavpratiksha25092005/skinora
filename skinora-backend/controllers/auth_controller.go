package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"skinora-backend/config"
	"skinora-backend/models"
	"skinora-backend/utils"
)

// ---------- Request payloads ----------

type UserSignupInput struct {
	FullName     string `json:"full_name" binding:"required"`
	MobileNumber string `json:"mobile_number" binding:"required"`
	Password     string `json:"password" binding:"required,min=6"`
}

type DoctorSignupInput struct {
	FullName        string `json:"full_name" binding:"required"`
	MobileNumber    string `json:"mobile_number" binding:"required"`
	Email           string `json:"email" binding:"required,email"`
	Password        string `json:"password" binding:"required,min=6"`
	Specialization  string `json:"specialization" binding:"required"`
	LicenseNumber   string `json:"license_number" binding:"required"`
	ExperienceYears int    `json:"experience_years"`
	Qualification   string `json:"qualification"`
	ClinicName      string `json:"clinic_name"`
}

type LoginInput struct {
	MobileNumber string `json:"mobile_number" binding:"required"`
	Password     string `json:"password" binding:"required"`
	// Role tells the backend which table to check: "user" or "doctor"
	Role string `json:"role" binding:"required,oneof=user doctor"`
}

// ---------- Response helper ----------

func respond(c *gin.Context, status int, success bool, message string, data interface{}) {
	c.JSON(status, gin.H{
		"success": success,
		"message": message,
		"data":    data,
	})
}

// ---------- USER SIGNUP ----------

func UserSignup(c *gin.Context) {
	var input UserSignupInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond(c, http.StatusBadRequest, false, "Invalid input: "+err.Error(), nil)
		return
	}

	// Check if mobile number already exists among users
	var existing models.User
	if err := config.DB.Where("mobile_number = ?", input.MobileNumber).First(&existing).Error; err == nil {
		respond(c, http.StatusConflict, false, "mobile number already registered", nil)
		return
	}

	hashedPassword, err := utils.HashPassword(input.Password)
	if err != nil {
		respond(c, http.StatusInternalServerError, false, "Failed to secure password", nil)
		return
	}

	user := models.User{
		FullName:     input.FullName,
		MobileNumber: input.MobileNumber,
		PasswordHash: hashedPassword,
		Role:         "user",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		respond(c, http.StatusInternalServerError, false, "Failed to create account", nil)
		return
	}

	token, _ := utils.GenerateJWT(user.ID, "user")

	respond(c, http.StatusCreated, true, "Signup successful", gin.H{
		"token": token,
		"user":  user,
	})
}

// ---------- DOCTOR SIGNUP ----------

func DoctorSignup(c *gin.Context) {
	var input DoctorSignupInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond(c, http.StatusBadRequest, false, "Invalid input: "+err.Error(), nil)
		return
	}

	// Check mobile number and license number uniqueness among doctors
	var existing models.Doctor
	if err := config.DB.Where("mobile_number = ? OR license_number = ?", input.MobileNumber, input.LicenseNumber).First(&existing).Error; err == nil {
		respond(c, http.StatusConflict, false, "mobile number or license already registered", nil)
		return
	}

	hashedPassword, err := utils.HashPassword(input.Password)
	if err != nil {
		respond(c, http.StatusInternalServerError, false, "Failed to secure password", nil)
		return
	}

	doctor := models.Doctor{
		FullName:        input.FullName,
		MobileNumber:    input.MobileNumber,
		Email:           input.Email,
		PasswordHash:    hashedPassword,
		Role:            "doctor",
		Specialization:  input.Specialization,
		LicenseNumber:   input.LicenseNumber,
		ExperienceYears: input.ExperienceYears,
		Qualification:   input.Qualification,
		ClinicName:      input.ClinicName,
		IsVerified:      true, // admin must verify before doctor is visible to users
	}

	if err := config.DB.Create(&doctor).Error; err != nil {
		respond(c, http.StatusInternalServerError, false, "Failed to create account", nil)
		return
	}

	token, _ := utils.GenerateJWT(doctor.ID, "doctor")

	respond(c, http.StatusCreated, true, "Signup successful", gin.H{"token": token,
		"doctor": doctor,
	})
}

// ---------- LOGIN (shared endpoint, role decides which table to check) ----------

func Login(c *gin.Context) {
	var input LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		respond(c, http.StatusBadRequest, false, "Invalid input: "+err.Error(), nil)
		return
	}

	// Same generic error message for both "not found" and "wrong password"
	// so attackers can't enumerate registered numbers.
	const invalidMsg = "invalid mobile number or password"

	if input.Role == "doctor" {
		var doctor models.Doctor
		err := config.DB.Where("mobile_number = ?", input.MobileNumber).First(&doctor).Error
		if err != nil || !utils.CheckPasswordHash(input.Password, doctor.PasswordHash) {
			respond(c, http.StatusUnauthorized, false, invalidMsg, nil)
			return
		}

		token, _ := utils.GenerateJWT(doctor.ID, "doctor")
		respond(c, http.StatusOK, true, "Login successful", gin.H{
			"token":  token,
			"doctor": doctor,
		})
		return
	}

	// default: role == "user"
	var user models.User
	err := config.DB.Where("mobile_number = ?", input.MobileNumber).First(&user).Error
	if err != nil || !utils.CheckPasswordHash(input.Password, user.PasswordHash) {
		respond(c, http.StatusUnauthorized, false, invalidMsg, nil)
		return
	}

	token, _ := utils.GenerateJWT(user.ID, "user")
	respond(c, http.StatusOK, true, "Login successful", gin.H{
		"token": token,
		"user":  user,
	})
}

// helper to satisfy unused import if gorm.ErrRecordNotFound ever needed directly
var _ = gorm.ErrRecordNotFound
