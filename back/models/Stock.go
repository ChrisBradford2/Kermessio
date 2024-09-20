package models

type StockType string

const (
	Beverage StockType = "Boisson"
	Food     StockType = "Nourriture"
)

// Stock represents a food or beverage item with its available stock
type Stock struct {
	Base
	ItemName      string     `json:"item_name" gorm:"not null" binding:"required" example:"item_name"`
	Type          StockType  `json:"type" gorm:"not null" binding:"required" example:"Boisson"`
	Quantity      int        `json:"quantity" gorm:"not null" binding:"required" example:"quantity"`
	Price         int        `json:"price" gorm:"not null" binding:"required" example:"price"`
	BoothHolderID uint       `json:"booth_holder_id" gorm:"not null" binding:"required" example:"1"`
	BoothHolder   User       `json:"booth_holder" gorm:"foreignKey:BoothHolderID"`
	Purchases     []Purchase `json:"purchases" gorm:"foreignKey:StockID"`
	KermesseID    uint       `json:"kermesse_id" gorm:"not null"`
	Kermesse      Kermesse   `json:"kermesse" gorm:"foreignKey:KermesseID"`
}

type BuyStockRequest struct {
	BoothHolderID uint `json:"booth_holder_id" binding:"required"`
	StockID       uint `json:"stock_id" binding:"required"`
}
