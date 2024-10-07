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
		protected.GET("/check/:kermesseId/:userId", controllers.CheckIfUserHasTicket)
		protected.POST("/:kermesseId/draw", controllers.DrawTombolaWinner)
		protected.PUT("/:kermesseId/add-prize", controllers.AddPrizeToTombola)
		protected.GET("/:kermesseId/status/:userId", controllers.GetTombolaStatus)
	}
}
