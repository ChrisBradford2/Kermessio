package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func PurchaseRoutes(r *gin.Engine) {
	protected := r.Group("")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.POST("/stocks/buy", controllers.CreatePurchase)
		protected.POST("/purchases/validate", controllers.ValidatePurchaseById)
		protected.POST("/purchases/verify", controllers.VerifyPurchaseCode)
		protected.GET("/users/:id/purchases", controllers.GetPurchasesByUser)
	}
}
