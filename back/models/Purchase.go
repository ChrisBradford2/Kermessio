package models

type Status string

const (
	Pending  = "pending"
	Approved = "approved"
	Rejected = "rejected"
)

type Purchase struct {
	Base
	UserID         uint   `json:"user_id" gorm:"not null" binding:"required" example:"1"`
	User           User   `json:"user" gorm:"foreignKey:UserID"`
	StockID        uint   `json:"stock_id" gorm:"not null" binding:"required" example:"1"`
	Stock          Stock  `json:"stock" gorm:"foreignKey:StockID"`
	Quantity       int    `json:"quantity" gorm:"not null" binding:"required" example:"2"`
	Price          int    `json:"price" gorm:"not null" binding:"required" example:"5"`
	ValidationCode string `json:"validation_code" gorm:"unique;not null"`
	Status         Status `json:"status" gorm:"not null,default:'pending'" binding:"required" example:"pending"`
}

type CreatePurchaseRequest struct {
	UserID   uint `json:"user_id" binding:"required"`
	StockID  uint `json:"stock_id" binding:"required"`
	Quantity int  `json:"quantity" binding:"required"`
}
