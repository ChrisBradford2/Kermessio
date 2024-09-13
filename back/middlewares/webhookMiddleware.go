package middleware

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"io/ioutil"
	"kermessio/database"
	"kermessio/models"
	"net/http"
)

func HandleWebhook(c *gin.Context) {
	const MaxBodyBytes = int64(65536)
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, MaxBodyBytes)
	payload, err := ioutil.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Error reading request body"})
		return
	}

	var event stripe.Event
	if err := json.Unmarshal(payload, &event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error parsing webhook JSON"})
		return
	}

	switch event.Type {
	case "payment_intent.succeeded":
		var paymentIntentData map[string]interface{}

		// Extraire l'objet PaymentIntent depuis event.Data.Object
		if err := json.Unmarshal(event.Data.Raw, &paymentIntentData); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Error decoding payment intent object"})
			return
		}

		// Extraire les métadonnées (metadata) si elles existent
		if metadata, ok := paymentIntentData["metadata"].(map[string]interface{}); ok {
			if userID, ok := metadata["user_id"].(string); ok {
				var user models.User
				if err := database.DB.Where("id = ?", userID).First(&user).Error; err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "User not found"})
					return
				}

				// Extraire le montant payé (en centimes)
				amount := int(paymentIntentData["amount"].(float64))

				// Ajouter les jetons à l'utilisateur
				tokensToAdd := amount / 100 // 1€ = 1 jeton
				user.Tokens += int64(tokensToAdd)
				if err := database.DB.Save(&user).Error; err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user tokens"})
					return
				}

				c.JSON(http.StatusOK, gin.H{"message": "User tokens updated successfully"})
				return
			}
		}

		c.JSON(http.StatusBadRequest, gin.H{"error": "Missing or invalid metadata"})
	default:
		c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Unhandled event type: %s", event.Type)})
	}
}
