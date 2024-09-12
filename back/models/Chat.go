package models

import (
	"time"
)

type Chat struct {
	ID         uint      `gorm:"primaryKey"`
	SenderID   uint      `gorm:"not null"` // Foreign key to User (Sender)
	Sender     User      `gorm:"foreignKey:SenderID"`
	ReceiverID uint      `gorm:"not null"` // Foreign key to User (Receiver)
	Receiver   User      `gorm:"foreignKey:ReceiverID"`
	Message    string    `gorm:"not null"`
	CreatedAt  time.Time `gorm:"autoCreateTime"`
}
