package models

type Transaction struct {
	Base
	UserID     uint     `json:"user_id"`
	User       User     `json:"user" gorm:"foreignKey:UserID"`
	KermesseID uint     `json:"kermesse_id"`
	Kermesse   Kermesse `json:"kermesse" gorm:"foreignKey:KermesseID"`
	Amount     int64    `json:"amount"`
	Tokens     int64    `json:"tokens"`
}
