package models

type Interaction struct {
	Base
	UserID     uint     `json:"user_id"`
	User       User     `json:"user"`                                  // Relation avec User
	ActivityID *uint    `json:"activity_id"`                           // Pointeur pour permettre des valeurs nulles
	Activity   Activity `json:"activity" gorm:"foreignKey:ActivityID"` // Relation avec Activity
	StockID    *uint    `json:"stock_id"`                              // Pointeur pour permettre des valeurs nulles
	Stock      Stock    `json:"stock" gorm:"foreignKey:StockID"`       // Relation avec Stock
	Tokens     int      `json:"tokens"`                                // Montant des jetons utilisés dans cette interaction
}
