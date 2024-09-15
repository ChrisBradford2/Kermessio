package models

type CreatePaymentIntentRequest struct {
	Amount   int64  `json:"amount" binding:"required" example:"1000"`
	Currency string `json:"currency" binding:"required" example:"eur"`
}

type CreatePaymentIntentResponse struct {
	ClientSecret string `json:"clientSecret"`
}
