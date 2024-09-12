package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/paymentintent"
	"net/http"
)

func CreatePaymentIntent(c *gin.Context) {
	// Extract the amount and currency from the request (e.g., amount for purchasing tokens)
	var request struct {
		Amount   int64  `json:"amount"`   // Amount in the smallest currency unit (e.g., cents)
		Currency string `json:"currency"` // e.g., "usd"
	}

	if err := c.BindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
		return
	}

	// Create the payment intent
	params := &stripe.PaymentIntentParams{
		Amount:   stripe.Int64(request.Amount),
		Currency: stripe.String(request.Currency),
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to create payment intent: %v", err)})
		return
	}

	// Return the client secret to the frontend to confirm the payment
	c.JSON(http.StatusOK, gin.H{"clientSecret": pi.ClientSecret})
}
