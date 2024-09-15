package models

// Stock represents a food or beverage item with its available stock
type Stock struct {
	Base
	ItemName string `json:"item_name" gorm:"not null" binding:"required" example:"item_name"`
	Quantity int    `json:"quantity" gorm:"not null" binding:"required" example:"quantity"`
	Price    int    `json:"price" gorm:"not null" binding:"required" example:"price"`
}
