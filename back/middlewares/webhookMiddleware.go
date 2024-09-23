package middleware

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/webhook"
	"io"
	"kermessio/database"
	"kermessio/models"
	"net/http"
	"os"
	"strconv"
)

func HandleWebhook(c *gin.Context) {
	const MaxBodyBytes = int64(65536)
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, MaxBodyBytes)
	payload, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Error reading request body"})
		return
	}

	// Vérifier la signature du webhook
	endpointSecret := os.Getenv("STRIPE_WEBHOOK_SECRET")
	event, err := webhook.ConstructEvent(payload, c.GetHeader("Stripe-Signature"), endpointSecret)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid signature"})
		return
	}

	switch event.Type {
	case "payment_intent.succeeded":
		var paymentIntent stripe.PaymentIntent
		err := json.Unmarshal(event.Data.Raw, &paymentIntent)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Error parsing payment intent"})
			return
		}

		if err := handlePaymentIntentSucceeded(paymentIntent); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "Payment processed successfully"})
	default:
		c.JSON(http.StatusForbidden, gin.H{"message": fmt.Sprintf("Unhandled event type: %s", event.Type)})
	}
}

func handlePaymentIntentSucceeded(paymentIntent stripe.PaymentIntent) error {
	// Récupérer l'ID de l'utilisateur
	userID, ok := paymentIntent.Metadata["user_id"]
	if !ok {
		return fmt.Errorf("missing user_id in metadata")
	}

	// Récupérer l'ID de la kermesse
	kermesseIDStr, ok := paymentIntent.Metadata["kermesse_id"]
	if !ok {
		return fmt.Errorf("missing kermesse_id in metadata")
	}

	// Convertir kermesseID de string à uint
	kermesseID, err := strconv.ParseUint(kermesseIDStr, 10, 32)
	if err != nil {
		return fmt.Errorf("invalid kermesse_id: %w", err)
	}

	// Récupérer l'utilisateur
	var user models.User
	if err := database.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		return fmt.Errorf("user not found: %w", err)
	}

	// Calculer les jetons à ajouter
	eurosToCents := paymentIntent.Amount / 100 // 1€ = 1 jeton
	tokensToAdd := eurosToCents
	user.Tokens += tokensToAdd

	// Démarrer une transaction
	tx := database.DB.Begin()
	if err := tx.Save(&user).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to update user tokens: %w", err)
	}

	// Créer la transaction avec l'ID de la kermesse
	transaction := models.Transaction{
		UserID:     user.ID,
		KermesseID: uint(kermesseID),
		Amount:     eurosToCents,
		Tokens:     tokensToAdd,
	}

	if err := tx.Create(&transaction).Error; err != nil {
		tx.Rollback()
		return fmt.Errorf("failed to create transaction: %w", err)
	}

	// Commit de la transaction
	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}
