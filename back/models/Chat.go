package models

type ChatMessage struct {
	Base
	SenderID   uint   `gorm:"not null" json:"sender_id"` // Foreign key to User (Sender)
	Sender     User   `gorm:"foreignKey:SenderID"`
	ReceiverID uint   `gorm:"not null" json:"receiver_id"` // Foreign key to User (Receiver)
	Receiver   User   `gorm:"foreignKey:ReceiverID"`
	Message    string `gorm:"not null" json:"message"`
}
