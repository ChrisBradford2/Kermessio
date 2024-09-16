package models

// Participation represents a User's participation in an activity and the points awarded.
type Participation struct {
	Base
	UserID     uint `json:"user_id" gorm:"not null" binding:"required" example:"1"`
	ActivityID uint `json:"activity_id" gorm:"not null" binding:"required" example:"1"`
	Points     uint `json:"points" gorm:"not null" binding:"required" example:"10"`
	IsWinner   bool `json:"is_winner" gorm:"not null" example:"false"`
}

type CreateParticipationRequest struct {
	UserID     uint `json:"user_id" binding:"required" example:"1"`
	ActivityID uint `json:"activity_id" binding:"required" example:"1"`
}

type UpdateParticipationRequest struct {
	ParticipationID uint `json:"participation_id" binding:"required" example:"1"`
	IsWinner        bool `json:"is_winner" binding:"required" example:"true"`
}
