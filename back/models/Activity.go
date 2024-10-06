package models

// Activity represents an activity that can be done by a User.
type Activity struct {
	Base
	Name          string   `json:"name" gorm:"type:varchar(100);not null" binding:"required" example:"Ping Pong"`
	Type          string   `json:"type" gorm:"type:varchar(50);not null" binding:"required" example:"Sport"`
	Emoji         string   `json:"emoji" gorm:"type:varchar(10)" example:"🏓"`
	Price         uint     `json:"price" gorm:"not null" binding:"required" example:"10"`
	Points        uint     `json:"points" gorm:"not null" example:"10"`
	BoothHolderID uint     `json:"booth_holder_id" gorm:"not null" binding:"required" example:"1"`
	BoothHolder   User     `json:"booth_holder" gorm:"foreignKey:BoothHolderID"`
	KermesseID    uint     `json:"kermesse_id" gorm:"not null"`
	Kermesse      Kermesse `json:"kermesse" gorm:"foreignKey:KermesseID"`
}

type CreateActivityRequest struct {
	Name       string `json:"name" binding:"required"`
	Type       string `json:"type" binding:"required"`
	Emoji      string `json:"emoji"`
	Price      uint   `json:"price" binding:"required"`
	Points     uint   `json:"points" binding:"required"`
	KermesseID uint   `json:"kermesse_id" binding:"required"`
}
