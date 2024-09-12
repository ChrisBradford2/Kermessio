package models

import "time"

type Base struct {
	ID        uint       `json:"id" gorm:"primarykey"`
	CreatedAt time.Time  `json:"createdAt"`
	UpdatedAt time.Time  `json:"updatedAt"`
	DeletedAt *time.Time `json:"deletedAt" gorm:"index"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type JSONResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}
