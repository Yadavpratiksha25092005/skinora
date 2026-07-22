package models

import "time"

// Doctor represents a dermatologist/medical professional account.
// Kept as a separate table from User because doctors have a
// fundamentally different data shape (credentials, verification, etc.)
type Doctor struct {
	ID           uint   `json:"id" gorm:"primaryKey"`
	FullName     string `json:"full_name"`
	MobileNumber string `json:"mobile_number" gorm:"unique;not null"`
	Email        string `json:"email" gorm:"unique"`
	PasswordHash string `json:"-"`
	Role         string `json:"role" gorm:"default:'doctor'"`

	// Professional details
	Specialization  string `json:"specialization"`
	LicenseNumber   string `json:"license_number" gorm:"unique"`
	ExperienceYears int    `json:"experience_years"`
	Qualification   string `json:"qualification"`
	ClinicName      string `json:"clinic_name"`

	// Verification & status
	IsVerified       bool   `json:"is_verified" gorm:"default:false"`
	VerificationDocs string `json:"verification_docs"`
	IsAvailable      bool   `json:"is_available" gorm:"default:true"`

	// Ratings
	Rating        float64 `json:"rating" gorm:"default:0"`
	TotalConsults int     `json:"total_consults" gorm:"default:0"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
