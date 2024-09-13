package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/paymentintent"
	"kermessio/models"
	"net/http"
)

// CreatePaymentIntent godoc
// @Summary Create a payment intent
// @Description Create a payment intent for purchasing tokens
// @Tags PaymentIntent
// @Accept json
// @Produce json
// @Security ApiKeyAuth
// @Param request body models.CreatePaymentIntentRequest true "Payment Intent Request"
// @Success 200 {object} models.CreatePaymentIntentResponse
// @Router /create-payment-intent [post]
func CreatePaymentIntent(c *gin.Context) {
	var request models.CreatePaymentIntentRequest

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
