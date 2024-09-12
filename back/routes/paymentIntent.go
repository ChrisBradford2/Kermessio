package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func PaymentIntentRoutes(r *gin.Engine) {
	protected := r.Group("/")
	protected.Use(middleware.AuthMiddleware())
	protected.POST("/create-payment-intent", controllers.CreatePaymentIntent)

	// Route for handling Stripe webhooks
	r.POST("/webhook", middleware.HandleWebhook)
}
