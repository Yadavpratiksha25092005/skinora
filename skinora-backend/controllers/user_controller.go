package controllers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	"skinora-backend/config"
	"skinora-backend/models"
	"skinora-backend/utils"
)

// UpdateBasicInfoRequest is the expected JSON body for updating basic profile info.
type UpdateBasicInfoRequest struct {
	Age      int     `json:"age" binding:"required"`
	Gender   string  `json:"gender" binding:"required"`
	HeightCM float64 `json:"height_cm"`
	WeightKG float64 `json:"weight_kg"`
}

// GetProfile returns the authenticated user's profile.
func GetProfile(c *gin.Context) {
	userID := c.GetUint("userID")

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			utils.Error(c, http.StatusNotFound, "user not found")
			return
		}
		utils.Error(c, http.StatusInternalServerError, "failed to fetch user")
		return
	}

	utils.Success(c, http.StatusOK, "profile fetched successfully", user)
}

// UpdateBasicInfo updates the authenticated user's age, gender, height and weight,
// and marks the profile as completed.
func UpdateBasicInfo(c *gin.Context) {
	userID := c.GetUint("userID")

	var req UpdateBasicInfoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.Error(c, http.StatusBadRequest, "age and gender are required")
		return
	}

	if req.Gender != "male" && req.Gender != "female" {
		utils.Error(c, http.StatusBadRequest, "gender must be 'male' or 'female'")
		return
	}

	var user models.User
	if err := config.DB.First(&user, userID).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			utils.Error(c, http.StatusNotFound, "user not found")
			return
		}
		utils.Error(c, http.StatusInternalServerError, "failed to fetch user")
		return
	}

	user.Age = req.Age
	user.Gender = req.Gender
	user.HeightCM = req.HeightCM
	user.WeightKG = req.WeightKG
	user.ProfileCompleted = true

	if err := config.DB.Save(&user).Error; err != nil {
		utils.Error(c, http.StatusInternalServerError, "failed to update profile")
		return
	}

	utils.Success(c, http.StatusOK, "profile updated successfully", user)
}
