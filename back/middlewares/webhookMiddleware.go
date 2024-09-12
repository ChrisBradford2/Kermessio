package middleware

import (
	"encoding/json"
	"fmt"
	"github.com/gin-gonic/gin"
	"github.com/stripe/stripe-go/v79"
	"io"
	"net/http"
)

func HandleWebhook(c *gin.Context) {
	const MaxBodyBytes = int64(65536)
	body, err := io.ReadAll(http.MaxBytesReader(c.Writer, c.Request.Body, MaxBodyBytes))
	if err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{"error": "Error reading request body"})
		return
	}

	event := stripe.Event{}
	if err := json.Unmarshal(body, &event); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Error parsing webhook JSON"})
		return
	}

	// Handle the event based on its type
	switch event.Type {
	case "payment_intent.succeeded":
		fmt.Println("PaymentIntent was successful!")
		// Handle successful payment here
	case "payment_intent.payment_failed":
		fmt.Println("PaymentIntent failed!")
		// Handle failed payment here
	default:
		fmt.Printf("Unhandled event type: %s\n", event.Type)
	}

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}
