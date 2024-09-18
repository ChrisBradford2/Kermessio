package routes

import (
	"github.com/gin-gonic/gin"
	"kermessio/controllers"
	middleware "kermessio/middlewares"
)

func TombolaRoutes(r *gin.Engine) {
	protected := r.Group("/tombola")
	protected.Use(middleware.AuthMiddleware())
	{
		protected.GET("/:kermesseId", controllers.GetTombolaByKermesse)
		protected.POST("/buy", controllers.BuyTombolaTicket)
	}
}
