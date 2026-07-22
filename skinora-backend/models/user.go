package models

import "time"

// User represents a normal app user (patient).
// Role distinguishes user accounts from doctor accounts.
type User struct {
	ID               uint      `json:"id" gorm:"primaryKey"`
	FullName         string    `json:"full_name"`
	MobileNumber     string    `json:"mobile_number" gorm:"unique;not null"`
	PasswordHash     string    `json:"-"`                          // never expose in JSON responses
	Role             string    `json:"role" gorm:"default:'user'"` // always "user" for this table
	Age              int       `json:"age"`
	Gender           string    `json:"gender"`
	HeightCM         float64   `json:"height_cm"`
	WeightKG         float64   `json:"weight_kg"`
	ProfileCompleted bool      `json:"profile_completed" gorm:"default:false"`
	CreatedAt        time.Time `json:"created_at"`
	UpdatedAt        time.Time `json:"updated_at"`
}
