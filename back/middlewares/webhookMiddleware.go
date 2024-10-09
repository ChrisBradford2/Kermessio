package middleware

import (
	"encoding/json"
	"fmt"
	"io"
	"kermessio/database"
	"kermessio/models"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"github.com/stripe/stripe-go/v79/webhook"
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
        log.Println("Erreur: missing user_id in metadata")
        return fmt.Errorf("missing user_id in metadata")
    }
    log.Println("user_id:", userID)

    // Récupérer l'ID de la kermesse
    kermesseID, ok := paymentIntent.Metadata["kermesse_id"]
    if !ok {
        log.Println("Erreur: missing kermesse_id in metadata")
        return fmt.Errorf("missing kermesse_id in metadata")
    }
    log.Println("kermesse_id:", kermesseID)

    // Récupérer l'utilisateur
    var user models.User
    if err := database.DB.Where("id = ?", userID).First(&user).Error; err != nil {
        log.Println("Erreur: user not found:", err)
        return fmt.Errorf("user not found: %w", err)
    }

    // Calculer les jetons à ajouter
    eurosToCents := paymentIntent.Amount / 100 // 1€ = 1 jeton
    tokensToAdd := eurosToCents
    user.Tokens += tokensToAdd

    log.Println("Tokens to add:", tokensToAdd)

    // Démarrer une transaction
    tx := database.DB.Begin()
    if err := tx.Save(&user).Error; err != nil {
        log.Println("Erreur lors de la mise à jour des jetons utilisateur:", err)
        tx.Rollback()
        return fmt.Errorf("failed to update user tokens: %w", err)
    }

    // Créer la transaction avec l'ID de la kermesse
    transaction := models.Transaction{
        UserID:     user.ID,
        KermesseID: uint(1),
        Amount:     eurosToCents,
        Tokens:     tokensToAdd,
    }

    if err := tx.Create(&transaction).Error; err != nil {
        log.Println("Erreur lors de la création de la transaction:", err)
        tx.Rollback()
        return fmt.Errorf("failed to create transaction: %w", err)
    }

    // Commit de la transaction
    if err := tx.Commit().Error; err != nil {
        log.Println("Erreur lors du commit de la transaction:", err)
        return fmt.Errorf("failed to commit transaction: %w", err)
    }

    log.Println("Transaction réussie avec succès pour l'utilisateur:", userID)

    return nil
}
