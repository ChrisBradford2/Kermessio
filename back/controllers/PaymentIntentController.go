package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/paymentintent"
	"kermessio/database"
	"kermessio/models"
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

	// Ajoutez ici l'ID de la kermesse
	kermesseID := c.Query("kermesse_id")

	params := &stripe.PaymentIntentParams{
		Amount:   stripe.Int64(request.Amount),
		Currency: stripe.String(request.Currency),
		Metadata: map[string]string{
			"user_id":     strconv.Itoa(int(user.ID)),
			"kermesse_id": kermesseID, // Ajout de l'ID de la kermesse
		},
	}

	pi, err := paymentintent.New(params)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to create payment intent: %v", err)})
		return
	}

	c.JSON(http.StatusOK, gin.H{"clientSecret": pi.ClientSecret})
}

func GetKermesseRevenue(c *gin.Context) {
	// Récupérer l'ID de la kermesse depuis les paramètres
	kermesseID, err := strconv.Atoi(c.Param("kermesseId"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid kermesse ID"})
		return
	}

	var totalRevenue int64
	// Utilisation de COALESCE pour retourner 0 si SUM(tokens) est NULL
	if err := database.DB.Model(&models.Transaction{}).
		Where("kermesse_id = ?", kermesseID).
		Select("COALESCE(SUM(tokens), 0)").
		Scan(&totalRevenue).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des recettes globales"})
		return
	}

	var transactions []models.Transaction
	// Récupérer l'historique des transactions
	if err := database.DB.Where("kermesse_id = ?", kermesseID).Find(&transactions).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Erreur lors de la récupération des transactions"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"total_revenue": totalRevenue,
		"transactions":  transactions,
	})
}
