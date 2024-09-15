package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/paymentintent"
	"kermessio/database"
	"kermessio/models"
	"log"
	"net/http"
	"strconv"
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

	user := c.MustGet("currentUser").(models.User)

	params := &stripe.PaymentIntentParams{
		Amount:   stripe.Int64(request.Amount),
		Currency: stripe.String(request.Currency),
		Metadata: map[string]string{
			"user_id": strconv.Itoa(int(user.ID)),
		},
	}

	pi, err := paymentintent.New(params)
	log.Println("Payment intent created")
	log.Println(pi)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to create payment intent: %v", err)})
		return
	}

	if pi.Status == "succeeded" {
		log.Println("Payment intent already succeeded")
		tokensToAdd := request.Amount / 100 // 1€ = 1 jeton
		err = database.DB.Model(&user).Update("tokens", user.Tokens+tokensToAdd).Error
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user tokens"})
			return
		}
	}

	// Retourner le client secret pour confirmer le paiement sur le frontend
	c.JSON(http.StatusOK, gin.H{"clientSecret": pi.ClientSecret})
}
