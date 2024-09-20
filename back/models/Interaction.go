package models

type Interaction struct {
	Base
	UserID     uint     `json:"user_id"`
	User       User     `json:"user"`
	ActivityID *uint    `json:"activity_id"`
	Activity   Activity `json:"activity" gorm:"foreignKey:ActivityID"`
	StockID    *uint    `json:"stock_id"`
	Stock      Stock    `json:"stock" gorm:"foreignKey:StockID"`
	Tokens     int      `json:"tokens"`
}
